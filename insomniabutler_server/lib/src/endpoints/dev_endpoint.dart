import 'dart:math';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart' as protocol;
import '../services/embedding_service.dart';

class DevEndpoint extends Endpoint {
  Future<bool> generateRealisticData(Session session, int userId) async {
    final random = Random();
    final now = DateTime.now().toUtc();

    await session.db.transaction((transaction) async {
      // Generate data for the last 30 days
      for (int i = 30; i >= 1; i--) {
        final date = now.subtract(Duration(days: i));

        // 1. Generate Sleep Session
        // Bedtime between 10 PM and 11:30 PM
        final bedtime = DateTime.utc(
          date.year,
          date.month,
          date.day,
          22,
          random.nextInt(90),
        );

        // Wake time between 6 AM and 8 AM
        final wakeTime = bedtime.add(
          Duration(
            hours: 7 + random.nextInt(2),
            minutes: random.nextInt(60),
          ),
        );

        final sleepDurationMinutes = wakeTime.difference(bedtime).inMinutes;

        // Realistic sleep stages (percentages)
        final deepMinutes =
            (sleepDurationMinutes * (0.15 + random.nextDouble() * 0.1)).round();
        final remMinutes =
            (sleepDurationMinutes * (0.2 + random.nextDouble() * 0.05)).round();
        final awakeMinutes =
            (sleepDurationMinutes * (0.05 + random.nextDouble() * 0.05)).round();
        final lightMinutes =
            sleepDurationMinutes - deepMinutes - remMinutes - awakeMinutes;

        final usedButler = random.nextDouble() < 0.6; // 60% chance to use Butler

        final sleepLatency = usedButler
            ? 5 + random.nextInt(10) // 5 to 15 mins with Butler
            : 25 + random.nextInt(25); // 25 to 50 mins without Butler

        final sleepQuality = usedButler
            ? 4 + random.nextInt(2) // 4 or 5 quality with Butler
            : 2 + random.nextInt(3); // 2, 3, or 4 without Butler

        final moods = ['Happy', 'Calm', 'Tired', 'Blah', 'Sad'];
        final morningMood = moods[random.nextInt(moods.length)];

        final sessionRecord = protocol.SleepSession(
          userId: userId,
          bedTime: bedtime,
          wakeTime: wakeTime,
          sleepQuality: sleepQuality,
          morningMood: morningMood,
          sleepLatencyMinutes: sleepLatency,
          usedButler: usedButler,
          thoughtsProcessed: usedButler ? 1 + random.nextInt(4) : 0,
          sessionDate: bedtime,
          deepSleepDuration: deepMinutes,
          lightSleepDuration: lightMinutes,
          remSleepDuration: remMinutes,
          awakeDuration: awakeMinutes,
          restingHeartRate: 50 + random.nextInt(20),
          hrv: 30 + random.nextInt(70),
          respiratoryRate: 12 + random.nextInt(6),
          interruptions: sleepQuality >= 4 ? random.nextInt(2) : random.nextInt(4),
        );

        final savedSession = await protocol.SleepSession.db.insertRow(
          session,
          sessionRecord,
          transaction: transaction,
        );

        // 2. Generate Chat History for Butler sessions
        if (usedButler) {
          final messages = [
            {
              "user": "I can't stop thinking about my presentation.",
              "ai":
                  "It's natural to feel that way. Let's break down that worry. What's the specific part bothering you?",
            },
            {
              "user": "Too much to do tomorrow.",
              "ai":
                  "Let's capture those tasks in a list so your brain can let go for tonight. What's first?",
            },
            {
              "user": "Just feeling restless.",
              "ai":
                  "I understand. Let's try some progressive muscle relaxation together.",
            },
          ];

          final set = messages[random.nextInt(messages.length)];

          await protocol.ChatMessage.db.insertRow(
            session,
            protocol.ChatMessage(
              userId: userId,
              sessionId: savedSession.id.toString(),
              role: 'user',
              content: set['user']!,
              timestamp: bedtime.subtract(const Duration(minutes: 5)),
            ),
            transaction: transaction,
          );

          await protocol.ChatMessage.db.insertRow(
            session,
            protocol.ChatMessage(
              userId: userId,
              sessionId: savedSession.id.toString(),
              role: 'ai',
              content: set['ai']!,
              timestamp: bedtime.subtract(const Duration(minutes: 4)),
            ),
            transaction: transaction,
          );
        }

        // 3. Generate Journal Entry for ~70% of days
        if (random.nextDouble() < 0.7) {
          final journalMoods = ['Happy', 'Calm', 'Tired', 'Blah', 'Sad'];
          final mood = journalMoods[random.nextInt(journalMoods.length)];

          final contents = [
            "Had a productive day today. Feeling ready for sleep.",
            "A bit stressed about work, but trying to unwind.",
            "Spent some time outdoors today, which usually helps me sleep better.",
            "Drank coffee a bit late in the afternoon, hope it doesn't affect my sleep.",
            "Feeling very peaceful tonight after the meditation session.",
            "Tomorrow is going to be busy, but I've planned everything out.",
            "Read a book for 30 minutes before bed. Very relaxing.",
            "Workout was intense today. Body feels tired but in a good way.",
          ];

          final journalEntry = protocol.JournalEntry(
            userId: userId,
            title: "Evening Reflection",
            content: contents[random.nextInt(contents.length)],
            mood: mood,
            sleepSessionId: savedSession.id,
            createdAt: bedtime.subtract(const Duration(minutes: 15)),
            updatedAt: bedtime.subtract(const Duration(minutes: 15)),
            entryDate: bedtime,
          );

          await protocol.JournalEntry.db.insertRow(
            session,
            journalEntry,
            transaction: transaction,
          );
        }

        // 4. Generate Thought Logs for each session
        if (sessionRecord.thoughtsProcessed > 0) {
          final thoughtCategories = [
            'Work',
            'Health',
            'Future',
            'Relationships',
            'To-do',
          ];
          final thoughtContents = [
            "Thinking about the upcoming project deadline.",
            "Wondering if I should start a new workout routine.",
            "Reminiscing about the trip last summer.",
            "Planning what to cook for dinner tomorrow.",
            "Worried about a conversation I had earlier today.",
          ];

          for (int t = 0; t < sessionRecord.thoughtsProcessed; t++) {
            final thoughtLog = protocol.ThoughtLog(
              userId: userId,
              sessionId: savedSession.id,
              category:
                  thoughtCategories[random.nextInt(thoughtCategories.length)],
              content: thoughtContents[random.nextInt(thoughtContents.length)],
              timestamp: bedtime.subtract(Duration(minutes: 5 + t * 2)),
              resolved: random.nextBool(),
              readinessIncrease: 2 + random.nextInt(5),
            );
            await protocol.ThoughtLog.db.insertRow(
              session,
              thoughtLog,
              transaction: transaction,
            );
          }
        }
      }
    });

    return true;
  }

