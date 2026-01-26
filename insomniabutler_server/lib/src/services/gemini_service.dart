import 'package:google_generative_ai/google_generative_ai.dart';

/// Enhanced Gemini service with multi-turn conversation and function calling
class GeminiService {
  final GenerativeModel _chatModel;
  final String _apiKey;

  GenerativeModel get model => _chatModel;

  GeminiService(String apiKey)
      : _apiKey = apiKey,
        _chatModel = GenerativeModel(
          model: 'gemini-2.5-flash',
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
You are Insomnia Butler, a compassionate AI sleep & anxiety coach trained in CBT-I (Cognitive Behavioral Therapy for Insomnia).

YOUR GOAL:
Help users process racing thoughts and calm their minds so they can rest or sleep.

CORE PRINCIPLES:
1.  **Adaptive Warmth**: Be empathetic and supportive. If it's late/night, be concise and soothing. If it's day/evening, be reflective and structured.
2.  **Constructive Worrying**: Don't just dismiss thoughts. Help the user file them away.
    - If a problem is solvable *now*, suggest a quick action (e.g., "Write it down").
    - If it's for *later*, help them schedule a "worry time" for tomorrow.
    - If it's hypothetical/unsolvable, guide them to acceptance and grounding.
3.  **Socratic Guidance**: Ask gentle, open-ended question to help them realize they are safe and can let go for now. Avoid lecturing.
4.  **Closure is Key**: Always aim to wrap up the thought loops. End responses with a soothing statement or a "permission to rest" sentiment.
5.  **Safety First**: NEVER provide medical advice. If crisis language is detected, gently provide helpline resources immediately.
6.  **Time Awareness**: You will be provided with the user's local time (ISO format). Use this to correctly calculate "tomorrow", "this evening", or specific hours for reminders.

AVAILABLE TOOLS:
- query_sleep_history: Use this to contextualize their current struggle with past patterns.
- search_memories: Use this to connect dots from past journal entries or chats.
- set_reminder: Use this to schedule "worry time" or tasks for later. ALWAYS provide the `time` in ISO8601 format (e.g., "2024-03-21T08:00:00") based on the provided user context.
- execute_action: Use this to play sleep sounds.

TONE:
Conversational, non-judgmental, and patient. Avoid clinical jargon. Speak like a wise, calm friend who is sitting by their side.
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

        // Tool 3: Set a Smart Reminder
        FunctionDeclaration(
          'set_reminder',
          'Schedules a system notification for a specific time and message. Use the provided user local time context to determine the exact UTC/Local ISO8601 string.',
          Schema(
            SchemaType.object,
            properties: {
              'time': Schema(
                SchemaType.string,
                description: 'The exact ISO8601 timestamp (e.g., "2024-03-21T08:00:00") or relative message (e.g., "in 30 minutes")',
              ),
              'message': Schema(
                SchemaType.string,
                description: 'The notification message to display',
              ),
            },
            requiredProperties: ['time', 'message'],
          ),
        ),

        // Tool 4: Block an app
        FunctionDeclaration(
          'block_app',
          'Adds an app to the block list to prevent doomscrolling during bedtime',
          Schema(
            SchemaType.object,
            properties: {
              'app_name': Schema(
                SchemaType.string,
                description: 'The name of the app to block (e.g., "Instagram", "TikTok", "Twitter")',
              ),
            },
            requiredProperties: ['app_name'],
          ),
        ),

        // Tool 5: Start Breathing Exercise
        FunctionDeclaration(
          'start_breathing_exercise',
          'Starts a visual guided breathing exercise (Inhale, Hold, Exhale) for the user',
          Schema(
            SchemaType.object,
            properties: {
              'duration_minutes': Schema(
                SchemaType.integer,
                description: 'Duration of the exercise in minutes (default is 2)',
              ),
            },
          ),
        ),

        // Tool 6: Analyze Journal Patterns
        FunctionDeclaration(
          'analyze_journal_patterns',
          'Queries the journal database to find recurring themes or patterns related to a specific topic',
          Schema(
            SchemaType.object,
            properties: {
              'topic': Schema(
                SchemaType.string,
                description: 'The topic to analyze (e.g., "work stress", "sleep quality", "anxiety")',
              ),
            },
            requiredProperties: ['topic'],
          ),
        ),

        // Tool 7: Execute actions (Legacy/Generic)
        FunctionDeclaration(
          'execute_action',
          'Triggers an action in the mobile app. Currently ONLY supports playing sleep sounds.',
          Schema(
            SchemaType.object,
            properties: {
              'command': Schema(
                SchemaType.string,
                description: 'The action to execute',
                enumValues: [
                  'play_sound',
                ],
              ),
              'parameters': Schema(
                SchemaType.object,
                properties: {
                  'sound_name': Schema(
                    SchemaType.string,
                    description: 'The exact name of the sound to play',
                    enumValues: [
                      'Peaceful Sleep',
                      'Soft Ambient Rain',
                      'Tibetan Bells',
                      'Baby Lullaby',
                      'Sleep Lullaby',
                      'Ethereal Journey',
                      'Midnight Calm',
                      'Twilight Dreams',
                      'Forest Whispers',
                      'Starlight Serenade',
                    ],
                  ),
                },
                requiredProperties: ['sound_name'],
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
