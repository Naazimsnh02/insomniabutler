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
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i3;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i4;
import 'ai_action.dart' as _i5;
import 'chat_message.dart' as _i6;
import 'chat_session_info.dart' as _i7;
import 'greetings/greeting.dart' as _i8;
import 'journal_entry.dart' as _i9;
import 'journal_insight.dart' as _i10;
import 'journal_prompt.dart' as _i11;
import 'journal_stats.dart' as _i12;
import 'sleep_insight.dart' as _i13;
import 'sleep_session.dart' as _i14;
import 'thought_log.dart' as _i15;
import 'thought_response.dart' as _i16;
import 'user.dart' as _i17;
import 'user_insights.dart' as _i18;
import 'package:insomniabutler_server/src/generated/sleep_session.dart' as _i19;
import 'package:insomniabutler_server/src/generated/journal_entry.dart' as _i20;
import 'package:insomniabutler_server/src/generated/journal_prompt.dart'
    as _i21;
import 'package:insomniabutler_server/src/generated/journal_insight.dart'
    as _i22;
import 'package:insomniabutler_server/src/generated/chat_message.dart' as _i23;
import 'package:insomniabutler_server/src/generated/chat_session_info.dart'
    as _i24;
export 'ai_action.dart';
export 'chat_message.dart';
export 'chat_session_info.dart';
export 'greetings/greeting.dart';
export 'journal_entry.dart';
export 'journal_insight.dart';
export 'journal_prompt.dart';
export 'journal_stats.dart';
export 'sleep_insight.dart';
export 'sleep_session.dart';
export 'thought_log.dart';
export 'thought_response.dart';
export 'user.dart';
export 'user_insights.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'chat_messages',
      dartName: 'ChatMessage',
      schema: 'public',
      module: 'insomniabutler',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'chat_messages_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'sessionId',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'role',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'content',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'timestamp',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'embedding',
          columnType: _i2.ColumnType.vector,
          isNullable: true,
          dartType: 'Vector(768)?',
          vectorDimension: 768,
        ),
        _i2.ColumnDefinition(
          name: 'widgetType',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'widgetData',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'chat_messages_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'chat_messages_embedding_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'embedding',
            ),
          ],
          type: 'hnsw',
          isUnique: false,
          isPrimary: false,
          vectorDistanceFunction: _i2.VectorDistanceFunction.l2,
          vectorColumnType: _i2.ColumnType.vector,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'journal_entries',
      dartName: 'JournalEntry',
      schema: 'public',
      module: 'insomniabutler',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'journal_entries_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'content',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'mood',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'sleepSessionId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'tags',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'isFavorite',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'entryDate',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'embedding',
          columnType: _i2.ColumnType.vector,
          isNullable: true,
          dartType: 'Vector(768)?',
          vectorDimension: 768,
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'journal_entries_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'journal_entries_embedding_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'embedding',
            ),
          ],
          type: 'hnsw',
          isUnique: false,
          isPrimary: false,
          vectorDistanceFunction: _i2.VectorDistanceFunction.l2,
          vectorColumnType: _i2.ColumnType.vector,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'journal_prompts',
      dartName: 'JournalPrompt',
      schema: 'public',
      module: 'insomniabutler',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'journal_prompts_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'category',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'promptText',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'isSystemPrompt',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'journal_prompts_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'sleep_insights',
      dartName: 'SleepInsight',
      schema: 'public',
      module: 'insomniabutler',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'sleep_insights_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'insightType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'metric',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'value',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'description',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'generatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'sleep_insights_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'sleep_sessions',
      dartName: 'SleepSession',
      schema: 'public',
      module: 'insomniabutler',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'sleep_sessions_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'bedTime',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'wakeTime',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'sleepLatencyMinutes',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'usedButler',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'thoughtsProcessed',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'sleepQuality',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'morningMood',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'sessionDate',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'deepSleepDuration',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'lightSleepDuration',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'remSleepDuration',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'awakeDuration',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'restingHeartRate',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'hrv',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'respiratoryRate',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'interruptions',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'sleep_sessions_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'thought_logs',
      dartName: 'ThoughtLog',
      schema: 'public',
      module: 'insomniabutler',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'thought_logs_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'sessionId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'category',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'content',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'timestamp',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'resolved',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'readinessIncrease',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'thought_logs_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'users',
      dartName: 'User',
      schema: 'public',
      module: 'insomniabutler',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'users_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'email',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'sleepGoal',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'bedtimePreference',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'users_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i5.AIAction) {
      return _i5.AIAction.fromJson(data) as T;
    }
    if (t == _i6.ChatMessage) {
      return _i6.ChatMessage.fromJson(data) as T;
    }
    if (t == _i7.ChatSessionInfo) {
      return _i7.ChatSessionInfo.fromJson(data) as T;
    }
    if (t == _i8.Greeting) {
      return _i8.Greeting.fromJson(data) as T;
    }
    if (t == _i9.JournalEntry) {
      return _i9.JournalEntry.fromJson(data) as T;
    }
    if (t == _i10.JournalInsight) {
      return _i10.JournalInsight.fromJson(data) as T;
    }
    if (t == _i11.JournalPrompt) {
      return _i11.JournalPrompt.fromJson(data) as T;
    }
    if (t == _i12.JournalStats) {
      return _i12.JournalStats.fromJson(data) as T;
    }
    if (t == _i13.SleepInsight) {
      return _i13.SleepInsight.fromJson(data) as T;
    }
    if (t == _i14.SleepSession) {
      return _i14.SleepSession.fromJson(data) as T;
    }
    if (t == _i15.ThoughtLog) {
      return _i15.ThoughtLog.fromJson(data) as T;
    }
    if (t == _i16.ThoughtResponse) {
      return _i16.ThoughtResponse.fromJson(data) as T;
    }
    if (t == _i17.User) {
      return _i17.User.fromJson(data) as T;
    }
    if (t == _i18.UserInsights) {
      return _i18.UserInsights.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.AIAction?>()) {
      return (data != null ? _i5.AIAction.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.ChatMessage?>()) {
      return (data != null ? _i6.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.ChatSessionInfo?>()) {
      return (data != null ? _i7.ChatSessionInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Greeting?>()) {
      return (data != null ? _i8.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.JournalEntry?>()) {
      return (data != null ? _i9.JournalEntry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.JournalInsight?>()) {
      return (data != null ? _i10.JournalInsight.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.JournalPrompt?>()) {
      return (data != null ? _i11.JournalPrompt.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.JournalStats?>()) {
      return (data != null ? _i12.JournalStats.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.SleepInsight?>()) {
      return (data != null ? _i13.SleepInsight.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.SleepSession?>()) {
      return (data != null ? _i14.SleepSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.ThoughtLog?>()) {
      return (data != null ? _i15.ThoughtLog.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.ThoughtResponse?>()) {
      return (data != null ? _i16.ThoughtResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.User?>()) {
      return (data != null ? _i17.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.UserInsights?>()) {
      return (data != null ? _i18.UserInsights.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == Map<String, int>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<int>(v)),
          )
          as T;
    }
    if (t == List<_i19.SleepSession>) {
      return (data as List)
              .map((e) => deserialize<_i19.SleepSession>(e))
              .toList()
          as T;
    }
    if (t == List<_i20.JournalEntry>) {
      return (data as List)
              .map((e) => deserialize<_i20.JournalEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_i21.JournalPrompt>) {
      return (data as List)
              .map((e) => deserialize<_i21.JournalPrompt>(e))
              .toList()
          as T;
    }
    if (t == List<_i22.JournalInsight>) {
      return (data as List)
              .map((e) => deserialize<_i22.JournalInsight>(e))
              .toList()
          as T;
    }
    if (t == List<_i23.ChatMessage>) {
      return (data as List)
              .map((e) => deserialize<_i23.ChatMessage>(e))
              .toList()
          as T;
    }
    if (t == List<_i24.ChatSessionInfo>) {
      return (data as List)
              .map((e) => deserialize<_i24.ChatSessionInfo>(e))
              .toList()
          as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i5.AIAction => 'AIAction',
      _i6.ChatMessage => 'ChatMessage',
      _i7.ChatSessionInfo => 'ChatSessionInfo',
      _i8.Greeting => 'Greeting',
      _i9.JournalEntry => 'JournalEntry',
      _i10.JournalInsight => 'JournalInsight',
      _i11.JournalPrompt => 'JournalPrompt',
      _i12.JournalStats => 'JournalStats',
      _i13.SleepInsight => 'SleepInsight',
      _i14.SleepSession => 'SleepSession',
      _i15.ThoughtLog => 'ThoughtLog',
      _i16.ThoughtResponse => 'ThoughtResponse',
      _i17.User => 'User',
      _i18.UserInsights => 'UserInsights',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'insomniabutler.',
        '',
      );
    }

    switch (data) {
      case _i5.AIAction():
        return 'AIAction';
      case _i6.ChatMessage():
        return 'ChatMessage';
      case _i7.ChatSessionInfo():
        return 'ChatSessionInfo';
      case _i8.Greeting():
        return 'Greeting';
      case _i9.JournalEntry():
        return 'JournalEntry';
      case _i10.JournalInsight():
        return 'JournalInsight';
      case _i11.JournalPrompt():
        return 'JournalPrompt';
      case _i12.JournalStats():
        return 'JournalStats';
      case _i13.SleepInsight():
        return 'SleepInsight';
      case _i14.SleepSession():
        return 'SleepSession';
      case _i15.ThoughtLog():
        return 'ThoughtLog';
      case _i16.ThoughtResponse():
        return 'ThoughtResponse';
      case _i17.User():
        return 'User';
      case _i18.UserInsights():
        return 'UserInsights';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AIAction') {
      return deserialize<_i5.AIAction>(data['data']);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i6.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatSessionInfo') {
      return deserialize<_i7.ChatSessionInfo>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i8.Greeting>(data['data']);
    }
    if (dataClassName == 'JournalEntry') {
      return deserialize<_i9.JournalEntry>(data['data']);
    }
    if (dataClassName == 'JournalInsight') {
      return deserialize<_i10.JournalInsight>(data['data']);
    }
    if (dataClassName == 'JournalPrompt') {
      return deserialize<_i11.JournalPrompt>(data['data']);
    }
    if (dataClassName == 'JournalStats') {
      return deserialize<_i12.JournalStats>(data['data']);
    }
    if (dataClassName == 'SleepInsight') {
      return deserialize<_i13.SleepInsight>(data['data']);
    }
    if (dataClassName == 'SleepSession') {
      return deserialize<_i14.SleepSession>(data['data']);
    }
    if (dataClassName == 'ThoughtLog') {
      return deserialize<_i15.ThoughtLog>(data['data']);
    }
    if (dataClassName == 'ThoughtResponse') {
      return deserialize<_i16.ThoughtResponse>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i17.User>(data['data']);
    }
    if (dataClassName == 'UserInsights') {
      return deserialize<_i18.UserInsights>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i4.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i6.ChatMessage:
        return _i6.ChatMessage.t;
      case _i9.JournalEntry:
        return _i9.JournalEntry.t;
      case _i11.JournalPrompt:
        return _i11.JournalPrompt.t;
      case _i13.SleepInsight:
        return _i13.SleepInsight.t;
      case _i14.SleepSession:
        return _i14.SleepSession.t;
      case _i15.ThoughtLog:
        return _i15.ThoughtLog.t;
      case _i17.User:
        return _i17.User.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'insomniabutler';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
