import 'package:get/get.dart';

class RecentsController extends GetxController {
  String id = '';

  setid(String idm) {
    id = idm;
    update();
  }
}
