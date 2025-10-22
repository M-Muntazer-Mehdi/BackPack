import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/globals/enum.dart';

class LocationMessageBubble extends StatelessWidget {
  final Map<String, dynamic> locationData;
  final MsgType msgType;
  final Timestamp time;

  const LocationMessageBubble({
    Key? key,
    required this.locationData,
    required this.msgType,
    required this.time,
  }) : super(key: key);

  Future<void> _openInMaps() async {
    try {
      final latitude = locationData['latitude'] as double? ?? 0.0;
      final longitude = locationData['longitude'] as double? ?? 0.0;
      final address = locationData['address'] as String? ?? '';

      // Open in Google Maps
      final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      
      log('📍 Opening location: $latitude, $longitude');
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        // Fallback to geo URI
        final geoUrl = 'geo:$latitude,$longitude?q=$latitude,$longitude';
        await launchUrl(Uri.parse(geoUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      log('❌ Error opening maps: $e');
      Get.snackbar(
        'Error',
        'Could not open location in maps',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSender = msgType == MsgType.right;
    final latitude = locationData['latitude'] as double? ?? 0.0;
    final longitude = locationData['longitude'] as double? ?? 0.0;
    final address = locationData['address'] as String? ?? 'Location';

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: _openInMaps,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          margin: EdgeInsets.only(
            top: 4,
            bottom: 4,
            left: isSender ? 60 : 10,
            right: isSender ? 10 : 60,
          ),
          decoration: BoxDecoration(
            color: isSender 
                ? AppColors.primaryColor.withOpacity(0.9)
                : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isSender ? 20 : 0),
              bottomRight: Radius.circular(isSender ? 0 : 20),
            ),
            boxShadow: [
              BoxShadow(
                color: isSender 
                    ? AppColors.primaryColor.withOpacity(0.25)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Map preview
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[800],
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude, longitude),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('location'),
                        position: LatLng(latitude, longitude),
                      ),
                    },
                    zoomControlsEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: false,
                    liteModeEnabled: true, // Use lite mode for static preview
                  ),
                ),
              ),
              
              // Location info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: isSender ? Colors.white : AppColors.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSender ? Colors.white : AppColors.txtDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tap to open in maps',
                          style: TextStyle(
                            fontSize: 10,
                            color: isSender ? Colors.white.withOpacity(0.85) : AppColors.txtGrey,
                          ),
                        ),
                        Text(
                          _formatTime(time),
                          style: TextStyle(
                            fontSize: 10,
                            color: isSender ? Colors.white.withOpacity(0.85) : AppColors.txtGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}




