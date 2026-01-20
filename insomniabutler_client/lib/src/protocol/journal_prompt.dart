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

abstract class JournalPrompt implements _i1.SerializableModel {
  JournalPrompt._({
    this.id,
    required this.category,
    required this.promptText,
    bool? isActive,
    bool? isSystemPrompt,
    required this.createdAt,
  }) : isActive = isActive ?? true,
       isSystemPrompt = isSystemPrompt ?? true;

  factory JournalPrompt({
    int? id,
    required String category,
    required String promptText,
    bool? isActive,
    bool? isSystemPrompt,
    required DateTime createdAt,
  }) = _JournalPromptImpl;

  factory JournalPrompt.fromJson(Map<String, dynamic> jsonSerialization) {
    return JournalPrompt(
      id: jsonSerialization['id'] as int?,
      category: jsonSerialization['category'] as String,
      promptText: jsonSerialization['promptText'] as String,
      isActive: jsonSerialization['isActive'] as bool?,
      isSystemPrompt: jsonSerialization['isSystemPrompt'] as bool?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String category;

  String promptText;

  bool isActive;

  bool isSystemPrompt;

  DateTime createdAt;

  /// Returns a shallow copy of this [JournalPrompt]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  JournalPrompt copyWith({
    int? id,
    String? category,
    String? promptText,
    bool? isActive,
    bool? isSystemPrompt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'JournalPrompt',
      if (id != null) 'id': id,
      'category': category,
      'promptText': promptText,
      'isActive': isActive,
      'isSystemPrompt': isSystemPrompt,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _JournalPromptImpl extends JournalPrompt {
  _JournalPromptImpl({
    int? id,
    required String category,
    required String promptText,
    bool? isActive,
    bool? isSystemPrompt,
    required DateTime createdAt,
  }) : super._(
         id: id,
         category: category,
         promptText: promptText,
         isActive: isActive,
         isSystemPrompt: isSystemPrompt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [JournalPrompt]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  JournalPrompt copyWith({
    Object? id = _Undefined,
    String? category,
    String? promptText,
    bool? isActive,
    bool? isSystemPrompt,
    DateTime? createdAt,
  }) {
    return JournalPrompt(
      id: id is int? ? id : this.id,
      category: category ?? this.category,
      promptText: promptText ?? this.promptText,
      isActive: isActive ?? this.isActive,
      isSystemPrompt: isSystemPrompt ?? this.isSystemPrompt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
