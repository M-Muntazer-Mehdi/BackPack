import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:back_packers/services/local_notifications_helper.dart';

class FirebaseUtils {
  Future<void> pushNotifications() async {
    // 2. Instantiate Firebase Messaging
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else {
      log('User declined or has not accepted permission');
    }
    messaging.subscribeToTopic('global');
    FirebaseMessaging.instance.getInitialMessage().then((message) {});
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      LocalNotificationChannel.display(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
    FirebaseMessaging.onMessage.listen((event) async {
      // var data = jsonEncode(event.data);
      // log("FCM data: $data");
    });
    var token = await messaging.getToken();
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'token': token});
    }
    log('token $token');
  }
}
