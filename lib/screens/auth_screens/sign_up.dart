import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/auth_controllers/sign_up_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/screens/other_screens/pick_location_controller.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/primary_button.dart';
import 'package:back_packers/widgets/text_fields.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var controller = Get.put(SignUpController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: wd(30), vertical: ht(15)),
          children: [
            SizedBox(
              height: ht(40),
            ),
            Text(
              'Create Account',
              style: headingText(color: Colors.white, size: 24),
            ),
            SizedBox(
              height: ht(8),
            ),
            Text(
              'Complete form below to continue ',
              style: normalText(color: Colors.white, size: 12),
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
                  GestureDetector(
                    onTap: () {
                      controller.changeTerms();
                    },
                    child: Row(
                      children: [
                        GetBuilder<SignUpController>(builder: (value) {
                          return Container(
                            margin: const EdgeInsets.only(left: 3),
                            height: 20,
                            width: 20,
                            child: Checkbox(
                                activeColor: AppColors.primaryColor,
                                value: value.terms,
                                onChanged: (check) => controller.changeTerms()),
                          );
                        }),
                        Expanded(
                          child: Text(
                            '  Accept terms & conditions',
                            style: normalText(
                                size: 13, color: AppColors.borderColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ht(20),
                  ),
                  PrimaryButton(
                    label: 'Continue',
                    onPress: () async {
                      if (await controller.initvalidation()) {
                        controller.createUser();
                      }
                    },
                  ),
                  SizedBox(
                    height: ht(20),
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: normalText(
                              size: 13, color: AppColors.borderColor),
                        ),
                        Text(
                          'Sign in here',
                          style: regularText(
                              size: 13, color: AppColors.primaryColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ht(40),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _userSignUp(SignUpController value) {
    return Column(
      children: [
        customTextFiled(
            controller.controllerFirstName,
            controller.focusNodeFirstName,
            [],
            SizedBox(
              height: 50,
              width: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/ic_person.png',
                  height: 18,
                  color: AppColors.iconColor,
                ),
              ),
            ),
            hint: 'First Name'),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
            controller.controllerLastName,
            controller.focusNodeLastName,
            [],
            SizedBox(
              height: 50,
              width: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/ic_person.png',
                  height: 18,
                  color: AppColors.iconColor,
                ),
              ),
            ),
            hint: 'Last Name'),
        SizedBox(
          height: ht(12),
        ),
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
            hint: 'Email'),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
          controller.locationController,
          controller.locationNode,
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
          ontap: () {
            Get.to(() => PickLocation(onSubmit: (loc, latlang) {
                  Get.back();
                  controller.latlng = latlang;
                  controller.locationController.text = loc ?? '';
                }));
          },
          hint: 'Location',
        ),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
            controller.controllerPhone,
            controller.focusNodePhone,
            [],
            SizedBox(
              height: 50,
              width: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/ic_phone.png',
                  height: 13,
                  color: AppColors.iconColor,
                ),
              ),
            ),
            hint: 'Phone',
            textInputType: TextInputType.number),
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
                  color: AppColors.iconColor,
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
                  color: AppColors.iconColor,
                ))),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
            controller.controllerConfirmPassword,
            controller.focusNodeConfirm,
            [],
            SizedBox(
              height: 50,
              width: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/ic_lock.png',
                  height: 18,
                  color: AppColors.iconColor,
                ),
              ),
            ),
            hint: 'Re-type Password',
            obscure: controller.obscure,
            suffixIcon: GestureDetector(
                onTap: () {
                  controller.obscure = !controller.obscure;
                  controller.update();
                },
                child: Icon(
                  controller.obscure ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.iconColor,
                ))),
      ],
    );
  }
}
