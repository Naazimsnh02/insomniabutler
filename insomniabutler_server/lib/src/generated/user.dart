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

abstract class User implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = UserTable();

  static const db = UserRepository._();

  @override
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

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static UserInclude include() {
    return UserInclude._();
  }

  static UserIncludeList includeList({
    _i1.WhereExpressionBuilder<UserTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserTable>? orderByList,
    UserInclude? include,
  }) {
    return UserIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(User.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(User.t),
      include: include,
    );
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

class UserUpdateTable extends _i1.UpdateTable<UserTable> {
  UserUpdateTable(super.table);

  _i1.ColumnValue<String, String> email(String value) => _i1.ColumnValue(
    table.email,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> sleepGoal(String? value) => _i1.ColumnValue(
    table.sleepGoal,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> bedtimePreference(DateTime? value) =>
      _i1.ColumnValue(
        table.bedtimePreference,
        value,
      );

  _i1.ColumnValue<bool, bool> sleepInsightsEnabled(bool value) =>
      _i1.ColumnValue(
        table.sleepInsightsEnabled,
        value,
      );

  _i1.ColumnValue<String, String> sleepInsightsTime(String? value) =>
      _i1.ColumnValue(
        table.sleepInsightsTime,
        value,
      );

  _i1.ColumnValue<bool, bool> journalInsightsEnabled(bool value) =>
      _i1.ColumnValue(
        table.journalInsightsEnabled,
        value,
      );

  _i1.ColumnValue<String, String> journalInsightsTime(String? value) =>
      _i1.ColumnValue(
        table.journalInsightsTime,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class UserTable extends _i1.Table<int?> {
  UserTable({super.tableRelation}) : super(tableName: 'users') {
    updateTable = UserUpdateTable(this);
    email = _i1.ColumnString(
      'email',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    sleepGoal = _i1.ColumnString(
      'sleepGoal',
      this,
    );
    bedtimePreference = _i1.ColumnDateTime(
      'bedtimePreference',
      this,
    );
    sleepInsightsEnabled = _i1.ColumnBool(
      'sleepInsightsEnabled',
      this,
    );
    sleepInsightsTime = _i1.ColumnString(
      'sleepInsightsTime',
      this,
    );
    journalInsightsEnabled = _i1.ColumnBool(
      'journalInsightsEnabled',
      this,
    );
    journalInsightsTime = _i1.ColumnString(
      'journalInsightsTime',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final UserUpdateTable updateTable;

  late final _i1.ColumnString email;

  late final _i1.ColumnString name;

  late final _i1.ColumnString sleepGoal;

  late final _i1.ColumnDateTime bedtimePreference;

  late final _i1.ColumnBool sleepInsightsEnabled;

  late final _i1.ColumnString sleepInsightsTime;

  late final _i1.ColumnBool journalInsightsEnabled;

  late final _i1.ColumnString journalInsightsTime;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    email,
    name,
    sleepGoal,
    bedtimePreference,
    sleepInsightsEnabled,
    sleepInsightsTime,
    journalInsightsEnabled,
    journalInsightsTime,
    createdAt,
  ];
}

class UserInclude extends _i1.IncludeObject {
  UserInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => User.t;
}

class UserIncludeList extends _i1.IncludeList {
  UserIncludeList._({
    _i1.WhereExpressionBuilder<UserTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(User.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => User.t;
}

class UserRepository {
  const UserRepository._();

  /// Returns a list of [User]s matching the given query parameters.
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
  Future<List<User>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<User>(
      where: where?.call(User.t),
      orderBy: orderBy?.call(User.t),
      orderByList: orderByList?.call(User.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [User] matching the given query parameters.
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
  Future<User?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<User>(
      where: where?.call(User.t),
      orderBy: orderBy?.call(User.t),
      orderByList: orderByList?.call(User.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [User] by its [id] or null if no such row exists.
  Future<User?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<User>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [User]s in the list and returns the inserted rows.
  ///
  /// The returned [User]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<User>> insert(
    _i1.Session session,
    List<User> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<User>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [User] and returns the inserted row.
  ///
  /// The returned [User] will have its `id` field set.
  Future<User> insertRow(
    _i1.Session session,
    User row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<User>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [User]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<User>> update(
    _i1.Session session,
    List<User> rows, {
    _i1.ColumnSelections<UserTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<User>(
      rows,
      columns: columns?.call(User.t),
      transaction: transaction,
    );
  }

  /// Updates a single [User]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<User> updateRow(
    _i1.Session session,
    User row, {
    _i1.ColumnSelections<UserTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<User>(
      row,
      columns: columns?.call(User.t),
      transaction: transaction,
    );
  }

  /// Updates a single [User] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<User?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<UserUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<User>(
      id,
      columnValues: columnValues(User.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [User]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<User>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<UserUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<UserTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserTable>? orderBy,
    _i1.OrderByListBuilder<UserTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<User>(
      columnValues: columnValues(User.t.updateTable),
      where: where(User.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(User.t),
      orderByList: orderByList?.call(User.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [User]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<User>> delete(
    _i1.Session session,
    List<User> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<User>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [User].
  Future<User> deleteRow(
    _i1.Session session,
    User row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<User>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<User>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<UserTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<User>(
      where: where(User.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<User>(
      where: where?.call(User.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
