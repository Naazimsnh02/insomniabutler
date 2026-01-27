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

abstract class JournalInsight implements _i1.SerializableModel {
  JournalInsight._({
    this.id,
    required this.userId,
    required this.insightType,
    required this.message,
    required this.confidence,
    this.relatedEntryIds,
    required this.generatedAt,
  });

  factory JournalInsight({
    int? id,
    required int userId,
    required String insightType,
    required String message,
    required double confidence,
    String? relatedEntryIds,
    required DateTime generatedAt,
  }) = _JournalInsightImpl;

  factory JournalInsight.fromJson(Map<String, dynamic> jsonSerialization) {
    return JournalInsight(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      insightType: jsonSerialization['insightType'] as String,
      message: jsonSerialization['message'] as String,
      confidence: (jsonSerialization['confidence'] as num).toDouble(),
      relatedEntryIds: jsonSerialization['relatedEntryIds'] as String?,
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

  String message;

  double confidence;

  String? relatedEntryIds;

  DateTime generatedAt;

  /// Returns a shallow copy of this [JournalInsight]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  JournalInsight copyWith({
    int? id,
    int? userId,
    String? insightType,
    String? message,
    double? confidence,
    String? relatedEntryIds,
    DateTime? generatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'JournalInsight',
      if (id != null) 'id': id,
      'userId': userId,
      'insightType': insightType,
      'message': message,
      'confidence': confidence,
      if (relatedEntryIds != null) 'relatedEntryIds': relatedEntryIds,
      'generatedAt': generatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _JournalInsightImpl extends JournalInsight {
  _JournalInsightImpl({
    int? id,
    required int userId,
    required String insightType,
    required String message,
    required double confidence,
    String? relatedEntryIds,
    required DateTime generatedAt,
  }) : super._(
         id: id,
         userId: userId,
         insightType: insightType,
         message: message,
         confidence: confidence,
         relatedEntryIds: relatedEntryIds,
         generatedAt: generatedAt,
       );

  /// Returns a shallow copy of this [JournalInsight]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  JournalInsight copyWith({
    Object? id = _Undefined,
    int? userId,
    String? insightType,
    String? message,
    double? confidence,
    Object? relatedEntryIds = _Undefined,
    DateTime? generatedAt,
  }) {
    return JournalInsight(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      insightType: insightType ?? this.insightType,
      message: message ?? this.message,
      confidence: confidence ?? this.confidence,
      relatedEntryIds: relatedEntryIds is String?
          ? relatedEntryIds
          : this.relatedEntryIds,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}
