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

abstract class ThoughtLog implements _i1.SerializableModel {
  ThoughtLog._({
    this.id,
    required this.userId,
    this.sessionId,
    required this.category,
    required this.content,
    required this.timestamp,
    required this.resolved,
    required this.readinessIncrease,
  });

  factory ThoughtLog({
    int? id,
    required int userId,
    int? sessionId,
    required String category,
    required String content,
    required DateTime timestamp,
    required bool resolved,
    required int readinessIncrease,
  }) = _ThoughtLogImpl;

  factory ThoughtLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return ThoughtLog(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      sessionId: jsonSerialization['sessionId'] as int?,
      category: jsonSerialization['category'] as String,
      content: jsonSerialization['content'] as String,
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
      resolved: jsonSerialization['resolved'] as bool,
      readinessIncrease: jsonSerialization['readinessIncrease'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userId;

  int? sessionId;

  String category;

  String content;

  DateTime timestamp;

  bool resolved;

  int readinessIncrease;

  /// Returns a shallow copy of this [ThoughtLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ThoughtLog copyWith({
    int? id,
    int? userId,
    int? sessionId,
    String? category,
    String? content,
    DateTime? timestamp,
    bool? resolved,
    int? readinessIncrease,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ThoughtLog',
      if (id != null) 'id': id,
      'userId': userId,
      if (sessionId != null) 'sessionId': sessionId,
      'category': category,
      'content': content,
      'timestamp': timestamp.toJson(),
      'resolved': resolved,
      'readinessIncrease': readinessIncrease,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ThoughtLogImpl extends ThoughtLog {
  _ThoughtLogImpl({
    int? id,
    required int userId,
    int? sessionId,
    required String category,
    required String content,
    required DateTime timestamp,
    required bool resolved,
    required int readinessIncrease,
  }) : super._(
         id: id,
         userId: userId,
         sessionId: sessionId,
         category: category,
         content: content,
         timestamp: timestamp,
         resolved: resolved,
         readinessIncrease: readinessIncrease,
       );

  /// Returns a shallow copy of this [ThoughtLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ThoughtLog copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? sessionId = _Undefined,
    String? category,
    String? content,
    DateTime? timestamp,
    bool? resolved,
    int? readinessIncrease,
  }) {
    return ThoughtLog(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId is int? ? sessionId : this.sessionId,
      category: category ?? this.category,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      resolved: resolved ?? this.resolved,
      readinessIncrease: readinessIncrease ?? this.readinessIncrease,
    );
  }
}
