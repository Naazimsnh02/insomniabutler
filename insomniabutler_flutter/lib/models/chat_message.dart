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

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
    };
  }
}
