import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final GenerativeModel model;

  final String _apiKey;

  GeminiService(String apiKey)
    : _apiKey = apiKey,
      model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> sendMessage({
    required String systemPrompt,
    required String userMessage,
  }) async {
    final prompt = '$systemPrompt\n\nUser: $userMessage';
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }
}
