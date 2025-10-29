import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/services/local_notifications_helper.dart';
import 'package:back_packers/screens/main_screens/buddies.dart';
import 'package:back_packers/screens/main_screens/chat_view/all_chats.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize FCM
  static Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('🔔 FCM Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ FCM: User granted permission');
        
        // Get FCM token
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          print('📱 FCM Token: $token');
          await _saveTokenToFirestore(token);
        }

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen(_saveTokenToFirestore);

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle notification taps when app is in background
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Handle notification tap when app is terminated
        RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }
      } else {
        print('❌ FCM: User declined or has not accepted permission');
      }
    } catch (e) {
      print('❌ FCM Initialization error: $e');
    }
  }

  // Save FCM token to Firestore
  static Future<void> _saveTokenToFirestore(String token) async {
    try {
      // Check if user is logged in
      if (!Get.isRegistered<UserDetail>()) {
        print('⏭️ FCM: User not logged in, skipping token save');
        return;
      }
      
      final userDetail = Get.find<UserDetail>();
      
      // Only save if user ID is available
      if (userDetail.userId.isEmpty) {
        print('⏭️ FCM: User ID is empty, skipping token save');
        return;
      }
      
      await _firestore.collection('users').doc(userDetail.userId).update({
        'fcmToken': token,
        'lastSeen': FieldValue.serverTimestamp(),
        'isOnline': true,
      });
      print('✅ FCM Token saved to Firestore for user: ${userDetail.userId}');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }
  
  // Public method to refresh FCM token after login
  static Future<void> refreshToken() async {
    try {
      if (!Get.isRegistered<UserDetail>()) {
        return;
      }
      
      final userDetail = Get.find<UserDetail>();
      if (userDetail.userId.isEmpty) {
        return;
      }
      
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }
    } catch (e) {
      print('❌ Error refreshing FCM token: $e');
    }
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('📨 FCM Foreground message: ${message.messageId}');
    print('📨 Message data: ${message.data}');
    
    // Show local notification for foreground messages using LocalNotificationChannel
    if (message.notification != null) {
      LocalNotificationChannel.display(message);
    }
  }

  // Handle notification taps
  static void _handleNotificationTap(RemoteMessage message) {
    print('👆 FCM Notification tapped: ${message.messageId}');
    print('👆 Notification data: ${message.data}');
    
    // Wait a bit for app to fully initialize
    Future.delayed(const Duration(milliseconds: 500), () {
      final data = message.data;
      final type = data['type'];
      
      if (type == 'connection_request') {
        // Navigate to buddies screen to see connection requests
        Get.to(() => const Buddies());
      } else if (type == 'connection_accepted') {
        // Navigate to all chats screen
        Get.to(() => const ChatScreen());
      } else if (type == 'message') {
        // Navigate to chat list screen
        // For now, navigate to chat list. To open specific chat,
        // we'd need to fetch ChatGroupModel from Firestore first
        Get.to(() => const ChatScreen());
      }
    });
  }

  // Send push notification to specific user
  static Future<void> sendNotificationToUser({
    required String targetUserId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Get target user's FCM token
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(targetUserId).get();
      
      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
        String? fcmToken = userData?['fcmToken'];
        
        if (fcmToken != null) {
          // This would typically be done via Cloud Functions
          // For now, we'll store the notification in Firestore
          await _firestore.collection('notifications').add({
            'userId': targetUserId,
            'title': title,
            'body': body,
            'data': data,
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
          
          print('✅ Notification queued for user: $targetUserId');
        } else {
          print('❌ No FCM token found for user: $targetUserId');
        }
      } else {
        print('❌ User not found: $targetUserId');
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  // Update user online status
  static Future<void> updateUserStatus(bool isOnline) async {
    try {
      final userDetail = Get.find<UserDetail>();
      await _firestore.collection('users').doc(userDetail.userId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
      print('✅ User status updated: ${isOnline ? 'Online' : 'Offline'}');
    } catch (e) {
      print('❌ Error updating user status: $e');
    }
  }

  // Get user's online status
  static Future<bool> isUserOnline(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
        return userData?['isOnline'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Error checking user status: $e');
      return false;
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📨 FCM Background message: ${message.messageId}');
  print('📨 Background message data: ${message.data}');
  
  // Handle background message here
  // Note: You can't use GetX or UI components in background handler
  // The notification will be shown automatically by the system
}

