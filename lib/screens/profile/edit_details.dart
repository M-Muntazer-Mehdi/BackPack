import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/global.dart';
import 'package:back_packers/globals/network_image.dart';
import 'package:back_packers/models/user.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/appbars.dart';
import 'package:back_packers/widgets/custom_bottom_option_sheet.dart';
import 'package:back_packers/widgets/primary_button.dart';
import 'package:back_packers/widgets/text_fields.dart';

class EditDetails extends StatefulWidget {
  const EditDetails({super.key});

  @override
  State<EditDetails> createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> {
  TextEditingController nameCont = TextEditingController();
  TextEditingController lastnameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController numberCont = TextEditingController();
  FocusNode nameFocus = FocusNode();
  FocusNode numberFocus = FocusNode();
  FocusNode lastname = FocusNode();
  FocusNode emailFocus = FocusNode();
  String imageUrl = '';
  var isLoading = false;
  getProfile() async {
    try {
      isLoading = true;
      setState(() {});
      EasyLoading.show();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(Get.find<UserDetail>().userId)
          .get()
          .then((value) {
        UserModel user = UserModel.fromDocumentSnapshot(value);
        nameCont.text = user.fname;
        lastnameCont.text = user.lname;
        emailCont.text = user.email;
        numberCont.text = user.phone;
        imageUrl = user.image;
        setState(() {});
      });
      isLoading = false;
      setState(() {});
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      isLoading = false;
      setState(() {});
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: "Something went wrong. Try later",
          toastType: TOAST_TYPE.toastError);
    }
  }

  uploadImage({bool isCamera = true}) async {
    EasyLoading.show();
    File file = await selectImage(isCamera);
    Reference ref =
        FirebaseStorage.instance.ref().child("images/${DateTime.now()}");

    final UploadTask uploadTask = ref.putFile(file);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    final url = await taskSnapshot.ref.getDownloadURL();
    EasyLoading.dismiss();
    imageUrl = url;
    setState(() {});
  }

  selectImage(bool isCamera) async {
    XFile? image;

    ImagePicker picker = ImagePicker();
    image = await picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);

    File file = File(image!.path);
    return file;
  }

  bool initvalidation() {
    if (!Global.checkNull(nameCont.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please enter first name',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(nameFocus);
      return false;
    }
    if (!Global.checkNull(lastnameCont.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please enter last name',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(lastname);
      return false;
    }
    if (!Global.checkNull(numberCont.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please enter phone number',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(nameFocus);
      return false;
    }
    return true;
  }

  validateRegister() async {
    log('message');
    if (initvalidation()) {
      try {
        EasyLoading.show();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(Get.find<UserDetail>().userId)
            .update({
          'fname': nameCont.text,
          'lname': lastnameCont.text,
          'image': imageUrl,
          'phone': numberCont.text,
        });
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "",
            strMsg: 'Profile Updated',
            toastType: TOAST_TYPE.toastSuccess);
        Get.find<UserDetail>()
            .updateProfile(nameCont.text, lastnameCont.text, imageUrl);
        // Get.back();
        EasyLoading.dismiss();
      } catch (e) {
        EasyLoading.dismiss();
      }
    } else {
      log('message');
    }
  }

  @override
  void initState() {
    getProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(backButton: true, title: 'Edit Profile'),
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: wd(30), vertical: ht(15)),
          children: [
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                customBottomSheet(['Camera', 'Gallery'], -1, (i) {
                  if (i == 0) {
                    uploadImage();
                  } else {
                    uploadImage(isCamera: false);
                  }
                });
              },
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.grey.shade300,
                  ),
                  height: ht(90),
                  width: ht(90),
                  child: Center(
                    child: imageUrl == ''
                        ? const Icon(Icons.image)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: NetworkImageCustom(
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                                image: imageUrl),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "${nameCont.text} ${lastnameCont.text}",
                style: regularText(size: 16, color: Colors.white),
              ),
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
                  label: 'Update Profile',
                  onPress: () {
                    validateRegister();
                  },
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
            hint: 'First Name'),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
            lastnameCont,
            lastname,
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
            numberCont,
            numberFocus,
            [],
            SizedBox(
              height: 50,
              width: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/ic_phone.png',
                  height: 18,
                  color: AppColors.iconColor,
                ),
              ),
            ),
            hint: 'Phone Number'),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
            emailCont,
            emailFocus,
            [],
            SizedBox(
              height: 50,
              width: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/ic_email.png',
                  height: 14,
                  color: AppColors.iconColor,
                ),
              ),
            ),
            hint: 'Email'),
        SizedBox(
          height: ht(12),
        ),
      ],
    );
  }
}
