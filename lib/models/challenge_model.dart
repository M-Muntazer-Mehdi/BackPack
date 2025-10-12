// To parse this JSON data, do
//
//     final challengeModel = challengeModelFromMap(jsonString);

import 'dart:convert';
import 'dart:developer';

import 'package:intl/intl.dart';

class ChallengeModel {
  ChallengeModel({
    required this.challengeId,
    required this.title,
    required this.description,
    required this.fee,
    required this.thumbnail,
    required this.video,
    required this.startDate,
    required this.endDate,
    required this.participent,
    required this.participated,
  });

  int challengeId;
  String title;
  String description;
  dynamic fee;
  String thumbnail;
  String video;
  String startDate;
  String endDate;
  int? participent;
  bool participated;

  factory ChallengeModel.fromJson(String str) =>
      ChallengeModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ChallengeModel.fromMap(Map<String, dynamic> json) => ChallengeModel(
        challengeId: json["challengeId"],
        title: json["title"],
        description: json["description"] ?? "",
        fee: json["fee"],
        thumbnail: json["thumbnail"] ?? "",
        video: json["video"] ?? "",
        startDate: json["startDate"],
        endDate: json["endDate"],
        participent: json["participent"] ?? 0,
        participated: json["participated"] == null ? false : true,
      );

  Map<String, dynamic> toMap() => {
        "challengeId": challengeId,
        "title": title,
        "description": description,
        "fee": fee,
        "thumbnail": thumbnail,
        "video": video,
        "startDate": startDate,
        "endDate": endDate,
        "participent": participent,
      };
}

DateTime ConverttoLocal(String dateUtc) {
  var dateTime = DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(dateUtc, true);
  var dateLocal = dateTime.toLocal();
  return dateLocal;
}

String getDate(DateTime dateTime) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String formatted = formatter.format(dateTime);
  return formatted;
}

bool isToday(String dateTime) {
  DateTime serverDate = DateTime.parse(dateTime);
  DateTime serverUtc = DateTime.utc(serverDate.year, serverDate.month,
      serverDate.day, serverDate.hour, serverDate.minute);
  DateTime utc = DateTime.now().toUtc();
  log('serverDate $serverUtc');
  log('utc $utc');
  return utc.isAfter(serverUtc);
}

String getTime(DateTime dateTime) {
  String formattedTime = DateFormat.jm().format(dateTime);
  return formattedTime;
}

String getWinnerFormat(String dateTime) {
  DateTime date = DateTime.parse(dateTime);

  return DateFormat('EE hh:mm a').format(date);
}

String getWinnerFormatServer(String date) {
  var dateTime = DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(date, true);
  var dateLocal = dateTime.toLocal();
  return DateFormat('EE hh:mm a').format(dateLocal);
}
