import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:back_packers/models/user.dart';
import 'package:back_packers/models/user_profile.dart';
import 'package:back_packers/screens/auth_screens/login.dart';

class UserDetail extends GetxController {
  String userId = '';
  String fname = '';
  String lname = '';
  String image = '';
  String email = '';
  String phone = '';
  List reportedUsers = [];

  Future<void> getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    fname = sharedPreferences.getString('fname') ?? '';
    lname = sharedPreferences.getString('lname') ?? '';
    userId = sharedPreferences.getString('id') ?? '';
    email = sharedPreferences.getString('email') ?? '';
    image = sharedPreferences.getString('image') ?? '';
    phone = sharedPreferences.getString('phone') ?? '';
    reportedUsers = sharedPreferences.getStringList('reportedUsers') ?? [];
    update();
  }

  Future<void> setData(UserModel user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> reportedUsers = List<String>.from(user.reportedUsers);
    await sharedPreferences.setString('fname', user.fname);
    await sharedPreferences.setString('lname', user.lname);
    await sharedPreferences.setString('id', user.id);
    await sharedPreferences.setString('email', user.email);
    await sharedPreferences.setString('image', user.image);
    await sharedPreferences.setString('phone', user.phone);
    await sharedPreferences.setBool('isLogin', true);
    await sharedPreferences.setStringList('reportedUsers',reportedUsers);
    await getData();
    update();
  }

  Future<bool> isLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool('isLogin') ?? false;
  }

  Future<void> logout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    await sharedPreferences.remove('isLogin');

    // await FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => const LoginScreen());
  }

  Future<void> updateImage(String n) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('image', n);
    image = n;
    update();
  }

  Future<void> updateProfile(String fn, String ln, img) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('fname', fn);
    await sharedPreferences.setString('lname', ln);
    await sharedPreferences.setString('image', img);
    image = img;
    fname = fn;
    lname = ln;
    update();
  }
}
