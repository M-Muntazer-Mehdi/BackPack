import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  late String id;
  late String fname;
  late String lname;
  late String email;
  late bool approved;
  late String phone;
  late String image;
  late dynamic geo;
  late List reportedUsers;
  UserModel({
    required this.id,
    required this.fname,
    required this.lname,
    required this.email,
    required this.approved,
    required this.phone,
    required this.image,
    required this.geo,
    required this.reportedUsers,
  });

  UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    try {
      id = doc.id;
      var data = doc.data() as Map;
      fname = data['fname'] ?? '';
      lname = data['lname'] ?? '';
      email = data['email'] ?? '';
      image = data['image'] ?? '';
      phone = data['phone'] ?? '';
      geo = doc['geo']['geopoint'] as GeoPoint;
      approved = data['approved'] ?? false;
      reportedUsers = data['reportedUsers'] ?? [];
    } catch (e) {}
  }
  Map<String, dynamic> toMap() => {
        "fname": fname,
        "lname": lname,
        "email": email,
        "image": image,
        "phone": phone,
        "geo": geo,
        "createdAt": Timestamp.now(),
        "approved": false,
        "reportedUsers": reportedUsers,
      };
  Map<String, dynamic> toMapSignup() => {
        "fname": fname,
        "lname": lname,
        "email": email,
        "image": image,
        "phone": phone,
        "geo": geo,
        "createdAt": Timestamp.now(),
        "approved": false,
        "reportedUsers": [],

      };
}
