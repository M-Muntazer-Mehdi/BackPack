import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  late String id;
  late String itemId;
  late String requestBy;
  late String status;
  late String period;
  late String requestTo;
  late DateTime dateTime;
  late int count;

  RequestModel(
      {required this.id,
      required this.itemId,
      required this.period,
      required this.requestBy,
      required this.requestTo,
      required this.status,
      required this.dateTime,
      required this.count});

  factory RequestModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    var id = doc.id;
    var data = doc.data() as Map;
    return RequestModel(
      id: id,
      itemId: data['itemId'] ?? '',
      requestBy: data['requestBy'] ?? '',
      period: data['period'] ?? 'Hourly',
      requestTo: data['requestTo'] ?? '',
      status: data['status'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      count: data['hours'] ?? 0,
    );
  }
  Map<String, dynamic> toMap() => {
        "itemId": itemId,
        "requestTo": requestTo,
        "requestBy": requestBy,
        "period": period,
        "dateTime": dateTime,
        "hours": count,
        "status": RequestStatus.requested,
        'createdAt': DateTime.now()
      };

  String getPeriod(String period) {
    switch (period) {
      case 'Daily':
        return 'Days';
      case 'Hourly':
        return 'Hours';
      case 'Weekly':
        return 'Week';
      case 'Monthly':
        return 'Month';
    }
    return 'Hours';
  }
}

class RequestStatus {
  static String accepted = 'accepted';
  static String rejected = 'rejected';
  static String requested = 'requested';
  static String proceeded = 'proceeded';
}
