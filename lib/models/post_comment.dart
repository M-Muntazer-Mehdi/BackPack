// To parse this JSON data, do
//
//     final postComments = postCommentsFromMap(jsonString);

import 'dart:convert';

class PostComments {
  PostComments({
    required this.image,
    required this.firstname,
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.comment,
    required this.createdAt,
  });

  dynamic image;
  String firstname;
  int commentId;
  int postId;
  int userId;
  String comment;
  String createdAt;

  factory PostComments.fromJson(String str) =>
      PostComments.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PostComments.fromMap(Map<String, dynamic> json) => PostComments(
        image: json["image"],
        firstname: json["name"],
        commentId: json["commentId"],
        postId: json["postId"],
        userId: json["userId"],
        comment: json["comment"],
        createdAt: json["createdAt"] ?? 'T',
      );

  Map<String, dynamic> toMap() => {
        "image": image,
        "firstname": firstname,
        "commentId": commentId,
        "postId": postId,
        "userId": userId,
        "comment": comment,
        "createdAt": createdAt,
      };
}
