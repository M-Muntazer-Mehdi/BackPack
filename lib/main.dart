import 'dart:ui';

import 'package:back_packers/screens/main_screens/bottom_bar_screen.dart';
import 'package:back_packers/services/firebase_utils.dart';
import 'package:back_packers/services/local_notifications_helper.dart';
import 'package:back_packers/services/fcm_service.dart';
import 'package:back_packers/services/app_lifecycle_observer.dart';
import 'package:back_packers/utils/app_theme_input_dec.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/widgets/error_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';

import 'bindings/initial_binding.dart';
import 'globals/adaptive_helper.dart';
import 'screens/splash/initial_splash_screen.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase error is : $e");
  }

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    EasyLoading.dismiss();
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    Future.delayed(Duration.zero, () {
      EasyLoading.dismiss();
    });
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return CustomError(errorDetails: errorDetails);
  };
  LocalNotificationChannel.initializer();
  FirebaseUtils().pushNotifications();
  
  // Initialize FCM Service
  await FCMService.initialize();
  
  // Add app lifecycle observer
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());
  
  EasyLoading().dismissOnTap = false;
  EasyLoading().userInteractions = false;

  var user = Get.put(UserDetail());
  await user.getData();

  var login = await user.isLogin();
  runApp(OverlaySupport(child: BoosterMaterialApp(login: login)));
}

class BoosterMaterialApp extends StatelessWidget {
  final bool login;
  const BoosterMaterialApp({super.key, required this.login});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrainst) {
        Responsive.init(constrainst.maxHeight, constrainst.maxWidth);
        return GetMaterialApp(
          title: 'Backpackers',
          themeMode: ThemeMode.light,
          theme: AppTheme.data(),
          fallbackLocale: const Locale('en', 'US'),
          locale: const Locale('en', 'US'),
          defaultTransition: Transition.cupertino,
          debugShowCheckedModeBanner: false,
          initialBinding: InitialBinding(),
          home: InitialSplashScreen(isLoggedIn: login),
          builder: EasyLoading.init(),
        );
      },
    );
  }
}
