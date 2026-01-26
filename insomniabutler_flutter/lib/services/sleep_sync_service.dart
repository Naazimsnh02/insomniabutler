import 'package:insomniabutler_client/insomniabutler_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'health_data_service.dart';
import 'user_service.dart';

/// Result of a sync operation
class SyncResult {
  final int sessionsImported;
  final int sessionsFailed;
  final List<String> errors;
  final bool success;

  SyncResult({
    required this.sessionsImported,
    required this.sessionsFailed,
    required this.errors,
    required this.success,
  });
}

/// Status of ongoing sync
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

/// Service for syncing sleep data from health platforms to backend
class SleepSyncService {
  final HealthDataService _healthService;
  final Client _client;
  
  static const String _lastSyncKey = 'last_health_sync_time';
  static const String _autoSyncKey = 'auto_sync_enabled';

  SleepSyncService(this._healthService, this._client);

  /// Sync sleep data for a date range
  Future<SyncResult> syncSleepData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final errors = <String>[];
    int imported = 0;
    int failed = 0;

    try {
      // Default to last 7 days if no range specified
      final end = endDate ?? DateTime.now();
      final start = startDate ?? end.subtract(const Duration(days: 7));

      // Check permissions
      final hasPermissions = await _healthService.hasPermissions();
      if (!hasPermissions) {
        final granted = await _healthService.requestPermissions();
        if (!granted) {
          return SyncResult(
            sessionsImported: 0,
            sessionsFailed: 0,
            errors: ['Health permissions not granted'],
            success: false,
          );
        }
      }

      // Get user ID from session
      final userId = await UserService.getCurrentUserId() ?? 0;

      if (userId == 0) {
        return SyncResult(
          sessionsImported: 0,
          sessionsFailed: 0,
          errors: ['User not logged in'],
          success: false,
        );
      }

      // Fetch sleep sessions from health platform
      final sessions = await _healthService.getSleepSessions(
        start,
        end,
        userId,
      );

      print('Found ${sessions.length} sleep sessions to sync');

      // Import each session
      for (var session in sessions) {
        try {
          // Check if session already exists
          final exists = await _sessionExists(session);
          if (exists) {
            print('Session already exists for ${session.bedTime}, skipping');
            continue;
          }

          // Save to backend
          await _client.sleepSession.createSleepSession(session);
          imported++;
          print('Imported session for ${session.bedTime}');
        } catch (e) {
          failed++;
          errors.add('Failed to import session: $e');
          print('Error importing session: $e');
        }
      }

      // Save last sync time
      await _saveLastSyncTime(DateTime.now());

      return SyncResult(
        sessionsImported: imported,
        sessionsFailed: failed,
        errors: errors,
        success: true,
      );
    } catch (e) {
      errors.add('Sync failed: $e');
      return SyncResult(
        sessionsImported: imported,
        sessionsFailed: failed,
        errors: errors,
        success: false,
      );
    }
  }

  /// Sync last N days
  Future<SyncResult> syncLastNDays(int days) async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    return syncSleepData(startDate: start, endDate: end);
  }

  /// Auto sync on app launch (last 3 days)
  Future<SyncResult?> autoSync() async {
    try {
      final autoSyncEnabled = await isAutoSyncEnabled();
      if (!autoSyncEnabled) {
        print('Auto sync is disabled');
        return null;
      }

      final hasPermissions = await _healthService.hasPermissions();
      if (!hasPermissions) {
        print('No health permissions for auto sync');
        return null;
      }

      print('Running auto sync...');
      return await syncLastNDays(3);
    } catch (e) {
      print('Auto sync error: $e');
      return null;
    }
  }

  /// Check if a session already exists
  Future<bool> _sessionExists(SleepSession session) async {
    try {
      // Get all sessions for the user on this date
      // Get all sessions for the user on this date
      final existingSessions = await _client.sleepSession.getUserSessions(
        session.userId,
        100, // Reasonable limit
      );

      // Check if any session has the same bedTime
      return existingSessions.any((existing) {
        final timeDiff = existing.bedTime.difference(session.bedTime).abs();
        return timeDiff.inMinutes < 5; // Within 5 minutes
      });
    } catch (e) {
      print('Error checking if session exists: $e');
      return false;
    }
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastSyncKey);
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      print('Error getting last sync time: $e');
      return null;
    }
  }

  /// Save last sync time
  Future<void> _saveLastSyncTime(DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, time.millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving last sync time: $e');
    }
  }

  /// Check if auto sync is enabled
  Future<bool> isAutoSyncEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_autoSyncKey) ?? true; // Default to enabled
    } catch (e) {
      print('Error checking auto sync setting: $e');
      return true;
    }
  }

  /// Set auto sync enabled/disabled
  Future<void> setAutoSyncEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoSyncKey, enabled);
    } catch (e) {
      print('Error setting auto sync: $e');
    }
  }

  /// Clear all sync data
  Future<void> clearSyncData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastSyncKey);
    } catch (e) {
      print('Error clearing sync data: $e');
    }
  }
}
