import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/app_views.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/global.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/appbars.dart';
import 'package:back_packers/widgets/delete_dialogue.dart';
import 'package:back_packers/widgets/primary_button.dart';
import 'package:back_packers/widgets/text_fields.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  TextEditingController password = TextEditingController();
  TextEditingController holderCont = TextEditingController();
  TextEditingController numberCont = TextEditingController();
  FocusNode passwordNode = FocusNode();
  FocusNode numberFocus = FocusNode();
  FocusNode holderFocus = FocusNode();

  var isLoading = false;
  changepass() async {
    try {} catch (e) {
      print(e);
      isLoading = false;
      setState(() {});
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: "Something went wrong. Try later",
          toastType: TOAST_TYPE.toastError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: wd(30), vertical: ht(15)),
          children: [
            // SizedBox(
            //   height: ht(20),
            // ),
            // Row(
            //   children: [
            //     Expanded(
            //       child: Align(
            //         alignment: Alignment.centerLeft,
            //         child: InkWell(
            //           onTap: () => Get.back(),
            //           child: Container(
            //               child: Icon(
            //             Icons.keyboard_arrow_left,
            //             color: AppColors.colorWhite,
            //             size: 32,
            //           )),
            //         ),
            //       ),
            //     ),
            //     // Text(
            //     //   'Change Password',
            //     //   style: headingText(size: 13, color: Colors.black),
            //     // ),
            //     Spacer()
            //   ],
            // ),
            const SizedBox(
              height: 30,
            ),
            Text(
              'Create new password',
              style: subHeadingText(size: 32, color: AppColors.colorWhite),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              'Your new password must be different from your previously used password',
              style: regularText(size: 12, color: AppColors.borderColor)
                  .copyWith(fontWeight: FontWeight.w300),
            ),
            SizedBox(
              height: ht(50),
            ),
            Column(
              children: [
                _userSignUp(),
                SizedBox(
                  height: ht(45),
                ),
                PrimaryButton(
                  label: 'Confirm',
                  onPress: () {},
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _userSignUp() {
    return Column(
      children: [
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
            password,
            passwordNode,
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
            // color: Colors.white,
            hint: 'Password'),
        SizedBox(
          height: ht(12),
        ),
      ],
    );
  }
}
