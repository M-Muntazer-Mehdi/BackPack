// To parse this JSON data, do
//
//     final chatGroupModel = chatGroupModelFromMap(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatGroupModel {
  ChatGroupModel({
    required this.users,
    required this.roomId,
    required this.createdBy,
    required this.lastMessage,
    required this.user1,
    required this.user2,
    required this.status,
    required this.reportedBy,
    required this.timestamp,
    required this.unreadCount,
    required this.lastMessageBy,
  });

  List users;
  String roomId;
  String createdBy;
  String status;
  int unreadCount;
  String lastMessageBy;
  String lastMessage;
  String reportedBy;
  GroupChatUser user1;
  GroupChatUser user2;
  Timestamp timestamp;

  factory ChatGroupModel.fromMap(DocumentSnapshot json) {
    var data = json.data() as Map;
    return ChatGroupModel(
      roomId: json.id,
      status: data['status'],
      createdBy: data['createdBy'],
      users: data["users"],
      lastMessageBy: data["lastMessageBy"],
      unreadCount: data["unreadCount"] ?? 0,
      lastMessage: data["lastMessage"] ?? "",
      reportedBy: data["reportedBy"] ?? "",
      user1: GroupChatUser.fromMap(data["user1"]),
      user2: GroupChatUser.fromMap(data["user2"]),
      timestamp: data["timestamp"] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'status': status,
      'createdBy': createdBy,
      'users': users,
      'lastMessageBy': lastMessageBy,
      'unreadCount': unreadCount,
      'lastMessage': lastMessage,
      'reportedBy': reportedBy,
      'user1': user1.toMap(),
      'user2': user2.toMap(),
      'timestamp': Timestamp.now(),
    };
  }
}

class GroupChatUser {
  GroupChatUser({required this.id, required this.name});

  String id;
  String name;

  factory GroupChatUser.fromJson(String str) =>
      GroupChatUser.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GroupChatUser.fromMap(Map<String, dynamic> json) => GroupChatUser(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
      };
}
