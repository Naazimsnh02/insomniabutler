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

abstract class JournalInsight
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = JournalInsightTable();

  static const db = JournalInsightRepository._();

  @override
  int? id;

  int userId;

  String insightType;

  String message;

  double confidence;

  String? relatedEntryIds;

  DateTime generatedAt;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static JournalInsightInclude include() {
    return JournalInsightInclude._();
  }

  static JournalInsightIncludeList includeList({
    _i1.WhereExpressionBuilder<JournalInsightTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<JournalInsightTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<JournalInsightTable>? orderByList,
    JournalInsightInclude? include,
  }) {
    return JournalInsightIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(JournalInsight.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(JournalInsight.t),
      include: include,
    );
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

class JournalInsightUpdateTable extends _i1.UpdateTable<JournalInsightTable> {
  JournalInsightUpdateTable(super.table);

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<String, String> insightType(String value) => _i1.ColumnValue(
    table.insightType,
    value,
  );

  _i1.ColumnValue<String, String> message(String value) => _i1.ColumnValue(
    table.message,
    value,
  );

  _i1.ColumnValue<double, double> confidence(double value) => _i1.ColumnValue(
    table.confidence,
    value,
  );

  _i1.ColumnValue<String, String> relatedEntryIds(String? value) =>
      _i1.ColumnValue(
        table.relatedEntryIds,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> generatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.generatedAt,
        value,
      );
}

class JournalInsightTable extends _i1.Table<int?> {
  JournalInsightTable({super.tableRelation})
    : super(tableName: 'journal_insights') {
    updateTable = JournalInsightUpdateTable(this);
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    insightType = _i1.ColumnString(
      'insightType',
      this,
    );
    message = _i1.ColumnString(
      'message',
      this,
    );
    confidence = _i1.ColumnDouble(
      'confidence',
      this,
    );
    relatedEntryIds = _i1.ColumnString(
      'relatedEntryIds',
      this,
    );
    generatedAt = _i1.ColumnDateTime(
      'generatedAt',
      this,
    );
  }

  late final JournalInsightUpdateTable updateTable;

  late final _i1.ColumnInt userId;

  late final _i1.ColumnString insightType;

  late final _i1.ColumnString message;

  late final _i1.ColumnDouble confidence;

  late final _i1.ColumnString relatedEntryIds;

  late final _i1.ColumnDateTime generatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    insightType,
    message,
    confidence,
    relatedEntryIds,
    generatedAt,
  ];
}

class JournalInsightInclude extends _i1.IncludeObject {
  JournalInsightInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => JournalInsight.t;
}

class JournalInsightIncludeList extends _i1.IncludeList {
  JournalInsightIncludeList._({
    _i1.WhereExpressionBuilder<JournalInsightTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(JournalInsight.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => JournalInsight.t;
}

class JournalInsightRepository {
  const JournalInsightRepository._();

  /// Returns a list of [JournalInsight]s matching the given query parameters.
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
  Future<List<JournalInsight>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<JournalInsightTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<JournalInsightTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<JournalInsightTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<JournalInsight>(
      where: where?.call(JournalInsight.t),
      orderBy: orderBy?.call(JournalInsight.t),
      orderByList: orderByList?.call(JournalInsight.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [JournalInsight] matching the given query parameters.
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
  Future<JournalInsight?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<JournalInsightTable>? where,
    int? offset,
    _i1.OrderByBuilder<JournalInsightTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<JournalInsightTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<JournalInsight>(
      where: where?.call(JournalInsight.t),
      orderBy: orderBy?.call(JournalInsight.t),
      orderByList: orderByList?.call(JournalInsight.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [JournalInsight] by its [id] or null if no such row exists.
  Future<JournalInsight?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<JournalInsight>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [JournalInsight]s in the list and returns the inserted rows.
  ///
  /// The returned [JournalInsight]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<JournalInsight>> insert(
    _i1.Session session,
    List<JournalInsight> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<JournalInsight>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [JournalInsight] and returns the inserted row.
  ///
  /// The returned [JournalInsight] will have its `id` field set.
  Future<JournalInsight> insertRow(
    _i1.Session session,
    JournalInsight row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<JournalInsight>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [JournalInsight]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<JournalInsight>> update(
    _i1.Session session,
    List<JournalInsight> rows, {
    _i1.ColumnSelections<JournalInsightTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<JournalInsight>(
      rows,
      columns: columns?.call(JournalInsight.t),
      transaction: transaction,
    );
  }

  /// Updates a single [JournalInsight]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<JournalInsight> updateRow(
    _i1.Session session,
    JournalInsight row, {
    _i1.ColumnSelections<JournalInsightTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<JournalInsight>(
      row,
      columns: columns?.call(JournalInsight.t),
      transaction: transaction,
    );
  }

  /// Updates a single [JournalInsight] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<JournalInsight?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<JournalInsightUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<JournalInsight>(
      id,
      columnValues: columnValues(JournalInsight.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [JournalInsight]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<JournalInsight>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<JournalInsightUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<JournalInsightTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<JournalInsightTable>? orderBy,
    _i1.OrderByListBuilder<JournalInsightTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<JournalInsight>(
      columnValues: columnValues(JournalInsight.t.updateTable),
      where: where(JournalInsight.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(JournalInsight.t),
      orderByList: orderByList?.call(JournalInsight.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [JournalInsight]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<JournalInsight>> delete(
    _i1.Session session,
    List<JournalInsight> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<JournalInsight>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [JournalInsight].
  Future<JournalInsight> deleteRow(
    _i1.Session session,
    JournalInsight row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<JournalInsight>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<JournalInsight>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<JournalInsightTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<JournalInsight>(
      where: where(JournalInsight.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<JournalInsightTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<JournalInsight>(
      where: where?.call(JournalInsight.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
