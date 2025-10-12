// To parse this JSON data, do
//
//     final accountDetails = accountDetailsFromMap(jsonString);

import 'dart:convert';

List<CscPicker> cscPickerFromMap(String str) =>
    List<CscPicker>.from(json.decode(str).map((x) => CscPicker.fromMap(x)));

String cscPickerToMap(List<CscPicker> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class CscPicker {
  CscPicker({
    required this.name,
    required this.code,
  });
  String name;
  String code;

  factory CscPicker.fromMap(Map<String, dynamic> json) => CscPicker(
        name: json["name"],
        code: json["code"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "code": code,
      };
}
