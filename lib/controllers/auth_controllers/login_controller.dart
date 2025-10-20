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
import '../../widgets/error_modal.dart';

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
          ErrorModal.show(
            title: 'Account Not Found',
            message: 'Unable to retrieve account information. Please try again.',
          );
          return;
        }

        await Get.find<UserDetail>().setData(user);
        await Get.find<UserDetail>().getData();

        EasyLoading.dismiss();
        Get.offAll(() => NavBarScreen());
      } else {
        EasyLoading.dismiss();
        await Future.delayed(const Duration(milliseconds: 100));
        ErrorModal.show(
          title: 'Login Failed',
          message: 'Email or password are incorrect. Please check your credentials and try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (e.code == 'user-not-found') {
        ErrorModal.show(
          title: 'Account Not Found',
          message: 'We couldn\'t find an account with this email address. Please check and try again or create a new account.',
        );
      } else if (e.code == 'wrong-password') {
        ErrorModal.show(
          title: 'Incorrect Password',
          message: 'The password you entered is incorrect. Please try again or reset your password.',
        );
      } else if (e.code == 'invalid-email') {
        ErrorModal.show(
          title: 'Invalid Email',
          message: 'Please enter a valid email address.',
        );
      } else if (e.code == 'user-disabled') {
        ErrorModal.show(
          title: 'Account Disabled',
          message: 'This account has been disabled. Please contact support for assistance.',
        );
      } else if (e.code == 'too-many-requests') {
        ErrorModal.show(
          title: 'Too Many Attempts',
          message: 'Too many failed login attempts. Please try again later or reset your password.',
        );
      } else {
        ErrorModal.show(
          title: 'Login Failed',
          message: 'Email or password are incorrect. Please check your credentials and try again.',
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      await Future.delayed(const Duration(milliseconds: 100));
      print(e);
      ErrorModal.show(
        title: 'Something Went Wrong',
        message: 'We encountered an unexpected error. Please try again in a moment.',
      );
    }
  }
}
