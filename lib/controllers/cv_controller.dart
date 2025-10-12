import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:back_packers/globals/database.dart';

class DocType {
  static String cv = 'cv';
  static String letter = 'letter';
}

class CvController extends GetxController {
  uploadDocs(String type) async {
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
      Database.addDoc(result.files.single.name, type, url);
    } else {
      // User canceled the picker
    }
    EasyLoading.dismiss();
  }
}
