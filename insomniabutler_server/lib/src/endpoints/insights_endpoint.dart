import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/insight_service.dart';

/// Analytics and insights endpoint for sleep intelligence
class InsightsEndpoint extends Endpoint {
  /// Get current personalized sleep insights (cached or newly generated)
  Future<List<SleepInsight>> getPersonalizedSleepInsights(
    Session session,
    int userId,
  ) async {
    final now = DateTime.now().toUtc();
    final oneDayAgo = now.subtract(const Duration(hours: 24));

    // 1. Check for cached insights from the last 24 hours
    final cached = await SleepInsight.db.find(
      session,
      where: (t) => t.userId.equals(userId) & (t.generatedAt > oneDayAgo),
      orderBy: (t) => t.generatedAt,
      orderDescending: true,
    );

    if (cached.isNotEmpty) {
      session.log('Returning ${cached.length} cached sleep insights for user $userId');
      return cached;
    }

    session.log('No cached sleep insights for user $userId, generating new ones...');

    // 2. If no cache, trigger generation now (for new users or first time)
    await InsightService.generateSleepInsights(session, userId);

    // 3. Return the newly generated insights
    return await SleepInsight.db.find(
      session,
      where: (t) => t.userId.equals(userId) & (t.generatedAt > oneDayAgo),
      orderBy: (t) => t.generatedAt,
      orderDescending: true,
    );
  }

  /// Get comprehensive user insights
  Future<UserInsights> getUserInsights(Session session, int userId) async {
    // Get sessions with and without Butler
    final withButler = await SleepSession.db.find(
      session,
      where: (t) => t.userId.equals(userId) & t.usedButler.equals(true),
    );

    final withoutButler = await SleepSession.db.find(
      session,
      where: (t) => t.userId.equals(userId) & t.usedButler.equals(false),
    );

    // Calculate average latencies
    final avgWithButler = _calculateAvgLatency(withButler);
    final avgWithoutButler = _calculateAvgLatency(withoutButler);

    final improvement = avgWithoutButler > 0
        ? ((avgWithoutButler - avgWithButler) / avgWithoutButler * 100).round()
        : 0;

    // Get thought patterns
    final thoughts = await ThoughtLog.db.find(
      session,
      where: (t) => t.userId.equals(userId),
    );

    final categoryCount = <String, int>{};
    for (var thought in thoughts) {
      categoryCount[thought.category] =
          (categoryCount[thought.category] ?? 0) + 1;
    }

    final topCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return UserInsights(
      latencyImprovement: improvement,
      avgLatencyWithButler: avgWithButler,
      avgLatencyWithoutButler: avgWithoutButler,
      topThoughtCategories: topCategories.take(3).map((e) => e.key).toList(),
      totalThoughtsProcessed: thoughts.length,
      totalSessions: withButler.length + withoutButler.length,
    );
  }

  /// Get weekly insights for a specific week
  Future<UserInsights> getWeeklyInsights(
    Session session,
    int userId,
    DateTime weekStart,
  ) async {
    final weekEnd = weekStart.add(Duration(days: 7));

    // Get sessions for the week
    final withButler = await SleepSession.db.find(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          t.usedButler.equals(true) &
          t.sessionDate.between(weekStart, weekEnd),
    );

    final withoutButler = await SleepSession.db.find(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          t.usedButler.equals(false) &
          t.sessionDate.between(weekStart, weekEnd),
    );

    // Calculate metrics
    final avgWithButler = _calculateAvgLatency(withButler);
    final avgWithoutButler = _calculateAvgLatency(withoutButler);

    final improvement = avgWithoutButler > 0
        ? ((avgWithoutButler - avgWithButler) / avgWithoutButler * 100).round()
        : 0;

    // Get thought patterns for the week
    final thoughts = await ThoughtLog.db.find(
      session,
      where: (t) =>
          t.userId.equals(userId) & t.timestamp.between(weekStart, weekEnd),
    );

    final categoryCount = <String, int>{};
    for (var thought in thoughts) {
      categoryCount[thought.category] =
          (categoryCount[thought.category] ?? 0) + 1;
    }

    final topCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return UserInsights(
      latencyImprovement: improvement,
      avgLatencyWithButler: avgWithButler,
      avgLatencyWithoutButler: avgWithoutButler,
      topThoughtCategories: topCategories.take(3).map((e) => e.key).toList(),
      totalThoughtsProcessed: thoughts.length,
      totalSessions: withButler.length + withoutButler.length,
    );
  }

  /// Get thought category breakdown
  Future<Map<String, int>> getThoughtCategoryBreakdown(
    Session session,
    int userId,
  ) async {
    final thoughts = await ThoughtLog.db.find(
      session,
      where: (t) => t.userId.equals(userId),
    );

    final categoryCount = <String, int>{};
    for (var thought in thoughts) {
      categoryCount[thought.category] =
          (categoryCount[thought.category] ?? 0) + 1;
    }

    return categoryCount;
  }

  /// Get sleep quality trend (last N days)
  Future<List<SleepSession>> getSleepTrend(
    Session session,
    int userId,
    int days,
  ) async {
    final startDate = DateTime.now().toUtc().subtract(Duration(days: days));

    return await SleepSession.db.find(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          t.sessionDate.between(startDate, DateTime.now().toUtc()),
      orderBy: (t) => t.sessionDate,
    );
  }

  /// Calculate average sleep latency from sessions
  double _calculateAvgLatency(List<SleepSession> sessions) {
    if (sessions.isEmpty) return 0;

    final validSessions = sessions.where((s) => s.sleepLatencyMinutes != null);
    if (validSessions.isEmpty) return 0;

    final total = validSessions.fold<int>(
      0,
      (sum, s) => sum + (s.sleepLatencyMinutes ?? 0),
    );

    return total / validSessions.length;
  }

  /// Get Butler effectiveness score (0-100)
  Future<int> getButlerEffectivenessScore(Session session, int userId) async {
    final insights = await getUserInsights(session, userId);

    // Score based on multiple factors
    int score = 50; // Base score

    // Improvement factor (up to +40 points)
    if (insights.latencyImprovement > 0) {
      score += (insights.latencyImprovement * 0.4).round().clamp(0, 40);
    }

    // Usage factor (up to +10 points)
    if (insights.totalSessions > 0) {
      final usageRate =
          insights.totalThoughtsProcessed / insights.totalSessions;
      score += (usageRate * 2).round().clamp(0, 10);
    }

    return score.clamp(0, 100);
  }
}
