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

abstract class AIAction implements _i1.SerializableModel {
  AIAction._({
    required this.command,
    this.parameters,
    this.description,
  });

  factory AIAction({
    required String command,
    String? parameters,
    String? description,
  }) = _AIActionImpl;

  factory AIAction.fromJson(Map<String, dynamic> jsonSerialization) {
    return AIAction(
      command: jsonSerialization['command'] as String,
      parameters: jsonSerialization['parameters'] as String?,
      description: jsonSerialization['description'] as String?,
    );
  }

  String command;

  String? parameters;

  String? description;

  /// Returns a shallow copy of this [AIAction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AIAction copyWith({
    String? command,
    String? parameters,
    String? description,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AIAction',
      'command': command,
      if (parameters != null) 'parameters': parameters,
      if (description != null) 'description': description,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AIActionImpl extends AIAction {
  _AIActionImpl({
    required String command,
    String? parameters,
    String? description,
  }) : super._(
         command: command,
         parameters: parameters,
         description: description,
       );

  /// Returns a shallow copy of this [AIAction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AIAction copyWith({
    String? command,
    Object? parameters = _Undefined,
    Object? description = _Undefined,
  }) {
    return AIAction(
      command: command ?? this.command,
      parameters: parameters is String? ? parameters : this.parameters,
      description: description is String? ? description : this.description,
    );
  }
}
