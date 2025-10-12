import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/auth_controllers/login_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/screens/auth_screens/forget_password.dart';
import 'package:back_packers/screens/auth_screens/sign_up.dart';
import 'package:back_packers/screens/main_screens/bottom_bar_screen.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/primary_button.dart';
import 'package:back_packers/widgets/text_fields.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var controller = Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(18))),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(children: [
                    Image.asset(
                      'assets/images/login_img.png',
                      height: wd(150),
                    ),
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
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                // shrinkWrap: true,
                // padding:
                //     EdgeInsets.symmetric(horizontal: wd(30), vertical: ht(15)),
                children: [
                  SizedBox(
                    height: ht(40),
                  ),
                  Text(
                    'Login',
                    style: headingText(color: Colors.white, size: 24),
                  ),
                  SizedBox(
                    height: ht(8),
                  ),
                  Text(
                    'Enter your email and password',
                    style: normalText(color: Colors.white, size: 12),
                  ),
                  SizedBox(
                    height: ht(34),
                  ),
                  GetBuilder<LoginController>(builder: (value) {
                    return Column(
                      children: [
                        _userSignUp(value),
                        SizedBox(
                          height: ht(10),
                        ),
                        _rememberMeForgetPassword(),
                        SizedBox(
                          height: ht(20),
                        ),
                        PrimaryButton(
                          label: 'SIGN IN',
                          // whiteButton: true,
                          onPress: () {
                            controller.getLogin();
                          },
                        ),
                        const SizedBox(
                          height: 23,
                        ),
                        Text(
                          'Didn’t have an accoount?',
                          style: regularText(color: Colors.white, size: 12),
                        ),
                        const SizedBox(
                          height: 23,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          height: 55,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => const SignUpScreen());
                            },
                            style: ButtonStyle(
                                shadowColor: const MaterialStatePropertyAll(
                                    Colors.transparent),
                                elevation: MaterialStateProperty.all(0),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                )),
                            child: Text(
                              'Create an Account',
                              style: regularText(size: 18)
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        )
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

  Widget _userSignUp(LoginController value) {
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
                  color: AppColors.colorWhite,
                ),
              ),
            ),
            hint: 'Email'),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
            controller.controllerPassword,
            controller.focusNodePassword,
            [],
            SizedBox(
              height: 50,
              width: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/ic_lock.png',
                  height: 18,
                  color: AppColors.colorWhite,
                ),
              ),
            ),
            hint: 'Password',
            obscure: controller.obscure,
            suffixIcon: GestureDetector(
                onTap: () {
                  controller.obscure = !controller.obscure;
                  controller.update();
                },
                child: Icon(
                  controller.obscure ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.colorWhite,
                ))),
        SizedBox(
          height: ht(12),
        ),
      ],
    );
  }

  _rememberMeForgetPassword() => Row(
        children: [
          GetBuilder<LoginController>(builder: (value) {
            return Container(
              margin: const EdgeInsets.only(left: 3),
              height: 20,
              width: 20,
              child: Checkbox(
                  value: value.isRememberMe,
                  onChanged: (check) => controller.rememberMe(check!)),
            );
          }),
          Expanded(
            child: Text(
              ' Remember Me',
              style: regularText(size: 13, color: AppColors.colorWhite),
            ),
          ),
          InkWell(
            onTap: () => Get.to(() => const ForgetPassword()),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Forgot Password?',
                style: regularText(size: 13, color: HexColor('#AD3D3D')),
              ),
            ),
          )
        ],
      );
}
