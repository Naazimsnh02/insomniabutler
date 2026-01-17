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

abstract class ThoughtLog
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ThoughtLog._({
    this.id,
    required this.userId,
    this.sessionId,
    required this.category,
    required this.content,
    required this.timestamp,
    required this.resolved,
    required this.readinessIncrease,
  });

  factory ThoughtLog({
    int? id,
    required int userId,
    int? sessionId,
    required String category,
    required String content,
    required DateTime timestamp,
    required bool resolved,
    required int readinessIncrease,
  }) = _ThoughtLogImpl;

  factory ThoughtLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return ThoughtLog(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      sessionId: jsonSerialization['sessionId'] as int?,
      category: jsonSerialization['category'] as String,
      content: jsonSerialization['content'] as String,
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
      resolved: jsonSerialization['resolved'] as bool,
      readinessIncrease: jsonSerialization['readinessIncrease'] as int,
    );
  }

  static final t = ThoughtLogTable();

  static const db = ThoughtLogRepository._();

  @override
  int? id;

  int userId;

  int? sessionId;

  String category;

  String content;

  DateTime timestamp;

  bool resolved;

  int readinessIncrease;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ThoughtLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ThoughtLog copyWith({
    int? id,
    int? userId,
    int? sessionId,
    String? category,
    String? content,
    DateTime? timestamp,
    bool? resolved,
    int? readinessIncrease,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ThoughtLog',
      if (id != null) 'id': id,
      'userId': userId,
      if (sessionId != null) 'sessionId': sessionId,
      'category': category,
      'content': content,
      'timestamp': timestamp.toJson(),
      'resolved': resolved,
      'readinessIncrease': readinessIncrease,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ThoughtLog',
      if (id != null) 'id': id,
      'userId': userId,
      if (sessionId != null) 'sessionId': sessionId,
      'category': category,
      'content': content,
      'timestamp': timestamp.toJson(),
      'resolved': resolved,
      'readinessIncrease': readinessIncrease,
    };
  }

  static ThoughtLogInclude include() {
    return ThoughtLogInclude._();
  }

  static ThoughtLogIncludeList includeList({
    _i1.WhereExpressionBuilder<ThoughtLogTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ThoughtLogTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ThoughtLogTable>? orderByList,
    ThoughtLogInclude? include,
  }) {
    return ThoughtLogIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ThoughtLog.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ThoughtLog.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ThoughtLogImpl extends ThoughtLog {
  _ThoughtLogImpl({
    int? id,
    required int userId,
    int? sessionId,
    required String category,
    required String content,
    required DateTime timestamp,
    required bool resolved,
    required int readinessIncrease,
  }) : super._(
         id: id,
         userId: userId,
         sessionId: sessionId,
         category: category,
         content: content,
         timestamp: timestamp,
         resolved: resolved,
         readinessIncrease: readinessIncrease,
       );

  /// Returns a shallow copy of this [ThoughtLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ThoughtLog copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? sessionId = _Undefined,
    String? category,
    String? content,
    DateTime? timestamp,
    bool? resolved,
    int? readinessIncrease,
  }) {
    return ThoughtLog(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId is int? ? sessionId : this.sessionId,
      category: category ?? this.category,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      resolved: resolved ?? this.resolved,
      readinessIncrease: readinessIncrease ?? this.readinessIncrease,
    );
  }
}

class ThoughtLogUpdateTable extends _i1.UpdateTable<ThoughtLogTable> {
  ThoughtLogUpdateTable(super.table);

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<int, int> sessionId(int? value) => _i1.ColumnValue(
    table.sessionId,
    value,
  );

  _i1.ColumnValue<String, String> category(String value) => _i1.ColumnValue(
    table.category,
    value,
  );

  _i1.ColumnValue<String, String> content(String value) => _i1.ColumnValue(
    table.content,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> timestamp(DateTime value) =>
      _i1.ColumnValue(
        table.timestamp,
        value,
      );

  _i1.ColumnValue<bool, bool> resolved(bool value) => _i1.ColumnValue(
    table.resolved,
    value,
  );

  _i1.ColumnValue<int, int> readinessIncrease(int value) => _i1.ColumnValue(
    table.readinessIncrease,
    value,
  );
}

class ThoughtLogTable extends _i1.Table<int?> {
  ThoughtLogTable({super.tableRelation}) : super(tableName: 'thought_logs') {
    updateTable = ThoughtLogUpdateTable(this);
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    sessionId = _i1.ColumnInt(
      'sessionId',
      this,
    );
    category = _i1.ColumnString(
      'category',
      this,
    );
    content = _i1.ColumnString(
      'content',
      this,
    );
    timestamp = _i1.ColumnDateTime(
      'timestamp',
      this,
    );
    resolved = _i1.ColumnBool(
      'resolved',
      this,
    );
    readinessIncrease = _i1.ColumnInt(
      'readinessIncrease',
      this,
    );
  }

