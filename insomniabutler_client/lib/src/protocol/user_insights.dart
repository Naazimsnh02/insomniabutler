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
import 'package:insomniabutler_client/src/protocol/protocol.dart' as _i2;

abstract class UserInsights implements _i1.SerializableModel {
  UserInsights._({
    required this.latencyImprovement,
    required this.avgLatencyWithButler,
    required this.avgLatencyWithoutButler,
    required this.topThoughtCategories,
    required this.totalThoughtsProcessed,
    required this.totalSessions,
  });

  factory UserInsights({
    required int latencyImprovement,
    required double avgLatencyWithButler,
    required double avgLatencyWithoutButler,
    required List<String> topThoughtCategories,
    required int totalThoughtsProcessed,
    required int totalSessions,
  }) = _UserInsightsImpl;

  factory UserInsights.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserInsights(
      latencyImprovement: jsonSerialization['latencyImprovement'] as int,
      avgLatencyWithButler: (jsonSerialization['avgLatencyWithButler'] as num)
          .toDouble(),
      avgLatencyWithoutButler:
          (jsonSerialization['avgLatencyWithoutButler'] as num).toDouble(),
      topThoughtCategories: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['topThoughtCategories'],
      ),
      totalThoughtsProcessed:
          jsonSerialization['totalThoughtsProcessed'] as int,
      totalSessions: jsonSerialization['totalSessions'] as int,
    );
  }

  int latencyImprovement;

  double avgLatencyWithButler;

  double avgLatencyWithoutButler;

  List<String> topThoughtCategories;

  int totalThoughtsProcessed;

  int totalSessions;

  /// Returns a shallow copy of this [UserInsights]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserInsights copyWith({
    int? latencyImprovement,
    double? avgLatencyWithButler,
    double? avgLatencyWithoutButler,
    List<String>? topThoughtCategories,
    int? totalThoughtsProcessed,
    int? totalSessions,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserInsights',
      'latencyImprovement': latencyImprovement,
      'avgLatencyWithButler': avgLatencyWithButler,
      'avgLatencyWithoutButler': avgLatencyWithoutButler,
      'topThoughtCategories': topThoughtCategories.toJson(),
      'totalThoughtsProcessed': totalThoughtsProcessed,
      'totalSessions': totalSessions,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _UserInsightsImpl extends UserInsights {
  _UserInsightsImpl({
    required int latencyImprovement,
    required double avgLatencyWithButler,
    required double avgLatencyWithoutButler,
    required List<String> topThoughtCategories,
    required int totalThoughtsProcessed,
    required int totalSessions,
  }) : super._(
         latencyImprovement: latencyImprovement,
         avgLatencyWithButler: avgLatencyWithButler,
         avgLatencyWithoutButler: avgLatencyWithoutButler,
         topThoughtCategories: topThoughtCategories,
         totalThoughtsProcessed: totalThoughtsProcessed,
         totalSessions: totalSessions,
       );

  /// Returns a shallow copy of this [UserInsights]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserInsights copyWith({
    int? latencyImprovement,
    double? avgLatencyWithButler,
    double? avgLatencyWithoutButler,
    List<String>? topThoughtCategories,
    int? totalThoughtsProcessed,
    int? totalSessions,
  }) {
    return UserInsights(
      latencyImprovement: latencyImprovement ?? this.latencyImprovement,
      avgLatencyWithButler: avgLatencyWithButler ?? this.avgLatencyWithButler,
      avgLatencyWithoutButler:
          avgLatencyWithoutButler ?? this.avgLatencyWithoutButler,
      topThoughtCategories:
          topThoughtCategories ??
          this.topThoughtCategories.map((e0) => e0).toList(),
      totalThoughtsProcessed:
          totalThoughtsProcessed ?? this.totalThoughtsProcessed,
      totalSessions: totalSessions ?? this.totalSessions,
    );
  }
}
