import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/auth_controllers/sign_up_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/primary_button.dart';
import 'package:back_packers/widgets/text_fields.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  var controller = Get.put(SignUpController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      // appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          // padding: EdgeInsets.symmetric(horizontal: wd(30), vertical: ht(15)),
          children: [
            Container(
              decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(18))),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 40),
                  child: Column(children: [
                    // Image.asset(
                    //   'assets/images/login_img.png',
                    //   height: wd(150),
                    // ),
                    Text(
                      'Back Pack Buddies',
                      textAlign: TextAlign.center,
                      style: headingText(
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            SizedBox(
              height: ht(20),
            ),
            Container(
              padding: EdgeInsets.only(top: 50, left: 20, right: 20),
              child: Column(
                children: [
                  Text(
                    'Forgot password?',
                    textAlign: TextAlign.center,
                    style: headingText(color: Colors.white, size: 26),
                  ),
                  SizedBox(
                    height: ht(20),
                  ),
                  Text(
                    'Welcome Back! Enter Your Register Email & Password',
                    textAlign: TextAlign.center,
                    style: normalText(color: Colors.white, size: 14),
                  ),
                  SizedBox(
                    height: ht(34),
                  ),
                  GetBuilder<SignUpController>(builder: (value) {
                    return Column(
                      children: [
                        _userSignUp(value),
                        SizedBox(
                          height: ht(20),
                        ),
                        PrimaryButton(
                          label: 'Submit',
                          onPress: () {
                            controller.resestPassowrd();
                          },
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userSignUp(SignUpController value) {
    return Column(
      children: [
        customTextFiled(
            controller.controllerEmail,
            controller.focusNodeEmail,
            [],
            SizedBox(
              height: 50,
              width: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/ic_email.png',
                  height: 13,
                  color: AppColors.iconColor,
                ),
              ),
            ),
            hint: 'Enter your email'),
      ],
    );
  }
}
