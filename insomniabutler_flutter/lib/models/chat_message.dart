/// Represents a single message in the thought clearing chat
class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final String? category; // Optional thought category
  final String? widgetType; // e.g., 'breathing_exercise', 'sound_card'
  final Map<String, dynamic>? widgetData;
  final bool isStreaming; // True when message is being streamed

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.category,
    this.widgetType,
    this.widgetData,
    this.isStreaming = false,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  /// Create a copy of this message with updated fields
  ChatMessage copyWith({
    String? role,
    String? content,
    DateTime? timestamp,
    String? category,
    String? widgetType,
    Map<String, dynamic>? widgetData,
    bool? isStreaming,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      widgetType: widgetType ?? this.widgetType,
      widgetData: widgetData ?? this.widgetData,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }


  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      category: json['category'] as String?,
      widgetType: json['widgetType'] as String?,
      widgetData: json['widgetData'] as Map<String, dynamic>?,
      isStreaming: json['isStreaming'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'widgetType': widgetType,
      'widgetData': widgetData,
      'isStreaming': isStreaming,
    };
  }

}
