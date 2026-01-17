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

abstract class ThoughtResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ThoughtResponse._({
    required this.message,
    required this.category,
    required this.newReadiness,
  });

  factory ThoughtResponse({
    required String message,
    required String category,
    required int newReadiness,
  }) = _ThoughtResponseImpl;

  factory ThoughtResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return ThoughtResponse(
      message: jsonSerialization['message'] as String,
      category: jsonSerialization['category'] as String,
      newReadiness: jsonSerialization['newReadiness'] as int,
    );
  }

  String message;

  String category;

  int newReadiness;

  /// Returns a shallow copy of this [ThoughtResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ThoughtResponse copyWith({
    String? message,
    String? category,
    int? newReadiness,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ThoughtResponse',
      'message': message,
      'category': category,
      'newReadiness': newReadiness,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ThoughtResponse',
      'message': message,
      'category': category,
      'newReadiness': newReadiness,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ThoughtResponseImpl extends ThoughtResponse {
  _ThoughtResponseImpl({
    required String message,
    required String category,
    required int newReadiness,
  }) : super._(
         message: message,
         category: category,
         newReadiness: newReadiness,
       );

  /// Returns a shallow copy of this [ThoughtResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ThoughtResponse copyWith({
    String? message,
    String? category,
    int? newReadiness,
  }) {
    return ThoughtResponse(
      message: message ?? this.message,
      category: category ?? this.category,
      newReadiness: newReadiness ?? this.newReadiness,
    );
  }
}
