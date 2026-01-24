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
import 'ai_action.dart' as _i2;
import 'package:insomniabutler_server/src/generated/protocol.dart' as _i3;

abstract class ThoughtResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ThoughtResponse._({
    required this.message,
    required this.category,
    required this.newReadiness,
    this.action,
    this.metadata,
  });

  factory ThoughtResponse({
    required String message,
    required String category,
    required int newReadiness,
    _i2.AIAction? action,
    String? metadata,
  }) = _ThoughtResponseImpl;

  factory ThoughtResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return ThoughtResponse(
      message: jsonSerialization['message'] as String,
      category: jsonSerialization['category'] as String,
      newReadiness: jsonSerialization['newReadiness'] as int,
      action: jsonSerialization['action'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.AIAction>(
              jsonSerialization['action'],
            ),
      metadata: jsonSerialization['metadata'] as String?,
    );
  }

  String message;

  String category;

  int newReadiness;

  _i2.AIAction? action;

  String? metadata;

  /// Returns a shallow copy of this [ThoughtResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ThoughtResponse copyWith({
    String? message,
    String? category,
    int? newReadiness,
    _i2.AIAction? action,
    String? metadata,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ThoughtResponse',
      'message': message,
      'category': category,
      'newReadiness': newReadiness,
      if (action != null) 'action': action?.toJson(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ThoughtResponse',
      'message': message,
      'category': category,
      'newReadiness': newReadiness,
      if (action != null) 'action': action?.toJsonForProtocol(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ThoughtResponseImpl extends ThoughtResponse {
  _ThoughtResponseImpl({
    required String message,
    required String category,
    required int newReadiness,
    _i2.AIAction? action,
    String? metadata,
  }) : super._(
         message: message,
         category: category,
         newReadiness: newReadiness,
         action: action,
         metadata: metadata,
       );

  /// Returns a shallow copy of this [ThoughtResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ThoughtResponse copyWith({
    String? message,
    String? category,
    int? newReadiness,
    Object? action = _Undefined,
    Object? metadata = _Undefined,
  }) {
    return ThoughtResponse(
      message: message ?? this.message,
      category: category ?? this.category,
      newReadiness: newReadiness ?? this.newReadiness,
      action: action is _i2.AIAction? ? action : this.action?.copyWith(),
      metadata: metadata is String? ? metadata : this.metadata,
    );
  }
}
