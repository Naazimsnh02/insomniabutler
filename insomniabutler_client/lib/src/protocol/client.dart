/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'dart:async' as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:insomniabutler_client/src/protocol/user.dart' as _i5;
import 'package:insomniabutler_client/src/protocol/user_insights.dart' as _i6;
import 'package:insomniabutler_client/src/protocol/sleep_session.dart' as _i7;
import 'package:insomniabutler_client/src/protocol/journal_entry.dart' as _i8;
import 'package:insomniabutler_client/src/protocol/journal_prompt.dart' as _i9;
import 'package:insomniabutler_client/src/protocol/journal_stats.dart' as _i10;
import 'package:insomniabutler_client/src/protocol/journal_insight.dart'
    as _i11;
import 'package:insomniabutler_client/src/protocol/thought_response.dart'
    as _i12;
import 'package:insomniabutler_client/src/protocol/chat_message.dart' as _i13;
import 'package:insomniabutler_client/src/protocol/chat_session_info.dart'
    as _i14;
import 'package:insomniabutler_client/src/protocol/greetings/greeting.dart'
    as _i15;
import 'protocol.dart' as _i16;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _i1.EndpointEmailIdpBase {
  EndpointEmailIdp(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<_i4.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i3.Future<_i2.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i3.Future<String> verifyRegistrationCode({
    required _i2.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i3.Future<_i4.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i3.Future<_i2.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i3.Future<String> verifyPasswordResetCode({
    required _i2.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i4.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i3.Future<_i4.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// Authentication endpoint for user registration and login
/// {@category Endpoint}
class EndpointAuth extends _i2.EndpointRef {
  EndpointAuth(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'auth';

  /// Register a new user
  /// Returns the created user or null if email already exists
  _i3.Future<_i5.User?> register(
    String email,
    String name,
  ) => caller.callServerEndpoint<_i5.User?>(
    'auth',
    'register',
    {
      'email': email,
      'name': name,
    },
  );

  /// Login user by email
  /// Returns the user if found, null otherwise
  _i3.Future<_i5.User?> login(String email) =>
      caller.callServerEndpoint<_i5.User?>(
        'auth',
        'login',
        {'email': email},
      );

  /// Get user by ID
  _i3.Future<_i5.User?> getUserById(int userId) =>
      caller.callServerEndpoint<_i5.User?>(
        'auth',
        'getUserById',
        {'userId': userId},
      );

  /// Update user preferences
  _i3.Future<_i5.User?> updatePreferences(
    int userId,
    String? sleepGoal,
    DateTime? bedtimePreference,
  ) => caller.callServerEndpoint<_i5.User?>(
    'auth',
    'updatePreferences',
    {
      'userId': userId,
      'sleepGoal': sleepGoal,
      'bedtimePreference': bedtimePreference,
    },
  );

  /// Update user profile (name)
  _i3.Future<_i5.User?> updateUserProfile(
    int userId,
    String name,
  ) => caller.callServerEndpoint<_i5.User?>(
    'auth',
    'updateUserProfile',
    {
      'userId': userId,
      'name': name,
    },
  );

  /// Delete user and all associated data
  _i3.Future<bool> deleteUser(int userId) => caller.callServerEndpoint<bool>(
    'auth',
    'deleteUser',
    {'userId': userId},
  );

  /// Get user statistics
  /// Returns total sleep sessions, journal entries, and current streak
  _i3.Future<Map<String, int>> getUserStats(int userId) =>
      caller.callServerEndpoint<Map<String, int>>(
        'auth',
        'getUserStats',
        {'userId': userId},
      );
}

/// {@category Endpoint}
class EndpointDev extends _i2.EndpointRef {
  EndpointDev(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'dev';

  _i3.Future<bool> generateRealisticData(int userId) =>
      caller.callServerEndpoint<bool>(
        'dev',
        'generateRealisticData',
        {'userId': userId},
      );

  _i3.Future<bool> clearUserData(int userId) => caller.callServerEndpoint<bool>(
    'dev',
    'clearUserData',
    {'userId': userId},
  );

  /// Generates embeddings for all historical data that doesn't have them
  _i3.Future<Map<String, int>> backfillEmbeddings() =>
      caller.callServerEndpoint<Map<String, int>>(
        'dev',
        'backfillEmbeddings',
        {},
      );
}

/// Analytics and insights endpoint for sleep intelligence
/// {@category Endpoint}
class EndpointInsights extends _i2.EndpointRef {
  EndpointInsights(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'insights';

  /// Get comprehensive user insights
  _i3.Future<_i6.UserInsights> getUserInsights(int userId) =>
      caller.callServerEndpoint<_i6.UserInsights>(
        'insights',
        'getUserInsights',
        {'userId': userId},
      );

  /// Get weekly insights for a specific week
  _i3.Future<_i6.UserInsights> getWeeklyInsights(
    int userId,
    DateTime weekStart,
  ) => caller.callServerEndpoint<_i6.UserInsights>(
    'insights',
    'getWeeklyInsights',
    {
      'userId': userId,
      'weekStart': weekStart,
    },
  );

  /// Get thought category breakdown
  _i3.Future<Map<String, int>> getThoughtCategoryBreakdown(int userId) =>
      caller.callServerEndpoint<Map<String, int>>(
        'insights',
        'getThoughtCategoryBreakdown',
        {'userId': userId},
      );

  /// Get sleep quality trend (last N days)
  _i3.Future<List<_i7.SleepSession>> getSleepTrend(
    int userId,
    int days,
  ) => caller.callServerEndpoint<List<_i7.SleepSession>>(
    'insights',
    'getSleepTrend',
    {
      'userId': userId,
      'days': days,
    },
  );

  /// Get Butler effectiveness score (0-100)
  _i3.Future<int> getButlerEffectivenessScore(int userId) =>
      caller.callServerEndpoint<int>(
        'insights',
        'getButlerEffectivenessScore',
        {'userId': userId},
      );
}

/// {@category Endpoint}
class EndpointJournal extends _i2.EndpointRef {
  EndpointJournal(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'journal';

  /// Create a new journal entry
  _i3.Future<_i8.JournalEntry> createEntry(
    int userId,
    String content, {
    String? title,
    String? mood,
    int? sleepSessionId,
    String? tags,
    required bool isFavorite,
    DateTime? entryDate,
  }) => caller.callServerEndpoint<_i8.JournalEntry>(
    'journal',
    'createEntry',
    {
      'userId': userId,
      'content': content,
      'title': title,
      'mood': mood,
      'sleepSessionId': sleepSessionId,
      'tags': tags,
      'isFavorite': isFavorite,
      'entryDate': entryDate,
    },
  );

  /// Update an existing journal entry
  _i3.Future<_i8.JournalEntry?> updateEntry(
    int entryId,
    int userId, {
    String? title,
    String? content,
    String? mood,
    String? tags,
    bool? isFavorite,
  }) => caller.callServerEndpoint<_i8.JournalEntry?>(
    'journal',
    'updateEntry',
    {
      'entryId': entryId,
      'userId': userId,
      'title': title,
      'content': content,
      'mood': mood,
      'tags': tags,
      'isFavorite': isFavorite,
    },
  );

  /// Delete a journal entry
  _i3.Future<bool> deleteEntry(
    int entryId,
    int userId,
  ) => caller.callServerEndpoint<bool>(
    'journal',
    'deleteEntry',
    {
      'entryId': entryId,
      'userId': userId,
    },
  );

  /// Get a single journal entry
  _i3.Future<_i8.JournalEntry?> getEntry(
    int entryId,
    int userId,
  ) => caller.callServerEndpoint<_i8.JournalEntry?>(
    'journal',
    'getEntry',
    {
      'entryId': entryId,
      'userId': userId,
    },
  );

  /// Get user's journal entries with pagination
  _i3.Future<List<_i8.JournalEntry>> getUserEntries(
    int userId, {
    required int limit,
    required int offset,
    DateTime? startDate,
    DateTime? endDate,
  }) => caller.callServerEndpoint<List<_i8.JournalEntry>>(
    'journal',
    'getUserEntries',
    {
      'userId': userId,
      'limit': limit,
      'offset': offset,
      'startDate': startDate,
      'endDate': endDate,
    },
  );

  /// Search journal entries
  _i3.Future<List<_i8.JournalEntry>> searchEntries(
    int userId,
    String query, {
    String? mood,
    String? tag,
  }) => caller.callServerEndpoint<List<_i8.JournalEntry>>(
    'journal',
    'searchEntries',
    {
      'userId': userId,
      'query': query,
      'mood': mood,
      'tag': tag,
    },
  );

  /// Toggle favorite status
  _i3.Future<_i8.JournalEntry?> toggleFavorite(
    int entryId,
    int userId,
  ) => caller.callServerEndpoint<_i8.JournalEntry?>(
    'journal',
    'toggleFavorite',
    {
      'entryId': entryId,
      'userId': userId,
    },
  );

  /// Get daily prompts
  _i3.Future<List<_i9.JournalPrompt>> getDailyPrompts(String category) =>
      caller.callServerEndpoint<List<_i9.JournalPrompt>>(
        'journal',
        'getDailyPrompts',
        {'category': category},
      );

  /// Get all active prompts
  _i3.Future<List<_i9.JournalPrompt>> getAllPrompts() =>
      caller.callServerEndpoint<List<_i9.JournalPrompt>>(
        'journal',
        'getAllPrompts',
        {},
      );

  /// Get journal statistics
  _i3.Future<_i10.JournalStats> getJournalStats(int userId) =>
      caller.callServerEndpoint<_i10.JournalStats>(
        'journal',
        'getJournalStats',
        {'userId': userId},
      );

  /// Get AI-powered insights
  _i3.Future<List<_i11.JournalInsight>> getJournalInsights(int userId) =>
      caller.callServerEndpoint<List<_i11.JournalInsight>>(
        'journal',
        'getJournalInsights',
        {'userId': userId},
      );

  /// Seed initial prompts (call once during setup)
  _i3.Future<void> seedPrompts() => caller.callServerEndpoint<void>(
    'journal',
    'seedPrompts',
    {},
  );
}

/// Sleep session management endpoint
/// {@category Endpoint}
class EndpointSleepSession extends _i2.EndpointRef {
  EndpointSleepSession(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'sleepSession';

  /// Start a new sleep session
  _i3.Future<_i7.SleepSession> startSession(int userId) =>
      caller.callServerEndpoint<_i7.SleepSession>(
        'sleepSession',
        'startSession',
        {'userId': userId},
      );

  /// End a sleep session with quality feedback
  _i3.Future<_i7.SleepSession?> endSession(
    int sessionId,
    int sleepQuality,
    String morningMood,
    int? sleepLatencyMinutes, {
    int? interruptions,
  }) => caller.callServerEndpoint<_i7.SleepSession?>(
    'sleepSession',
    'endSession',
    {
      'sessionId': sessionId,
      'sleepQuality': sleepQuality,
      'morningMood': morningMood,
      'sleepLatencyMinutes': sleepLatencyMinutes,
      'interruptions': interruptions,
    },
  );

  /// Mark that Butler was used during this session
  _i3.Future<void> markButlerUsed(
    int sessionId,
    int thoughtCount,
  ) => caller.callServerEndpoint<void>(
    'sleepSession',
    'markButlerUsed',
    {
      'sessionId': sessionId,
      'thoughtCount': thoughtCount,
    },
  );

  /// Get user's sleep sessions with optional limit
  _i3.Future<List<_i7.SleepSession>> getUserSessions(
    int userId,
    int limit,
  ) => caller.callServerEndpoint<List<_i7.SleepSession>>(
    'sleepSession',
    'getUserSessions',
    {
      'userId': userId,
      'limit': limit,
    },
  );

  /// Get the most recent active session for a user
  _i3.Future<_i7.SleepSession?> getActiveSession(int userId) =>
      caller.callServerEndpoint<_i7.SleepSession?>(
        'sleepSession',
        'getActiveSession',
        {'userId': userId},
      );

  /// Get last night's session
  _i3.Future<_i7.SleepSession?> getLastNightSession(int userId) =>
      caller.callServerEndpoint<_i7.SleepSession?>(
        'sleepSession',
        'getLastNightSession',
        {'userId': userId},
      );

  /// Get session for a specific date
  _i3.Future<_i7.SleepSession?> getSessionForDate(
    int userId,
    DateTime date,
  ) => caller.callServerEndpoint<_i7.SleepSession?>(
    'sleepSession',
    'getSessionForDate',
    {
      'userId': userId,
      'date': date,
    },
  );

  /// Update sleep latency for a session
  _i3.Future<_i7.SleepSession?> updateSleepLatency(
    int sessionId,
    int latencyMinutes,
  ) => caller.callServerEndpoint<_i7.SleepSession?>(
    'sleepSession',
    'updateSleepLatency',
    {
      'sessionId': sessionId,
      'latencyMinutes': latencyMinutes,
    },
  );

  /// Log a manual sleep session (retroactive)
  _i3.Future<_i7.SleepSession> logManualSession(
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
  }) => caller.callServerEndpoint<_i7.SleepSession>(
    'sleepSession',
    'logManualSession',
    {
      'userId': userId,
      'bedTime': bedTime,
      'wakeTime': wakeTime,
      'sleepQuality': sleepQuality,
      'sleepLatencyMinutes': sleepLatencyMinutes,
      'deepSleepDuration': deepSleepDuration,
      'lightSleepDuration': lightSleepDuration,
      'remSleepDuration': remSleepDuration,
      'awakeDuration': awakeDuration,
      'restingHeartRate': restingHeartRate,
      'hrv': hrv,
      'respiratoryRate': respiratoryRate,
      'interruptions': interruptions,
    },
  );

  /// Update an existing sleep session
  _i3.Future<_i7.SleepSession?> updateSession(
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
  }) => caller.callServerEndpoint<_i7.SleepSession?>(
    'sleepSession',
    'updateSession',
    {
      'sessionId': sessionId,
      'bedTime': bedTime,
      'wakeTime': wakeTime,
      'sleepQuality': sleepQuality,
      'sleepLatencyMinutes': sleepLatencyMinutes,
      'deepSleepDuration': deepSleepDuration,
      'lightSleepDuration': lightSleepDuration,
      'remSleepDuration': remSleepDuration,
      'awakeDuration': awakeDuration,
      'restingHeartRate': restingHeartRate,
      'hrv': hrv,
      'respiratoryRate': respiratoryRate,
      'interruptions': interruptions,
    },
  );

  /// Delete a sleep session
  _i3.Future<bool> deleteSession(int sessionId) =>
      caller.callServerEndpoint<bool>(
        'sleepSession',
        'deleteSession',
        {'sessionId': sessionId},
      );

  /// Update mood for the user's latest session
  _i3.Future<_i7.SleepSession?> updateMoodForLatestSession(
    int userId,
    String mood,
  ) => caller.callServerEndpoint<_i7.SleepSession?>(
    'sleepSession',
    'updateMoodForLatestSession',
    {
      'userId': userId,
      'mood': mood,
    },
  );
}

/// Core thought clearing endpoint - processes user thoughts through AI
/// {@category Endpoint}
class EndpointThoughtClearing extends _i2.EndpointRef {
  EndpointThoughtClearing(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'thoughtClearing';

  /// Process a user's thought through AI and return categorized response
  _i3.Future<_i12.ThoughtResponse> processThought(
    int userId,
    String userMessage,
    String sessionId,
    int currentReadiness,
  ) => caller.callServerEndpoint<_i12.ThoughtResponse>(
    'thoughtClearing',
    'processThought',
    {
      'userId': userId,
      'userMessage': userMessage,
      'sessionId': sessionId,
      'currentReadiness': currentReadiness,
    },
  );

  /// Get conversation history for a session
  _i3.Future<List<_i13.ChatMessage>> getChatSessionMessages(String sessionId) =>
      caller.callServerEndpoint<List<_i13.ChatMessage>>(
        'thoughtClearing',
        'getChatSessionMessages',
        {'sessionId': sessionId},
      );

  /// Get list of all chat sessions for a user
  _i3.Future<List<_i14.ChatSessionInfo>> getChatHistory(int userId) =>
      caller.callServerEndpoint<List<_i14.ChatSessionInfo>>(
        'thoughtClearing',
        'getChatHistory',
        {'userId': userId},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i2.EndpointRef {
  EndpointGreeting(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i3.Future<_i15.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i15.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i1.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i1.Caller serverpod_auth_idp;

  late final _i4.Caller serverpod_auth_core;
}

class Client extends _i2.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i2.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i2.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i16.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    auth = EndpointAuth(this);
    dev = EndpointDev(this);
    insights = EndpointInsights(this);
    journal = EndpointJournal(this);
    sleepSession = EndpointSleepSession(this);
    thoughtClearing = EndpointThoughtClearing(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointAuth auth;

  late final EndpointDev dev;

  late final EndpointInsights insights;

  late final EndpointJournal journal;

  late final EndpointSleepSession sleepSession;

  late final EndpointThoughtClearing thoughtClearing;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'auth': auth,
    'dev': dev,
    'insights': insights,
    'journal': journal,
    'sleepSession': sleepSession,
    'thoughtClearing': thoughtClearing,
    'greeting': greeting,
  };

  @override
  Map<String, _i2.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