  Future<bool> clearUserData(Session session, int userId) async {
    // Delete all user data in order to avoid foreign key issues
    await session.db.transaction((transaction) async {
      await protocol.ChatMessage.db.deleteWhere(
        session,
        where: (t) => t.userId.equals(userId),
        transaction: transaction,
      );
      await protocol.ThoughtLog.db.deleteWhere(
        session,
        where: (t) => t.userId.equals(userId),
        transaction: transaction,
      );
      await protocol.JournalEntry.db.deleteWhere(
        session,
        where: (t) => t.userId.equals(userId),
        transaction: transaction,
      );
      await protocol.SleepInsight.db.deleteWhere(
        session,
        where: (t) => t.userId.equals(userId),
        transaction: transaction,
      );
      await protocol.SleepSession.db.deleteWhere(
        session,
        where: (t) => t.userId.equals(userId),
        transaction: transaction,
      );
    });
    return true;
  }

  /// Generates embeddings for all historical data that doesn't have them
  Future<Map<String, int>> backfillEmbeddings(Session session) async {
    // Get API key
    var apiKey = session.passwords['geminiApiKey'];
    if (apiKey == null || apiKey.isEmpty) {
      apiKey = Platform.environment['GEMINI_API_KEY'];
    }

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not found');
    }

    final embeddingService = EmbeddingService(apiKey);
    int journalCount = 0;
    int chatCount = 0;

    // 1. Backfill Journal Entries
    final allJournalEntries = await protocol.JournalEntry.db.find(session);
    final journalEntries = allJournalEntries.where((e) => e.embedding == null).toList();

    session.log('Backfilling ${journalEntries.length} journal entries...');
    for (var entry in journalEntries) {
      try {
        final text = '${entry.title ?? ''} ${entry.content}';
        final embedding = await embeddingService.generateEmbedding(text);
        entry.embedding = Vector(embedding);
        await protocol.JournalEntry.db.updateRow(session, entry);
        journalCount++;
      } catch (e) {
        session.log('Failed to backfill journal entry ${entry.id}: $e');
      }
    }

    // 2. Backfill Chat Messages
    final allChatMessages = await protocol.ChatMessage.db.find(session);
    final chatMessages = allChatMessages.where((m) => m.embedding == null).toList();

    session.log('Backfilling ${chatMessages.length} chat messages...');
    for (var message in chatMessages) {
      try {
        final embedding = await embeddingService.generateEmbedding(message.content);
        message.embedding = Vector(embedding);
        await protocol.ChatMessage.db.updateRow(session, message);
        chatCount++;
      } catch (e) {
        session.log('Failed to backfill chat message ${message.sessionId}: $e');
      }
    }

    return {
      'journal_entries_processed': journalCount,
      'chat_messages_processed': chatCount,
    };
  }
}
