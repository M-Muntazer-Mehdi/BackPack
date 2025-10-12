import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/globals/app_views.dart';

class Loader {
  static showLoadingDialogue() {
    return showDialog(
        barrierDismissible: false,
        context: Get.overlayContext!,
        builder: (context) => Container(
              child: AppViews.showLoading(),
            ));
  }

  static dismiss() {
    Get.back();
  }
}
