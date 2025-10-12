// To parse this JSON data, do
//
//     final unsplashPics = unsplashPicsFromMap(jsonString);

import 'dart:convert';

class UnsplashPics {
  UnsplashPics({
    required this.urls,
  });

  Urls urls;

  factory UnsplashPics.fromJson(String str) =>
      UnsplashPics.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UnsplashPics.fromMap(Map<String, dynamic> json) => UnsplashPics(
        urls: Urls.fromMap(json["urls"]),
      );

  Map<String, dynamic> toMap() => {
        "urls": urls.toMap(),
      };
}

class Urls {
  Urls({
    required this.full,
    required this.regular,
    required this.small,
    required this.thumb,
    required this.smallS3,
  });

  String full;
  String regular;
  String small;
  String thumb;
  String smallS3;

  factory Urls.fromJson(String str) => Urls.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Urls.fromMap(Map<String, dynamic> json) => Urls(
        full: json["full"] ?? "",
        regular: json["regular"] ?? '',
        small: json["small"] ?? '',
        thumb: json["thumb"] ?? "",
        smallS3: json["small_s3"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "full": full,
        "regular": regular,
        "small": small,
        "thumb": thumb,
        "small_s3": smallS3,
      };
}
