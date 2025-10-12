// To parse this JSON data, do
//
//     final moodScoreStatsOrg = moodScoreStatsOrgFromMap(jsonString);

import 'dart:convert';

class MoodScoreStatsOrg {
  int organizationId;
  String code;
  dynamic name;
  dynamic logo;
  dynamic organizationscol;
  int userId;
  String organizationCode;
  int members;
  String score;

  MoodScoreStatsOrg({
    required this.organizationId,
    required this.code,
    required this.name,
    required this.logo,
    required this.userId,
    required this.organizationCode,
    required this.members,
    required this.score,
  });

  factory MoodScoreStatsOrg.fromJson(String str) =>
      MoodScoreStatsOrg.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MoodScoreStatsOrg.fromMap(Map<dynamic, dynamic> json) =>
      MoodScoreStatsOrg(
        organizationId: json["organizationId"],
        code: json["code"],
        name: json["name"],
        logo: json["logo"],
        userId: json["userId"],
        organizationCode: json["organizationCode"] ?? '',
        members: json["members"] ?? 0,
        score: (json["score"] ?? '0').toString(),
      );

  Map<String, dynamic> toMap() => {
        "organizationId": organizationId,
        "code": code,
        "name": name,
        "logo": logo,
        "userId": userId,
        "organizationCode": organizationCode,
        "members": members,
        "score": score,
      };
}
