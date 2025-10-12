import 'package:get/get.dart';

import '../controllers/mainScreen_controllers/navbar_controller.dart';
import '../controllers/order_controller.dart';
import '../utils/login_details.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserDetail(), fenix: true);
    Get.lazyPut(() => NavBarController(), fenix: true);
    Get.lazyPut(() => OrderController());
  }
}
