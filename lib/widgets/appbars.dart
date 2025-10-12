import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/mainScreen_controllers/navbar_controller.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';

PreferredSize customAppBar(
    {String title = '', Widget? lable, bool backButton = true, actions}) {
  return PreferredSize(
    preferredSize: const Size(double.infinity, 70),
    child: AppBar(
      actions: actions,
      backgroundColor: AppColors.scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: backButton
          ? GestureDetector(
              onTap: () {
                Get.back();
              },
              child: const Padding(
                padding: EdgeInsets.only(top: 15, left: 20),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 27,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: lable ??
            Text(
              title,
              style: headingText(size: 22, color: Colors.white),
            ),
      ),
    ),
  );
}
