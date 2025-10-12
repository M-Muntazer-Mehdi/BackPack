import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/cv_controller.dart';
import 'package:back_packers/models/application_model.dart';
import 'package:back_packers/models/doc_model.dart';

import '../../globals/enum.dart';
import '../../globals/global.dart';

class ApplyjobsController extends GetxController {
  DocModel selectedCV = DocModel(id: "", type: DocType.cv, name: "", url: "");
  DocModel selectedCoverLetter =
      DocModel(id: "", type: DocType.letter, name: "", url: "");

  bool visaStatus = false;
  bool workingRights = false;

  handleVisaStatusChange() {
    visaStatus = !visaStatus;
    update();
  }

  handleWorkingRightsChange() {
    workingRights = !workingRights;
    update();
  }

  bool validation(ApplicantModel data) {
    if (!Global.checkNull(data.coverLetter.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Kindly Select Cover Letter',
          toastType: TOAST_TYPE.toastError);
      return false;
    }
    if (!Global.checkNull(data.cv.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Kindly Select CV',
          toastType: TOAST_TYPE.toastError);
      return false;
    }

    return true;
  }

  Future<String> uploadDocs(String type) async {
    EasyLoading.show();
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("files/${result.files.single.name}");

      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      final url = await taskSnapshot.ref.getDownloadURL();
      EasyLoading.dismiss();
      if (type == DocType.cv) {
        selectedCV.name = result.files.single.name;
        selectedCV.url = url;
      } else {
        selectedCoverLetter.name = result.files.single.name;
        selectedCoverLetter.url = url;
      }
      update();
      return url;
    } else {
      EasyLoading.dismiss();
      return '';
      // User canceled the picker
    }
  }

  var isLoading = false;

  handleApplyJob(ApplicantModel data) async {
    EasyLoading.show();
    try {
      await FirebaseFirestore.instance
          .collection('applicants')
          .add(data.toMap());

      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Succesfully Applied to Job.',
          toastType: TOAST_TYPE.toastSuccess);
      Get.back();
      update();
    } catch (err) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Something Went Wrong.',
          toastType: TOAST_TYPE.toastError);
    }
    EasyLoading.dismiss();
  }
}
