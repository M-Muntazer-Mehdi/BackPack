import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../globals/app_views.dart';
import '../../globals/constants.dart';
import '../../globals/enum.dart';


class NavBarController extends GetxController {
  int currentIndex = 0;
  Widget currentPage = Container();
  PageType currentPageType = PageType.home;

  changeTab(int index) {
    currentIndex = index;
    update();
  }

  onChangeBottomBar(int index) {
    update();
    switch (index) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        break;
      case 4:
        break;
    }
  }

  Future<bool> onWillPop() async {
    if (currentPageType == PageType.home) {
      return showCustomAlertExitApp() ?? false;
    } else {
      return false;
    }
  }

  showCustomAlertExitApp() {
    AppViews.showCustomAlert(
        context: Get.overlayContext!,
        strTitle: Constants.TEXT_EXIT,
        strMessage: Constants.TEXT_EXIT_MSG,
        strLeftBtnText: Constants.TEXT_NO,
        onTapLeftBtn: () {
          Get.back();
        },
        strRightBtnText: Constants.TEXT_YES,
        onTapRightBtn: () {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else {
            exit(0);
          }
        });
  }

  late AnimationController animationController;
  double maxSlide = 225.0;

  void toggle() => animationController.isDismissed
      ? animationController.forward()
      : animationController.reverse();
}