  late final ThoughtLogUpdateTable updateTable;

  late final _i1.ColumnInt userId;

  late final _i1.ColumnInt sessionId;

  late final _i1.ColumnString category;

  late final _i1.ColumnString content;

  late final _i1.ColumnDateTime timestamp;

  late final _i1.ColumnBool resolved;

  late final _i1.ColumnInt readinessIncrease;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    sessionId,
    category,
    content,
    timestamp,
    resolved,
    readinessIncrease,
  ];
}

class ThoughtLogInclude extends _i1.IncludeObject {
  ThoughtLogInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ThoughtLog.t;
}

class ThoughtLogIncludeList extends _i1.IncludeList {
  ThoughtLogIncludeList._({
    _i1.WhereExpressionBuilder<ThoughtLogTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ThoughtLog.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ThoughtLog.t;
}

class ThoughtLogRepository {
  const ThoughtLogRepository._();

  /// Returns a list of [ThoughtLog]s matching the given query parameters.
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
  Future<List<ThoughtLog>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ThoughtLogTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ThoughtLogTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ThoughtLogTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ThoughtLog>(
      where: where?.call(ThoughtLog.t),
      orderBy: orderBy?.call(ThoughtLog.t),
      orderByList: orderByList?.call(ThoughtLog.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ThoughtLog] matching the given query parameters.
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
  Future<ThoughtLog?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ThoughtLogTable>? where,
    int? offset,
    _i1.OrderByBuilder<ThoughtLogTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ThoughtLogTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ThoughtLog>(
      where: where?.call(ThoughtLog.t),
      orderBy: orderBy?.call(ThoughtLog.t),
      orderByList: orderByList?.call(ThoughtLog.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ThoughtLog] by its [id] or null if no such row exists.
  Future<ThoughtLog?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ThoughtLog>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ThoughtLog]s in the list and returns the inserted rows.
  ///
  /// The returned [ThoughtLog]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ThoughtLog>> insert(
    _i1.Session session,
    List<ThoughtLog> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ThoughtLog>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ThoughtLog] and returns the inserted row.
  ///
  /// The returned [ThoughtLog] will have its `id` field set.
  Future<ThoughtLog> insertRow(
    _i1.Session session,
    ThoughtLog row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ThoughtLog>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ThoughtLog]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ThoughtLog>> update(
    _i1.Session session,
    List<ThoughtLog> rows, {
    _i1.ColumnSelections<ThoughtLogTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ThoughtLog>(
      rows,
      columns: columns?.call(ThoughtLog.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ThoughtLog]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ThoughtLog> updateRow(
    _i1.Session session,
    ThoughtLog row, {
    _i1.ColumnSelections<ThoughtLogTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ThoughtLog>(
      row,
      columns: columns?.call(ThoughtLog.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ThoughtLog] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ThoughtLog?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<ThoughtLogUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ThoughtLog>(
      id,
      columnValues: columnValues(ThoughtLog.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ThoughtLog]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ThoughtLog>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ThoughtLogUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ThoughtLogTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ThoughtLogTable>? orderBy,
    _i1.OrderByListBuilder<ThoughtLogTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ThoughtLog>(
      columnValues: columnValues(ThoughtLog.t.updateTable),
      where: where(ThoughtLog.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ThoughtLog.t),
      orderByList: orderByList?.call(ThoughtLog.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ThoughtLog]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ThoughtLog>> delete(
    _i1.Session session,
    List<ThoughtLog> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ThoughtLog>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ThoughtLog].
  Future<ThoughtLog> deleteRow(
    _i1.Session session,
    ThoughtLog row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ThoughtLog>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ThoughtLog>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ThoughtLogTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ThoughtLog>(
      where: where(ThoughtLog.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ThoughtLogTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ThoughtLog>(
      where: where?.call(ThoughtLog.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
