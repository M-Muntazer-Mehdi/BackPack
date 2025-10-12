import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image_v2/flutter_native_image.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../globals/chat_database.dart';
import '../../globals/enum.dart';
import '../../globals/global.dart';
import '../../models/chat_model.dart';
import '../../models/local_chat_model.dart';
import '../../utils/login_details.dart';

class ChatDetailController extends GetxController {
  bool mShowData = false;
  bool isShowLoader = false;
  bool isShowEmojis = false;

  // late io.Socket socket;
  List<LocalChatModel> alChat = [];
  int initialCount = 0;
  TextEditingController controllerMessage = TextEditingController();

  bool showSendButton = false;

  String imgProfilePic = '';
  String id = '';
  String userId = '';

  changeText(String strvalue) {
    if (Global.checkNull(strvalue) && strvalue.trim().isNotEmpty) {
      showSendButton = true;
    } else {
      showSendButton = false;
    }
    update();
  }

  sendMessage({List<String> files = const []}) {
    if (controllerMessage.text.trim().isNotEmpty || files.isNotEmpty) {
      FireDatabase.addMessage(
          id,
          ChatModel(
            from: Get.find<UserDetail>().userId,
            to: userId,
            message: controllerMessage.text.trim(),
            files: files,
            timeStamp: Timestamp.now(),
          ));
    }

    controllerMessage.clear();
  }

  addEmojis(String strvalue) {
    controllerMessage.text = controllerMessage.text + strvalue;
    showSendButton = true;
    update();
  }

  showEmoji() {
    isShowEmojis = isShowEmojis ? false : true;
    update();
  }

  disableEmoji() {
    isShowEmojis = false;

    update();
  }

  List<String> emojis = [
    '😀',
    '😃',
    '😄',
    '😁',
    '😅',
    '😂',
    '🤣',
    '🥲',
    '😊',
    '😇',
    '🙂',
    '🙃',
    '😉',
    '😌',
    '😍',
    '🥰',
    '😘',
    '😗',
    '😙',
    '😚'
  ];

  void showImagePicker(
    context,
  ) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Gallery'),
                    onTap: () async {
                      await imgFromGallery2();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () async {
                    await imgFromCamera2();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  imgFromCamera2() async {
    try {
      ImagePicker _picker = ImagePicker();
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
      );
      imageCompressor([pickedFile!]);
    } catch (e) {
      print('image picker error: $e');
    }
  }

  imgFromGallery2() async {
    try {
      ImagePicker _picker = ImagePicker();
      final pickedFile = await _picker.pickMultiImage();
      imageCompressor(pickedFile!);
    } catch (e) {
      print('image picker error: $e');
    }
  }

  var loading = false;

  imageCompressor(List<XFile> selectedImage) async {
    try {
      loading = true;
      update();

      List<File> files = [];
      for (int i = 0; i < selectedImage.length; i++) {
        File compressedFile = await FlutterNativeImage.compressImage(
            selectedImage[i].path,
            quality: 30,
            percentage: 50);

        files.add(compressedFile);
      }

      uploadImage(files);
    } catch (e) {
      Future.error(e);
      return;
    }
  }

  Future<void> uploadImage(List<File> files) async {
    log(files.length.toString());
    if (files.isEmpty) {
      loading = false;
      update();
      return;
    }

    HashMap<String, String> requestParams = HashMap();
    HashMap<String, String> requestParamsImg = HashMap();
    List<String> paths = [];
    for (int i = 0; i < files.length; i++) {
      paths.add(files[i].path);
    }

    var res;

    res.fold((failure) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: "Something went wrong! Try again",
          toastType: TOAST_TYPE.toastError);
      loading = false;
      update();
    }, (mResult) async {
      List<String> images = mResult.responseData as List<String>;
      sendMessage(files: images);
      loading = false;
      update();
    });
  }
}
