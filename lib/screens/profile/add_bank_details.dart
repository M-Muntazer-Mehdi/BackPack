import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/auth_controllers/sign_up_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/primary_button.dart';
import 'package:back_packers/widgets/text_fields.dart';

class AddBank extends StatefulWidget {
  const AddBank({super.key});

  @override
  State<AddBank> createState() => _AddBankState();
}

class _AddBankState extends State<AddBank> {
  TextEditingController nameCont = TextEditingController();
  TextEditingController holderCont = TextEditingController();
  TextEditingController numberCont = TextEditingController();
  FocusNode nameFocus = FocusNode();
  FocusNode numberFocus = FocusNode();
  FocusNode holderFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: wd(30), vertical: ht(15)),
          children: [
            SizedBox(
              height: ht(20),
            ),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: Icon(Icons.keyboard_arrow_left)),
                    ),
                  ),
                ),
                Text(
                  'Add Bank Details',
                  style: headingText(size: 13, color: Colors.black),
                ),
                Spacer()
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              'Enter your bank details',
              style: regularText(size: 32),
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
                  label: 'Add Acount',
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
            nameCont,
            nameFocus,
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
            color: Colors.white,
            hint: 'Registration Number'),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
            numberCont,
            numberFocus,
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
            color: Colors.white,
            hint: 'Registration Number'),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
            holderCont,
            holderFocus,
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
            color: Colors.white,
            hint: 'Registration Number'),
        SizedBox(
          height: ht(12),
        ),
      ],
    );
  }
}
