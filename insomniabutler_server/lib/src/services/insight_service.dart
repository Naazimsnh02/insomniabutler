import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'gemini_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class InsightService {
  /// Generate and cache sleep insights for a specific user
  static Future<void> generateSleepInsights(Session session, int userId) async {
    final user = await User.db.findById(session, userId);
    if (user == null || !user.sleepInsightsEnabled) return;

    session.log('Generating sleep insights for user $userId');

    // Fetch last 7 days of sleep sessions (Manual or Synced)
    final now = DateTime.now().toUtc();
    final weekAgo = now.subtract(const Duration(days: 7));
    final sessions = await SleepSession.db.find(
      session,
      where: (t) =>
          t.userId.equals(userId) & t.sessionDate.between(weekAgo, now),
      orderBy: (t) => t.sessionDate,
      orderDescending: true,
    );

    if (sessions.isEmpty) {
      session.log(
        'No sleep sessions found for user $userId to generate insights.',
      );
      return;
    }

    try {
      final apiKey =
          session.passwords['geminiApiKey'] ??
          Platform.environment['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) return;
      final gemini = GeminiService(apiKey);

      final sessionData = sessions
          .map(
            (s) => {
              'date': s.sessionDate.toString().split(' ')[0],
              'duration':
                  '${s.wakeTime?.difference(s.bedTime).inMinutes ?? 0} mins',
              'latency': s.sleepLatencyMinutes ?? 'N/A',
              'quality': s.sleepQuality ?? 'N/A',
              'source': s.sleepDataSource ?? 'Manual',
              'mood': s.morningMood ?? 'N/A',
            },
          )
          .toList();

      final prompt =
          '''
Analyze these recent sleep sessions for a user.
Include BOTH manual entries and synced data.
Provide 1-2 personalized, actionable insights or "Butler's Tips" for better sleep tonight.
Focus on patterns like consistency, latency, or mood-sleep connections.
Return ONLY a raw JSON array of objects.
Structure: [{"insightType": "string", "metric": "string", "value": number, "description": "string"}]
Example Types: "consistency", "latency", "quality", "duration".
Keep messages concise (under 30 words).

Sessions:
${jsonEncode(sessionData)}
''';

      final response = await gemini.model.generateContent([
        Content.text('You are a professional sleep analyst.\n\nUser: $prompt'),
      ]);

      final aiText = response.text ?? '';
      var jsonStr = aiText.trim();
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.replaceAll('```json', '').replaceAll('```', '');
      } else if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.replaceAll('```', '');
      }

      final List<dynamic> aiData = jsonDecode(jsonStr);
      for (var item in aiData) {
        await SleepInsight.db.insertRow(
          session,
          SleepInsight(
            userId: userId,
            insightType: item['insightType'] ?? 'general',
            metric: item['metric'] ?? 'Sleep Analysis',
            value: (item['value'] as num?)?.toDouble() ?? 0.0,
            description: item['description'] ?? '',
            generatedAt: now,
          ),
        );
      }
      session.log(
        'Successfully generated ${aiData.length} sleep insights for user $userId',
      );
    } catch (e) {
      session.log('Error generating sleep insights: $e', level: LogLevel.error);
    }
  }

  /// Generate and cache journal insights for a specific user
  static Future<void> generateJournalInsights(
    Session session,
    int userId,
  ) async {
    final user = await User.db.findById(session, userId);
    if (user == null || !user.journalInsightsEnabled) return;

    session.log('Generating journal insights for user $userId');

    // Fetch all entries for stats
    final allEntries = await JournalEntry.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.entryDate,
      orderDescending: true,
    );

    if (allEntries.isEmpty) return;

    final now = DateTime.now().toUtc();
    final weekAgo = now.subtract(const Duration(days: 7));

    // 1. Rule-based Insights (Fast & Reliable)

    // Streak Calculation
    int currentStreak = 0;
    DateTime? lastDate;
    for (var entry in allEntries) {
      final entryDate = DateTime(
        entry.entryDate.year,
        entry.entryDate.month,
        entry.entryDate.day,
      );
      if (lastDate == null) {
        final today = DateTime(now.year, now.month, now.day);
        if (today.difference(entryDate).inDays <= 1) {
          currentStreak = 1;
          lastDate = entryDate;
        } else {
          break;
        }
      } else {
        final diff = lastDate.difference(entryDate).inDays;
        if (diff == 1) {
          currentStreak++;
          lastDate = entryDate;
        } else if (diff == 0) {
          continue;
        } else {
          break;
        }
      }
    }

    if (currentStreak >= 3) {
      await JournalInsight.db.insertRow(
        session,
        JournalInsight(
          userId: userId,
          insightType: 'streak',
          message:
              '🏆 $currentStreak-day streak! Consistency is your superpower for better sleep.',
          confidence: 1.0,
          generatedAt: now,
        ),
      );
    }

    final thisWeekCount = allEntries
        .where((e) => e.entryDate.isAfter(weekAgo))
        .length;
    if (thisWeekCount >= 3) {
      await JournalInsight.db.insertRow(
        session,
        JournalInsight(
          userId: userId,
          insightType: 'habit',
          message:
              '🔥 logged $thisWeekCount entries this week. Clear mind, better sleep.',
          confidence: 1.0,
          generatedAt: now,
        ),
      );
    }

    // 2. AI Analysis (Deep)
    try {
      final apiKey =
          session.passwords['geminiApiKey'] ??
          Platform.environment['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) return;
      final gemini = GeminiService(apiKey);

      final entriesText = allEntries
          .take(10)
          .map(
            (e) =>
                'Date: ${e.entryDate.toString().split(' ')[0]}, Mood: ${e.mood ?? "N/A"}, Title: ${e.title ?? "N/A"}, Content: ${e.content}',
          )
          .join('\n---\n');

      final prompt =
          '''
Analyze these recent journal entries.
Provide 2 personalized insights or observations about their mental state or patterns.
Return ONLY a raw JSON array of objects.
Structure: [{"insightType": "string", "message": "string", "confidence": number}]
Keep messages concise.

Entries:
$entriesText
''';

      final response = await gemini.model.generateContent([
        Content.text('You are an empathetic psychologist.\n\nUser: $prompt'),
      ]);

      final aiText = response.text ?? '';
      var jsonStr = aiText.trim();
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.replaceAll('```json', '').replaceAll('```', '');
      } else if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.replaceAll('```', '');
      }

      final List<dynamic> aiData = jsonDecode(jsonStr);
      int aiCount = 0;
      for (var item in aiData) {
        await JournalInsight.db.insertRow(
          session,
          JournalInsight(
            userId: userId,
            insightType: item['insightType'] ?? 'pattern',
            message: item['message'] ?? '',
            confidence: (item['confidence'] as num?)?.toDouble() ?? 0.8,
            generatedAt: now,
          ),
        );
        aiCount++;
      }
      session.log(
        'Successfully generated $aiCount AI journal insights for user $userId',
      );
    } catch (e) {
      session.log(
        'Error generating AI journal insights: $e',
        level: LogLevel.error,
      );
    }
  }

  /// Calculate the delay until the next target time (HH:mm)
  static Duration calculateDelay(String? timeStr) {
    if (timeStr == null || !timeStr.contains(':'))
      return const Duration(hours: 24);

    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = DateTime.now();
      final target = DateTime(now.year, now.month, now.day, hour, minute);

      var diff = target.difference(now);
      if (diff.isNegative) {
        // If the time has already passed today, schedule for tomorrow
        diff += const Duration(days: 1);
      }
      return diff;
    } catch (e) {
      return const Duration(hours: 24);
    }
  }
}
