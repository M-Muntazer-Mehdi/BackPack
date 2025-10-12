// To parse this JSON data, do
//
//     final userProfile = userProfileFromMap(jsonString);

import 'dart:convert';

class UserProfile {
  int userId;
  String name;
  String email;
  int isIndividual;
  String refrelCode;
  String organizationCode;
  String inviteCode;
  int isVerified;
  int deactivated;
  String postCode;
  String gender;
  String ethnicBackground;
  String dob;
  String subgroup;
  String image;
  String? token;
  String? interests;
  String? bio;
  int? followByMe;
  int followers;
  int following;
  int posts;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.isIndividual,
    required this.refrelCode,
    required this.organizationCode,
    required this.inviteCode,
    required this.isVerified,
    required this.deactivated,
    required this.postCode,
    required this.gender,
    required this.ethnicBackground,
    required this.dob,
    required this.subgroup,
    required this.image,
    required this.token,
    required this.interests,
    required this.bio,
    required this.followByMe,
    required this.followers,
    required this.following,
    required this.posts,
  });

  factory UserProfile.fromJson(String str) =>
      UserProfile.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserProfile.fromMap(Map<dynamic, dynamic> json) => UserProfile(
        userId: json["userId"],
        name: json["name"] ?? "",
        email: json["email"] ?? "",
        isIndividual: json["isIndividual"] ?? 1,
        refrelCode: json["refrelCode"],
        organizationCode: json["organizationCode"] ?? "",
        inviteCode: json["inviteCode"] ?? "",
        isVerified: json["isVerified"],
        deactivated: json["deactivated"],
        postCode: json["postCode"] ?? "",
        gender: json["gender"],
        ethnicBackground: json["ethnicBackground"] ?? "",
        dob: json["dob"],
        subgroup: json["subgroup"] ?? '',
        image: json["image"],
        token: json["token"],
        interests: json["interests"] ?? '',
        bio: json["bio"] ?? '',
        followByMe: json["followByMe"],
        followers: json["followers"],
        following: json["following"],
        posts: json["posts"],
      );

  Map<String, dynamic> toMap() => {
        "userId": userId,
        "name": name,
        "email": email,
        "isIndividual": isIndividual,
        "refrelCode": refrelCode,
        "organizationCode": organizationCode,
        "inviteCode": inviteCode,
        "isVerified": isVerified,
        "deactivated": deactivated,
        "postCode": postCode,
        "gender": gender,
        "ethnicBackground": ethnicBackground,
        "dob": dob,
        "subgroup": subgroup,
        "image": image,
        "token": token,
        "interests": interests,
        "bio": bio,
        "followByMe": followByMe,
        "followers": followers,
        "following": following,
        "posts": posts,
      };

  bool get followed => followByMe != null;

  List<String> get userInterest =>
      interests!.isEmpty ? [] : interests!.split(',');
}
