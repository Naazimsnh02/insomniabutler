import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:insomniabutler_client/insomniabutler_client.dart';
import '../main.dart';

/// Service to manage current user state
class UserService {
  static const String _userIdKey = 'current_user_id';
  static const String _userNameKey = 'current_user_name';
  static const String _userEmailKey = 'current_user_email';

  static User? _currentUser;

  /// Get the current logged-in user
  static Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);

    // If we have no ID, we can't fetch from server by ID
    if (userId == null) return null;

    try {
      _currentUser = await client.auth.getUserById(userId);
      return _currentUser;
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  /// Get current user ID (faster than getting full user)
  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt(_userIdKey);

    // If not in prefs, try to get from session or server
    if (userId == null) {
      final user = await getCurrentUser();
      if (user != null) {
        userId = user.id;
        // Cache it for next time
        if (userId != null) {
          await prefs.setInt(_userIdKey, userId);
        }
      }
    }

    return userId;
  }

  /// Set the current user after login/registration
  static Future<void> setCurrentUser(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, user.id!);
    await prefs.setString(_userNameKey, user.name);
    await prefs.setString(_userEmailKey, user.email);
  }

  /// Clear current user (logout)
  static Future<void> clearCurrentUser() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final userId = await getCurrentUserId();
    return userId != null;
  }

  /// Get cached user name (no network call)
  static Future<String> getCachedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'User';
  }

  /// Get cached user email (no network call)
  static Future<String> getCachedUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey) ?? '';
  }

  /// Update user profile (name)
  static Future<User?> updateUserProfile(String name) async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    try {
      final updatedUser = await client.auth.updateUserProfile(userId, name);
      if (updatedUser != null) {
        _currentUser = updatedUser;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userNameKey, updatedUser.name);
      }
      return updatedUser;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return null;
    }
  }

  /// Update sleep preferences
  static Future<User?> updateSleepPreferences({
    String? sleepGoal,
    DateTime? bedtimePreference,
    bool? sleepInsightsEnabled,
    String? sleepInsightsTime,
    bool? journalInsightsEnabled,
    String? journalInsightsTime,
  }) async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    try {
      final updated = await client.auth.updatePreferences(
        userId,
        sleepGoal: sleepGoal,
        bedtimePreference: bedtimePreference,
        sleepInsightsEnabled: sleepInsightsEnabled,
        sleepInsightsTime: sleepInsightsTime,
        journalInsightsEnabled: journalInsightsEnabled,
        journalInsightsTime: journalInsightsTime,
      );
      if (updated != null) {
        _currentUser = updated;
      }
      return updated;
    } catch (e) {
      debugPrint('Error updating sleep preferences: $e');
      return null;
    }
  }

  /// Delete user account and all associated data
  static Future<bool> deleteAccount() async {
    final userId = await getCurrentUserId();
    if (userId == null) return false;

    try {
      await client.auth.deleteUser(userId);
      await clearCurrentUser();
      return true;
    } catch (e) {
      debugPrint('Error deleting account: $e');
      return false;
    }
  }
}
