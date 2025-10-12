import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:back_packers/globals/enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../globals/database.dart';
import '../../models/item_model.dart';
import '../../models/user.dart';
import '../../screens/main_screens/buddies.dart';
import '../../screens/profile/jobs/job_details.dart';
import '../../utils/app_colors.dart';
import '../../utils/login_details.dart';
import '../../utils/text_styles.dart';
import '../../widgets/primary_button.dart';
import '../location_manager.dart';

class StoreController extends GetxController {
  Map<String, List<String>> categories = {
    'All': [],
    'Jobs': [],
    'Accommodation': [],
    'Buddies': [],
  };

  int selectedCat = 0;
  LatLng latLng = const LatLng(-36.9161458, 174.640739);
  int radius = 50;
  List<int> radiusList = [30, 50, 70, 80, 100];

  CameraPosition get initialLocation => CameraPosition(
        target: latLng,
        zoom: 12.00,
      );
  changeCategory(int index) {
    selectedCat = index;
    getDataStream();
    update();
  }

  changeRadius(int index) {
    radius = radiusList[index];
    update();
    getDataStream();
  }

  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();

  String location = '';
  var isLoading = false;

  getLocation() async {
    try {
      isLoading = true;
      update();

      PermissionStatus status = await Permission.location.status;

      if (await Permission.location.status.isGranted == false ||
          await Permission.location.status.isLimited == false ||
          (Platform.isIOS
                  ? await Permission.location.status.isDenied == true
                  : await Permission.location.status.isDenied == false) &&
              await Permission.location.status.isPermanentlyDenied == false) {
        status = await Permission.location.request();
      }
      log(status.toString());
      if (status == PermissionStatus.granted ||
          status == PermissionStatus.limited) {
        log(status.toString());
        Position locationData = await Geolocator.getCurrentPosition();

        latLng = LatLng(locationData.latitude, locationData.longitude);
        final GoogleMapController controller = await mapController.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: latLng,
              zoom: 10,
            ),
          ),
        );
      }
      location = await LocationController.getAddressFromLatLng(
        latLng.latitude,
        latLng.longitude,
      );

      print(location);
      isLoading = false;
      update();
      getDataStream();
    } catch (e) {
      log(e.toString());
      // latLng = const LatLng(-36.9161458, 174.640739);
      latLng = const LatLng(31.4593734, 74.3325133);
      isLoading = false;
      update();
    }
  }

  updateLocation(String loc, LatLng latlng) async {
    location = loc;
    latLng = latlng;
    update();
    final GoogleMapController controller = await mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLng,
          zoom: 10,
        ),
      ),
    );
    getDataStream();
  }

  Completer<GoogleMapController> mapController = Completer();

  Map<MarkerId, Marker> markers = {};
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  getDataStream({String data = ""}) {
    markers.clear();
    update();
    getBuddies();
    getJobs();
    getHostels();
  }

  getJobs({String data = ''}) {
    if (selectedCat == 0 || selectedCat == 1) {
      Database.getNearByItemsOnTim(latLng, data, radius: radius)
          .then((items) async {
        items = items.toList();
        for (var item in items) {
          final Uint8List vehicle =
              await getBytesFromAsset('assets/images/location.png', 100);
          addMarkerJob(
              item.data()!,
              LatLng((item.data()!.geo as GeoPoint).latitude,
                  (item.data()!.geo as GeoPoint).longitude),
              vehicle,
              markers);
        }
        update();
      });
    }
  }

  getBuddies({String data = ''}) {
    if (selectedCat == 0 || selectedCat == 3) {
      Database.getNearByBuddiesOneTime(latLng, data, radius: radius)
          .then((items) async {
        items = items.toList();
        for (var item in items) {
          if (item.id != Get.find<UserDetail>().userId) {
            final Uint8List vehicle =
                await getBytesFromAsset('assets/images/user.png', 100);
            addMarkerUser(
                item.data()!,
                LatLng((item.data()!.geo as GeoPoint).latitude,
                    (item.data()!.geo as GeoPoint).longitude),
                vehicle,
                markers);
          }
        }
        update();
      });
    }
  }

  getHostels({String data = ''}) {
    if (selectedCat == 0 || selectedCat == 2) {
   post(Uri.parse('https://places.googleapis.com/v1/places:searchText'),
          body: jsonEncode({
            "textQuery": "hostel",
            "maxResultCount": 20,
            "locationBias": {
              "circle": {
                "center": {
                  "latitude": latLng.latitude,
                  "longitude": latLng.longitude
                },
                "radius": radius
              }
            }
          }),
          headers: {
            'X-Goog-Api-Key': LocationController.apiKey,
            'X-Goog-FieldMask':
                'places.formattedAddress,places.displayName,places.location,places.id'
          }).then((value) async {
            debugPrint("response is : ${value.body}");
        if (value.statusCode == 200) {
          List data = (jsonDecode(value.body)['places'] ?? []) as List;

          final Uint8List hotel =
              await getBytesFromAsset('assets/images/hotel.png', 100);
          for (var d in data) {
            print(d['location']['longitude']);
            print(d['location']['latitude']);
            addMarkerHostel(
                d,
                LatLng(d['location']['latitude'], d['location']['longitude']),
                hotel,
                markers);
          }
          update();
        }
      });
    }
  }

  addMarkerJob(ItemModel itemModel, LatLng latLng, Uint8List icon,
      Map<MarkerId, Marker> m) {
    MarkerId markerId = MarkerId(itemModel.id);
    m[markerId] = Marker(
      markerId: markerId,
      position: latLng,
      icon: BitmapDescriptor.fromBytes(icon),
      infoWindow: InfoWindow(
          title: itemModel.title,
          onTap: () {
            Get.to(() => AppliedJobDetails(itemModel: itemModel));
          }),
    );
  }

  addMarkerHostel(
      Map data, LatLng latLng, Uint8List icon, Map<MarkerId, Marker> m) {
    MarkerId markerId = MarkerId(data['id']);
    m[markerId] = Marker(
      markerId: markerId,
      position: latLng,
      onTap: () {
        Get.bottomSheet(Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data['displayName']['text'],
                style: subHeadingText(size: 23, color: AppColors.primaryColor),
              ),
              15.hp,
              Text(
                data['formattedAddress'] ?? "",
                style: subHeadingText(
                  size: 16,
                ),
              ),
              30.hp,
              PrimaryButton(
                  label: 'Get Direction',
                  onPress: () {
                    launchUrl(Uri.parse(
                        'https://www.google.com/maps/search/?api=1&query=${latLng.latitude},${latLng.longitude}'));
                  })
            ],
          ),
        ));
      },
      icon: BitmapDescriptor.fromBytes(icon),
    );
  }

  addMarkerUser(UserModel userModel, LatLng latLng, Uint8List icon,
      Map<MarkerId, Marker> m) {
    MarkerId markerId = MarkerId(userModel.id);
    m[markerId] = Marker(
      markerId: markerId,
      position: latLng,
      icon: BitmapDescriptor.fromBytes(icon),
      infoWindow: InfoWindow(
          title: "${userModel.fname} ${userModel.lname}",
          onTap: () {
            Get.bottomSheet(
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        padding: EdgeInsets.all(15),
                        child: Center(child: buddieContainer(userModel))),
                  ],
                ),
                isScrollControlled: true);
          }),
    );
  }
}
