import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// True only on platforms where flutter_local_notifications is fully supported.
  bool get _isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  Future<void> initialize() async {
    if (_isInitialized) return;
    if (!_isSupported) {
      _isInitialized = true;
      return;
    }

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Darwin covers both iOS and macOS
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    if (!_isSupported) return false;

    if (Platform.isIOS || Platform.isMacOS) {
      final impl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await impl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    } else if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted =
          await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    if (!_isSupported || Platform.isMacOS) return; // macOS doesn't support zonedSchedule
    await initialize();
    await _notificationsPlugin.cancel(0);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      0,
      'Log Your Day 🌙',
      'Take a moment to record your flow, mood, or symptoms.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Reminders to log daily info',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    if (!_isSupported) return;
    await _notificationsPlugin.cancel(0);
  }

  Future<void> schedulePredictionAlert(DateTime predictedDate) async {
    if (!_isSupported || Platform.isMacOS) return;
    await initialize();
    await _notificationsPlugin.cancel(1);

    final targetDate = predictedDate.subtract(const Duration(days: 2));
    final now = DateTime.now();

    if (targetDate.isAfter(now)) {
      final scheduledDate = tz.TZDateTime.from(targetDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        1,
        'Cycle Update 🌸',
        'Your period is predicted to start in 2 days.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'prediction_channel',
            'Cycle Predictions',
            channelDescription: 'Alerts before period starts',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> scheduleLateAlert(DateTime predictedDate) async {
    if (!_isSupported || Platform.isMacOS) return;
    await initialize();
    await _notificationsPlugin.cancel(2);

    final targetDate = predictedDate.add(const Duration(days: 1));
    final now = DateTime.now();

    if (targetDate.isAfter(now)) {
      final scheduledDate = tz.TZDateTime.from(targetDate, tz.local);

      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('displayName') ?? 'there';

      await _notificationsPlugin.zonedSchedule(
        2,
        'Period Update 🌙',
        'Hi $userName, your period is delayed by 1 day. Do you want to log it?',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'late_prediction_channel',
            'Late Alerts',
            channelDescription: 'Alerts for delayed period',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelPredictionAlerts() async {
    if (!_isSupported) return;
    await _notificationsPlugin.cancel(1);
    await _notificationsPlugin.cancel(2);
  }
}
