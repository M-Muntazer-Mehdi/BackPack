// To parse this JSON data, do
//
//     final surveyQuestionModel = surveyQuestionModelFromMap(jsonString);

import 'dart:convert';

class SurveyQuestionModel {
  SurveyQuestionModel({
    required this.questionId,
    required this.title,
    required this.answersOptions,
  });

  int questionId;
  String title;
  List<AnswersOption> answersOptions;

  factory SurveyQuestionModel.fromJson(String str) =>
      SurveyQuestionModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SurveyQuestionModel.fromMap(Map<String, dynamic> json) =>
      SurveyQuestionModel(
        questionId: json["questionId"],
        title: json["title"],
        answersOptions: List<AnswersOption>.from(
            (jsonDecode(json["answersOptions"]) as List)
                .map((x) => AnswersOption.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "questionId": questionId,
        "title": title,
        "answersOptions":
            List<dynamic>.from(answersOptions.map((x) => x.toMap())),
      };
}

class AnswersOption {
  AnswersOption({
    required this.answer,
    required this.score,
  });

  String answer;
  int score;

  factory AnswersOption.fromJson(String str) =>
      AnswersOption.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AnswersOption.fromMap(Map<String, dynamic> json) => AnswersOption(
        answer: json["answer"],
        score: json["score"],
      );

  Map<String, dynamic> toMap() => {
        "answer": answer,
        "id": score,
      };
}
