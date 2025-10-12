import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:back_packers/globals/constants.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/global.dart';
import 'package:back_packers/models/item_model.dart';
import 'package:back_packers/models/order_model.dart';
import 'package:back_packers/models/request_model.dart';
import 'package:back_packers/utils/apis.dart';
import 'package:back_packers/utils/login_details.dart';

class OrderController extends GetxController {
  TextEditingController notesController = TextEditingController();
  FocusNode notesNode = FocusNode();
  TextEditingController firstnameController =
      TextEditingController(text: Get.find<UserDetail>().fname);
  FocusNode firstnameNode = FocusNode();
  TextEditingController lastnameController =
      TextEditingController(text: Get.find<UserDetail>().lname);
  FocusNode lastNamesNode = FocusNode();
  TextEditingController emailController =
      TextEditingController(text: Get.find<UserDetail>().email);
  FocusNode emailNode = FocusNode();
  TextEditingController streetAddresController = TextEditingController();
  FocusNode streetAddresNode = FocusNode();
  TextEditingController cityController = TextEditingController();
  FocusNode cityNode = FocusNode();
  TextEditingController zipCodeController = TextEditingController();
  FocusNode zipCodeNode = FocusNode();
  TextEditingController phoneController =
      TextEditingController(text: Get.find<UserDetail>().phone);
  FocusNode phoneNode = FocusNode();
  TextEditingController otherCommentsController = TextEditingController();
  FocusNode otherCommentsNode = FocusNode();
  TextEditingController periodController =
      TextEditingController(text: 'Hourly');
  FocusNode periodNode = FocusNode();

  // List<String> periods = ['Hourly', 'Daily', 'Weekly', 'Monthly'];

  int count = 1;
  ItemModel? itemModel;
  DateTime dateTime = DateTime.now();

  updateDate(DateTime date) {
    dateTime =
        dateTime.copyWith(day: date.day, month: date.month, year: date.year);
    update();
  }

  updateTime(TimeOfDay time) {
    dateTime = dateTime.copyWith(hour: time.hour, minute: time.minute);
    update();
  }

  addHour() {
    count++;
    update();
  }

  removeHour() {
    if (count == 1) return;
    count = count - 1;
    update();
  }

  void updateItem(ItemModel item) {
    itemModel = item;
    update();
  }

  var paymentIntent;
  bool isPaymentDone = false;
  Map cartItem = {};
  makeOrder() async {
    try {
      Map remaining = cartItem;
      EasyLoading.show();
      for (int i = 0; i < cartItem.keys.toList().length; i++) {
        String key = cartItem.keys.toList()[i];
        Map value = cartItem.values.toList()[i];
        Database.updateRequesStatus(key, RequestStatus.proceeded);
        RequestModel request = value['model'] as RequestModel;
        OrderModel orderModel = OrderModel(
            id: '0',
            itemId: request.itemId,
            dropPicture: [],
            period: request.getPeriod(request.period),
            requestBy: request.requestBy,
            ratingDone: false,
            requestTo: request.requestTo,
            status: OrderStatus.ordered,
            dateTime: request.dateTime,
            price: value['price'],
            pictures: [],
            hours: request.count);
        if (await Database.submitOrder(orderModel)) {
        } else {
          Global.showToastAlert(
              context: Get.overlayContext!,
              strTitle: "",
              strMsg: 'Something went wrong!. Please try again',
              toastType: TOAST_TYPE.toastError);
        }
      }
      EasyLoading.dismiss();
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Order submitted',
          toastType: TOAST_TYPE.toastSuccess);
      Get.back();
      Get.back();
    } catch (e) {
      print(e);
    }
  }

  createPaymentIntent(int amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': (amount * 100).toString(),
        'currency': 'NZD',
      };

      //Make post request to Stripe
      var response = await post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${Constants.stripeKey}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      if (response.body.contains('error') &&
          !response.body.contains('client_secret')) {}
      return jsonDecode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }
}
