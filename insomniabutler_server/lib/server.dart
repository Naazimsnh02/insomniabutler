import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/endpoints/journal_endpoint.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/root.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Configure the email identity provider for email/password authentication.
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode: _sendRegistrationCode,
        sendPasswordResetVerificationCode: _sendPasswordResetCode,
      ),
    ],
  );

  // Setup a default page at the web root.
  // These are used by the default page.
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  // Serve all files in the web/static relative directory under /.
  // These are used by the default web page.
  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.addRoute(StaticRoute.directory(root));

  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/app/assets/assets/config.json',
  );

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under the /app path.
    pod.webServer.addRoute(
      FlutterRoute(
        Directory(
          Uri(path: 'web/app').toFilePath(),
        ),
      ),
      '/app',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    pod.webServer.addRoute(
      StaticRoute.file(
        File(
          Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
        ),
      ),
      '/app/**',
    );
  }

  // Start the server.
  await pod.start();

  // Seed journal prompts and perform database migrations
  final session = await pod.createSession();
  try {
    // 1. Seed journal prompts
    await JournalEndpoint().seedPrompts(session);
    session.log('Journal prompts seeded successfully');

    // 2. Perform Widget Persistence Migration
    session.log('Checking for chat_messages table updates...');
    try {
      await session.db.unsafeQuery(
        'ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS "widgetType" text;',
      );
      await session.db.unsafeQuery(
        'ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS "widgetData" text;',
      );
      session.log('✅ Chat messages table migration successful.');
    } catch (e) {
      session.log(
        'Warning: Chat migration skipped or failed (likely already exists): $e',
      );
    }

    // 3. Perform Health Tracking Fields Migration
    session.log('Checking for sleep_sessions table updates...');
    try {
      await session.db.unsafeQuery(
        'ALTER TABLE sleep_sessions ADD COLUMN IF NOT EXISTS "sleepDataSource" text;',
      );
      await session.db.unsafeQuery(
        'ALTER TABLE sleep_sessions ADD COLUMN IF NOT EXISTS "deviceType" text;',
      );
      await session.db.unsafeQuery(
        'ALTER TABLE sleep_sessions ADD COLUMN IF NOT EXISTS "deviceModel" text;',
      );
      await session.db.unsafeQuery(
        'ALTER TABLE sleep_sessions ADD COLUMN IF NOT EXISTS "recordingMethod" text;',
      );
      await session.db.unsafeQuery(
        'ALTER TABLE sleep_sessions ADD COLUMN IF NOT EXISTS "timeInBedMinutes" integer;',
      );
      await session.db.unsafeQuery(
        'ALTER TABLE sleep_sessions ADD COLUMN IF NOT EXISTS "sleepEfficiency" double precision;',
      );
      await session.db.unsafeQuery(
        'ALTER TABLE sleep_sessions ADD COLUMN IF NOT EXISTS "unspecifiedSleepDuration" integer;',
      );
      await session.db.unsafeQuery(
        'ALTER TABLE sleep_sessions ADD COLUMN IF NOT EXISTS "wristTemperature" double precision;',
      );
      
      // Add indexes
      await session.db.unsafeQuery(
        'CREATE INDEX IF NOT EXISTS idx_sleep_sessions_data_source ON sleep_sessions("sleepDataSource");',
      );
      await session.db.unsafeQuery(
        'CREATE INDEX IF NOT EXISTS idx_sleep_sessions_date_source ON sleep_sessions("sessionDate", "sleepDataSource");',
      );
      
      session.log('✅ Sleep sessions table migration successful.');
    } catch (e) {
      session.log(
        'Warning: Sleep sessions migration skipped or failed (likely already exists): $e',
      );
    }

  } catch (e) {
    session.log(
      'Error during server initialization tasks: $e',
      level: LogLevel.error,
    );
  } finally {
    await session.close();
  }
}

void _sendRegistrationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  // NOTE: Here you call your mail service to send the verification code to
  // the user. For testing, we will just log the verification code.
  session.log('[EmailIdp] Registration code ($email): $verificationCode');
}

void _sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  // NOTE: Here you call your mail service to send the verification code to
  // the user. For testing, we will just log the verification code.
  session.log('[EmailIdp] Password reset code ($email): $verificationCode');
}
