/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class ChatMessage implements _i1.SerializableModel {
  ChatMessage._({
    this.id,
    required this.sessionId,
    required this.userId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.embedding,
    this.widgetType,
    this.widgetData,
  });

  factory ChatMessage({
    int? id,
    required String sessionId,
    required int userId,
    required String role,
    required String content,
    required DateTime timestamp,
    _i1.Vector? embedding,
    String? widgetType,
    String? widgetData,
  }) = _ChatMessageImpl;

  factory ChatMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatMessage(
      id: jsonSerialization['id'] as int?,
      sessionId: jsonSerialization['sessionId'] as String,
      userId: jsonSerialization['userId'] as int,
      role: jsonSerialization['role'] as String,
      content: jsonSerialization['content'] as String,
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
      embedding: jsonSerialization['embedding'] == null
          ? null
          : _i1.VectorJsonExtension.fromJson(jsonSerialization['embedding']),
      widgetType: jsonSerialization['widgetType'] as String?,
      widgetData: jsonSerialization['widgetData'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String sessionId;

  int userId;

  String role;

  String content;

  DateTime timestamp;

  _i1.Vector? embedding;

  String? widgetType;

  String? widgetData;

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatMessage copyWith({
    int? id,
    String? sessionId,
    int? userId,
    String? role,
    String? content,
    DateTime? timestamp,
    _i1.Vector? embedding,
    String? widgetType,
    String? widgetData,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatMessage',
      if (id != null) 'id': id,
      'sessionId': sessionId,
      'userId': userId,
      'role': role,
      'content': content,
      'timestamp': timestamp.toJson(),
      if (embedding != null) 'embedding': embedding?.toJson(),
      if (widgetType != null) 'widgetType': widgetType,
      if (widgetData != null) 'widgetData': widgetData,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatMessageImpl extends ChatMessage {
  _ChatMessageImpl({
    int? id,
    required String sessionId,
    required int userId,
    required String role,
    required String content,
    required DateTime timestamp,
    _i1.Vector? embedding,
    String? widgetType,
    String? widgetData,
  }) : super._(
         id: id,
         sessionId: sessionId,
         userId: userId,
         role: role,
         content: content,
         timestamp: timestamp,
         embedding: embedding,
         widgetType: widgetType,
         widgetData: widgetData,
       );

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatMessage copyWith({
    Object? id = _Undefined,
    String? sessionId,
    int? userId,
    String? role,
    String? content,
    DateTime? timestamp,
    Object? embedding = _Undefined,
    Object? widgetType = _Undefined,
    Object? widgetData = _Undefined,
  }) {
    return ChatMessage(
      id: id is int? ? id : this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      embedding: embedding is _i1.Vector? ? embedding : this.embedding?.clone(),
      widgetType: widgetType is String? ? widgetType : this.widgetType,
      widgetData: widgetData is String? ? widgetData : this.widgetData,
    );
  }
}
