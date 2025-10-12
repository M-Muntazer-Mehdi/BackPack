import 'package:cloud_firestore/cloud_firestore.dart';

class DocModel {
  late String id;
  late String type;
  late String url;
  late String name;

  DocModel({
    required this.id,
    required this.type,
    required this.name,
    required this.url,
  });

  factory DocModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    var id = doc.id;
    var data = doc.data() as Map;
    return DocModel(
      id: id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      url: data['url'] ?? '',
    );
  }
  Map<String, dynamic> toMap() => {
        "name": name,
        "type": type,
        "url": url,
      };
}
