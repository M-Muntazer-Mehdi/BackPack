import 'package:http/http.dart';

class NotificationApis {
  static sendCustomNotification(String message, String id) {
    post(Uri.parse('uri'), body: {'id': id, 'message': message});
  }
}
