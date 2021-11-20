import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

extension DateTimeEx on tz.TZDateTime {
  tz.TZDateTime applied(TimeOfDay time) {
    return tz.TZDateTime(location, year, month, day, time.hour, time.minute);
  }
}

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() {
    return _instance;
  }
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static const int _id = 1111;

  NotificationManager._internal()
      : _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin() {
    _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  }

  void showNotificationWithDefaultSound(String title, String body) {
    _flutterLocalNotificationsPlugin.show(
      _id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
        ),
      ),
    );
  }

  Future<void> zonedScheduleNotification(TimeOfDay time) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      _id,
      "Reminder",
      "Don't forget to update transactions today",
      tz.TZDateTime.now(tz.local).applied(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
        ),
      ),
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void cancal() {
    _flutterLocalNotificationsPlugin.cancel(_id);
  }
}
