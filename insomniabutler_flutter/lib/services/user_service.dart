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
    
    if (userId == null) return null;
    
    try {
      _currentUser = await client.auth.getUserById(userId);
      return _currentUser;
    } catch (e) {
      return null;
    }
  }
  
  /// Get current user ID (faster than getting full user)
  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
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
}
