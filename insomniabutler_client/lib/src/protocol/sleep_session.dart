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

abstract class SleepSession implements _i1.SerializableModel {
  SleepSession._({
    this.id,
    required this.userId,
    required this.bedTime,
    this.wakeTime,
    this.sleepLatencyMinutes,
    required this.usedButler,
    required this.thoughtsProcessed,
    this.sleepQuality,
    this.morningMood,
    required this.sessionDate,
  });

  factory SleepSession({
    int? id,
    required int userId,
    required DateTime bedTime,
    DateTime? wakeTime,
    int? sleepLatencyMinutes,
    required bool usedButler,
    required int thoughtsProcessed,
    int? sleepQuality,
    String? morningMood,
    required DateTime sessionDate,
  }) = _SleepSessionImpl;

  factory SleepSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return SleepSession(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      bedTime: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['bedTime']),
      wakeTime: jsonSerialization['wakeTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['wakeTime']),
      sleepLatencyMinutes: jsonSerialization['sleepLatencyMinutes'] as int?,
      usedButler: jsonSerialization['usedButler'] as bool,
      thoughtsProcessed: jsonSerialization['thoughtsProcessed'] as int,
      sleepQuality: jsonSerialization['sleepQuality'] as int?,
      morningMood: jsonSerialization['morningMood'] as String?,
      sessionDate: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['sessionDate'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userId;

  DateTime bedTime;

  DateTime? wakeTime;

  int? sleepLatencyMinutes;

  bool usedButler;

  int thoughtsProcessed;

  int? sleepQuality;

  String? morningMood;

  DateTime sessionDate;

  /// Returns a shallow copy of this [SleepSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SleepSession copyWith({
    int? id,
    int? userId,
    DateTime? bedTime,
    DateTime? wakeTime,
    int? sleepLatencyMinutes,
    bool? usedButler,
    int? thoughtsProcessed,
    int? sleepQuality,
    String? morningMood,
    DateTime? sessionDate,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SleepSession',
      if (id != null) 'id': id,
      'userId': userId,
      'bedTime': bedTime.toJson(),
      if (wakeTime != null) 'wakeTime': wakeTime?.toJson(),
      if (sleepLatencyMinutes != null)
        'sleepLatencyMinutes': sleepLatencyMinutes,
      'usedButler': usedButler,
      'thoughtsProcessed': thoughtsProcessed,
      if (sleepQuality != null) 'sleepQuality': sleepQuality,
      if (morningMood != null) 'morningMood': morningMood,
      'sessionDate': sessionDate.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SleepSessionImpl extends SleepSession {
  _SleepSessionImpl({
    int? id,
    required int userId,
    required DateTime bedTime,
    DateTime? wakeTime,
    int? sleepLatencyMinutes,
    required bool usedButler,
    required int thoughtsProcessed,
    int? sleepQuality,
    String? morningMood,
    required DateTime sessionDate,
  }) : super._(
         id: id,
         userId: userId,
         bedTime: bedTime,
         wakeTime: wakeTime,
         sleepLatencyMinutes: sleepLatencyMinutes,
         usedButler: usedButler,
         thoughtsProcessed: thoughtsProcessed,
         sleepQuality: sleepQuality,
         morningMood: morningMood,
         sessionDate: sessionDate,
       );

  /// Returns a shallow copy of this [SleepSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SleepSession copyWith({
    Object? id = _Undefined,
    int? userId,
    DateTime? bedTime,
    Object? wakeTime = _Undefined,
    Object? sleepLatencyMinutes = _Undefined,
    bool? usedButler,
    int? thoughtsProcessed,
    Object? sleepQuality = _Undefined,
    Object? morningMood = _Undefined,
    DateTime? sessionDate,
  }) {
    return SleepSession(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      bedTime: bedTime ?? this.bedTime,
      wakeTime: wakeTime is DateTime? ? wakeTime : this.wakeTime,
      sleepLatencyMinutes: sleepLatencyMinutes is int?
          ? sleepLatencyMinutes
          : this.sleepLatencyMinutes,
      usedButler: usedButler ?? this.usedButler,
      thoughtsProcessed: thoughtsProcessed ?? this.thoughtsProcessed,
      sleepQuality: sleepQuality is int? ? sleepQuality : this.sleepQuality,
      morningMood: morningMood is String? ? morningMood : this.morningMood,
      sessionDate: sessionDate ?? this.sessionDate,
    );
  }
}
