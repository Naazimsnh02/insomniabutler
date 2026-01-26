import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage local app settings and preferences
class AccountSettingsService {
  static const String _notificationsBedtimeKey = 'notifications_bedtime';
  static const String _notificationsInsightsKey = 'notifications_insights';
  static const String _notificationsJournalKey = 'notifications_journal';
  static const String _hapticsEnabledKey = 'haptics_enabled';
  static const String _soundEffectsEnabledKey = 'sound_effects_enabled';
  static const String _autoStartTrackingKey = 'auto_start_tracking';
  static const String _distractionBlockingEnabledKey = 'distraction_blocking_enabled';
  static const String _blockedAppsKey = 'blocked_apps';
  static const String _distractionBedtimeStartKey = 'distraction_bedtime_start';
  static const String _distractionBedtimeEndKey = 'distraction_bedtime_end';
  static const String _bedtimeTimeKey = 'notifications_bedtime_time';
  static const String _insightsTimeKey = 'notifications_insights_time';
  static const String _journalTimeKey = 'notifications_journal_time';

  // Notification Settings
  static Future<bool> getBedtimeNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsBedtimeKey) ?? true;
  }

  static Future<void> setBedtimeNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsBedtimeKey, enabled);
  }

  static Future<bool> getInsightsNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsInsightsKey) ?? true;
  }

  static Future<void> setInsightsNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsInsightsKey, enabled);
  }

  static Future<bool> getJournalNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsJournalKey) ?? true;
  }

  static Future<void> setJournalNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsJournalKey, enabled);
  }

  // Display & Sound Settings
  static Future<bool> getHapticsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticsEnabledKey) ?? true;
  }

  static Future<void> setHapticsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsEnabledKey, enabled);
  }

  static Future<bool> getSoundEffectsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEffectsEnabledKey) ?? true;
  }

  static Future<void> setSoundEffectsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEffectsEnabledKey, enabled);
  }

  // Tracking Settings
  static Future<bool> getAutoStartTracking() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoStartTrackingKey) ?? false;
  }

  static Future<void> setAutoStartTracking(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoStartTrackingKey, enabled);
  }

  // Distraction Blocking Settings
  static Future<bool> getDistractionBlockingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_distractionBlockingEnabledKey) ?? false;
  }

  static Future<void> setDistractionBlockingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_distractionBlockingEnabledKey, enabled);
  }

  static Future<List<String>> getBlockedApps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_blockedAppsKey) ?? [];
  }

  static Future<void> setBlockedApps(List<String> packages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_blockedAppsKey, packages);
  }

  static Future<String> getDistractionBedtimeStart() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_distractionBedtimeStartKey) ?? '22:00';
  }

  static Future<void> setDistractionBedtimeStart(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_distractionBedtimeStartKey, time);
  }

  static Future<String> getDistractionBedtimeEnd() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_distractionBedtimeEndKey) ?? '06:00';
  }

  static Future<void> setDistractionBedtimeEnd(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_distractionBedtimeEndKey, time);
  }

  // Notification Times
  static Future<String> getBedtimeTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bedtimeTimeKey) ?? '22:30';
  }

  static Future<void> setBedtimeTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bedtimeTimeKey, time);
  }

  static Future<String> getInsightsTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_insightsTimeKey) ?? '09:00';
  }

  static Future<void> setInsightsTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_insightsTimeKey, time);
  }

  static Future<String> getJournalTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_journalTimeKey) ?? '21:00';
  }

  static Future<void> setJournalTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_journalTimeKey, time);
  }

  /// Clear all app settings (reset to defaults)
  static Future<void> clearAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsBedtimeKey);
    await prefs.remove(_notificationsInsightsKey);
    await prefs.remove(_notificationsJournalKey);
    await prefs.remove(_bedtimeTimeKey);
    await prefs.remove(_insightsTimeKey);
    await prefs.remove(_journalTimeKey);
    await prefs.remove(_hapticsEnabledKey);
    await prefs.remove(_soundEffectsEnabledKey);
    await prefs.remove(_autoStartTrackingKey);
  }
}
