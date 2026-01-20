import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Authentication endpoint for user registration and login
class AuthEndpoint extends Endpoint {
  /// Register a new user
  /// Returns the created user or null if email already exists
  Future<User?> register(
    Session session,
    String email,
    String name,
  ) async {
    // Check if user exists
    var existing = await User.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email),
    );
    
    if (existing != null) return null;
    
    // Create user
    var user = User(
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );
    
    return await User.db.insertRow(session, user);
  }
  
  /// Login user by email
  /// Returns the user if found, null otherwise
  Future<User?> login(Session session, String email) async {
    return await User.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email),
    );
  }
  
  /// Get user by ID
  Future<User?> getUserById(Session session, int userId) async {
    return await User.db.findById(session, userId);
  }
  
  /// Update user preferences
  Future<User?> updatePreferences(
    Session session,
    int userId,
    String? sleepGoal,
    DateTime? bedtimePreference,
  ) async {
    var user = await User.db.findById(session, userId);
    
    if (user == null) return null;
    
    var updated = user.copyWith(
      sleepGoal: sleepGoal ?? user.sleepGoal,
      bedtimePreference: bedtimePreference ?? user.bedtimePreference,
    );
    
    return await User.db.updateRow(session, updated);
  }
  
  /// Update user profile (name)
  Future<User?> updateUserProfile(
    Session session,
    int userId,
    String name,
  ) async {
    var user = await User.db.findById(session, userId);
    
    if (user == null) return null;
    
    var updated = user.copyWith(name: name);
    
    return await User.db.updateRow(session, updated);
  }
  
  /// Delete user and all associated data
  Future<bool> deleteUser(Session session, int userId) async {
    try {
      var user = await User.db.findById(session, userId);
      if (user == null) return false;
      
      // Delete user (cascade delete will handle related data if configured)
      await User.db.deleteRow(session, user);
      return true;
    } catch (e) {
      session.log('Error deleting user: $e');
      return false;
    }
  }
  
  /// Get user statistics
  /// Returns total sleep sessions, journal entries, and current streak
  Future<Map<String, int>> getUserStats(Session session, int userId) async {
    // TODO: Implement actual queries once we have the data
    // For now, return placeholder data
    return {
      'totalSleepSessions': 0,
      'totalJournalEntries': 0,
      'currentStreak': 0,
    };
  }
}
