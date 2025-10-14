import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/models/chat_model.dart';

class LocalChatModel {
  String message;
  Timestamp time;
  List files;
  MsgType mMsgType;
  String status;
  MessageType messageType;
  Map<String, dynamic>? voiceData;

  LocalChatModel({
    Key? key,
    required this.time,
    required this.message,
    required this.files,
    required this.mMsgType,
    required this.status,
    this.messageType = MessageType.text,
    this.voiceData,
  });
}
