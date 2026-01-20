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

abstract class JournalEntry
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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
    );
  }

  static final t = JournalEntryTable();

  static const db = JournalEntryRepository._();

  @override
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

  @override
  _i1.Table<int?> get table => t;

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
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
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
    };
  }

  static JournalEntryInclude include() {
    return JournalEntryInclude._();
  }

  static JournalEntryIncludeList includeList({
    _i1.WhereExpressionBuilder<JournalEntryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<JournalEntryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<JournalEntryTable>? orderByList,
    JournalEntryInclude? include,
  }) {
    return JournalEntryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(JournalEntry.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(JournalEntry.t),
      include: include,
    );
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
    );
  }
}

class JournalEntryUpdateTable extends _i1.UpdateTable<JournalEntryTable> {
  JournalEntryUpdateTable(super.table);

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<String, String> title(String? value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<String, String> content(String value) => _i1.ColumnValue(
    table.content,
    value,
  );

  _i1.ColumnValue<String, String> mood(String? value) => _i1.ColumnValue(
    table.mood,
    value,
  );

  _i1.ColumnValue<int, int> sleepSessionId(int? value) => _i1.ColumnValue(
    table.sleepSessionId,
    value,
  );

  _i1.ColumnValue<String, String> tags(String? value) => _i1.ColumnValue(
    table.tags,
    value,
  );

  _i1.ColumnValue<bool, bool> isFavorite(bool value) => _i1.ColumnValue(
    table.isFavorite,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> entryDate(DateTime value) =>
      _i1.ColumnValue(
        table.entryDate,
        value,
      );
}

class JournalEntryTable extends _i1.Table<int?> {
  JournalEntryTable({super.tableRelation})
    : super(tableName: 'journal_entries') {
    updateTable = JournalEntryUpdateTable(this);
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    content = _i1.ColumnString(
      'content',
      this,
    );
    mood = _i1.ColumnString(
      'mood',
      this,
    );
    sleepSessionId = _i1.ColumnInt(
      'sleepSessionId',
      this,
    );
    tags = _i1.ColumnString(
      'tags',
      this,
    );
    isFavorite = _i1.ColumnBool(
      'isFavorite',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
    entryDate = _i1.ColumnDateTime(
      'entryDate',
      this,
    );
  }

  late final JournalEntryUpdateTable updateTable;

  late final _i1.ColumnInt userId;

  late final _i1.ColumnString title;

  late final _i1.ColumnString content;

  late final _i1.ColumnString mood;

  late final _i1.ColumnInt sleepSessionId;

  late final _i1.ColumnString tags;

  late final _i1.ColumnBool isFavorite;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnDateTime entryDate;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    title,
    content,
    mood,
    sleepSessionId,
    tags,
    isFavorite,
    createdAt,
    updatedAt,
    entryDate,
  ];
}

class JournalEntryInclude extends _i1.IncludeObject {
  JournalEntryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => JournalEntry.t;
}

class JournalEntryIncludeList extends _i1.IncludeList {
  JournalEntryIncludeList._({
    _i1.WhereExpressionBuilder<JournalEntryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(JournalEntry.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => JournalEntry.t;
}

class JournalEntryRepository {
  const JournalEntryRepository._();

  /// Returns a list of [JournalEntry]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<JournalEntry>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<JournalEntryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<JournalEntryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<JournalEntryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<JournalEntry>(
      where: where?.call(JournalEntry.t),
      orderBy: orderBy?.call(JournalEntry.t),
      orderByList: orderByList?.call(JournalEntry.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [JournalEntry] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<JournalEntry?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<JournalEntryTable>? where,
    int? offset,
    _i1.OrderByBuilder<JournalEntryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<JournalEntryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<JournalEntry>(
      where: where?.call(JournalEntry.t),
      orderBy: orderBy?.call(JournalEntry.t),
      orderByList: orderByList?.call(JournalEntry.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [JournalEntry] by its [id] or null if no such row exists.
  Future<JournalEntry?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<JournalEntry>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [JournalEntry]s in the list and returns the inserted rows.
  ///
  /// The returned [JournalEntry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<JournalEntry>> insert(
    _i1.Session session,
    List<JournalEntry> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<JournalEntry>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [JournalEntry] and returns the inserted row.
  ///
  /// The returned [JournalEntry] will have its `id` field set.
  Future<JournalEntry> insertRow(
    _i1.Session session,
    JournalEntry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<JournalEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [JournalEntry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<JournalEntry>> update(
    _i1.Session session,
    List<JournalEntry> rows, {
    _i1.ColumnSelections<JournalEntryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<JournalEntry>(
      rows,
      columns: columns?.call(JournalEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [JournalEntry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<JournalEntry> updateRow(
    _i1.Session session,
    JournalEntry row, {
    _i1.ColumnSelections<JournalEntryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<JournalEntry>(
      row,
      columns: columns?.call(JournalEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [JournalEntry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<JournalEntry?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<JournalEntryUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<JournalEntry>(
      id,
      columnValues: columnValues(JournalEntry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [JournalEntry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<JournalEntry>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<JournalEntryUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<JournalEntryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<JournalEntryTable>? orderBy,
    _i1.OrderByListBuilder<JournalEntryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<JournalEntry>(
      columnValues: columnValues(JournalEntry.t.updateTable),
      where: where(JournalEntry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(JournalEntry.t),
      orderByList: orderByList?.call(JournalEntry.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [JournalEntry]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<JournalEntry>> delete(
    _i1.Session session,
    List<JournalEntry> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<JournalEntry>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [JournalEntry].
  Future<JournalEntry> deleteRow(
    _i1.Session session,
    JournalEntry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<JournalEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<JournalEntry>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<JournalEntryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<JournalEntry>(
      where: where(JournalEntry.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<JournalEntryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<JournalEntry>(
      where: where?.call(JournalEntry.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
