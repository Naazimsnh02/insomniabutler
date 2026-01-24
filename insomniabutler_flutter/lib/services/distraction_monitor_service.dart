import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:installed_apps/installed_apps.dart';
import 'account_settings_service.dart';
import 'notification_service.dart';

class DistractionMonitorService {
  // Singleton pattern
  static final DistractionMonitorService _instance = DistractionMonitorService._internal();
  static DistractionMonitorService get instance => _instance;
  DistractionMonitorService._internal();

  // State
  String? _currentDistractionPackage;
  DateTime? _sessionStartTime;
  DateTime? _lastNudgeTime;
  int _nudgeCount = 0;

  // Configuration
  static const Duration _checkInterval = Duration(seconds: 3);
  
  // Backoff Strategy (Time to wait before next nudge)
  // Index 0 (First Nudge): Wait 0 seconds (after initial detection buffer)
  // Index 1 (Second Nudge): Wait 2 minutes
  // Index 2 (Third Nudge): Wait 10 minutes
  // After that: Stop
  final List<Duration> _backoffIntervals = [
    Duration.zero,
    const Duration(minutes: 2),
    const Duration(minutes: 10),
  ];

  Timer? _monitorTimer;
  bool _isRunning = false;

  /// Start monitoring
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    debugPrint('DistractionMonitorService: Started');
    
    _monitorTimer = Timer.periodic(_checkInterval, (timer) => _check());
  }

  /// Stop monitoring
  void stop() {
    _monitorTimer?.cancel();
    _isRunning = false;
    _resetState();
    debugPrint('DistractionMonitorService: Stopped');
  }

  void _resetState() {
    _currentDistractionPackage = null;
    _sessionStartTime = null;
    _lastNudgeTime = null;
    _nudgeCount = 0;
  }

  Future<void> _check() async {
    try {
      // 1. Check if enabled
      final isEnabled = await AccountSettingsService.getDistractionBlockingEnabled();
      if (!isEnabled) {
        if (_currentDistractionPackage != null) _resetState();
        return;
      }
      
      // 2. Check if it is bedtime
      if (!(await _isBedtime())) {
        if (_currentDistractionPackage != null) _resetState();
        return;
      }

      // 3. Identify Foreground App
      final foregroundPackage = await _getForegroundApp();
      
      // Ignore valid contexts (Launcher, self, System UI)
      if (foregroundPackage == null || 
          foregroundPackage == 'com.example.insomniabutler_flutter' || 
          foregroundPackage == 'com.example.insomniabutler' ||
          foregroundPackage.contains('launcher') || // Generic launcher catch
          foregroundPackage.contains('systemui')) {
            // User is "safe" or navigating.
            // If they were previously distracted, we reset state immediately (Context Switch logic)
            // This means if they leave Twitter to go Home, and come back, it starts over.
            if (_currentDistractionPackage != null) {
               debugPrint('DistractionMonitorService: User switched to safe context. Resetting state.');
               _resetState();
            }
            return;
      }

      // 4. Check if Blocked
      final blockedApps = await AccountSettingsService.getBlockedApps();
      
      if (blockedApps.contains(foregroundPackage)) {
        await _handleDistraction(foregroundPackage);
      } else {
        // User is in a "Safe App" (e.g., Reading app, Utility)
        if (_currentDistractionPackage != null) {
           debugPrint('DistractionMonitorService: User switched to safe app ($foregroundPackage). Resetting state.');
           _resetState();
        }
      }

    } catch (e) {
      debugPrint('DistractionMonitorService error: $e');
    }
  }

  Future<void> _handleDistraction(String package) async {
    final now = DateTime.now();

    // A. Context Switching (Hopping logic)
    if (_currentDistractionPackage != package) {
      // New distraction app found!
      debugPrint('DistractionMonitorService: New distraction detected ($package). Resetting count.');
      _currentDistractionPackage = package;
      _sessionStartTime = now;
      _nudgeCount = 0;
      _lastNudgeTime = null;
    }

    // B. Nudge Decision Logic
    // If we have exceeded our max nudges, we stay silent for this session
    if (_nudgeCount >= _backoffIntervals.length) {
       return;
    }

    // Calculate if it's time to nudge based on backoff
    final requiredWait = _backoffIntervals[_nudgeCount];
    
    bool shouldNudge = false;

    if (_lastNudgeTime == null) {
      // First nudge of the session
      // Add a small buffer (e.g., 5 seconds) from session start to avoid accidental nudges
      // This prevents immediate spam if they just accidentally tapped it
      if (_sessionStartTime != null && now.difference(_sessionStartTime!) > const Duration(seconds: 5)) {
        shouldNudge = true;
      }
    } else {
      // Subsequent nudges
      if (now.difference(_lastNudgeTime!) >= requiredWait) {
        shouldNudge = true;
      }
    }

    if (shouldNudge) {
      await _sendNudge(package);
    }
  }

  Future<void> _sendNudge(String package) async {
    _lastNudgeTime = DateTime.now();
    _nudgeCount++;

    String appName = package;
    try {
      final info = await InstalledApps.getAppInfo(package);
      if (info != null) appName = info.name ?? package;
    } catch (_) {}

    String title = "Sleep Goal Check-in";
    String body = "";

    switch (_nudgeCount) {
      case 1:
        body = "It looks like $appName is keeping you up. Ready to rest?";
        break;
      case 2:
        body = "Still browsing? Your sleep is waiting for you.";
        break;
      case 3:
        body = "We'll let you be now, but remember your goal for tomorrow morning.";
        break;
      default:
        body = "Time to rest.";
    }

    debugPrint('DistractionMonitorService: Sending Nudge #$_nudgeCount for $appName');
    await NotificationService.showFullScreenNotification(
      id: 1001,
      title: title,
      body: body,
    );
  }

  Future<bool> _isBedtime() async {
    final now = DateTime.now();
    final startTimeStr = await AccountSettingsService.getDistractionBedtimeStart();
    final endTimeStr = await AccountSettingsService.getDistractionBedtimeEnd();
    
    final startParts = startTimeStr.split(':');
    final endParts = endTimeStr.split(':');
    
    final nowInMinutes = now.hour * 60 + now.minute;
    final startInMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endInMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    
    if (startInMinutes <= endInMinutes) {
      return nowInMinutes >= startInMinutes && nowInMinutes <= endInMinutes;
    } else {
      // Overnight (e.g., 22:00 to 06:00)
      return nowInMinutes >= startInMinutes || nowInMinutes <= endInMinutes;
    }
  }

  Future<String?> _getForegroundApp() async {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(seconds: 30)); 
      
      List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);
      
      if (usageStats.isEmpty) return null;
      
      // Filter out apps that haven't been used in the last 10 seconds
      final activeApps = usageStats.where((u) => u.lastTimeUsed != null && 
        DateTime.fromMillisecondsSinceEpoch(int.parse(u.lastTimeUsed!)).isAfter(endDate.subtract(const Duration(seconds: 10)))).toList();
      
      if (activeApps.isEmpty) return null;
      
      // Find latest
      activeApps.sort((a, b) => int.parse(b.lastTimeUsed!).compareTo(int.parse(a.lastTimeUsed!)));
      return activeApps.first.packageName;
  }
}
