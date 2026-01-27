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

abstract class User implements _i1.SerializableModel {
  User._({
    this.id,
    required this.email,
    required this.name,
    this.sleepGoal,
    this.bedtimePreference,
    required this.sleepInsightsEnabled,
    this.sleepInsightsTime,
    required this.journalInsightsEnabled,
    this.journalInsightsTime,
    required this.createdAt,
  });

  factory User({
    int? id,
    required String email,
    required String name,
    String? sleepGoal,
    DateTime? bedtimePreference,
    required bool sleepInsightsEnabled,
    String? sleepInsightsTime,
    required bool journalInsightsEnabled,
    String? journalInsightsTime,
    required DateTime createdAt,
  }) = _UserImpl;

  factory User.fromJson(Map<String, dynamic> jsonSerialization) {
    return User(
      id: jsonSerialization['id'] as int?,
      email: jsonSerialization['email'] as String,
      name: jsonSerialization['name'] as String,
      sleepGoal: jsonSerialization['sleepGoal'] as String?,
      bedtimePreference: jsonSerialization['bedtimePreference'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['bedtimePreference'],
            ),
      sleepInsightsEnabled: jsonSerialization['sleepInsightsEnabled'] as bool,
      sleepInsightsTime: jsonSerialization['sleepInsightsTime'] as String?,
      journalInsightsEnabled:
          jsonSerialization['journalInsightsEnabled'] as bool,
      journalInsightsTime: jsonSerialization['journalInsightsTime'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String email;

  String name;

  String? sleepGoal;

  DateTime? bedtimePreference;

  bool sleepInsightsEnabled;

  String? sleepInsightsTime;

  bool journalInsightsEnabled;

  String? journalInsightsTime;

  DateTime createdAt;

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  User copyWith({
    int? id,
    String? email,
    String? name,
    String? sleepGoal,
    DateTime? bedtimePreference,
    bool? sleepInsightsEnabled,
    String? sleepInsightsTime,
    bool? journalInsightsEnabled,
    String? journalInsightsTime,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'User',
      if (id != null) 'id': id,
      'email': email,
      'name': name,
      if (sleepGoal != null) 'sleepGoal': sleepGoal,
      if (bedtimePreference != null)
        'bedtimePreference': bedtimePreference?.toJson(),
      'sleepInsightsEnabled': sleepInsightsEnabled,
      if (sleepInsightsTime != null) 'sleepInsightsTime': sleepInsightsTime,
      'journalInsightsEnabled': journalInsightsEnabled,
      if (journalInsightsTime != null)
        'journalInsightsTime': journalInsightsTime,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserImpl extends User {
  _UserImpl({
    int? id,
    required String email,
    required String name,
    String? sleepGoal,
    DateTime? bedtimePreference,
    required bool sleepInsightsEnabled,
    String? sleepInsightsTime,
    required bool journalInsightsEnabled,
    String? journalInsightsTime,
    required DateTime createdAt,
  }) : super._(
         id: id,
         email: email,
         name: name,
         sleepGoal: sleepGoal,
         bedtimePreference: bedtimePreference,
         sleepInsightsEnabled: sleepInsightsEnabled,
         sleepInsightsTime: sleepInsightsTime,
         journalInsightsEnabled: journalInsightsEnabled,
         journalInsightsTime: journalInsightsTime,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  User copyWith({
    Object? id = _Undefined,
    String? email,
    String? name,
    Object? sleepGoal = _Undefined,
    Object? bedtimePreference = _Undefined,
    bool? sleepInsightsEnabled,
    Object? sleepInsightsTime = _Undefined,
    bool? journalInsightsEnabled,
    Object? journalInsightsTime = _Undefined,
    DateTime? createdAt,
  }) {
    return User(
      id: id is int? ? id : this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      sleepGoal: sleepGoal is String? ? sleepGoal : this.sleepGoal,
      bedtimePreference: bedtimePreference is DateTime?
          ? bedtimePreference
          : this.bedtimePreference,
      sleepInsightsEnabled: sleepInsightsEnabled ?? this.sleepInsightsEnabled,
      sleepInsightsTime: sleepInsightsTime is String?
          ? sleepInsightsTime
          : this.sleepInsightsTime,
      journalInsightsEnabled:
          journalInsightsEnabled ?? this.journalInsightsEnabled,
      journalInsightsTime: journalInsightsTime is String?
          ? journalInsightsTime
          : this.journalInsightsTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
