import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Sleep session management endpoint
class SleepSessionEndpoint extends Endpoint {
  /// Start a new sleep session
  Future<SleepSession> startSession(Session session, int userId) async {
    final sleepSession = SleepSession(
      userId: userId,
      bedTime: DateTime.now().toUtc(),
      usedButler: false,
      thoughtsProcessed: 0,
      sessionDate: DateTime.now().toUtc(),
    );

    return await SleepSession.db.insertRow(session, sleepSession);
  }

  /// End a sleep session with quality feedback
  Future<SleepSession?> endSession(
    Session session,
    int sessionId,
    int sleepQuality,
    String morningMood,
    int? sleepLatencyMinutes, {
    int? interruptions,
  }) async {
    final sleepSession = await SleepSession.db.findById(session, sessionId);

    if (sleepSession == null) {
      throw Exception('Session not found');
    }

    final wakeTime = DateTime.now().toUtc();

    final updated = sleepSession.copyWith(
      wakeTime: wakeTime,
      sleepQuality: sleepQuality,
      morningMood: morningMood,
      sleepLatencyMinutes: sleepLatencyMinutes,
      interruptions: interruptions,
    );

    return await SleepSession.db.updateRow(session, updated);
  }

  /// Mark that Butler was used during this session
  Future<void> markButlerUsed(
    Session session,
    int sessionId,
    int thoughtCount,
  ) async {
    final sleepSession = await SleepSession.db.findById(session, sessionId);

    if (sleepSession != null) {
      await SleepSession.db.updateRow(
        session,
        sleepSession.copyWith(
          usedButler: true,
          thoughtsProcessed: thoughtCount,
        ),
      );
    }
  }

  /// Get user's sleep sessions with optional limit
  Future<List<SleepSession>> getUserSessions(
    Session session,
    int userId,
    int limit,
  ) async {
    return await SleepSession.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.sessionDate,
      orderDescending: true,
      limit: limit,
    );
  }

  /// Get the most recent active session for a user
  Future<SleepSession?> getActiveSession(Session session, int userId) async {
    final sessions = await SleepSession.db.find(
      session,
      where: (t) => t.userId.equals(userId) & t.wakeTime.equals(null),
      orderBy: (t) => t.bedTime,
      orderDescending: true,
      limit: 1,
    );

    return sessions.isNotEmpty ? sessions.first : null;
  }

  /// Get last night's session
  Future<SleepSession?> getLastNightSession(Session session, int userId) async {
    final sessions = await SleepSession.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.sessionDate,
      orderDescending: true,
      limit: 1,
    );

    return sessions.isNotEmpty ? sessions.first : null;
  }

  /// Get session for a specific date
  Future<SleepSession?> getSessionForDate(
    Session session,
    int userId,
    DateTime date,
  ) async {
    // We search for a session where sessionDate is on the given date (ignoring time)
    // Adjust to local time of the request if needed, but here we assume the date passed is the "target" day
    final startOfDay = DateTime.utc(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final sessions = await SleepSession.db.find(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          (t.sessionDate >= startOfDay) &
          (t.sessionDate < endOfDay),
      orderBy: (t) => t.sessionDate,
      orderDescending: true,
      limit: 1,
    );

    return sessions.isNotEmpty ? sessions.first : null;
  }

  /// Update sleep latency for a session
  Future<SleepSession?> updateSleepLatency(
    Session session,
    int sessionId,
    int latencyMinutes,
  ) async {
    final sleepSession = await SleepSession.db.findById(session, sessionId);

    if (sleepSession == null) return null;

    final updated = sleepSession.copyWith(
      sleepLatencyMinutes: latencyMinutes,
    );

    return await SleepSession.db.updateRow(session, updated);
  }

  /// Log a manual sleep session (retroactive)
  Future<SleepSession> logManualSession(
    Session session,
    int userId,
    DateTime bedTime,
    DateTime wakeTime,
    int sleepQuality, {
    int? sleepLatencyMinutes,
    int? deepSleepDuration,
    int? lightSleepDuration,
    int? remSleepDuration,
    int? awakeDuration,
    int? restingHeartRate,
    int? hrv,
    int? respiratoryRate,
    int? interruptions,
  }) async {
    final sleepSession = SleepSession(
      userId: userId,
      bedTime: bedTime,
      wakeTime: wakeTime,
      sleepQuality: sleepQuality,
      usedButler: false,
      thoughtsProcessed: 0,
      sessionDate: bedTime,
      sleepLatencyMinutes: sleepLatencyMinutes,
      deepSleepDuration: deepSleepDuration,
      lightSleepDuration: lightSleepDuration,
      remSleepDuration: remSleepDuration,
      awakeDuration: awakeDuration,
      restingHeartRate: restingHeartRate,
      hrv: hrv,
      respiratoryRate: respiratoryRate,
      interruptions: interruptions,
    );

    return await SleepSession.db.insertRow(session, sleepSession);
  }

  /// Update an existing sleep session
  Future<SleepSession?> updateSession(
    Session session,
    int sessionId,
    DateTime bedTime,
    DateTime wakeTime,
    int sleepQuality,
    int? sleepLatencyMinutes, {
    int? deepSleepDuration,
    int? lightSleepDuration,
    int? remSleepDuration,
    int? awakeDuration,
    int? restingHeartRate,
    int? hrv,
    int? respiratoryRate,
    int? interruptions,
  }) async {
    final sleepSession = await SleepSession.db.findById(session, sessionId);
    if (sleepSession == null) return null;

    final updated = sleepSession.copyWith(
      bedTime: bedTime,
      wakeTime: wakeTime,
      sleepQuality: sleepQuality,
      sleepLatencyMinutes: sleepLatencyMinutes,
      deepSleepDuration: deepSleepDuration,
      lightSleepDuration: lightSleepDuration,
      remSleepDuration: remSleepDuration,
      awakeDuration: awakeDuration,
      restingHeartRate: restingHeartRate,
      hrv: hrv,
      respiratoryRate: respiratoryRate,
      interruptions: interruptions,
    );

    return await SleepSession.db.updateRow(session, updated);
  }

  /// Delete a sleep session
  Future<bool> deleteSession(Session session, int sessionId) async {
    final sleepSession = await SleepSession.db.findById(session, sessionId);
    if (sleepSession == null) return false;

    await SleepSession.db.deleteRow(session, sleepSession);
    return true;
  }

  /// Update mood for the user's latest session
  Future<SleepSession?> updateMoodForLatestSession(
    Session session,
    int userId,
    String mood,
  ) async {
    final latest = await SleepSession.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.sessionDate,
      orderDescending: true,
    );

    if (latest == null) return null;

    final updated = latest.copyWith(morningMood: mood);
    return await SleepSession.db.updateRow(session, updated);
  }
}
