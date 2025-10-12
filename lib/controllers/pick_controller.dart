import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'location_manager.dart';

class PickScreenController extends GetxController {
  LatLng? latLng;

  final Set<Marker> markers = <Marker>{};

  Completer<GoogleMapController> mapController = Completer();

  CameraPosition initialLocation = const CameraPosition(target: LatLng(-36.9161458, 174.640739), zoom: 11.00);
  TextEditingController fromLoc = TextEditingController();
  FocusNode fromnodeloc = FocusNode();
  List<String> places = [];
  var markerPadding = false.obs;
  void changeMarkerPadding(val) {
    markerPadding(val);
  }

  // var apiKey = 'AIzaSyAcg4t_7-h6LvAaYz80KlTCrKtWhfsVCm0';
  // var apiKey = 'AlzaSyB837mF5NIMwZoka6Cl6qdhfkvT-ukVVDg';
  // var apiKey = 'AIzaSyBNkH8Ao7AnpIBenPfKDZtMYSvyTuV7nJ8';
  // var apiKey = 'AIzaSyC9FPLBwpCIQIRVERrlmHv94qv4u9zmILw';
  // var apiKey = 'AIzaSyCSlXpcwO19SMW7mv5T9c9UCI1vDZiIrls';
  var apiKey = 'AIzaSyBy4VmzgVngNmcxarMkiTkqDWjvhzNfZ0o';
  // var apiKey = 'AIzaSyCBDzA1PUvLkPkX9sTP_Br3gVPI8SzsL2Q';

  getLocation({LatLng? initialLatLng}) async {
    try {
      LatLng mLatLng_;
      if (initialLatLng != null) {
        mLatLng_ = initialLatLng;
      } else {
        mLatLng_ = await LocationController.getCurrentLocation();
      }
      markers.clear();
      final GoogleMapController controller = await mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: mLatLng_, zoom: 12)));
      update();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> changeAddressBarValue() async {
    if (places.isNotEmpty) return;
    fromLoc.text = await LocationController.getAddressFromLatLng(latLng!.latitude, latLng!.longitude);
  }

  bool showPlaces = false;

  Future<void> findPlaces(String placeId) async // to get google places api result
  {
    update();
    try {
      var url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeId&key=$apiKey&sessiontoken=1234567890';
      var response = await http.get(Uri.parse(url));
      log("response is : ${response.body}");
      var result = await json.decode(response.body);

      List<dynamic> list = result['predictions'];
      places.clear();
      for (int i = 0; i < list.length; i++) {
        var p = list[i]['description'];
        places.add(p);
      }
      if (places.isNotEmpty) {
        showPlaces = true;
        update();
      }
      debugPrint(list.toString());
    } catch (err) {
      log("error while searching places : $err");
    }
    update();
  }

  chooseLocation(String val) async {
    try {
      EasyLoading.show();

      var url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$val&key=${LocationController.apiKey}';
      debugPrint("url is ---------------------> $url");
      var response = await http.get(Uri.parse(url));
      var result = await json.decode(response.body);
      debugPrint("result is ---------------------> $result");
      double lat = 0;
      double lng = 0;
      if (result['status'] == 'OK' && result['results'].isNotEmpty) {
        lat = result['results'][0]['geometry']['location']['lat'] ?? 0;
        lng = result['results'][0]['geometry']['location']['lng'] ?? 0;
      }
      EasyLoading.dismiss();
      showPlaces = false;
      places.clear();
      update();
      if(lat==0 && lng==0){
        return;
      }
      final GoogleMapController controller = await mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lng), zoom: 17.5)));
      fromLoc.text = val;
      latLng = LatLng(lat, lng);

      update();
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint("error while getting the address is : $e");
      log(e.toString());
    }
  }
}
