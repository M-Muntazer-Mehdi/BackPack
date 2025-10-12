import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  late String id;
  late String itemId;
  late String requestBy;
  late String status;
  late String requestTo;
  late bool ratingDone;
  late DateTime dateTime;
  late String period;
  late int hours;
  late int price;
  late List<String> pictures;
  late List<String> dropPicture;

  OrderModel(
      {required this.id,
      required this.itemId,
      required this.requestBy,
      required this.period,
      required this.requestTo,
      required this.ratingDone,
      required this.status,
      required this.dateTime,
      required this.price,
      required this.pictures,
      required this.dropPicture,
      required this.hours});

  factory OrderModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    var id = doc.id;
    var data = doc.data() as Map;
    return OrderModel(
      id: id,
      itemId: data['itemId'] ?? '',
      period: data['period'] ?? 'Hours',
      pictures:
          ((data['pictures'] as List?) ?? []).map((e) => e.toString()).toList(),
      dropPicture: ((data['dropPicture'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      price: data['price'] ?? 0,
      requestBy: data['requestBy'] ?? '',
      requestTo: data['requestTo'] ?? '',
      ratingDone: data['ratingDone'] ?? false,
      status: data['status'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      hours: data['hours'] ?? 0,
    );
  }
  Map<String, dynamic> toMap() => {
        "itemId": itemId,
        "price": price,
        "pictures": pictures,
        "dropPicture": dropPicture,
        "period": period,
        "requestTo": requestTo,
        "requestBy": requestBy,
        "dateTime": dateTime,
        "ratingDone": false,
        "hours": hours,
        "status": OrderStatus.ordered,
        'createdAt': DateTime.now()
      };
}

class OrderStatus {
  static String drop = 'Dropped Off';
  static String picked = 'Picked Up';
  static String ordered = 'Yet to pick up';
}
