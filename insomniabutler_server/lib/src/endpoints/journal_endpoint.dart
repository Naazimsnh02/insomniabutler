import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'dart:convert';

class JournalEndpoint extends Endpoint {
  /// Create a new journal entry
  Future<JournalEntry> createEntry(
    Session session,
    int userId,
    String content, {
    String? title,
    String? mood,
    int? sleepSessionId,
    String? tags,
    bool isFavorite = false,
    DateTime? entryDate,
  }) async {
    final now = DateTime.now().toUtc();
    final entry = JournalEntry(
      userId: userId,
      title: title,
      content: content,
      mood: mood,
      sleepSessionId: sleepSessionId,
      tags: tags,
      isFavorite: isFavorite,
      createdAt: now,
      updatedAt: now,
      entryDate: entryDate ?? now,
    );

    await JournalEntry.db.insertRow(session, entry);
    return entry;
  }

  /// Update an existing journal entry
  Future<JournalEntry?> updateEntry(
    Session session,
    int entryId,
    int userId, {
    String? title,
    String? content,
    String? mood,
    String? tags,
    bool? isFavorite,
  }) async {
    final entry = await JournalEntry.db.findById(session, entryId);
    if (entry == null || entry.userId != userId) {
      return null;
    }

    entry.title = title ?? entry.title;
    entry.content = content ?? entry.content;
    entry.mood = mood ?? entry.mood;
    entry.tags = tags ?? entry.tags;
    entry.isFavorite = isFavorite ?? entry.isFavorite;
    entry.updatedAt = DateTime.now().toUtc();

    await JournalEntry.db.updateRow(session, entry);
    return entry;
  }

  /// Delete a journal entry
  Future<bool> deleteEntry(Session session, int entryId, int userId) async {
    final entry = await JournalEntry.db.findById(session, entryId);
    if (entry == null || entry.userId != userId) {
      return false;
    }

    await JournalEntry.db.deleteRow(session, entry);
    return true;
  }

  /// Get a single journal entry
  Future<JournalEntry?> getEntry(Session session, int entryId, int userId) async {
    final entry = await JournalEntry.db.findById(session, entryId);
    if (entry == null || entry.userId != userId) {
      return null;
    }
    return entry;
  }

  /// Get user's journal entries with pagination
  Future<List<JournalEntry>> getUserEntries(
    Session session,
    int userId, {
    int limit = 20,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = JournalEntry.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.entryDate,
      orderDescending: true,
      limit: limit,
      offset: offset,
    );

    // Apply date filters if provided
    if (startDate != null) {
      query = JournalEntry.db.find(
        session,
        where: (t) => t.userId.equals(userId) & t.entryDate.between(startDate, endDate ?? DateTime.now().toUtc()),
        orderBy: (t) => t.entryDate,
        orderDescending: true,
        limit: limit,
        offset: offset,
      );
    }

    return await query;
  }

  /// Search journal entries
  Future<List<JournalEntry>> searchEntries(
    Session session,
    int userId,
    String query, {
    String? mood,
    String? tag,
  }) async {
    // Basic search implementation
    // In production, you'd use full-text search or PostgreSQL's tsvector
    final allEntries = await JournalEntry.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.entryDate,
      orderDescending: true,
    );

