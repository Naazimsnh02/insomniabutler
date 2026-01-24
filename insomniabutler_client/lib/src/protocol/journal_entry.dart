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

abstract class JournalEntry implements _i1.SerializableModel {
  JournalEntry._({
    this.id,
    required this.userId,
    this.title,
    required this.content,
    this.mood,
    this.sleepSessionId,
    this.tags,
    bool? isFavorite,
    required this.createdAt,
    required this.updatedAt,
    required this.entryDate,
    this.embedding,
  }) : isFavorite = isFavorite ?? false;

  factory JournalEntry({
    int? id,
    required int userId,
    String? title,
    required String content,
    String? mood,
    int? sleepSessionId,
    String? tags,
    bool? isFavorite,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime entryDate,
    _i1.Vector? embedding,
  }) = _JournalEntryImpl;

  factory JournalEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return JournalEntry(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      title: jsonSerialization['title'] as String?,
      content: jsonSerialization['content'] as String,
      mood: jsonSerialization['mood'] as String?,
      sleepSessionId: jsonSerialization['sleepSessionId'] as int?,
      tags: jsonSerialization['tags'] as String?,
      isFavorite: jsonSerialization['isFavorite'] as bool?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      entryDate: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['entryDate'],
      ),
      embedding: jsonSerialization['embedding'] == null
          ? null
          : _i1.VectorJsonExtension.fromJson(jsonSerialization['embedding']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userId;

  String? title;

  String content;

  String? mood;

  int? sleepSessionId;

  String? tags;

  bool isFavorite;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime entryDate;

  _i1.Vector? embedding;

  /// Returns a shallow copy of this [JournalEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  JournalEntry copyWith({
    int? id,
    int? userId,
    String? title,
    String? content,
    String? mood,
    int? sleepSessionId,
    String? tags,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? entryDate,
    _i1.Vector? embedding,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'JournalEntry',
      if (id != null) 'id': id,
      'userId': userId,
      if (title != null) 'title': title,
      'content': content,
      if (mood != null) 'mood': mood,
      if (sleepSessionId != null) 'sleepSessionId': sleepSessionId,
      if (tags != null) 'tags': tags,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'entryDate': entryDate.toJson(),
      if (embedding != null) 'embedding': embedding?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _JournalEntryImpl extends JournalEntry {
  _JournalEntryImpl({
    int? id,
    required int userId,
    String? title,
    required String content,
    String? mood,
    int? sleepSessionId,
    String? tags,
    bool? isFavorite,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime entryDate,
    _i1.Vector? embedding,
  }) : super._(
         id: id,
         userId: userId,
         title: title,
         content: content,
         mood: mood,
         sleepSessionId: sleepSessionId,
         tags: tags,
         isFavorite: isFavorite,
         createdAt: createdAt,
         updatedAt: updatedAt,
         entryDate: entryDate,
         embedding: embedding,
       );

  /// Returns a shallow copy of this [JournalEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  JournalEntry copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? title = _Undefined,
    String? content,
    Object? mood = _Undefined,
    Object? sleepSessionId = _Undefined,
    Object? tags = _Undefined,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? entryDate,
    Object? embedding = _Undefined,
  }) {
    return JournalEntry(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      title: title is String? ? title : this.title,
      content: content ?? this.content,
      mood: mood is String? ? mood : this.mood,
      sleepSessionId: sleepSessionId is int?
          ? sleepSessionId
          : this.sleepSessionId,
      tags: tags is String? ? tags : this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      entryDate: entryDate ?? this.entryDate,
      embedding: embedding is _i1.Vector? ? embedding : this.embedding?.clone(),
    );
  }
}
