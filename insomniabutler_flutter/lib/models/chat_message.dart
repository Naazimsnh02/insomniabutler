/// Represents a single message in the thought clearing chat
class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final String? category; // Optional thought category

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.category,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}
