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
import 'chat_message.dart' as _i2;
import 'chat_session_info.dart' as _i3;
import 'greetings/greeting.dart' as _i4;
import 'journal_entry.dart' as _i5;
import 'journal_insight.dart' as _i6;
import 'journal_prompt.dart' as _i7;
import 'journal_stats.dart' as _i8;
import 'sleep_insight.dart' as _i9;
import 'sleep_session.dart' as _i10;
import 'thought_log.dart' as _i11;
import 'thought_response.dart' as _i12;
import 'user.dart' as _i13;
import 'user_insights.dart' as _i14;
import 'package:insomniabutler_client/src/protocol/sleep_session.dart' as _i15;
import 'package:insomniabutler_client/src/protocol/journal_entry.dart' as _i16;
import 'package:insomniabutler_client/src/protocol/journal_prompt.dart' as _i17;
import 'package:insomniabutler_client/src/protocol/journal_insight.dart'
    as _i18;
import 'package:insomniabutler_client/src/protocol/chat_message.dart' as _i19;
import 'package:insomniabutler_client/src/protocol/chat_session_info.dart'
    as _i20;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i21;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i22;
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
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

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

    if (t == _i2.ChatMessage) {
      return _i2.ChatMessage.fromJson(data) as T;
    }
    if (t == _i3.ChatSessionInfo) {
      return _i3.ChatSessionInfo.fromJson(data) as T;
    }
    if (t == _i4.Greeting) {
      return _i4.Greeting.fromJson(data) as T;
    }
    if (t == _i5.JournalEntry) {
      return _i5.JournalEntry.fromJson(data) as T;
    }
    if (t == _i6.JournalInsight) {
      return _i6.JournalInsight.fromJson(data) as T;
    }
    if (t == _i7.JournalPrompt) {
      return _i7.JournalPrompt.fromJson(data) as T;
    }
    if (t == _i8.JournalStats) {
      return _i8.JournalStats.fromJson(data) as T;
    }
    if (t == _i9.SleepInsight) {
      return _i9.SleepInsight.fromJson(data) as T;
    }
    if (t == _i10.SleepSession) {
      return _i10.SleepSession.fromJson(data) as T;
    }
    if (t == _i11.ThoughtLog) {
      return _i11.ThoughtLog.fromJson(data) as T;
    }
    if (t == _i12.ThoughtResponse) {
      return _i12.ThoughtResponse.fromJson(data) as T;
    }
    if (t == _i13.User) {
      return _i13.User.fromJson(data) as T;
    }
    if (t == _i14.UserInsights) {
      return _i14.UserInsights.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.ChatMessage?>()) {
      return (data != null ? _i2.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ChatSessionInfo?>()) {
      return (data != null ? _i3.ChatSessionInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Greeting?>()) {
      return (data != null ? _i4.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.JournalEntry?>()) {
      return (data != null ? _i5.JournalEntry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.JournalInsight?>()) {
      return (data != null ? _i6.JournalInsight.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.JournalPrompt?>()) {
      return (data != null ? _i7.JournalPrompt.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.JournalStats?>()) {
      return (data != null ? _i8.JournalStats.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.SleepInsight?>()) {
      return (data != null ? _i9.SleepInsight.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.SleepSession?>()) {
      return (data != null ? _i10.SleepSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.ThoughtLog?>()) {
      return (data != null ? _i11.ThoughtLog.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.ThoughtResponse?>()) {
      return (data != null ? _i12.ThoughtResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.User?>()) {
      return (data != null ? _i13.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.UserInsights?>()) {
      return (data != null ? _i14.UserInsights.fromJson(data) : null) as T;
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
    if (t == List<_i15.SleepSession>) {
      return (data as List)
              .map((e) => deserialize<_i15.SleepSession>(e))
              .toList()
          as T;
    }
    if (t == List<_i16.JournalEntry>) {
      return (data as List)
              .map((e) => deserialize<_i16.JournalEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_i17.JournalPrompt>) {
      return (data as List)
              .map((e) => deserialize<_i17.JournalPrompt>(e))
              .toList()
          as T;
    }
    if (t == List<_i18.JournalInsight>) {
      return (data as List)
              .map((e) => deserialize<_i18.JournalInsight>(e))
              .toList()
          as T;
    }
    if (t == List<_i19.ChatMessage>) {
      return (data as List)
              .map((e) => deserialize<_i19.ChatMessage>(e))
              .toList()
          as T;
    }
    if (t == List<_i20.ChatSessionInfo>) {
      return (data as List)
              .map((e) => deserialize<_i20.ChatSessionInfo>(e))
              .toList()
          as T;
    }
    try {
      return _i21.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i22.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.ChatMessage => 'ChatMessage',
      _i3.ChatSessionInfo => 'ChatSessionInfo',
      _i4.Greeting => 'Greeting',
      _i5.JournalEntry => 'JournalEntry',
      _i6.JournalInsight => 'JournalInsight',
      _i7.JournalPrompt => 'JournalPrompt',
      _i8.JournalStats => 'JournalStats',
      _i9.SleepInsight => 'SleepInsight',
      _i10.SleepSession => 'SleepSession',
      _i11.ThoughtLog => 'ThoughtLog',
      _i12.ThoughtResponse => 'ThoughtResponse',
      _i13.User => 'User',
      _i14.UserInsights => 'UserInsights',
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
      case _i2.ChatMessage():
        return 'ChatMessage';
      case _i3.ChatSessionInfo():
        return 'ChatSessionInfo';
      case _i4.Greeting():
        return 'Greeting';
      case _i5.JournalEntry():
        return 'JournalEntry';
      case _i6.JournalInsight():
        return 'JournalInsight';
      case _i7.JournalPrompt():
        return 'JournalPrompt';
      case _i8.JournalStats():
        return 'JournalStats';
      case _i9.SleepInsight():
        return 'SleepInsight';
      case _i10.SleepSession():
        return 'SleepSession';
      case _i11.ThoughtLog():
        return 'ThoughtLog';
      case _i12.ThoughtResponse():
        return 'ThoughtResponse';
      case _i13.User():
        return 'User';
      case _i14.UserInsights():
        return 'UserInsights';
    }
    className = _i21.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i22.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i2.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatSessionInfo') {
      return deserialize<_i3.ChatSessionInfo>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i4.Greeting>(data['data']);
    }
    if (dataClassName == 'JournalEntry') {
      return deserialize<_i5.JournalEntry>(data['data']);
    }
    if (dataClassName == 'JournalInsight') {
      return deserialize<_i6.JournalInsight>(data['data']);
    }
    if (dataClassName == 'JournalPrompt') {
      return deserialize<_i7.JournalPrompt>(data['data']);
    }
    if (dataClassName == 'JournalStats') {
      return deserialize<_i8.JournalStats>(data['data']);
    }
    if (dataClassName == 'SleepInsight') {
      return deserialize<_i9.SleepInsight>(data['data']);
    }
    if (dataClassName == 'SleepSession') {
      return deserialize<_i10.SleepSession>(data['data']);
    }
    if (dataClassName == 'ThoughtLog') {
      return deserialize<_i11.ThoughtLog>(data['data']);
    }
    if (dataClassName == 'ThoughtResponse') {
      return deserialize<_i12.ThoughtResponse>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i13.User>(data['data']);
    }
    if (dataClassName == 'UserInsights') {
      return deserialize<_i14.UserInsights>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i21.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i22.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

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
      return _i21.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i22.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
