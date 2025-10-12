// To parse this JSON data, do
//
//     final challengeVideos = challengeVideosFromMap(jsonString);

import 'dart:convert';

class ChallengeVideos {
  ChallengeVideos({
    required this.video,
    required this.thumbnail,
    required this.likes,
    required this.userId,
    required this.email,
    required this.name,
    required this.image,
  });

  String video;
  String thumbnail;
  int likes;
  int userId;
  String email;
  String name;
  String image;

  factory ChallengeVideos.fromJson(String str) =>
      ChallengeVideos.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ChallengeVideos.fromMap(Map<String, dynamic> json) => ChallengeVideos(
        video: json["video"],
        thumbnail: json["thumbnail"],
        likes: json["likes"],
        userId: json["userId"],
        email: json["email"] ?? "",
        name: json["name"],
        image: json["image"],
      );

  Map<String, dynamic> toMap() => {
        "video": video,
        "thumbnail": thumbnail,
        "likes": likes,
        "userId": userId,
        "email": email,
        "name": name,
        "image": image,
      };
}
