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

abstract class IntWrapper
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  IntWrapper._({required this.value});

  factory IntWrapper({required int value}) = _IntWrapperImpl;

  factory IntWrapper.fromJson(Map<String, dynamic> jsonSerialization) {
    return IntWrapper(value: jsonSerialization['value'] as int);
  }

  int value;

  /// Returns a shallow copy of this [IntWrapper]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  IntWrapper copyWith({int? value});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IntWrapper',
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IntWrapper',
      'value': value,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _IntWrapperImpl extends IntWrapper {
  _IntWrapperImpl({required int value}) : super._(value: value);

  /// Returns a shallow copy of this [IntWrapper]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  IntWrapper copyWith({int? value}) {
    return IntWrapper(value: value ?? this.value);
  }
}
