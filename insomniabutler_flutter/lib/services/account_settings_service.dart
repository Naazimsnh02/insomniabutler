import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage local app settings and preferences
class AccountSettingsService {
  static const String _notificationsBedtimeKey = 'notifications_bedtime';
  static const String _notificationsInsightsKey = 'notifications_insights';
  static const String _notificationsJournalKey = 'notifications_journal';
  static const String _hapticsEnabledKey = 'haptics_enabled';
  static const String _soundEffectsEnabledKey = 'sound_effects_enabled';
  static const String _autoStartTrackingKey = 'auto_start_tracking';

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

  /// Clear all app settings (reset to defaults)
  static Future<void> clearAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsBedtimeKey);
    await prefs.remove(_notificationsInsightsKey);
    await prefs.remove(_notificationsJournalKey);
    await prefs.remove(_hapticsEnabledKey);
    await prefs.remove(_soundEffectsEnabledKey);
    await prefs.remove(_autoStartTrackingKey);
  }
}
