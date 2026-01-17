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

abstract class SleepInsight implements _i1.SerializableModel {
  SleepInsight._({
    this.id,
    required this.userId,
    required this.insightType,
    required this.metric,
    required this.value,
    required this.description,
    required this.generatedAt,
  });

  factory SleepInsight({
    int? id,
    required int userId,
    required String insightType,
    required String metric,
    required double value,
    required String description,
    required DateTime generatedAt,
  }) = _SleepInsightImpl;

  factory SleepInsight.fromJson(Map<String, dynamic> jsonSerialization) {
    return SleepInsight(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      insightType: jsonSerialization['insightType'] as String,
      metric: jsonSerialization['metric'] as String,
      value: (jsonSerialization['value'] as num).toDouble(),
      description: jsonSerialization['description'] as String,
      generatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['generatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userId;

  String insightType;

  String metric;

  double value;

  String description;

  DateTime generatedAt;

  /// Returns a shallow copy of this [SleepInsight]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SleepInsight copyWith({
    int? id,
    int? userId,
    String? insightType,
    String? metric,
    double? value,
    String? description,
    DateTime? generatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SleepInsight',
      if (id != null) 'id': id,
      'userId': userId,
      'insightType': insightType,
      'metric': metric,
      'value': value,
      'description': description,
      'generatedAt': generatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SleepInsightImpl extends SleepInsight {
  _SleepInsightImpl({
    int? id,
    required int userId,
    required String insightType,
    required String metric,
    required double value,
    required String description,
    required DateTime generatedAt,
  }) : super._(
         id: id,
         userId: userId,
         insightType: insightType,
         metric: metric,
         value: value,
         description: description,
         generatedAt: generatedAt,
       );

  /// Returns a shallow copy of this [SleepInsight]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SleepInsight copyWith({
    Object? id = _Undefined,
    int? userId,
    String? insightType,
    String? metric,
    double? value,
    String? description,
    DateTime? generatedAt,
  }) {
    return SleepInsight(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      insightType: insightType ?? this.insightType,
      metric: metric ?? this.metric,
      value: value ?? this.value,
      description: description ?? this.description,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}
