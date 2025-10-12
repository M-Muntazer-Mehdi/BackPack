import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/global.dart';
import 'package:back_packers/utils/text_styles.dart';

class LocationController {
  // static const apiKey = 'AIzaSyAcg4t_7-h6LvAaYz80KlTCrKtWhfsVCm0';
  // static const apiKey = 'AlzaSyB837mF5NIMwZoka6Cl6qdhfkvT-ukVVDg';
  // static const apiKey = 'AIzaSyBNkH8Ao7AnpIBenPfKDZtMYSvyTuV7nJ8';
  // static const apiKey = 'AIzaSyC9FPLBwpCIQIRVERrlmHv94qv4u9zmILw';
  // static const apiKey = 'AIzaSyCSlXpcwO19SMW7mv5T9c9UCI1vDZiIrls';
  static const apiKey = 'AIzaSyBy4VmzgVngNmcxarMkiTkqDWjvhzNfZ0o';
  // static const apiKey = 'AIzaSyCBDzA1PUvLkPkX9sTP_Br3gVPI8SzsL2Q';

  static Future<LatLng> getCurrentLocation() async {
    try {
      PermissionStatus? status = await Permission.location.status;
      debugPrint("status is : $status");

      if (!await Permission.location.status.isGranted ||
          !await Permission.location.status.isLimited ||
          (Platform.isIOS
                  ? await Permission.location.status.isDenied == true
                  : await Permission.location.status.isDenied == false) &&
              await Permission.location.status.isPermanentlyDenied == false) {
        status = await Permission.location.request();
      }
      if (status == PermissionStatus.granted ||
          status == PermissionStatus.limited) {
        Position locationData = await Geolocator.getCurrentPosition();

        return LatLng(locationData.latitude, locationData.longitude);
      } else {
        Global.showToastAlert(
            context: Get.overlayContext!,
            strTitle: "ok",
            strMsg: 'Please enable location from app settings',
            toastType: TOAST_TYPE.toastInfo,
            action: InkWell(
                onTap: () {
                  openAppSettings();
                },
                child: Text(
                  'Settings',
                  style: subHeadingText(size: 15),
                )));
        return LatLng(-36.9161458, 174.640739);
      }
    } catch (e) {
      log(e.toString());
      return LatLng(-36.9161458, 174.640739);
    }
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load('assets/images/$path');
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static Future<List<LatLng>?> getPolyline(
      Completer<GoogleMapController> mapController,
      LatLng? fromLatLng,
      LatLng? toLatLng,
      Map<PolylineId, Polyline> polylines) async {
    if (fromLatLng == null || toLatLng == null) return null;

    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints(apiKey: LocationController.apiKey);
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
     request: PolylineRequest(
        origin: PointLatLng(fromLatLng.latitude, fromLatLng.longitude),
        destination: PointLatLng(toLatLng.latitude, toLatLng.longitude),
        mode:  TravelMode.driving,
      )
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    addPolyLine(polylineCoordinates, polylines);
    return polylineCoordinates;
  }

  static addPolyLine(
    List<LatLng> polylineCoordinates,
    Map<PolylineId, Polyline> polylines,
  ) {
    PolylineId id = PolylineId("k");
    Polyline polyline = Polyline(
        polylineId: id,
        visible: true,
        color: Colors.white,
        points: polylineCoordinates,
        width: 3);
    polylines[id] = polyline;
  }

  static Future customCameraZoom(
    Completer<GoogleMapController> mapController,
    LatLng? fromLatLng,
    LatLng? toLatLng,
  ) async {
    double miny = (fromLatLng!.latitude <= toLatLng!.latitude)
        ? fromLatLng.latitude
        : toLatLng.latitude;
    double minx = (fromLatLng.longitude <= toLatLng.longitude)
        ? fromLatLng.longitude
        : toLatLng.longitude;
    double maxy = (fromLatLng.latitude <= toLatLng.latitude)
        ? toLatLng.latitude
        : fromLatLng.latitude;
    double maxx = (fromLatLng.longitude <= toLatLng.longitude)
        ? toLatLng.longitude
        : fromLatLng.longitude;

    double southWestLatitude = miny;
    double southWestLongitude = minx;

    double northEastLatitude = maxy;
    double northEastLongitude = maxx;

    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(northEastLatitude, northEastLongitude),
          southwest: LatLng(southWestLatitude, southWestLongitude),
        ),
        100.0,
      ),
    );
  }

  static Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      Placemark place = placemarks.first; // Get the first placemark, which is usually the most relevant

      // Construct the address string from various placemark properties
      String address = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
      return address;
    } catch (e) {
      debugPrint("Error getting address: $e");
      return "Address not found";
    }
  }

  static Timer? updateTime;
}
