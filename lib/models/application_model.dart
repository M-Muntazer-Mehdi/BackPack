import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicantModel {
  late String id;
  late String coverLetter;
  late String jobId;
  late String cv;
  late bool visaStatus;
  late bool workingRights;
  late String userId;

  ApplicantModel({
    required this.id,
    required this.coverLetter,
    required this.jobId,
    required this.cv,
    required this.visaStatus,
    required this.workingRights,
    required this.userId,
  });

  factory ApplicantModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    var id = doc.id;
    var data = doc.data() as Map;
    return ApplicantModel(
        id: id,
        coverLetter: data['coverLetter'] ?? '',
        jobId: data['jobId'] ?? "",
        cv: data["cv"] ?? "",
        visaStatus: data["visaStatus"] ?? false,
        workingRights: data["workingRights"] ?? false,
        userId: data["userId"] ?? "");
  }
  Map<String, dynamic> toMap() => {
        "category": coverLetter,
        "createdAt": Timestamp.now(),
        "jobId": jobId,
        "cv": cv,
        "visaStatus": visaStatus,
        "workingRights": workingRights,
        "userId": userId
      };
}
