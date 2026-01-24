import 'package:google_generative_ai/google_generative_ai.dart';

/// Enhanced Gemini service with multi-turn conversation and function calling
class GeminiService {
  final GenerativeModel _chatModel;
  final String _apiKey;

  GenerativeModel get model => _chatModel;

  GeminiService(String apiKey)
      : _apiKey = apiKey,
        _chatModel = GenerativeModel(
          model: 'gemini-2.5-flash-lite',
          apiKey: apiKey,
          systemInstruction: Content.system(_buildSystemPrompt()),
          tools: _buildTools(),
        );

  bool get isConfigured => _apiKey.isNotEmpty;

  /// Send a message with conversation history and tool support
  Future<GenerateContentResponse> sendMessageWithHistory({
    required List<Content> history,
    required String userMessage,
  }) async {
    final chat = _chatModel.startChat(history: history);
    return await chat.sendMessage(Content.text(userMessage));
  }

  /// Build the system instruction for Insomnia Butler
  static String _buildSystemPrompt() {
    return '''
You are Insomnia Butler, an AI sleep coach trained in CBT-I (Cognitive Behavioral Therapy for Insomnia).

Your goal: Help users clear their racing thoughts so they can sleep.

CORE PRINCIPLES:
1. Be warm but concise (this is 2 AM, they're tired)
2. Use the Socratic method - guide, don't lecture
3. Always ask: "Can you solve this right now?"
4. Help them create tomorrow-actions for tonight-worries
5. End with a closure statement
6. NEVER provide medical advice
7. If detecting crisis language → provide helpline resources

AVAILABLE TOOLS:
- query_sleep_history: Get user's recent sleep data to provide personalized insights
- search_memories: Search through user's journal entries and past conversations
- execute_action: Trigger app actions like playing calming sounds

TOOL USAGE GUIDELINES:
- Use tools proactively when they would help the conversation
- If user mentions sleep problems, check their sleep history
- If user mentions past worries, search their memories
- If user seems anxious, suggest calming sounds via execute_action

Respond in a caring, conversational tone. Keep responses under 100 words unless providing detailed analysis.
''';
  }

  /// Define available tools for the AI
  static List<Tool> _buildTools() {
    return [
      Tool(functionDeclarations: [
        // Tool 1: Query sleep history
        FunctionDeclaration(
          'query_sleep_history',
          'Retrieves the user\'s recent sleep session data including quality, duration, interruptions, and sleep stages',
          Schema(
            SchemaType.object,
            properties: {
              'days': Schema(
                SchemaType.integer,
                description: 'Number of days to look back (1-30)',
              ),
            },
            requiredProperties: ['days'],
          ),
        ),

        // Tool 2: Search memories (journal + chat history)
        FunctionDeclaration(
          'search_memories',
          'Performs semantic search across user\'s journal entries and past conversations to find relevant context',
          Schema(
            SchemaType.object,
            properties: {
              'query': Schema(
                SchemaType.string,
                description: 'The topic or theme to search for (e.g., "work stress", "relationship anxiety")',
              ),
              'limit': Schema(
                SchemaType.integer,
                description: 'Maximum number of results to return (1-10)',
              ),
            },
            requiredProperties: ['query'],
          ),
        ),

        // Tool 3: Execute actions
        FunctionDeclaration(
          'execute_action',
          'Triggers an action in the mobile app such as playing a sound, setting a reminder, or logging data',
          Schema(
            SchemaType.object,
            properties: {
              'command': Schema(
                SchemaType.string,
                description: 'The action to execute',
                enumValues: [
                  'play_sound',
                  'set_reminder',
                  'save_thought',
                  'update_goal',
                ],
              ),
              'parameters': Schema(
                SchemaType.object,
                description: 'Action-specific parameters (e.g., {"sound_name": "Rain", "duration": 600})',
              ),
            },
            requiredProperties: ['command', 'parameters'],
          ),
        ),
      ]),
    ];
  }

  /// Legacy method for backward compatibility
  @deprecated
  Future<String> sendMessage({
    required String systemPrompt,
    required String userMessage,
  }) async {
    final prompt = '$systemPrompt\n\nUser: $userMessage';
    final response = await _chatModel.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }
}
