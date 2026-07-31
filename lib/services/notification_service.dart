import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../models/meeting.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static final Map<int, Timer> _webTimers = {};

  static bool _ready = false;

  static bool get isSupported {
    if (kIsWeb) {
      return WebFlutterLocalNotificationsPlugin.isSupported;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  static Future<void> initialise() async {
    timezone_data.initializeTimeZones();

    if (!kIsWeb) {
      try {
        final localTimeZone =
            await FlutterTimezone.getLocalTimezone();

        final location = timezone.getLocation(
          localTimeZone.identifier,
        );

        timezone.setLocalLocation(location);
      } catch (_) {
        timezone.setLocalLocation(timezone.UTC);
      }
    }

    if (!isSupported) {
      return;
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      web: WebInitializationSettings(),
    );

    try {
      final result = await _notifications.initialize(
        settings: settings,
      );

      _ready = result ?? true;
    } catch (_) {
      _ready = false;
    }
  }

  static Future<bool> requestPermission() async {
    if (!_ready) {
      return false;
    }

    try {
      // Chrome permission.
      if (kIsWeb) {
        final webPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                WebFlutterLocalNotificationsPlugin>();

        if (webPlugin == null) {
          return false;
        }

        if (webPlugin.permissionStatus ==
            WebNotificationPermission.granted) {
          return true;
        }

        final result =
            await webPlugin.requestNotificationsPermission();

        return result ?? false;
      }

      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        await androidPlugin?.requestExactAlarmsPermission();

        final result =
            await androidPlugin?.requestNotificationsPermission();

        return result ?? true;
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

        final result = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

        return result ?? false;
      }

      if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>();

        final result = await macPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

        return result ?? false;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> scheduleMeeting({
    required Meeting meeting,
    required bool german,
  }) async {
    if (!_ready || !meeting.enabled) {
      return;
    }

    final startAtExactMinute = DateTime(
      meeting.startTime.year,
      meeting.startTime.month,
      meeting.startTime.day,
      meeting.startTime.hour,
      meeting.startTime.minute,
    );

    final reminderTime = startAtExactMinute.subtract(
      const Duration(minutes: 1),
    );

    if (!reminderTime.isAfter(DateTime.now())) {
      return;
    }

    final modeText = meeting.mode == 'vibrate'
        ? (german ? 'Vibrationsmodus' : 'Vibrate mode')
        : (german ? 'Lautlosmodus' : 'Silent mode');

    final title = german
        ? 'Meeting-Erinnerung'
        : 'Meeting Reminder';

    final body = german
      ? '${meeting.title} beginnt in 1 Minute. $modeText.'
      : '${meeting.title} starts in 1 minute. $modeText.';

    if (kIsWeb) {
      _webTimers[meeting.id]?.cancel();

      final delay = reminderTime.difference(
        DateTime.now(),
      );

      _webTimers[meeting.id] = Timer(
        delay,
        () async {
          await _showNotification(
            id: meeting.id,
            title: title,
            body: body,
          );

          _webTimers.remove(meeting.id);
        },
      );

      return;
    }

    final scheduledTime = timezone.TZDateTime.from(
      reminderTime,
      timezone.local,
    );

    final vibrate = meeting.mode == 'vibrate';

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        vibrate
            ? 'meeting_vibrate_channel_v2'
            : 'meeting_silent_channel_v2',
        vibrate
            ? 'Vibrate Meeting Reminders'
            : 'Silent Meeting Reminders',
        channelDescription:
            'Notifications before scheduled meetings',
        importance: Importance.high,
        priority: Priority.high,
        playSound: false,
        enableVibration: vibrate,
      ),
      iOS: const DarwinNotificationDetails(
        presentSound: false,
      ),
      macOS: const DarwinNotificationDetails(
        presentSound: false,
      ),
    );

    try {
      await _notifications.zonedSchedule(
        id: meeting.id,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        notificationDetails: notificationDetails,
        androidScheduleMode:
            AndroidScheduleMode.exactAllowWhileIdle,
        payload: meeting.id.toString(),
      );
    } catch (_) {
    }
  }

  static Future<void> cancelMeeting(
    int meetingId,
  ) async {
    _webTimers[meetingId]?.cancel();
    _webTimers.remove(meetingId);

    if (!_ready) {
      return;
    }

    try {
      await _notifications.cancel(
        id: meetingId,
      );
    } catch (_) {
    }
  }

  static Future<void> rescheduleAll({
    required List<Meeting> meetings,
    required bool german,
  }) async {
    if (!_ready) {
      return;
    }

    for (final timer in _webTimers.values) {
      timer.cancel();
    }

    _webTimers.clear();

    for (final meeting in meetings) {
      await cancelMeeting(meeting.id);

      if (meeting.enabled &&
          meeting.endTime.isAfter(DateTime.now())) {
        await scheduleMeeting(
          meeting: meeting,
          german: german,
        );
      }
    }
  }

  static Future<bool> showTestNotification({
    required bool german,
  }) async {
    if (!_ready) {
      return false;
    }

    try {
      await _showNotification(
        id: 999999,
        title: german
            ? 'Benachrichtigungen aktiviert'
            : 'Notifications enabled',
        body: german
            ? 'Meeting-Erinnerungen sind jetzt aktiviert.'
            : 'Meeting reminders are now enabled.',
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'meeting_test_silent_channel_v2',
        'Meeting Notifications',
        channelDescription:
            'Silent notifications for Meeting Mode',
        importance: Importance.high,
        priority: Priority.high,
        playSound: false,
        enableVibration: false,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: false,
      ),
      macOS: DarwinNotificationDetails(
        presentSound: false,
      ),
      web: WebNotificationDetails(
        requireInteraction: true,
      ),
    );

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
}