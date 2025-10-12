// To parse this JSON data, do
//
//     final exploreUserModel = exploreUserModelFromMap(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  ChatModel({
    required this.from,
    required this.to,
    required this.message,
    required this.files,
    required this.timeStamp,
    this.status,
  });

  String from;
  String to;
  String message;
  List files;
  Timestamp timeStamp;
  String? status;

  factory ChatModel.fromMap(DocumentSnapshot json) {
    var data = json.data() as Map;
    return ChatModel(
      from: data["from"],
      to: data["to"],
      files: data["files"],
      message: data["message"],
      timeStamp: data["timestamp"],
      status: data["status"] ?? 'Active',
    );
  }
}
