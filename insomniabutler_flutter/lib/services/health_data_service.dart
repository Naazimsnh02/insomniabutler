import 'dart:io';
import 'package:health/health.dart';
import 'package:insomniabutler_client/insomniabutler_client.dart';

/// Service for interacting with Android Health Connect and Apple HealthKit
class HealthDataService {
  final Health _health = Health();
  bool _isConfigured = false;

  HealthDataService() {
    _configure();
  }

  Future<void> _configure() async {
    if (!_isConfigured) {
      try {
        await _health.configure();
        _isConfigured = true;
      } catch (e) {
        print('Error configuring health plugin: $e');
      }
    }
  }

  // Health data types we need permission for
  static final List<HealthDataType> _dataTypes = [
    HealthDataType.SLEEP_SESSION,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    HealthDataType.RESPIRATORY_RATE,
  ];

  /// Request permissions to access health data
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final status = await _health.getHealthConnectSdkStatus();
        if (status != HealthConnectSdkStatus.sdkAvailable) {
          print('Health Connect is not available: $status');
          // Optionally prompt to install
          // await _health.installHealthConnect();
          return false;
        }
      }

      final permissions = _dataTypes
          .map((type) => HealthDataAccess.READ)
          .toList();

      final authorized = await _health.requestAuthorization(
        _dataTypes,
        permissions: permissions,
      );

      return authorized;
    } catch (e) {
      print('Error requesting health permissions: $e');
      return false;
    }
  }

  /// Check if we have permissions
  Future<bool> hasPermissions() async {
    try {
      return await _health.hasPermissions(_dataTypes) ?? false;
    } catch (e) {
      print('Error checking health permissions: $e');
      return false;
    }
  }

  /// Fetch sleep data for a date range
  Future<List<HealthDataPoint>> fetchSleepData(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final sleepTypes = [
        HealthDataType.SLEEP_SESSION,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_REM,
        HealthDataType.SLEEP_AWAKE,
        HealthDataType.SLEEP_ASLEEP,
      ];

      final data = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: sleepTypes,
      );

      return data;
    } catch (e) {
      print('Error fetching sleep data: $e');
      return [];
    }
  }

  /// Fetch biometric data for a date range
  Future<List<HealthDataPoint>> fetchBiometricData(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final biometricTypes = [
        HealthDataType.HEART_RATE,
        HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
        HealthDataType.RESPIRATORY_RATE,
      ];

      final data = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: biometricTypes,
      );

      return data;
    } catch (e) {
      print('Error fetching biometric data: $e');
      return [];
    }
  }

  /// Convert health data points to SleepSession
  SleepSession? convertToSleepSession(
    List<HealthDataPoint> sleepPoints,
    List<HealthDataPoint> biometricPoints,
    int userId,
  ) {
    try {
      // Find main sleep session
      final sessionPoint = sleepPoints.firstWhere(
        (dp) => dp.type == HealthDataType.SLEEP_SESSION,
        orElse: () => throw Exception('No sleep session found'),
      );

      final bedTime = sessionPoint.dateFrom;
      final wakeTime = sessionPoint.dateTo;

      // Calculate stage durations
      final deepDuration = _calculateStageDuration(
        sleepPoints,
        HealthDataType.SLEEP_DEEP,
      );
      final lightDuration = _calculateStageDuration(
        sleepPoints,
        HealthDataType.SLEEP_LIGHT,
      );
      final remDuration = _calculateStageDuration(
        sleepPoints,
        HealthDataType.SLEEP_REM,
      );
      final awakeDuration = _calculateStageDuration(
        sleepPoints,
        HealthDataType.SLEEP_AWAKE,
      );
      final unspecifiedDuration = _calculateStageDuration(
        sleepPoints,
        HealthDataType.SLEEP_ASLEEP,
      );

      // Count interruptions (number of awake periods)
      final interruptions = sleepPoints
          .where((dp) => dp.type == HealthDataType.SLEEP_AWAKE)
          .length;

      // Calculate time in bed
      final timeInBedMinutes = wakeTime.difference(bedTime).inMinutes;

      // Calculate total sleep time
      final totalSleepMinutes =
          (deepDuration ?? 0) +
          (lightDuration ?? 0) +
          (remDuration ?? 0) +
          (unspecifiedDuration ?? 0);

      // Calculate sleep efficiency
      final sleepEfficiency = timeInBedMinutes > 0
          ? (totalSleepMinutes / timeInBedMinutes) * 100
          : null;

      // Extract device info
      final deviceInfo = _extractDeviceInfo(sessionPoint);

      // Calculate biometric averages
      final heartRate = _calculateAverage(
        biometricPoints,
        HealthDataType.HEART_RATE,
      );
      final hrv = _calculateAverage(
        biometricPoints,
        HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
      );
      final respiratoryRate = _calculateAverage(
        biometricPoints,
        HealthDataType.RESPIRATORY_RATE,
      );

      // Get wrist temperature (iOS only)
      double? wristTemp;
      try {
        final tempData = biometricPoints.where(
          (dp) => dp.type.name == 'BODY_TEMPERATURE',
        );
        if (tempData.isNotEmpty) {
          wristTemp = _calculateAverage(
            tempData.toList(),
            tempData.first.type,
          )?.toDouble();
        }
      } catch (e) {
        // Wrist temperature not available
      }

      return SleepSession(
        userId: userId,
        bedTime: bedTime,
        wakeTime: wakeTime,
        sessionDate: DateTime(bedTime.year, bedTime.month, bedTime.day),
        deepSleepDuration: deepDuration,
        lightSleepDuration: lightDuration,
        remSleepDuration: remDuration,
        awakeDuration: awakeDuration,
        unspecifiedSleepDuration: unspecifiedDuration,
        interruptions: interruptions,
        timeInBedMinutes: timeInBedMinutes,
        sleepEfficiency: sleepEfficiency,
        restingHeartRate: heartRate,
        hrv: hrv,
        respiratoryRate: respiratoryRate,
        wristTemperature: wristTemp,
        sleepDataSource: Platform.isIOS ? 'healthkit' : 'healthconnect',
        deviceType: deviceInfo['type'],
        deviceModel: deviceInfo['model'],
        recordingMethod: 'automatic',
        usedButler: false, // Will be updated based on app usage
        thoughtsProcessed: 0, // Will be updated based on app usage
      );
    } catch (e) {
      print('Error converting to SleepSession: $e');
      return null;
    }
  }

  int? _calculateStageDuration(List<HealthDataPoint> points, HealthDataType type) {
    final stagePoints = points.where((p) => p.type == type).toList();
    if (stagePoints.isEmpty) return null;
    
    int totalMinutes = 0;
    for (var p in stagePoints) {
      totalMinutes += p.dateTo.difference(p.dateFrom).inMinutes;
    }
    return totalMinutes;
  }

  int? _calculateAverage(List<HealthDataPoint> points, HealthDataType type) {
    final typePoints = points.where((p) => p.type == type).toList();
    if (typePoints.isEmpty) return null;
    
    double sum = 0;
    int count = 0;
    for (var p in typePoints) {
      final value = p.value;
      if (value is NumericHealthValue) {
        sum += value.numericValue;
        count++;
      }
    }
    return count > 0 ? (sum / count).round() : null;
  }

  /// Extract device information from health data point
  Map<String, String?> _extractDeviceInfo(HealthDataPoint point) {
    String? deviceType;
    String? deviceModel;

    // Use sourcePlatform instead of platform
    if (point.sourcePlatform == HealthPlatformType.appleHealth) {
      deviceType = 'watch'; // Assume Apple Watch for iOS
      deviceModel = point.sourceId; // May contain device info
    } else if (point.sourcePlatform == HealthPlatformType.googleHealthConnect) {
      deviceType = 'phone'; // Default to phone for Android
      deviceModel = point.sourceId;
    }

    return {
      'type': deviceType,
      'model': deviceModel,
    };
  }

  /// Get sleep sessions for a date range
  Future<List<SleepSession>> getSleepSessions(
    DateTime start,
    DateTime end,
    int userId,
  ) async {
    final sleepData = await fetchSleepData(start, end);
    final biometricData = await fetchBiometricData(start, end);

    // Group sleep data by session
    final sessionMap = <DateTime, List<HealthDataPoint>>{};
    
    for (var point in sleepData) {
      if (point.type == HealthDataType.SLEEP_SESSION) {
        sessionMap[point.dateFrom] = [point];
      }
    }

    // Add stage data to each session
    for (var point in sleepData) {
      if (point.type != HealthDataType.SLEEP_SESSION) {
        // Find the session this stage belongs to
        for (var sessionStart in sessionMap.keys) {
          final sessionEnd = sessionMap[sessionStart]!.first.dateTo;
          if (point.dateFrom.isAfter(sessionStart) &&
              point.dateFrom.isBefore(sessionEnd)) {
            sessionMap[sessionStart]!.add(point);
            break;
          }
        }
      }
    }

    // Convert each session
    final sessions = <SleepSession>[];
    for (var sessionPoints in sessionMap.values) {
      // Get biometric data for this session
      final sessionStart = sessionPoints.first.dateFrom;
      final sessionEnd = sessionPoints.first.dateTo;
      final sessionBiometrics = biometricData.where((bp) =>
          bp.dateFrom.isAfter(sessionStart) &&
          bp.dateFrom.isBefore(sessionEnd)).toList();

      final session = convertToSleepSession(
        sessionPoints,
        sessionBiometrics,
        userId,
      );

      if (session != null) {
        sessions.add(session);
      }
    }

    return sessions;
  }
}
