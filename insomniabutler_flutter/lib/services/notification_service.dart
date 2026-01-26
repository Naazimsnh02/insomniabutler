import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    debugPrint('🔔 Initializing NotificationService...');
    
    try {
      tz.initializeTimeZones();
      
      try {
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();
        final String timeZoneName = timezoneInfo.identifier;
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('✅ Timezone set to: $timeZoneName');
      } catch (e) {
        debugPrint('⚠️ Error setting local timezone: $e');
        // Fallback to UTC if timezone detection fails
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );
      debugPrint('✅ Notification plugin initialized');

      // Request permissions for Android 13+ and Exact Alarms
      final platform = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (platform != null) {
        // We wrap permission requests in a delayed future to ensure Activity is attached
        // and avoid NullPointerException on some devices/startups
        Future.delayed(const Duration(seconds: 1), () async {
          try {
            debugPrint('📱 Requesting notification permissions...');
            // Request notification permission
            final notificationPermission = await platform.requestNotificationsPermission();
            debugPrint('📱 Notification permission: ${notificationPermission == true ? "GRANTED" : "DENIED"}');
            
            // Request exact alarm permission (critical for scheduled notifications on Android 12+)
            final exactAlarmPermission = await platform.requestExactAlarmsPermission();
            debugPrint('⏰ Exact Alarm permission: ${exactAlarmPermission == true ? "GRANTED" : "DENIED"}');
            
            if (exactAlarmPermission != true) {
              debugPrint('⚠️ WARNING: Exact Alarm permission is DENIED!');
              debugPrint('   Scheduled notifications (bedtime, insights, journal, reminders) will NOT work!');
              debugPrint('   User must grant this permission in Settings > Apps > Insomnia Butler > Alarms & reminders');
            }
          } catch (e) {
            debugPrint('❌ Error requesting permissions in background: $e');
          }
        });
      }
      
      debugPrint('✅ NotificationService initialization complete');
    } catch (e, stackTrace) {
      debugPrint('❌ CRITICAL ERROR initializing NotificationService: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'insomnia_butler_channel', // channel Id
      'Insomnia Butler Notifications', // channel Name
      channelDescription: 'Notifications from Insomnia Butler',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      debugPrint('📅 Scheduling notification (ID: $id) for $scheduledTime');
      debugPrint('   Title: $title');
      debugPrint('   Body: $body');
      
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
      debugPrint('   TZ Scheduled Time: $tzScheduledTime in ${tz.local.name}');
      
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'insomnia_butler_reminders',
            'Butler Reminders',
            channelDescription: 'Scheduled reminders from your Butler',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: scheduledTime.toIso8601String(),
      );
      
      await _saveScheduledTime(id, scheduledTime);
      debugPrint('✅ Notification scheduled successfully (ID: $id)');
      
      // Verify it was scheduled
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      final scheduled = pending.where((p) => p.id == id).toList();
      if (scheduled.isNotEmpty) {
        debugPrint('✅ Verified: Notification $id is in pending list');
      } else {
        debugPrint('⚠️ WARNING: Notification $id NOT found in pending list!');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR scheduling notification (ID: $id): $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    try {
      debugPrint('📅 Scheduling DAILY notification (ID: $id)');
      debugPrint('   Title: $title');
      debugPrint('   Time: ${time.hour}:${time.minute}');
      
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        debugPrint('   Time already passed today, scheduling for tomorrow');
      }

      debugPrint('   Scheduled for: $scheduledDate in ${tz.local.name}');

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'insomnia_butler_daily_reminders_v2',
            'Daily Reminders',
            channelDescription: 'Daily reminders for your sleep hygiene',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      
      // CRITICAL FIX: Save the scheduled time for daily notifications
      await _saveScheduledTime(id, scheduledDate.toLocal());
      
      debugPrint('✅ Daily notification scheduled successfully (ID: $id)');
      
      // Verify it was scheduled
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      final scheduled = pending.where((p) => p.id == id).toList();
      if (scheduled.isNotEmpty) {
        debugPrint('✅ Verified: Daily notification $id is in pending list');
      } else {
        debugPrint('⚠️ WARNING: Daily notification $id NOT found in pending list!');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR scheduling daily notification (ID: $id): $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_time_$id');
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Debug method to print all pending notifications
  static Future<void> debugPrintPendingNotifications() async {
    try {
      final pending = await getPendingNotifications();
      debugPrint('📋 Pending Notifications (${pending.length} total):');
      if (pending.isEmpty) {
        debugPrint('   No pending notifications');
      } else {
        for (var notification in pending) {
          final scheduledTime = await getScheduledTime(notification.id);
          debugPrint('   ID: ${notification.id} | Title: ${notification.title} | Body: ${notification.body}');
          if (scheduledTime != null) {
            debugPrint('      Scheduled for: $scheduledTime');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error getting pending notifications: $e');
    }
  }

  static Future<void> _saveScheduledTime(int id, DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_time_$id', time.toIso8601String());
  }

  static Future<DateTime?> getScheduledTime(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString('notification_time_$id');
    if (timeStr != null) {
      return DateTime.tryParse(timeStr);
    }
    return null;
  }

  static Future<void> showFullScreenNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'insomnia_butler_alarm_channel',
      'Insomnia Butler Alarms',
      channelDescription: 'High priority notifications for cleaning',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true, // This attempts to show as a full screen intent/HUD
      category: AndroidNotificationCategory.alarm,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  /// Test method to verify notifications are working
  /// Sends an immediate test notification
  static Future<void> sendTestNotification() async {
    debugPrint('🧪 Sending test notification...');
    try {
      await showNotification(
        id: 9999,
        title: 'Test Notification ✅',
        body: 'If you see this, notifications are working correctly!',
      );
      debugPrint('✅ Test notification sent successfully');
    } catch (e) {
      debugPrint('❌ Error sending test notification: $e');
    }
  }
}
