import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/screens/auth_screens/login.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/primary_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [HexColor('#000'), HexColor('#414141')],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(),
            const Spacer(
              flex: 1,
            ),
            Image.asset(
              'assets/images/splash_img.png',
              width: ht(300),
            ),
            const Spacer(
              flex: 2,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Back Pack Buddies',
                    textAlign: TextAlign.center,
                    style: headingText(
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ]),
            ),
            const Spacer(
              flex: 1,
            ),
            PrimaryButton(
              label: 'Get Started',
              onPress: () {
                Get.off(() => LoginScreen());
              },
            ),
            SizedBox(
              height: ht(40),
            )
          ],
        ),
      ),
    );
  }
}
