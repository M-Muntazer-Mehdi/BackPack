import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:back_packers/controllers/auth_controllers/sign_up_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/global.dart';
import 'package:back_packers/globals/network_image.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/appbars.dart';
import 'package:back_packers/widgets/primary_button.dart';

class VerifyAccount extends StatefulWidget {
  const VerifyAccount({super.key});

  @override
  State<VerifyAccount> createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount> {
  var controller = Get.put(SignUpController());
  String photoID = '';
  String address = '';
  String faceIdentification = '';

  uploadImage(int type) async {
    EasyLoading.show();
    File file = await selectImage();
    Reference ref = FirebaseStorage.instance.ref().child("files/${DateTime.now()}");

    final UploadTask uploadTask = ref.putFile(file);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    final url = await taskSnapshot.ref.getDownloadURL();
    EasyLoading.dismiss();

    if (type == 0) {
      photoID = url;
    } else if (type == 1) {
      address = url;
    } else {
      faceIdentification = url;
    }
    setState(() {});
  }

  selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Upload Verification', backButton: true),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: wd(20), vertical: ht(10)),
        children: [
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              uploadImage(0);
            },
            child: DottedBorder(
                options: RoundedRectDottedBorderOptions(radius: const Radius.circular(10), color: HexColor('#C4C4C4')),
                child: photoID == ''
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: ht(40)),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/ic_folder.png',
                                height: 20,
                              ),
                              Text(
                                'Upload Photo ID',
                                style: normalText(color: HexColor('#545454')),
                              )
                            ],
                          ),
                        ),
                      )
                    : Center(
                        child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: NetworkImageCustom(
                          image: photoID,
                          height: 100,
                        ),
                      ))),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              uploadImage(1);
            },
            child: DottedBorder(
                options: RoundedRectDottedBorderOptions(radius: const Radius.circular(10), color: HexColor('#C4C4C4')),
                child: Center(
                  child: address == ''
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: ht(40)),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/ic_folder.png',
                                height: 20,
                              ),
                              Text(
                                'Upload Photo ID',
                                style: normalText(color: HexColor('#545454')),
                              )
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NetworkImageCustom(
                            image: address,
                            height: 100,
                          ),
                        ),
                )),
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              uploadImage(2);
            },
            child: DottedBorder(
                options: RoundedRectDottedBorderOptions(radius: const Radius.circular(10), color: HexColor('#C4C4C4')),
                child: Center(
                  child: faceIdentification == ''
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: ht(40)),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/ic_face_scan.png',
                                height: 20,
                              ),
                              Text(
                                'Face Identification',
                                style: normalText(color: HexColor('#545454')),
                              )
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NetworkImageCustom(
                            image: faceIdentification,
                            height: 100,
                          ),
                        ),
                )),
          ),
          const SizedBox(
            height: 40,
          ),
          PrimaryButton(
              label: 'Sign Up',
              onPress: () async {
                if (photoID == '' || address == '' || faceIdentification == '') {
                  Global.showToastAlert(
                      context: Get.overlayContext!,
                      strTitle: "",
                      strMsg: 'Please upload all required pictures',
                      toastType: TOAST_TYPE.toastError);
                  return;
                }
              })
        ],
      ),
    );
  }
}
