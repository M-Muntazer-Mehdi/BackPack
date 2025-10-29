import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/services/fcm_service.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground
        FCMService.updateUserStatus(true);
        print('📱 App resumed - User is online');
        break;
        
      case AppLifecycleState.paused:
        // App is in background
        FCMService.updateUserStatus(false);
        print('📱 App paused - User is offline');
        break;
        
      case AppLifecycleState.detached:
        // App is terminated
        FCMService.updateUserStatus(false);
        print('📱 App detached - User is offline');
        break;
        
      case AppLifecycleState.inactive:
        // App is inactive (e.g., phone call, notification panel)
        // Don't change status for inactive state
        break;
        
      case AppLifecycleState.hidden:
        // App is hidden
        FCMService.updateUserStatus(false);
        print('📱 App hidden - User is offline');
        break;
    }
  }
}

