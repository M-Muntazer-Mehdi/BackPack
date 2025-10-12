// To parse this JSON data, do
//
//     final contentVideos = contentVideosFromMap(jsonString);

import 'dart:convert';

class ContentVideos {
  ContentVideos({
    required this.contentId,
    required this.challengeId,
    required this.userId,
    required this.video,
    required this.thumbnail,
    required this.likes,
    required this.shares,
    required this.description,
    required this.name,
    required this.image,
    required this.isLikedByMe,
    required this.likeByme,
    required this.title,
    required this.reported,
  });

  int contentId;
  dynamic challengeId;
  int userId;
  String video;
  String thumbnail;
  int likes;
  int shares;
  dynamic description;
  String name;
  bool isLikedByMe;
  bool reported;
  String image;
  String title;
  dynamic likeByme;

  factory ContentVideos.fromJson(String str) =>
      ContentVideos.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ContentVideos.fromMap(Map<String, dynamic> json) => ContentVideos(
        contentId: json["contentId"],
        challengeId: json["challengeId"],
        userId: json["userId"],
        video: json["video"],
        thumbnail: json["thumbnail"],
        likes: json["likes"],
        shares: json["shares"] ?? 0,
        description: json["description"] ?? '',
        name: json["name"] ?? '',
        title: json["title"] ?? '',
        image: json["image"] ?? '',
        likeByme: json["likeByme"],
        isLikedByMe: json["likeByme"] == null ? false : true,
        reported: json["reportId"] == null ? false : true,
      );

  Map<String, dynamic> toMap() => {
        "contentId": contentId,
        "challengeId": challengeId,
        "userId": userId,
        "video": video,
        "thumbnail": thumbnail,
        "isLikedByMe": isLikedByMe,
        "likes": likes,
        "shares": shares,
        "description": description,
        "name": name,
        "image": image,
        "likeByme": likeByme,
      };
}
