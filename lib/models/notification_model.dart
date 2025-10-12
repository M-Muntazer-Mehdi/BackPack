// To parse this JSON data, do
//
//     final notifications = notificationsFromMap(jsonString);

import 'dart:convert';

import 'package:intl/intl.dart';

class NotificationsModel {
  NotificationsModel({
    required this.notificationId,
    required this.postId,
    required this.message,
    required this.fromUser,
    required this.toUser,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.image,
    required this.type,
  });

  int? notificationId;
  int? postId;
  String? message;
  int? fromUser;
  int? toUser;
  String? createdAt;
  String? updatedAt;
  String? name;
  String? image;
  String? type;

  factory NotificationsModel.fromJson(String str) =>
      NotificationsModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory NotificationsModel.fromMap(Map<String, dynamic> json) =>
      NotificationsModel(
        notificationId: json["notificationId"],
        postId: json["contentId"],
        message: json["message"],
        fromUser: json["fromUser"],
        toUser: json["toUser"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        name: json["name"],
        image: json["image"],
        type: json["type"],
      );

  Map<String, dynamic> toMap() => {
        "notificationId": notificationId,
        "message": message,
        "fromUser": fromUser,
        "toUser": toUser,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "name": name,
        "image": image,
        "thumbnail": type,
      };

  DateTime converttoLocal() {
    var dateTime = DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(createdAt!, true);
    var dateLocal = dateTime.toLocal();
    return dateLocal;
  }
}
