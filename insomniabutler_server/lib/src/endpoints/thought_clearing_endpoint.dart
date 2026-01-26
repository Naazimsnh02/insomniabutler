import 'dart:io';
import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart' as protocol;
import '../services/gemini_service.dart';
import '../services/embedding_service.dart';
import '../services/tool_executor.dart';
import '../services/sound_mapping_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as ai;

/// Core thought clearing endpoint - processes user thoughts through AI
class ThoughtClearingEndpoint extends Endpoint {
  GeminiService? _geminiService;
  EmbeddingService? _embeddingService;

  /// Get or create Gemini service instance
  GeminiService _getGeminiService(Session session) {
    if (_geminiService != null) return _geminiService!;

    // Get API key from passwords or environment
    var apiKey = session.passwords['geminiApiKey'];
    if (apiKey == null || apiKey.isEmpty) {
      apiKey = Platform.environment['GEMINI_API_KEY'];
    }

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'Gemini API key not found in passwords.yaml or environment variables',
      );
    }

    _geminiService = GeminiService(apiKey);
    return _geminiService!;
  }

  /// Get or create Embedding service instance
  EmbeddingService _getEmbeddingService(Session session) {
    if (_embeddingService != null) return _embeddingService!;

    var apiKey = session.passwords['geminiApiKey'];
    if (apiKey == null || apiKey.isEmpty) {
      apiKey = Platform.environment['GEMINI_API_KEY'];
    }

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not found');
    }

    _embeddingService = EmbeddingService(apiKey);
    return _embeddingService!;
  }

  /// Process a user's thought through AI and return categorized response
  Future<protocol.ThoughtResponse> processThought(
    Session session,
    int userId,
    String userMessage,
    String sessionId,
    int currentReadiness, {
    DateTime? userLocalTime,
  }) async {
    final gemini = _getGeminiService(session);
    final embeddingService = _getEmbeddingService(session);
    final toolExecutor = ToolExecutor(
      session: session,
      userId: userId,
      embeddingService: embeddingService,
    );

    // 1. Fetch conversation history
    final history = await _buildConversationHistory(session, sessionId);

    // Contextualize message with time if available
    String messageToSend = userMessage;
    if (userLocalTime != null) {
      final hour = userLocalTime.hour;
      final minute = userLocalTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      // Provide both human readable and ISO 8601 for the AI
      messageToSend =
          "[User Local Time: $formattedHour:$minute $period, ISO: ${userLocalTime.toIso8601String()}]\n$userMessage";
    }

    // 2. Generate embedding for user message (semantic memory)
    List<double>? userEmbedding;
    try {
      userEmbedding = await embeddingService.generateEmbedding(userMessage);
    } catch (e) {
      session.log('Failed to generate user embedding: $e');
    }

    // 3. Save user message immediately (so history is updated)
    await protocol.ChatMessage.db.insertRow(
      session,
      protocol.ChatMessage(
        sessionId: sessionId,
        userId: userId,
        role: 'user',
        content: userMessage,
        timestamp: DateTime.now(),
        embedding: userEmbedding != null ? Vector(userEmbedding) : null,
      ),
    );

    // 4. Gather User Context (Optimized for performance)
    final contextBuilder = StringBuffer();

    // recent journals
    try {
      final recentJournals = await protocol.JournalEntry.db.find(
        session,
        where: (t) => t.userId.equals(userId),
        limit: 3,
        orderBy: (t) => t.entryDate,
        orderDescending: true,
      );
      if (recentJournals.isNotEmpty) {
        contextBuilder.writeln("Recent Journal Entries:");
        for (var j in recentJournals) {
          contextBuilder.writeln(
            "- ${j.entryDate.toString().split(' ')[0]} (${j.mood ?? 'No mood'}): ${j.title ?? 'Untitled'}",
          );
        }
      }
    } catch (_) {}

    if (contextBuilder.isNotEmpty) {
      messageToSend =
          '''
[SYSTEM CONTEXT START]
${contextBuilder.toString()}
[SYSTEM CONTEXT END]

User Query: $messageToSend
''';
    }

    // 4. Send to Gemini with history and tools
    final response = await gemini.sendMessageWithHistory(
      history: history,
      userMessage: messageToSend,
    );

    // 5. Tool execution loop
    String finalMessage = '';
    protocol.AIAction? aiAction;

    if (response.candidates.isNotEmpty) {
      final candidate = response.candidates.first;
      final chat = gemini.model.startChat(history: history);

      // Handle potential function calls
      for (final part in candidate.content.parts) {
        if (part is ai.TextPart) {
          finalMessage += part.text;
        } else if (part is ai.FunctionCall) {
          session.log('AI requested tool: ${part.name}');
          final result = await toolExecutor.executeTool(part.name, part.args);

          // Send tool result back to model for final response
          final followUp = await chat.sendMessage(
            ai.Content('function', [
              ai.FunctionResponse(
                part.name,
                jsonDecode(result) as Map<String, dynamic>,
              ),
            ]),
          );

          finalMessage = followUp.text ?? '';

          // If the tool execution queued an action for the client, capture it
          final decodedResult = jsonDecode(result);
          if (decodedResult is Map<String, dynamic> &&
              decodedResult['action_queued'] == true) {
            aiAction = protocol.AIAction(
              command: decodedResult['command'],
              parameters: jsonEncode(decodedResult['parameters']),
              description: decodedResult['message'],
            );
          }
        }
      }
    }

    if (finalMessage.isEmpty) {
      finalMessage = response.text ?? 'I am here to help you rest.';
    }

    // 6. Generate embedding for AI response
    List<double>? aiEmbedding;
    try {
      aiEmbedding = await embeddingService.generateEmbedding(finalMessage);
    } catch (e) {
      session.log('Failed to generate AI embedding: $e');
    }

    // 7. Map AI action to widget for persistence if needed
    String? widgetType;
    String? widgetData;

    if (aiAction != null) {
      switch (aiAction.command) {
        case 'play_sound':
          widgetType = 'sound_card';
          // Extract sound name from parameters and get full metadata
          final params = jsonDecode(aiAction.parameters!);
          final soundName = params['sound_name'] as String?;

          if (soundName != null) {
            final soundMetadata = SoundMappingService.getSoundMetadata(
              soundName,
            );
            if (soundMetadata != null) {
              widgetData = jsonEncode({
                'sound_title': soundMetadata['title'],
                'sound_image': soundMetadata['imagePath'],
                'category': soundMetadata['category'],
                'sound_id': soundMetadata['id'],
              });
            } else {
              // Fallback if sound not found
              widgetData = jsonEncode({
                'sound_title': soundName,
                'sound_image': null,
                'category': 'Unknown',
                'sound_id': '0',
              });
            }
          }
          break;
        case 'set_reminder':
          widgetType = 'reminder_card';
          widgetData = aiAction.parameters;
          break;
        case 'start_breathing_exercise':
          widgetType = 'breathing_exercise';
          widgetData = aiAction.parameters;
          break;
      }
    }

    // 8. Save AI response
    await protocol.ChatMessage.db.insertRow(
      session,
      protocol.ChatMessage(
        sessionId: sessionId,
        userId: userId,
        role: 'assistant',
        content: finalMessage,
        timestamp: DateTime.now(),
        embedding: aiEmbedding != null ? Vector(aiEmbedding) : null,
        widgetType: widgetType,
        widgetData: widgetData,
      ),
    );

    // 8. Extract category and readiness (legacy logic for back-compat)
    final category = _extractCategory(userMessage, finalMessage);
    final readinessIncrease = _calculateReadinessIncrease(category);

    // Log thought
    await protocol.ThoughtLog.db.insertRow(
      session,
      protocol.ThoughtLog(
        userId: userId,
        category: category,
        content: userMessage,
        timestamp: DateTime.now(),
        resolved: false,
        readinessIncrease: readinessIncrease,
      ),
    );

    return protocol.ThoughtResponse(
      message: finalMessage,
      category: category,
      newReadiness: (currentReadiness + readinessIncrease).clamp(0, 100),
      action: aiAction,
      metadata: null,
    );
  }

  /// Build structured conversation history for Gemini
  Future<List<ai.Content>> _buildConversationHistory(
    Session session,
    String sessionId,
  ) async {
    final messages = await protocol.ChatMessage.db.find(
      session,
      where: (t) => t.sessionId.equals(sessionId),
      orderBy: (t) => t.timestamp,
      limit: 20,
    );

    final List<ai.Content> history = [];
    String? currentRole;
    StringBuffer? currentContent;

    for (final m in messages) {
      // Map 'assistant' to 'model' for Gemini
      final role = (m.role == 'user') ? 'user' : 'model';
      final content = m.content.trim().isEmpty ? '.' : m.content;

      if (currentRole == role) {
        // Merge consecutive messages of same role
        currentContent?.writeln('\n$content');
      } else {
        // Push previous message if exists
        if (currentRole != null && currentContent != null) {
          if (currentRole == 'user') {
            history.add(ai.Content.text(currentContent.toString()));
          } else {
            history.add(
              ai.Content.model([ai.TextPart(currentContent.toString())]),
            );
          }
        }
        // Start new block
        currentRole = role;
        currentContent = StringBuffer(content);
      }
    }

    // Push final message
    if (currentRole != null && currentContent != null) {
      if (currentRole == 'user') {
        history.add(ai.Content.text(currentContent.toString()));
      } else {
        history.add(ai.Content.model([ai.TextPart(currentContent.toString())]));
      }
    }

    return history;
  }

  /// Get conversation history for a session
  Future<List<protocol.ChatMessage>> getChatSessionMessages(
    Session session,
    String sessionId,
  ) async {
    return await protocol.ChatMessage.db.find(
      session,
      where: (t) => t.sessionId.equals(sessionId),
      orderBy: (t) => t.timestamp,
    );
  }

  /// Get list of all chat sessions for a user
  Future<List<protocol.ChatSessionInfo>> getChatHistory(
    Session session,
    int userId,
  ) async {
    final messages = await protocol.ChatMessage.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.timestamp,
      orderDescending: true,
    );

    final Map<String, List<protocol.ChatMessage>> grouped = {};
    for (var m in messages) {
      grouped.putIfAbsent(m.sessionId, () => []).add(m);
    }

    final List<protocol.ChatSessionInfo> history = [];
    grouped.forEach((sessionId, sessionMessages) {
      // sessionMessages are sorted descending (latest first) due to the query
      final latestMessage = sessionMessages.first;
      final earliestMessage = sessionMessages.last;

      history.add(
        protocol.ChatSessionInfo(
          sessionId: sessionId,
          startTime: earliestMessage.timestamp,
          lastMessage: latestMessage.content,
          messageCount: sessionMessages.length,
        ),
      );
    });

    // Sort history by startTime descending
    history.sort((a, b) => b.startTime.compareTo(a.startTime));

    return history;
  }

  /// Delete a chat session and all its messages
  Future<bool> deleteChatSession(
    Session session,
    int userId,
    String sessionId,
  ) async {
    try {
      // Delete all messages in the session
      await protocol.ChatMessage.db.deleteWhere(
        session,
        where: (t) => t.sessionId.equals(sessionId) & t.userId.equals(userId),
      );
      return true;
    } catch (e) {
      session.log('Error deleting chat session: $e');
      return false;
    }
  }

  /// Extract thought category from user message and AI response
  String _extractCategory(String userMessage, String aiResponse) {
    // Combine both for better categorization
    final combined = '${userMessage.toLowerCase()} ${aiResponse.toLowerCase()}';

    // Priority-based categorization
    if (combined.contains('work') ||
        combined.contains('job') ||
        combined.contains('presentation') ||
        combined.contains('meeting') ||
        combined.contains('deadline')) {
      return 'work';
    }

    if (combined.contains('relationship') ||
        combined.contains('social') ||
        combined.contains('friend') ||
        combined.contains('family') ||
        combined.contains('argument')) {
      return 'social';
    }

    if (combined.contains('health') ||
        combined.contains('anxiety') ||
        combined.contains('worry') ||
        combined.contains('stress')) {
      return 'health';
    }

    if (combined.contains('future') ||
        combined.contains('tomorrow') ||
        combined.contains('plan') ||
        combined.contains('schedule')) {
      return 'planning';
    }

    if (combined.contains('money') ||
        combined.contains('financial') ||
        combined.contains('budget')) {
      return 'financial';
    }

    return 'general';
  }

  /// Calculate sleep readiness increase based on category
  int _calculateReadinessIncrease(String category) {
    switch (category) {
      case 'work':
        return 15;
      case 'social':
        return 12;
      case 'health':
        return 10;
      case 'planning':
        return 18;
      case 'financial':
        return 14;
      default:
        return 10;
    }
  }
}
