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

abstract class JournalPrompt
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = JournalPromptTable();

  static const db = JournalPromptRepository._();

  @override
  int? id;

  String category;

  String promptText;

  bool isActive;

  bool isSystemPrompt;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static JournalPromptInclude include() {
    return JournalPromptInclude._();
  }

  static JournalPromptIncludeList includeList({
    _i1.WhereExpressionBuilder<JournalPromptTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<JournalPromptTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<JournalPromptTable>? orderByList,
    JournalPromptInclude? include,
  }) {
    return JournalPromptIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(JournalPrompt.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(JournalPrompt.t),
      include: include,
    );
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

class JournalPromptUpdateTable extends _i1.UpdateTable<JournalPromptTable> {
  JournalPromptUpdateTable(super.table);

  _i1.ColumnValue<String, String> category(String value) => _i1.ColumnValue(
    table.category,
    value,
  );

  _i1.ColumnValue<String, String> promptText(String value) => _i1.ColumnValue(
    table.promptText,
    value,
  );

  _i1.ColumnValue<bool, bool> isActive(bool value) => _i1.ColumnValue(
    table.isActive,
    value,
  );

  _i1.ColumnValue<bool, bool> isSystemPrompt(bool value) => _i1.ColumnValue(
    table.isSystemPrompt,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class JournalPromptTable extends _i1.Table<int?> {
  JournalPromptTable({super.tableRelation})
    : super(tableName: 'journal_prompts') {
    updateTable = JournalPromptUpdateTable(this);
    category = _i1.ColumnString(
      'category',
      this,
    );
    promptText = _i1.ColumnString(
      'promptText',
      this,
    );
    isActive = _i1.ColumnBool(
      'isActive',
      this,
      hasDefault: true,
    );
    isSystemPrompt = _i1.ColumnBool(
      'isSystemPrompt',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final JournalPromptUpdateTable updateTable;

  late final _i1.ColumnString category;

  late final _i1.ColumnString promptText;

  late final _i1.ColumnBool isActive;

  late final _i1.ColumnBool isSystemPrompt;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    category,
    promptText,
    isActive,
    isSystemPrompt,
    createdAt,
  ];
}

class JournalPromptInclude extends _i1.IncludeObject {
  JournalPromptInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => JournalPrompt.t;
}

class JournalPromptIncludeList extends _i1.IncludeList {
  JournalPromptIncludeList._({
    _i1.WhereExpressionBuilder<JournalPromptTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(JournalPrompt.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => JournalPrompt.t;
}

class JournalPromptRepository {
  const JournalPromptRepository._();

  /// Returns a list of [JournalPrompt]s matching the given query parameters.
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
  Future<List<JournalPrompt>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<JournalPromptTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<JournalPromptTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<JournalPromptTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<JournalPrompt>(
      where: where?.call(JournalPrompt.t),
      orderBy: orderBy?.call(JournalPrompt.t),
      orderByList: orderByList?.call(JournalPrompt.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [JournalPrompt] matching the given query parameters.
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
  Future<JournalPrompt?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<JournalPromptTable>? where,
    int? offset,
    _i1.OrderByBuilder<JournalPromptTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<JournalPromptTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<JournalPrompt>(
      where: where?.call(JournalPrompt.t),
      orderBy: orderBy?.call(JournalPrompt.t),
      orderByList: orderByList?.call(JournalPrompt.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [JournalPrompt] by its [id] or null if no such row exists.
  Future<JournalPrompt?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<JournalPrompt>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [JournalPrompt]s in the list and returns the inserted rows.
  ///
  /// The returned [JournalPrompt]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<JournalPrompt>> insert(
    _i1.Session session,
    List<JournalPrompt> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<JournalPrompt>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [JournalPrompt] and returns the inserted row.
  ///
  /// The returned [JournalPrompt] will have its `id` field set.
  Future<JournalPrompt> insertRow(
    _i1.Session session,
    JournalPrompt row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<JournalPrompt>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [JournalPrompt]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<JournalPrompt>> update(
    _i1.Session session,
    List<JournalPrompt> rows, {
    _i1.ColumnSelections<JournalPromptTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<JournalPrompt>(
      rows,
      columns: columns?.call(JournalPrompt.t),
      transaction: transaction,
    );
  }

  /// Updates a single [JournalPrompt]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<JournalPrompt> updateRow(
    _i1.Session session,
    JournalPrompt row, {
    _i1.ColumnSelections<JournalPromptTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<JournalPrompt>(
      row,
      columns: columns?.call(JournalPrompt.t),
      transaction: transaction,
    );
  }

  /// Updates a single [JournalPrompt] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<JournalPrompt?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<JournalPromptUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<JournalPrompt>(
      id,
      columnValues: columnValues(JournalPrompt.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [JournalPrompt]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<JournalPrompt>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<JournalPromptUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<JournalPromptTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<JournalPromptTable>? orderBy,
    _i1.OrderByListBuilder<JournalPromptTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<JournalPrompt>(
      columnValues: columnValues(JournalPrompt.t.updateTable),
      where: where(JournalPrompt.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(JournalPrompt.t),
      orderByList: orderByList?.call(JournalPrompt.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [JournalPrompt]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<JournalPrompt>> delete(
    _i1.Session session,
    List<JournalPrompt> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<JournalPrompt>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [JournalPrompt].
  Future<JournalPrompt> deleteRow(
    _i1.Session session,
    JournalPrompt row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<JournalPrompt>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<JournalPrompt>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<JournalPromptTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<JournalPrompt>(
      where: where(JournalPrompt.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<JournalPromptTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<JournalPrompt>(
      where: where?.call(JournalPrompt.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
