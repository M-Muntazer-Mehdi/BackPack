// To parse this JSON data, do
//
//     final exploreUserModel = exploreUserModelFromMap(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  voice,
  video,
  document,
  file,
  location,
}

class ChatModel {
  ChatModel({
    required this.from,
    required this.to,
    required this.message,
    required this.files,
    required this.timeStamp,
    this.status,
    this.messageType = MessageType.text,
    this.voiceData,
  });

  String from;
  String to;
  String message;
  List files;
  Timestamp timeStamp;
  String? status;
  MessageType messageType;
  Map<String, dynamic>? voiceData;

  factory ChatModel.fromMap(DocumentSnapshot json) {
    var data = json.data() as Map;
    
    // Parse message type
    MessageType type = MessageType.text;
    if (data["messageType"] != null) {
      switch (data["messageType"]) {
        case "voice":
          type = MessageType.voice;
          break;
        case "video":
          type = MessageType.video;
          break;
        case "document":
          type = MessageType.document;
          break;
        case "image":
          type = MessageType.image;
          break;
        case "file":
          type = MessageType.file;
          break;
        case "location":
          type = MessageType.location;
          break;
        default:
          type = MessageType.text;
      }
    } else {
      // Backward compatibility - if files are present, it's an image
      if (data["files"] != null && (data["files"] as List).isNotEmpty) {
        type = MessageType.image;
      }
    }

    return ChatModel(
      from: data["from"],
      to: data["to"],
      files: data["files"] ?? [],
      message: data["message"] ?? "",
      timeStamp: data["timestamp"],
      status: data["status"] ?? 'Active',
      messageType: type,
      voiceData: data["voiceData"] != null 
          ? Map<String, dynamic>.from(data["voiceData"]) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "from": from,
      "to": to,
      "message": message,
      "files": files,
      "timestamp": timeStamp,
      "status": status ?? 'Active',
      "messageType": messageType.name,
      "voiceData": voiceData,
    };
  }
}
