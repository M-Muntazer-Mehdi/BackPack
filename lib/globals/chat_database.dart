// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:back_packers/models/chat_model.dart';
import 'package:back_packers/models/user.dart';
import 'package:back_packers/utils/login_details.dart';

class FireDatabase {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> createChatRoom(UserModel otheruser) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('check',
              arrayContains: '${otheruser.id}${Get.find<UserDetail>().userId}')
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs[0].id;
      }
      DocumentReference df = await _firestore.collection('chats').add({
        'users': [Get.find<UserDetail>().userId, otheruser.id],
        'lastMessage': "",
        'createdBy': Get.find<UserDetail>().userId,
        'status': 'pending',
        'lastMessageBy': Get.find<UserDetail>().userId,
        'unreadCount': 0,
        'user1': {
          'id': Get.find<UserDetail>().userId,
          'name':
              Get.find<UserDetail>().fname + " " + Get.find<UserDetail>().lname,
        },
        'user2': {
          'id': otheruser.id,
          'name': otheruser.fname + " " + otheruser.lname,
        },
        'check': [
          '${otheruser.id}${Get.find<UserDetail>().userId}',
          '${Get.find<UserDetail>().userId}${otheruser.id}'
        ],
        'timestamp': Timestamp.now()
      });
      return df.id;
    } catch (e) {
      debugPrint(e.toString());
      return 'null';
    }
  }

  static Future<bool> addMessage(String docId, ChatModel chat) async {
    try {
      log(chat.to.toString());
      
      // Determine display message for chat list
      String displayMessage = chat.message;
      if (chat.messageType.name == 'voice') {
        displayMessage = '🎤 Voice message';
      } else if (chat.messageType.name == 'video') {
        displayMessage = '🎥 Video';
      } else if (chat.messageType.name == 'document') {
        displayMessage = '📄 ${chat.message}';
      } else if (chat.messageType.name == 'location') {
        displayMessage = '📍 Location';
      } else if (chat.files.isNotEmpty && chat.message.isEmpty) {
        displayMessage = '📷 Photo';
      }

      await _firestore
          .collection('chats')
          .doc(docId)
          .collection('messages')
          .add({
        "from": Get.find<UserDetail>().userId,
        "to": chat.to,
        "message": chat.message,
        "files": chat.files,
        "timestamp": chat.timeStamp,
        "messageType": chat.messageType.name,
        "voiceData": chat.voiceData,
      });
      await _firestore.collection('chats').doc(docId).update({
        'lastMessageBy': Get.find<UserDetail>().userId,
        'unreadCount': FieldValue.increment(1),
        'lastMessage': displayMessage,
        'timestamp': Timestamp.now(),
      });

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static changeUserAvailability(bool val) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(Get.find<UserDetail>().userId.toString())
        .update({'online': val});
  }
}
