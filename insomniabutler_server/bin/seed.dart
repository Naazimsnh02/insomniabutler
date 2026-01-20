// ignore_for_file: avoid_print
import 'package:serverpod/serverpod.dart';
import 'package:insomniabutler_server/src/endpoints/journal_endpoint.dart';
import 'dart:io';

void main(List<String> args) async {
  // Initialize Serverpod in maintenance mode or just a session
  final session = await _createSession();

  print('Seeding journal prompts...');
  final endpoint = JournalEndpoint();
  await endpoint.seedPrompts(session);
  print('Done!');

  await session.close();
  exit(0);
}

Future<Session> _createSession() async {
  // This is a bit tricky to do without a full server start,
  // but we can try to use the internal Serverpod tools if available.
  // Alternatively, just add it to server.dart startup.
  throw UnimplementedError('Standalone seeding needs full serverpod context.');
}
