import 'dart:io';

import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/gemini_service.dart';

/// Core thought clearing endpoint - processes user thoughts through AI
class ThoughtClearingEndpoint extends Endpoint {
  GeminiService? _geminiService;

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

  /// Process a user's thought through AI and return categorized response
  Future<ThoughtResponse> processThought(
    Session session,
    int userId,
    String userMessage,
    String sessionId,
    int currentReadiness,
  ) async {
    // Build CBT-I system prompt
    final systemPrompt = _buildSystemPrompt(currentReadiness);

    // Get AI response
    final gemini = _getGeminiService(session);
    final aiResponse = await gemini.sendMessage(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
    );

    // Extract category from response
    final category = _extractCategory(userMessage, aiResponse);

    // Calculate readiness increase
    final readinessIncrease = _calculateReadinessIncrease(category);

    // Save user message
    await ChatMessage.db.insertRow(
      session,
      ChatMessage(
        sessionId: sessionId,
        userId: userId,
        role: 'user',
        content: userMessage,
        timestamp: DateTime.now(),
      ),
    );

    // Save AI response
    await ChatMessage.db.insertRow(
      session,
      ChatMessage(
        sessionId: sessionId,
        userId: userId,
        role: 'assistant',
        content: aiResponse,
        timestamp: DateTime.now(),
      ),
    );

    // Log thought
    await ThoughtLog.db.insertRow(
      session,
      ThoughtLog(
        userId: userId,
        category: category,
        content: userMessage,
        timestamp: DateTime.now(),
        resolved: false,
        readinessIncrease: readinessIncrease,
      ),
    );

    return ThoughtResponse(
      message: aiResponse,
      category: category,
      newReadiness: (currentReadiness + readinessIncrease).clamp(0, 100),
    );
  }

  /// Get conversation history for a session
  Future<List<ChatMessage>> getSessionHistory(
    Session session,
    String sessionId,
  ) async {
    return await ChatMessage.db.find(
      session,
      where: (t) => t.sessionId.equals(sessionId),
      orderBy: (t) => t.timestamp,
    );
  }

  /// Build CBT-I based system prompt
  String _buildSystemPrompt(int currentReadiness) {
    return '''
You are Insomnia Butler, an AI sleep coach trained in CBT-I (Cognitive Behavioral Therapy for Insomnia).

Your goal: Help users clear their racing thoughts so they can sleep.

RULES:
1. Be warm but concise (this is 2 AM, they're tired)
2. Use the Socratic method - guide, don't lecture
3. Always ask: "Can you solve this right now?"
4. Help them create tomorrow-actions for tonight-worries
5. End with a closure statement
6. NEVER provide medical advice
7. If detecting crisis language → provide helpline resources

Current sleep readiness: $currentReadiness%

Respond in a caring, conversational tone. Keep responses under 100 words.
''';
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
