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

abstract class SleepInsight
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = SleepInsightTable();

  static const db = SleepInsightRepository._();

  @override
  int? id;

  int userId;

  String insightType;

  String metric;

  double value;

  String description;

  DateTime generatedAt;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static SleepInsightInclude include() {
    return SleepInsightInclude._();
  }

  static SleepInsightIncludeList includeList({
    _i1.WhereExpressionBuilder<SleepInsightTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SleepInsightTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SleepInsightTable>? orderByList,
    SleepInsightInclude? include,
  }) {
    return SleepInsightIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SleepInsight.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SleepInsight.t),
      include: include,
    );
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

class SleepInsightUpdateTable extends _i1.UpdateTable<SleepInsightTable> {
  SleepInsightUpdateTable(super.table);

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<String, String> insightType(String value) => _i1.ColumnValue(
    table.insightType,
    value,
  );

  _i1.ColumnValue<String, String> metric(String value) => _i1.ColumnValue(
    table.metric,
    value,
  );

  _i1.ColumnValue<double, double> value(double value) => _i1.ColumnValue(
    table.value,
    value,
  );

  _i1.ColumnValue<String, String> description(String value) => _i1.ColumnValue(
    table.description,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> generatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.generatedAt,
        value,
      );
}

class SleepInsightTable extends _i1.Table<int?> {
  SleepInsightTable({super.tableRelation})
    : super(tableName: 'sleep_insights') {
    updateTable = SleepInsightUpdateTable(this);
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    insightType = _i1.ColumnString(
      'insightType',
      this,
    );
    metric = _i1.ColumnString(
      'metric',
      this,
    );
    value = _i1.ColumnDouble(
      'value',
      this,
    );
    description = _i1.ColumnString(
      'description',
      this,
    );
    generatedAt = _i1.ColumnDateTime(
      'generatedAt',
      this,
    );
  }

  late final SleepInsightUpdateTable updateTable;

  late final _i1.ColumnInt userId;

  late final _i1.ColumnString insightType;

  late final _i1.ColumnString metric;

  late final _i1.ColumnDouble value;

  late final _i1.ColumnString description;

  late final _i1.ColumnDateTime generatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    insightType,
    metric,
    value,
    description,
    generatedAt,
  ];
}

class SleepInsightInclude extends _i1.IncludeObject {
  SleepInsightInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => SleepInsight.t;
}

class SleepInsightIncludeList extends _i1.IncludeList {
  SleepInsightIncludeList._({
    _i1.WhereExpressionBuilder<SleepInsightTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SleepInsight.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => SleepInsight.t;
}

class SleepInsightRepository {
  const SleepInsightRepository._();

  /// Returns a list of [SleepInsight]s matching the given query parameters.
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
  Future<List<SleepInsight>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SleepInsightTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SleepInsightTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SleepInsightTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<SleepInsight>(
      where: where?.call(SleepInsight.t),
      orderBy: orderBy?.call(SleepInsight.t),
      orderByList: orderByList?.call(SleepInsight.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [SleepInsight] matching the given query parameters.
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
  Future<SleepInsight?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SleepInsightTable>? where,
    int? offset,
    _i1.OrderByBuilder<SleepInsightTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SleepInsightTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<SleepInsight>(
      where: where?.call(SleepInsight.t),
      orderBy: orderBy?.call(SleepInsight.t),
      orderByList: orderByList?.call(SleepInsight.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [SleepInsight] by its [id] or null if no such row exists.
  Future<SleepInsight?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<SleepInsight>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [SleepInsight]s in the list and returns the inserted rows.
  ///
  /// The returned [SleepInsight]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<SleepInsight>> insert(
    _i1.Session session,
    List<SleepInsight> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<SleepInsight>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [SleepInsight] and returns the inserted row.
  ///
  /// The returned [SleepInsight] will have its `id` field set.
  Future<SleepInsight> insertRow(
    _i1.Session session,
    SleepInsight row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SleepInsight>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SleepInsight]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SleepInsight>> update(
    _i1.Session session,
    List<SleepInsight> rows, {
    _i1.ColumnSelections<SleepInsightTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SleepInsight>(
      rows,
      columns: columns?.call(SleepInsight.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SleepInsight]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SleepInsight> updateRow(
    _i1.Session session,
    SleepInsight row, {
    _i1.ColumnSelections<SleepInsightTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<SleepInsight>(
      row,
      columns: columns?.call(SleepInsight.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SleepInsight] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SleepInsight?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<SleepInsightUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<SleepInsight>(
      id,
      columnValues: columnValues(SleepInsight.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SleepInsight]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<SleepInsight>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<SleepInsightUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<SleepInsightTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SleepInsightTable>? orderBy,
    _i1.OrderByListBuilder<SleepInsightTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<SleepInsight>(
      columnValues: columnValues(SleepInsight.t.updateTable),
      where: where(SleepInsight.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SleepInsight.t),
      orderByList: orderByList?.call(SleepInsight.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [SleepInsight]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SleepInsight>> delete(
    _i1.Session session,
    List<SleepInsight> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SleepInsight>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SleepInsight].
  Future<SleepInsight> deleteRow(
    _i1.Session session,
    SleepInsight row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SleepInsight>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SleepInsight>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<SleepInsightTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SleepInsight>(
      where: where(SleepInsight.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SleepInsightTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SleepInsight>(
      where: where?.call(SleepInsight.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
