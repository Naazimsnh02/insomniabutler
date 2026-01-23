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
import 'package:serverpod/serverpod.dart' as _i1;

abstract class ChatSessionInfo
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ChatSessionInfo._({
    required this.sessionId,
    required this.startTime,
    required this.lastMessage,
    required this.messageCount,
  });

  factory ChatSessionInfo({
    required String sessionId,
    required DateTime startTime,
    required String lastMessage,
    required int messageCount,
  }) = _ChatSessionInfoImpl;

  factory ChatSessionInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatSessionInfo(
      sessionId: jsonSerialization['sessionId'] as String,
      startTime: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['startTime'],
      ),
      lastMessage: jsonSerialization['lastMessage'] as String,
      messageCount: jsonSerialization['messageCount'] as int,
    );
  }

  String sessionId;

  DateTime startTime;

  String lastMessage;

  int messageCount;

  /// Returns a shallow copy of this [ChatSessionInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatSessionInfo copyWith({
    String? sessionId,
    DateTime? startTime,
    String? lastMessage,
    int? messageCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatSessionInfo',
      'sessionId': sessionId,
      'startTime': startTime.toJson(),
      'lastMessage': lastMessage,
      'messageCount': messageCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatSessionInfo',
      'sessionId': sessionId,
      'startTime': startTime.toJson(),
      'lastMessage': lastMessage,
      'messageCount': messageCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ChatSessionInfoImpl extends ChatSessionInfo {
  _ChatSessionInfoImpl({
    required String sessionId,
    required DateTime startTime,
    required String lastMessage,
    required int messageCount,
  }) : super._(
         sessionId: sessionId,
         startTime: startTime,
         lastMessage: lastMessage,
         messageCount: messageCount,
       );

  /// Returns a shallow copy of this [ChatSessionInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatSessionInfo copyWith({
    String? sessionId,
    DateTime? startTime,
    String? lastMessage,
    int? messageCount,
  }) {
    return ChatSessionInfo(
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      lastMessage: lastMessage ?? this.lastMessage,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}
