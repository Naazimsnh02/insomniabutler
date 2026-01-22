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
import 'package:serverpod/serverpod.dart' as _i1;
import '../auth/email_idp_endpoint.dart' as _i2;
import '../auth/jwt_refresh_endpoint.dart' as _i3;
import '../endpoints/auth_endpoint.dart' as _i4;
import '../endpoints/insights_endpoint.dart' as _i5;
import '../endpoints/journal_endpoint.dart' as _i6;
import '../endpoints/sleep_session_endpoint.dart' as _i7;
import '../endpoints/thought_clearing_endpoint.dart' as _i8;
import '../greetings/greeting_endpoint.dart' as _i9;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i10;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i11;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'emailIdp': _i2.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _i3.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'auth': _i4.AuthEndpoint()
        ..initialize(
          server,
          'auth',
          null,
        ),
      'insights': _i5.InsightsEndpoint()
        ..initialize(
          server,
          'insights',
          null,
        ),
      'journal': _i6.JournalEndpoint()
        ..initialize(
          server,
          'journal',
          null,
        ),
      'sleepSession': _i7.SleepSessionEndpoint()
        ..initialize(
          server,
          'sleepSession',
          null,
        ),
      'thoughtClearing': _i8.ThoughtClearingEndpoint()
        ..initialize(
          server,
          'thoughtClearing',
          null,
        ),
      'greeting': _i9.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i3.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['auth'] = _i1.EndpointConnector(
      name: 'auth',
      endpoint: endpoints['auth']!,
      methodConnectors: {
        'register': _i1.MethodConnector(
          name: 'register',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i4.AuthEndpoint).register(
                session,
                params['email'],
                params['name'],
              ),
        ),
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i4.AuthEndpoint).login(
                session,
                params['email'],
              ),
        ),
        'getUserById': _i1.MethodConnector(
          name: 'getUserById',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i4.AuthEndpoint).getUserById(
                session,
                params['userId'],
              ),
        ),
        'updatePreferences': _i1.MethodConnector(
          name: 'updatePreferences',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'sleepGoal': _i1.ParameterDescription(
              name: 'sleepGoal',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'bedtimePreference': _i1.ParameterDescription(
              name: 'bedtimePreference',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['auth'] as _i4.AuthEndpoint).updatePreferences(
                    session,
                    params['userId'],
                    params['sleepGoal'],
                    params['bedtimePreference'],
                  ),
        ),
        'updateUserProfile': _i1.MethodConnector(
          name: 'updateUserProfile',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['auth'] as _i4.AuthEndpoint).updateUserProfile(
                    session,
                    params['userId'],
                    params['name'],
                  ),
        ),
        'deleteUser': _i1.MethodConnector(
          name: 'deleteUser',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i4.AuthEndpoint).deleteUser(
                session,
                params['userId'],
              ),
        ),
        'getUserStats': _i1.MethodConnector(
          name: 'getUserStats',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i4.AuthEndpoint).getUserStats(
                session,
                params['userId'],
              ),
        ),
      },
    );
    connectors['insights'] = _i1.EndpointConnector(
      name: 'insights',
      endpoint: endpoints['insights']!,
      methodConnectors: {
        'getUserInsights': _i1.MethodConnector(
          name: 'getUserInsights',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['insights'] as _i5.InsightsEndpoint)
                  .getUserInsights(
                    session,
                    params['userId'],
                  ),
        ),
        'getWeeklyInsights': _i1.MethodConnector(
          name: 'getWeeklyInsights',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'weekStart': _i1.ParameterDescription(
              name: 'weekStart',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['insights'] as _i5.InsightsEndpoint)
                  .getWeeklyInsights(
                    session,
                    params['userId'],
                    params['weekStart'],
                  ),
        ),
        'getThoughtCategoryBreakdown': _i1.MethodConnector(
          name: 'getThoughtCategoryBreakdown',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['insights'] as _i5.InsightsEndpoint)
                  .getThoughtCategoryBreakdown(
                    session,
                    params['userId'],
                  ),
        ),
        'getSleepTrend': _i1.MethodConnector(
          name: 'getSleepTrend',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'days': _i1.ParameterDescription(
              name: 'days',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['insights'] as _i5.InsightsEndpoint).getSleepTrend(
                    session,
                    params['userId'],
                    params['days'],
                  ),
        ),
        'getButlerEffectivenessScore': _i1.MethodConnector(
          name: 'getButlerEffectivenessScore',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['insights'] as _i5.InsightsEndpoint)
                  .getButlerEffectivenessScore(
                    session,
                    params['userId'],
                  ),
        ),
      },
    );
    connectors['journal'] = _i1.EndpointConnector(
      name: 'journal',
      endpoint: endpoints['journal']!,
      methodConnectors: {
        'createEntry': _i1.MethodConnector(
          name: 'createEntry',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'content': _i1.ParameterDescription(
              name: 'content',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'mood': _i1.ParameterDescription(
              name: 'mood',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'sleepSessionId': _i1.ParameterDescription(
              name: 'sleepSessionId',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'tags': _i1.ParameterDescription(
              name: 'tags',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'isFavorite': _i1.ParameterDescription(
              name: 'isFavorite',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'entryDate': _i1.ParameterDescription(
              name: 'entryDate',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['journal'] as _i6.JournalEndpoint).createEntry(
                    session,
                    params['userId'],
                    params['content'],
                    title: params['title'],
                    mood: params['mood'],
                    sleepSessionId: params['sleepSessionId'],
                    tags: params['tags'],
                    isFavorite: params['isFavorite'],
                    entryDate: params['entryDate'],
                  ),
        ),
        'updateEntry': _i1.MethodConnector(
          name: 'updateEntry',
          params: {
            'entryId': _i1.ParameterDescription(
              name: 'entryId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'content': _i1.ParameterDescription(
              name: 'content',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'mood': _i1.ParameterDescription(
              name: 'mood',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'tags': _i1.ParameterDescription(
              name: 'tags',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'isFavorite': _i1.ParameterDescription(
              name: 'isFavorite',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['journal'] as _i6.JournalEndpoint).updateEntry(
                    session,
                    params['entryId'],
                    params['userId'],
                    title: params['title'],
                    content: params['content'],
                    mood: params['mood'],
                    tags: params['tags'],
                    isFavorite: params['isFavorite'],
                  ),
        ),
        'deleteEntry': _i1.MethodConnector(
          name: 'deleteEntry',
          params: {
            'entryId': _i1.ParameterDescription(
              name: 'entryId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['journal'] as _i6.JournalEndpoint).deleteEntry(
                    session,
                    params['entryId'],
                    params['userId'],
                  ),
        ),
        'getEntry': _i1.MethodConnector(
          name: 'getEntry',
          params: {
            'entryId': _i1.ParameterDescription(
              name: 'entryId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['journal'] as _i6.JournalEndpoint).getEntry(
                session,
                params['entryId'],
                params['userId'],
              ),
        ),
        'getUserEntries': _i1.MethodConnector(
          name: 'getUserEntries',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'startDate': _i1.ParameterDescription(
              name: 'startDate',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'endDate': _i1.ParameterDescription(
              name: 'endDate',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['journal'] as _i6.JournalEndpoint).getUserEntries(
                    session,
                    params['userId'],
                    limit: params['limit'],
                    offset: params['offset'],
                    startDate: params['startDate'],
                    endDate: params['endDate'],
                  ),
        ),
        'searchEntries': _i1.MethodConnector(
          name: 'searchEntries',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'mood': _i1.ParameterDescription(
              name: 'mood',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'tag': _i1.ParameterDescription(
              name: 'tag',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['journal'] as _i6.JournalEndpoint).searchEntries(
                    session,
                    params['userId'],
                    params['query'],
                    mood: params['mood'],
                    tag: params['tag'],
                  ),
        ),
        'toggleFavorite': _i1.MethodConnector(
          name: 'toggleFavorite',
          params: {
            'entryId': _i1.ParameterDescription(
              name: 'entryId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['journal'] as _i6.JournalEndpoint).toggleFavorite(
                    session,
                    params['entryId'],
                    params['userId'],
                  ),
        ),
        'getDailyPrompts': _i1.MethodConnector(
          name: 'getDailyPrompts',
          params: {
            'category': _i1.ParameterDescription(
              name: 'category',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['journal'] as _i6.JournalEndpoint).getDailyPrompts(
                    session,
                    params['category'],
                  ),
        ),
        'getAllPrompts': _i1.MethodConnector(
          name: 'getAllPrompts',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['journal'] as _i6.JournalEndpoint)
                  .getAllPrompts(session),
        ),
        'getJournalStats': _i1.MethodConnector(
          name: 'getJournalStats',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['journal'] as _i6.JournalEndpoint).getJournalStats(
                    session,
                    params['userId'],
                  ),
        ),
        'getJournalInsights': _i1.MethodConnector(
          name: 'getJournalInsights',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['journal'] as _i6.JournalEndpoint)
                  .getJournalInsights(
                    session,
                    params['userId'],
                  ),
        ),
        'seedPrompts': _i1.MethodConnector(
          name: 'seedPrompts',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['journal'] as _i6.JournalEndpoint)
                  .seedPrompts(session),
        ),
      },
    );
    connectors['sleepSession'] = _i1.EndpointConnector(
      name: 'sleepSession',
      endpoint: endpoints['sleepSession']!,
      methodConnectors: {
        'startSession': _i1.MethodConnector(
          name: 'startSession',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['sleepSession'] as _i7.SleepSessionEndpoint)
                  .startSession(
                    session,
                    params['userId'],
                  ),
        ),
        'endSession': _i1.MethodConnector(
          name: 'endSession',
          params: {
            'sessionId': _i1.ParameterDescription(
              name: 'sessionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'sleepQuality': _i1.ParameterDescription(
              name: 'sleepQuality',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'morningMood': _i1.ParameterDescription(
              name: 'morningMood',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'sleepLatencyMinutes': _i1.ParameterDescription(
              name: 'sleepLatencyMinutes',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['sleepSession'] as _i7.SleepSessionEndpoint)
                  .endSession(
                    session,
                    params['sessionId'],
                    params['sleepQuality'],
                    params['morningMood'],
                    params['sleepLatencyMinutes'],
                  ),
        ),
        'markButlerUsed': _i1.MethodConnector(
          name: 'markButlerUsed',
          params: {
            'sessionId': _i1.ParameterDescription(
              name: 'sessionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'thoughtCount': _i1.ParameterDescription(
              name: 'thoughtCount',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['sleepSession'] as _i7.SleepSessionEndpoint)
                  .markButlerUsed(
                    session,
                    params['sessionId'],
                    params['thoughtCount'],
                  ),
        ),
        'getUserSessions': _i1.MethodConnector(
          name: 'getUserSessions',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['sleepSession'] as _i7.SleepSessionEndpoint)
                  .getUserSessions(
                    session,
                    params['userId'],
                    params['limit'],
                  ),
        ),
        'getActiveSession': _i1.MethodConnector(
          name: 'getActiveSession',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['sleepSession'] as _i7.SleepSessionEndpoint)
                  .getActiveSession(
                    session,
                    params['userId'],
                  ),
        ),
        'getLastNightSession': _i1.MethodConnector(
          name: 'getLastNightSession',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['sleepSession'] as _i7.SleepSessionEndpoint)
                  .getLastNightSession(
                    session,
                    params['userId'],
                  ),
        ),
        'updateSleepLatency': _i1.MethodConnector(
          name: 'updateSleepLatency',
          params: {
            'sessionId': _i1.ParameterDescription(
              name: 'sessionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'latencyMinutes': _i1.ParameterDescription(
              name: 'latencyMinutes',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['sleepSession'] as _i7.SleepSessionEndpoint)
                  .updateSleepLatency(
                    session,
                    params['sessionId'],
                    params['latencyMinutes'],
                  ),
        ),
        'logManualSession': _i1.MethodConnector(
          name: 'logManualSession',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'bedTime': _i1.ParameterDescription(
              name: 'bedTime',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'wakeTime': _i1.ParameterDescription(
              name: 'wakeTime',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'sleepQuality': _i1.ParameterDescription(
              name: 'sleepQuality',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'sleepLatencyMinutes': _i1.ParameterDescription(
              name: 'sleepLatencyMinutes',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'deepSleepDuration': _i1.ParameterDescription(
              name: 'deepSleepDuration',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'lightSleepDuration': _i1.ParameterDescription(
              name: 'lightSleepDuration',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'remSleepDuration': _i1.ParameterDescription(
              name: 'remSleepDuration',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'awakeDuration': _i1.ParameterDescription(
              name: 'awakeDuration',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'restingHeartRate': _i1.ParameterDescription(
              name: 'restingHeartRate',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'hrv': _i1.ParameterDescription(
              name: 'hrv',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'respiratoryRate': _i1.ParameterDescription(
              name: 'respiratoryRate',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['sleepSession'] as _i7.SleepSessionEndpoint)
                  .logManualSession(
                    session,
                    params['userId'],
                    params['bedTime'],
                    params['wakeTime'],
                    params['sleepQuality'],
                    sleepLatencyMinutes: params['sleepLatencyMinutes'],
                    deepSleepDuration: params['deepSleepDuration'],
                    lightSleepDuration: params['lightSleepDuration'],
                    remSleepDuration: params['remSleepDuration'],
                    awakeDuration: params['awakeDuration'],
                    restingHeartRate: params['restingHeartRate'],
                    hrv: params['hrv'],
                    respiratoryRate: params['respiratoryRate'],
                  ),
        ),
        'updateSession': _i1.MethodConnector(
          name: 'updateSession',
          params: {
            'sessionId': _i1.ParameterDescription(
              name: 'sessionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'bedTime': _i1.ParameterDescription(
              name: 'bedTime',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'wakeTime': _i1.ParameterDescription(
              name: 'wakeTime',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'sleepQuality': _i1.ParameterDescription(
              name: 'sleepQuality',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'sleepLatencyMinutes': _i1.ParameterDescription(
              name: 'sleepLatencyMinutes',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'deepSleepDuration': _i1.ParameterDescription(
              name: 'deepSleepDuration',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'lightSleepDuration': _i1.ParameterDescription(
              name: 'lightSleepDuration',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'remSleepDuration': _i1.ParameterDescription(
              name: 'remSleepDuration',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'awakeDuration': _i1.ParameterDescription(
              name: 'awakeDuration',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'restingHeartRate': _i1.ParameterDescription(
              name: 'restingHeartRate',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'hrv': _i1.ParameterDescription(
              name: 'hrv',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'respiratoryRate': _i1.ParameterDescription(
              name: 'respiratoryRate',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['sleepSession'] as _i7.SleepSessionEndpoint)
                  .updateSession(
                    session,
                    params['sessionId'],
                    params['bedTime'],
                    params['wakeTime'],
                    params['sleepQuality'],
                    params['sleepLatencyMinutes'],
                    deepSleepDuration: params['deepSleepDuration'],
                    lightSleepDuration: params['lightSleepDuration'],
                    remSleepDuration: params['remSleepDuration'],
                    awakeDuration: params['awakeDuration'],
                    restingHeartRate: params['restingHeartRate'],
                    hrv: params['hrv'],
                    respiratoryRate: params['respiratoryRate'],
                  ),
        ),
        'deleteSession': _i1.MethodConnector(
          name: 'deleteSession',
          params: {
            'sessionId': _i1.ParameterDescription(
              name: 'sessionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['sleepSession'] as _i7.SleepSessionEndpoint)
                  .deleteSession(
                    session,
                    params['sessionId'],
                  ),
        ),
        'updateMoodForLatestSession': _i1.MethodConnector(
          name: 'updateMoodForLatestSession',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'mood': _i1.ParameterDescription(
              name: 'mood',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['sleepSession'] as _i7.SleepSessionEndpoint)
                  .updateMoodForLatestSession(
                    session,
                    params['userId'],
                    params['mood'],
                  ),
        ),
      },
    );
    connectors['thoughtClearing'] = _i1.EndpointConnector(
      name: 'thoughtClearing',
      endpoint: endpoints['thoughtClearing']!,
      methodConnectors: {
        'processThought': _i1.MethodConnector(
          name: 'processThought',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'userMessage': _i1.ParameterDescription(
              name: 'userMessage',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'sessionId': _i1.ParameterDescription(
              name: 'sessionId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'currentReadiness': _i1.ParameterDescription(
              name: 'currentReadiness',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['thoughtClearing'] as _i8.ThoughtClearingEndpoint)
                      .processThought(
                        session,
                        params['userId'],
                        params['userMessage'],
                        params['sessionId'],
                        params['currentReadiness'],
                      ),
        ),
        'getSessionHistory': _i1.MethodConnector(
          name: 'getSessionHistory',
          params: {
            'sessionId': _i1.ParameterDescription(
              name: 'sessionId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['thoughtClearing'] as _i8.ThoughtClearingEndpoint)
                      .getSessionHistory(
                        session,
                        params['sessionId'],
                      ),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i9.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i10.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i11.Endpoints()
      ..initializeEndpoints(server);
  }
}