    return allEntries.where((entry) {
      final matchesQuery = query.isEmpty ||
          entry.content.toLowerCase().contains(query.toLowerCase()) ||
          (entry.title?.toLowerCase().contains(query.toLowerCase()) ?? false);

      final matchesMood = mood == null || entry.mood == mood;
      final matchesTag = tag == null || (entry.tags?.contains(tag) ?? false);

      return matchesQuery && matchesMood && matchesTag;
    }).toList();
  }

  /// Toggle favorite status
  Future<JournalEntry?> toggleFavorite(Session session, int entryId, int userId) async {
    final entry = await JournalEntry.db.findById(session, entryId);
    if (entry == null || entry.userId != userId) {
      return null;
    }

    entry.isFavorite = !entry.isFavorite;
    entry.updatedAt = DateTime.now().toUtc();

    await JournalEntry.db.updateRow(session, entry);
    return entry;
  }

  /// Get daily prompts
  Future<List<JournalPrompt>> getDailyPrompts(
    Session session,
    String category,
  ) async {
    return await JournalPrompt.db.find(
      session,
      where: (t) => t.category.equals(category) & t.isActive.equals(true),
      limit: 3,
    );
  }

  /// Get all active prompts
  Future<List<JournalPrompt>> getAllPrompts(Session session) async {
    return await JournalPrompt.db.find(
      session,
      where: (t) => t.isActive.equals(true),
      orderBy: (t) => t.category,
    );
  }

  /// Get journal statistics
  Future<JournalStats> getJournalStats(Session session, int userId) async {
    final allEntries = await JournalEntry.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.entryDate,
      orderDescending: true,
    );

    // Calculate current streak
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastDate;

    final sortedEntries = allEntries.toList()
      ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

    for (var entry in sortedEntries) {
      final entryDate = DateTime(entry.entryDate.year, entry.entryDate.month, entry.entryDate.day);
      
      if (lastDate == null) {
        tempStreak = 1;
        lastDate = entryDate;
      } else {
        final diff = lastDate.difference(entryDate).inDays;
        if (diff == 1) {
          tempStreak++;
        } else if (diff > 1) {
          if (currentStreak == 0) currentStreak = tempStreak;
          if (tempStreak > longestStreak) longestStreak = tempStreak;
          tempStreak = 1;
        }
        lastDate = entryDate;
      }
    }

    if (tempStreak > 0 && currentStreak == 0) currentStreak = tempStreak;
    if (tempStreak > longestStreak) longestStreak = tempStreak;

    // This week's entries
    final weekAgo = DateTime.now().toUtc().subtract(const Duration(days: 7));
    final thisWeekEntries = allEntries.where((e) => e.entryDate.isAfter(weekAgo)).length;

    // Mood distribution
    final moodCounts = <String, int>{};
    for (var entry in allEntries) {
      if (entry.mood != null) {
        moodCounts[entry.mood!] = (moodCounts[entry.mood!] ?? 0) + 1;
      }
    }

    return JournalStats(
      totalEntries: allEntries.length,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      thisWeekEntries: thisWeekEntries,
      favoriteCount: allEntries.where((e) => e.isFavorite).length,
      moodDistribution: jsonEncode(moodCounts),
    );
  }

  /// Get AI-powered insights
  Future<List<JournalInsight>> getJournalInsights(Session session, int userId) async {
    final insights = <JournalInsight>[];

    // Get recent entries
    final recentEntries = await JournalEntry.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.entryDate,
      orderDescending: true,
      limit: 30,
    );

    if (recentEntries.isEmpty) {
      return insights;
    }

    // Insight 1: Journaling frequency
    final weekAgo = DateTime.now().toUtc().subtract(const Duration(days: 7));
    final thisWeekCount = recentEntries.where((e) => e.entryDate.isAfter(weekAgo)).length;
    
    if (thisWeekCount >= 5) {
      insights.add(JournalInsight(
        insightType: 'frequency',
        message: '🔥 Amazing! You journaled $thisWeekCount times this week. Consistency is key to better sleep.',
        confidence: 1.0,
      ));
    } else if (thisWeekCount >= 3) {
      insights.add(JournalInsight(
        insightType: 'frequency',
        message: '✨ You journaled $thisWeekCount times this week. Keep building that habit!',
        confidence: 0.8,
      ));
    }

    // Insight 2: Mood patterns
    final moodCounts = <String, int>{};
    for (var entry in recentEntries) {
      if (entry.mood != null) {
        moodCounts[entry.mood!] = (moodCounts[entry.mood!] ?? 0) + 1;
      }
    }

    if (moodCounts.isNotEmpty) {
      final dominantMood = moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      final moodEmojis = {
        'Great': '😊',
        'Good': '🙂',
        'Okay': '😐',
        'Low': '😔',
        'Sad': '😢',
        'Anxious': '😰',
        'Calm': '😌',
        'Tired': '🥱',
      };
      
      insights.add(JournalInsight(
        insightType: 'mood',
        message: '${moodEmojis[dominantMood.key] ?? '💭'} Your most common mood lately is "${dominantMood.key}". Journaling helps process these feelings.',
        confidence: 0.7,
      ));
    }

    // Insight 3: Sleep correlation (if entries are linked to sleep sessions)
    final entriesWithSleep = recentEntries.where((e) => e.sleepSessionId != null).toList();
    if (entriesWithSleep.length >= 5) {
      insights.add(JournalInsight(
        insightType: 'sleep_correlation',
        message: '💤 You\'ve linked ${entriesWithSleep.length} journal entries to sleep sessions. This helps track what affects your rest.',
        confidence: 0.9,
      ));
    }

    // Insight 4: Streak motivation
    final stats = await getJournalStats(session, userId);
    if (stats.currentStreak >= 7) {
      insights.add(JournalInsight(
        insightType: 'streak',
        message: '🏆 ${stats.currentStreak}-day streak! You\'re building a powerful habit for better sleep.',
        confidence: 1.0,
      ));
    }

    return insights;
  }

  /// Seed initial prompts (call once during setup)
  Future<void> seedPrompts(Session session) async {
    final existingPrompts = await JournalPrompt.db.find(session);
    if (existingPrompts.isNotEmpty) {
      return; // Already seeded
    }

    final prompts = [
      // Evening prompts
      JournalPrompt(
        category: 'evening',
        promptText: 'What went well today?',
        isActive: true,
        isSystemPrompt: true,
        createdAt: DateTime.now().toUtc(),
      ),
      JournalPrompt(
        category: 'evening',
        promptText: 'What are you grateful for today?',
        isActive: true,
        isSystemPrompt: true,
        createdAt: DateTime.now().toUtc(),
      ),
      JournalPrompt(
        category: 'evening',
        promptText: 'What\'s on your mind right now?',
        isActive: true,
        isSystemPrompt: true,
        createdAt: DateTime.now().toUtc(),
      ),
      JournalPrompt(
        category: 'evening',
        promptText: 'What can wait until tomorrow?',
        isActive: true,
        isSystemPrompt: true,
        createdAt: DateTime.now().toUtc(),
      ),
      
      // Morning prompts
      JournalPrompt(
        category: 'morning',
        promptText: 'How do you feel this morning?',
        isActive: true,
        isSystemPrompt: true,
        createdAt: DateTime.now().toUtc(),
      ),
      JournalPrompt(
        category: 'morning',
        promptText: 'Did your worries from last night come true?',
        isActive: true,
        isSystemPrompt: true,
        createdAt: DateTime.now().toUtc(),
      ),
      JournalPrompt(
        category: 'morning',
        promptText: 'What are you looking forward to today?',
        isActive: true,
        isSystemPrompt: true,
        createdAt: DateTime.now().toUtc(),
      ),
      
      // Weekly prompts
      JournalPrompt(
        category: 'weekly',
        promptText: 'What patterns do you notice in your sleep this week?',
        isActive: true,
        isSystemPrompt: true,
        createdAt: DateTime.now().toUtc(),
      ),
      JournalPrompt(
        category: 'weekly',
        promptText: 'What helped you sleep best this week?',
        isActive: true,
        isSystemPrompt: true,
        createdAt: DateTime.now().toUtc(),
      ),
      JournalPrompt(
        category: 'weekly',
        promptText: 'What would you like to improve about your sleep?',
        isActive: true,
        isSystemPrompt: true,
        createdAt: DateTime.now().toUtc(),
      ),
    ];

    for (var prompt in prompts) {
      await JournalPrompt.db.insertRow(session, prompt);
    }
  }
}
