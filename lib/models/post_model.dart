// To parse this JSON data, do
//
//     final postModel = postModelFromMap(jsonString);

import 'dart:convert';

import 'package:intl/intl.dart';

class PostModel {
  PostModel({
    required this.postId,
    required this.feeling,
    required this.audioUrl,
    required this.photoUrl,
    required this.userId,
    required this.note,
    required this.size,
    required this.notificationId,
    required this.isPublic,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.isLikebyMe,
    required this.isSavedbyMe,
    required this.followByMe,
    required this.name,
    required this.image,
  });

  int postId;
  String feeling;
  dynamic audioUrl;
  String photoUrl;
  int userId;
  String note;
  dynamic notificationId;
  int isPublic;
  int? isLikebyMe;
  int? isSavedbyMe;
  int? followByMe;
  double size;
  String tags;
  String createdAt;
  String updatedAt;
  String name;
  String image;

  factory PostModel.fromJson(String str) => PostModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PostModel.fromMap(Map<String, dynamic> json) => PostModel(
        postId: json["postId"],
        feeling: json["feeling"],
        audioUrl: json["audioUrl"],
        photoUrl: json["photoUrl"] ?? '',
        userId: json["userId"],
        isLikebyMe: json["likedByMe"],
        followByMe: json["followByMe"],
        isSavedbyMe: json["savedByMe"],
        size: 0,
        note: json["note"],
        notificationId: json["notificationId"],
        isPublic: json["isPublic"],
        tags: json["tags"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        name: json["name"],
        image: json["image"],
      );

  Map<String, dynamic> toMap() => {
        "postId": postId,
        "feeling": feeling,
        "audioUrl": audioUrl,
        "photoUrl": photoUrl,
        "userId": userId,
        "note": note,
        "isLikebyMe": isLikebyMe,
        "notificationId": notificationId,
        "isPublic": isPublic,
        "tags": tags,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "name": name,
        "image": image,
      };

  bool get isAudioPost => audioUrl != null && audioUrl != "";
  bool get isPhotoPost => photoUrl != "";
  bool get liked => isLikebyMe != null;
  bool get saved => isSavedbyMe != null;
  bool get followed => followByMe != null;

  List<String> get getTags => tags.isEmpty ? [] : tags.split(',').toList();

  DateTime converttoLocal() {
    var dateTime = DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(createdAt, true);
    var dateLocal = dateTime.toLocal();
    return dateLocal;
  }

  String getDate() {
    final DateFormat formatter = DateFormat('yMMMd');
    final String formatted = formatter.format(converttoLocal());
    return formatted;
  }

  String getTime(DateTime dateTime) {
    String formattedTime = DateFormat.jm().format(dateTime);
    return formattedTime;
  }

  String getPostTime() {
    var dateTime = DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(createdAt, true);
    var dateLocal = dateTime.toLocal();
    return DateFormat('hh:mm a').format(dateLocal);
  }
}
