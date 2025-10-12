import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../globals/database.dart';
import '../../globals/enum.dart';
import '../../globals/global.dart';
import '../../screens/main_screens/bottom_bar_screen.dart';
import '../../utils/login_details.dart';

class LoginController extends GetxController {
  bool isRememberMe = false;
  bool obscure = true;

  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();

  FocusNode focusNodeEmail = FocusNode();

  FocusNode focusNodePassword = FocusNode();

  TextEditingController controllerPhone = TextEditingController();

  FocusNode focusNodePhone = FocusNode();

  rememberMe(bool value) {
    isRememberMe = value;
    update();
  }

  toggleeye() {
    obscure = !obscure;
    update();
  }

  bool validation() {
    if (!Global.checkNull(controllerEmail.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please enter email',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(focusNodeEmail);
      return false;
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(controllerEmail.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please enter a valid email',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(focusNodeEmail);
      return false;
    }
    if (!Global.checkNull(controllerPassword.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "ok",
          strMsg: 'Please enter password',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(focusNodePassword);
      return false;
    }

    return true;
  }

  var isLoading = false;

  forgetPassword() async {
    if (!validation()) return;
    try {} catch (e) {}

    Get.to(() => const NavBarScreen());
  }

  Future<void> getLogin() async {
    try {
      if (!validation()) return;
      EasyLoading.show();
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: controllerEmail.text.trim(),
              password: controllerPassword.text);
      log(userCredential.user.toString());
      if (userCredential.user != null) {
        var user = await Database.getUser(userCredential.user!.uid);
        if (user == null) {
          EasyLoading.dismiss();
          return;
        }

        await Get.find<UserDetail>().setData(user);
        await Get.find<UserDetail>().getData();

        Get.offAll(() => NavBarScreen());

        EasyLoading.dismiss();
      } else {
        EasyLoading.dismiss();
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "ok",
            strMsg: 'Email or Password are incorrect. Please try again',
            toastType: TOAST_TYPE.toastError);
      }
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      if (e.code == 'user-not-found') {
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "ok",
            strMsg: 'No user found with the provided email address',
            toastType: TOAST_TYPE.toastError);
      } else if (e.code == 'wrong-password') {
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "ok",
            strMsg: 'Email or Password are incorrect. Please try again',
            toastType: TOAST_TYPE.toastError);
      } else {
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "ok",
            strMsg: 'Email or Password are incorrect. Please try again',
            toastType: TOAST_TYPE.toastError);
      }
    } catch (e) {
      EasyLoading.dismiss();
      print(e);
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "ok",
          strMsg: 'Email or Password are incorrect. Please try again',
          toastType: TOAST_TYPE.toastError);
    }
  }
}
