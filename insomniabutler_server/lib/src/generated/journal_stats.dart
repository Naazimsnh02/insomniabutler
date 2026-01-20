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

abstract class JournalStats
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  JournalStats._({
    required this.totalEntries,
    required this.currentStreak,
    required this.longestStreak,
    required this.thisWeekEntries,
    required this.favoriteCount,
    required this.moodDistribution,
  });

  factory JournalStats({
    required int totalEntries,
    required int currentStreak,
    required int longestStreak,
    required int thisWeekEntries,
    required int favoriteCount,
    required String moodDistribution,
  }) = _JournalStatsImpl;

  factory JournalStats.fromJson(Map<String, dynamic> jsonSerialization) {
    return JournalStats(
      totalEntries: jsonSerialization['totalEntries'] as int,
      currentStreak: jsonSerialization['currentStreak'] as int,
      longestStreak: jsonSerialization['longestStreak'] as int,
      thisWeekEntries: jsonSerialization['thisWeekEntries'] as int,
      favoriteCount: jsonSerialization['favoriteCount'] as int,
      moodDistribution: jsonSerialization['moodDistribution'] as String,
    );
  }

  int totalEntries;

  int currentStreak;

  int longestStreak;

  int thisWeekEntries;

  int favoriteCount;

  String moodDistribution;

  /// Returns a shallow copy of this [JournalStats]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  JournalStats copyWith({
    int? totalEntries,
    int? currentStreak,
    int? longestStreak,
    int? thisWeekEntries,
    int? favoriteCount,
    String? moodDistribution,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'JournalStats',
      'totalEntries': totalEntries,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'thisWeekEntries': thisWeekEntries,
      'favoriteCount': favoriteCount,
      'moodDistribution': moodDistribution,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'JournalStats',
      'totalEntries': totalEntries,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'thisWeekEntries': thisWeekEntries,
      'favoriteCount': favoriteCount,
      'moodDistribution': moodDistribution,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _JournalStatsImpl extends JournalStats {
  _JournalStatsImpl({
    required int totalEntries,
    required int currentStreak,
    required int longestStreak,
    required int thisWeekEntries,
    required int favoriteCount,
    required String moodDistribution,
  }) : super._(
         totalEntries: totalEntries,
         currentStreak: currentStreak,
         longestStreak: longestStreak,
         thisWeekEntries: thisWeekEntries,
         favoriteCount: favoriteCount,
         moodDistribution: moodDistribution,
       );

  /// Returns a shallow copy of this [JournalStats]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  JournalStats copyWith({
    int? totalEntries,
    int? currentStreak,
    int? longestStreak,
    int? thisWeekEntries,
    int? favoriteCount,
    String? moodDistribution,
  }) {
    return JournalStats(
      totalEntries: totalEntries ?? this.totalEntries,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      thisWeekEntries: thisWeekEntries ?? this.thisWeekEntries,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      moodDistribution: moodDistribution ?? this.moodDistribution,
    );
  }
}
