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

abstract class SleepSession
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = SleepSessionTable();

  static const db = SleepSessionRepository._();

  @override
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

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static SleepSessionInclude include() {
    return SleepSessionInclude._();
  }

  static SleepSessionIncludeList includeList({
    _i1.WhereExpressionBuilder<SleepSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SleepSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SleepSessionTable>? orderByList,
    SleepSessionInclude? include,
  }) {
    return SleepSessionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SleepSession.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SleepSession.t),
      include: include,
    );
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

class SleepSessionUpdateTable extends _i1.UpdateTable<SleepSessionTable> {
  SleepSessionUpdateTable(super.table);

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> bedTime(DateTime value) =>
      _i1.ColumnValue(
        table.bedTime,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> wakeTime(DateTime? value) =>
      _i1.ColumnValue(
        table.wakeTime,
        value,
      );

  _i1.ColumnValue<int, int> sleepLatencyMinutes(int? value) => _i1.ColumnValue(
    table.sleepLatencyMinutes,
    value,
  );

  _i1.ColumnValue<bool, bool> usedButler(bool value) => _i1.ColumnValue(
    table.usedButler,
    value,
  );

  _i1.ColumnValue<int, int> thoughtsProcessed(int value) => _i1.ColumnValue(
    table.thoughtsProcessed,
    value,
  );

  _i1.ColumnValue<int, int> sleepQuality(int? value) => _i1.ColumnValue(
    table.sleepQuality,
    value,
  );

  _i1.ColumnValue<String, String> morningMood(String? value) => _i1.ColumnValue(
    table.morningMood,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> sessionDate(DateTime value) =>
      _i1.ColumnValue(
        table.sessionDate,
        value,
      );
}

class SleepSessionTable extends _i1.Table<int?> {
  SleepSessionTable({super.tableRelation})
    : super(tableName: 'sleep_sessions') {
    updateTable = SleepSessionUpdateTable(this);
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    bedTime = _i1.ColumnDateTime(
      'bedTime',
      this,
    );
    wakeTime = _i1.ColumnDateTime(
      'wakeTime',
      this,
    );
    sleepLatencyMinutes = _i1.ColumnInt(
      'sleepLatencyMinutes',
      this,
    );
    usedButler = _i1.ColumnBool(
      'usedButler',
      this,
    );
    thoughtsProcessed = _i1.ColumnInt(
      'thoughtsProcessed',
      this,
    );
    sleepQuality = _i1.ColumnInt(
      'sleepQuality',
      this,
    );
    morningMood = _i1.ColumnString(
      'morningMood',
      this,
    );
    sessionDate = _i1.ColumnDateTime(
      'sessionDate',
      this,
    );
  }

  late final SleepSessionUpdateTable updateTable;

  late final _i1.ColumnInt userId;

  late final _i1.ColumnDateTime bedTime;

  late final _i1.ColumnDateTime wakeTime;

  late final _i1.ColumnInt sleepLatencyMinutes;

  late final _i1.ColumnBool usedButler;

  late final _i1.ColumnInt thoughtsProcessed;

  late final _i1.ColumnInt sleepQuality;

  late final _i1.ColumnString morningMood;

  late final _i1.ColumnDateTime sessionDate;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    bedTime,
    wakeTime,
    sleepLatencyMinutes,
    usedButler,
    thoughtsProcessed,
    sleepQuality,
    morningMood,
    sessionDate,
  ];
}

class SleepSessionInclude extends _i1.IncludeObject {
  SleepSessionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => SleepSession.t;
}

class SleepSessionIncludeList extends _i1.IncludeList {
  SleepSessionIncludeList._({
    _i1.WhereExpressionBuilder<SleepSessionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SleepSession.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => SleepSession.t;
}

class SleepSessionRepository {
  const SleepSessionRepository._();

  /// Returns a list of [SleepSession]s matching the given query parameters.
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
  Future<List<SleepSession>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SleepSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SleepSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SleepSessionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<SleepSession>(
      where: where?.call(SleepSession.t),
      orderBy: orderBy?.call(SleepSession.t),
      orderByList: orderByList?.call(SleepSession.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [SleepSession] matching the given query parameters.
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
  Future<SleepSession?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SleepSessionTable>? where,
    int? offset,
    _i1.OrderByBuilder<SleepSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SleepSessionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<SleepSession>(
      where: where?.call(SleepSession.t),
      orderBy: orderBy?.call(SleepSession.t),
      orderByList: orderByList?.call(SleepSession.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [SleepSession] by its [id] or null if no such row exists.
  Future<SleepSession?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<SleepSession>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [SleepSession]s in the list and returns the inserted rows.
  ///
  /// The returned [SleepSession]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<SleepSession>> insert(
    _i1.Session session,
    List<SleepSession> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<SleepSession>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [SleepSession] and returns the inserted row.
  ///
  /// The returned [SleepSession] will have its `id` field set.
  Future<SleepSession> insertRow(
    _i1.Session session,
    SleepSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SleepSession>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SleepSession]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SleepSession>> update(
    _i1.Session session,
    List<SleepSession> rows, {
    _i1.ColumnSelections<SleepSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SleepSession>(
      rows,
      columns: columns?.call(SleepSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SleepSession]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SleepSession> updateRow(
    _i1.Session session,
    SleepSession row, {
    _i1.ColumnSelections<SleepSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<SleepSession>(
      row,
      columns: columns?.call(SleepSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SleepSession] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SleepSession?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<SleepSessionUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<SleepSession>(
      id,
      columnValues: columnValues(SleepSession.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SleepSession]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<SleepSession>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<SleepSessionUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<SleepSessionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SleepSessionTable>? orderBy,
    _i1.OrderByListBuilder<SleepSessionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<SleepSession>(
      columnValues: columnValues(SleepSession.t.updateTable),
      where: where(SleepSession.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SleepSession.t),
      orderByList: orderByList?.call(SleepSession.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [SleepSession]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SleepSession>> delete(
    _i1.Session session,
    List<SleepSession> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SleepSession>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SleepSession].
  Future<SleepSession> deleteRow(
    _i1.Session session,
    SleepSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SleepSession>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SleepSession>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<SleepSessionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SleepSession>(
      where: where(SleepSession.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SleepSessionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SleepSession>(
      where: where?.call(SleepSession.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
