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
import '../../widgets/buddy_modal.dart';
import '../../widgets/accommodation_modal.dart';
import '../../widgets/job_modal.dart';
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
        
        // Get map controller first
        final GoogleMapController controller = await mapController.future;
        
        // Immediately move camera to last known location with proper zoom
        try {
          Position lastKnown = await Geolocator.getLastKnownPosition() ?? 
              await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.low,
                timeLimit: const Duration(seconds: 1),
              );
          
          latLng = LatLng(lastKnown.latitude, lastKnown.longitude);
          
          // Immediate camera animation with balanced zoom
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: latLng,
                zoom: 10.0,
                tilt: 0,
              ),
            ),
          );
          
          isLoading = false;
          update();
        } catch (e) {
          log("Error getting last known position: $e");
        }
        
        // Get precise current position in background and update
        Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).then((Position locationData) {
          latLng = LatLng(locationData.latitude, locationData.longitude);
          
          // Smoothly update to precise location if different
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: latLng,
                zoom: 10.0,
                tilt: 0,
              ),
            ),
          );
          
          update();
          getDataStream();
          
          // Get address in background
          LocationController.getAddressFromLatLng(
            latLng.latitude,
            latLng.longitude,
          ).then((addr) {
            location = addr;
            print(location);
            update();
          });
        });
      } else {
        isLoading = false;
        update();
      }
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
      onTap: () {
        // Show beautiful job modal
        JobModal.show(itemModel);
      },
    );
  }

  addMarkerHostel(
      Map data, LatLng latLng, Uint8List icon, Map<MarkerId, Marker> m) {
    MarkerId markerId = MarkerId(data['id']);
    m[markerId] = Marker(
      markerId: markerId,
      position: latLng,
      onTap: () {
        // Show beautiful accommodation modal
        AccommodationModal.show(data, latLng);
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
      onTap: () {
        // Show beautiful buddy modal
        BuddyModal.show(userModel);
      },
    );
  }
}
