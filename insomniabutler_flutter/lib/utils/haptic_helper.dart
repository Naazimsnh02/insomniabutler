import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';

/// Haptic feedback helper for premium feel
class HapticHelper {
  /// Light impact feedback (for button taps)
  static Future<void> lightImpact() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 10);
      } else {
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Fallback to system haptic
      await HapticFeedback.lightImpact();
    }
  }
  
  /// Medium impact feedback (for important actions)
  static Future<void> mediumImpact() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 20);
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      await HapticFeedback.mediumImpact();
    }
  }
  
  /// Heavy impact feedback (for critical actions or success)
  static Future<void> heavyImpact() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 30);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      await HapticFeedback.heavyImpact();
    }
  }
  
  /// Selection feedback (for picker changes)
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }
  
  /// Success pattern (double vibration)
  static Future<void> success() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 20);
        await Future.delayed(const Duration(milliseconds: 100));
        await Vibration.vibrate(duration: 20);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      await HapticFeedback.heavyImpact();
    }
  }
  
  /// Error pattern (triple short vibration)
  static Future<void> error() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        for (int i = 0; i < 3; i++) {
          await Vibration.vibrate(duration: 10);
          if (i < 2) await Future.delayed(const Duration(milliseconds: 50));
        }
      } else {
        await HapticFeedback.vibrate();
      }
    } catch (e) {
      await HapticFeedback.vibrate();
    }
  }
}
