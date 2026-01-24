import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'embedding_service.dart';

/// Executes tool calls requested by the AI
class ToolExecutor {
  final Session session;
  final int userId;
  final EmbeddingService embeddingService;

  ToolExecutor({
    required this.session,
    required this.userId,
    required this.embeddingService,
  });

  /// Execute a tool call and return the result as JSON string
  Future<String> executeTool(String toolName, Map<String, dynamic> args) async {
    switch (toolName) {
      case 'query_sleep_history':
        return await _querySleepHistory(args);
      case 'search_memories':
        return await _searchMemories(args);
      case 'execute_action':
        return await _executeAction(args);
      default:
        return jsonEncode({'error': 'Unknown tool: $toolName'});
    }
  }

  /// Query sleep history for the user
  Future<String> _querySleepHistory(Map<String, dynamic> args) async {
    final days = args['days'] as int? ?? 7;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    final sessions = await SleepSession.db.find(
      session,
      where: (t) => t.userId.equals(userId) & (t.sessionDate > cutoffDate),
      orderBy: (t) => t.sessionDate,
      orderDescending: true,
      limit: days,
    );

    if (sessions.isEmpty) {
      return jsonEncode({
        'message': 'No sleep data found for the last $days days',
        'sessions': [],
      });
    }

    // Calculate statistics
    final totalSessions = sessions.length;
    final avgQuality = sessions
            .where((s) => s.sleepQuality != null)
            .map((s) => s.sleepQuality!)
            .fold(0, (a, b) => a + b) /
        totalSessions;

    final avgInterruptions = sessions
            .where((s) => s.interruptions != null)
            .map((s) => s.interruptions!)
            .fold(0, (a, b) => a + b) /
        totalSessions;

    final sessionsData = sessions.map((s) {
      final duration = s.wakeTime != null
          ? s.wakeTime!.difference(s.bedTime).inMinutes
          : 0;

      return {
        'date': s.sessionDate.toIso8601String(),
        'quality': s.sleepQuality,
        'duration_minutes': duration,
        'interruptions': s.interruptions,
        'deep_sleep_minutes': s.deepSleepDuration,
        'rem_sleep_minutes': s.remSleepDuration,
        'mood': s.morningMood,
        'used_butler': s.usedButler,
      };
    }).toList();

    return jsonEncode({
      'summary': {
        'total_sessions': totalSessions,
        'avg_quality': avgQuality.toStringAsFixed(1),
        'avg_interruptions': avgInterruptions.toStringAsFixed(1),
        'days_analyzed': days,
      },
      'sessions': sessionsData,
    });
  }

  /// Search through journal entries and chat history using vector similarity
  Future<String> _searchMemories(Map<String, dynamic> args) async {
    final query = args['query'] as String;
    final limit = args['limit'] as int? ?? 5;

    // Generate embedding for the search query
    final queryEmbedding = await embeddingService.generateQueryEmbedding(query);
    final embeddingStr = '[${queryEmbedding.join(',')}]';

    // Search journal entries using vector similarity
    final journalResults = await session.db.unsafeQuery(
      '''
      SELECT "id", "userId", "title", "content", "mood", "entryDate", "tags",
             ("embedding" <=> '$embeddingStr'::vector) as "distance"
      FROM "journal_entries"
      WHERE "userId" = $userId AND "embedding" IS NOT NULL
      ORDER BY "embedding" <=> '$embeddingStr'::vector
      LIMIT $limit
      ''',
    );

    // Search chat messages using vector similarity
    final chatResults = await session.db.unsafeQuery(
      '''
      SELECT "sessionId", "role", "content", "timestamp",
             ("embedding" <=> '$embeddingStr'::vector) as "distance"
      FROM "chat_messages"
      WHERE "userId" = $userId AND "embedding" IS NOT NULL AND "role" = 'user'
      ORDER BY "embedding" <=> '$embeddingStr'::vector
      LIMIT $limit
      ''',
    );

    // Debug logging for rows
    try {
      final journalMapped = journalResults.map((row) {
        // print('Journal Row: $row');
        return {
          'date': (row[5] as DateTime).toIso8601String(),
          'title': row[2],
          'content': row[3],
          'mood': row[4],
          'tags': row[6],
          'relevance': (1 - (row[7] as double)).toStringAsFixed(2),
        };
      }).toList();

      final chatMapped = chatResults.map((row) {
        // print('Chat Row: $row');
        return {
          'timestamp': (row[3] as DateTime).toIso8601String(),
          'content': row[2],
          'relevance': (1 - (row[4] as double)).toStringAsFixed(2),
        };
      }).toList();

      final memories = {
        'query': query,
        'journal_entries': journalMapped,
        'past_conversations': chatMapped,
      };
      
      return jsonEncode(memories);
    } catch (e, st) {
      print('ERROR encoding memories: $e');
      print('Stack trace: $st');
      rethrow;
    }
  }

  /// Execute an action (returns action object for client to handle)
  Future<String> _executeAction(Map<String, dynamic> args) async {
    final command = args['command'] as String;
    final parameters = args['parameters'] as Map<String, dynamic>? ?? {};

    // Validate command
    final validCommands = ['play_sound', 'set_reminder', 'save_thought', 'update_goal'];
    if (!validCommands.contains(command)) {
      return jsonEncode({
        'error': 'Invalid command: $command',
        'valid_commands': validCommands,
      });
    }

    // Return action details for client execution
    return jsonEncode({
      'action_queued': true,
      'command': command,
      'parameters': parameters,
      'message': 'Action will be executed on the client',
    });
  }
}
