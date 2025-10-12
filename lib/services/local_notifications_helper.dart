import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationChannel {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static initializer() {
    InitializationSettings initializationSettings =
        const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'));

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      NotificationDetails notificationDetails = const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'high_importance_channel channal',
          importance: Importance.max,
          priority: Priority.max,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentBanner: true,
          presentSound: true,
        ),
      );
      await _flutterLocalNotificationsPlugin.show(
          id,
          message.notification!.title,
          message.notification!.body,
          notificationDetails);
    } catch (e) {
      log(e.toString());
    }
  }

// static Future<void> displayScheduled(title, body, DateTime dateTime) async {
//   try {
//     final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//     NotificationDetails notificationDetails = NotificationDetails(
//         android: AndroidNotificationDetails(
//             'high_importance_channel', 'high_importance_channel channal',
//             importance: Importance.max, priority: Priority.max));
//     await _flutterLocalNotificationsPlugin.zonedSchedule(id, title, body,
//         tz.TZDateTime.from(dateTime, tz.local), notificationDetails,
//         payload: "",
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime);
//     log(dateTime.toString());
//   } catch (e) {
//     log(e);
//   }
// }
}
