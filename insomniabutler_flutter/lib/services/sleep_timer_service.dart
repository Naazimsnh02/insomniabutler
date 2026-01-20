import 'dart:async';
import 'package:flutter/foundation.dart';

/// Singleton service to manage sleep timer state across screens
class SleepTimerService {
  static final SleepTimerService _instance = SleepTimerService._internal();
  factory SleepTimerService() => _instance;
  SleepTimerService._internal();

  DateTime? _startTime;
  bool _isRunning = false;
  
  DateTime? get startTime => _startTime;
  bool get isRunning => _isRunning;

  final _updateController = StreamController<Duration>.broadcast();
  Stream<Duration> get onTick => _updateController.stream;
  
  final _statusController = StreamController<bool>.broadcast();
  Stream<bool> get onStatusChange => _statusController.stream;
  
  Timer? _timer;

  void start() {
    if (_isRunning) return;
    _startTime = DateTime.now();
    _isRunning = true;
    _statusController.add(true);
    _startTimer();
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
    _statusController.add(false);
  }

  void reset() {
    stop();
    _startTime = null;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        _updateController.add(DateTime.now().difference(_startTime!));
      }
    });
  }

  Duration get currentDuration {
    if (_startTime == null) return Duration.zero;
    return DateTime.now().difference(_startTime!);
  }
}
