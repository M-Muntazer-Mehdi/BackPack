import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:back_packers/controllers/pick_controller.dart';
import 'package:back_packers/utils/app_colors.dart';

class PickLocation extends StatefulWidget {
  final Function(String? address, LatLng latLng) onSubmit;
  final LatLng? initialLatLng;
  const PickLocation({super.key, required this.onSubmit, this.initialLatLng});

  @override
  State<PickLocation> createState() => _PickLocationState();
}

class _PickLocationState extends State<PickLocation> with TickerProviderStateMixin {
  var controller = Get.put(PickScreenController());
  Timer? _timer;
  late AnimationController _pulseController;
  late AnimationController _scaleController;

  @override
  void initState() {
    controller.getLocation(initialLatLng: widget.initialLatLng);
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<PickScreenController>(
          builder: (value) {
          return Stack(
              children: [
              // Google Map
              Positioned.fill(
                        child: GoogleMap(
                          onMapCreated: (GoogleMapController c) {
                            value.mapController.complete(c);
                          },
                          onCameraIdle: () async {
                            controller.changeAddressBarValue();
                          },
                          onCameraMove: (position) {
                            controller.changeMarkerPadding(true);
                            value.latLng = LatLng(position.target.latitude, position.target.longitude);
                          },
                          markers: value.markers,
                          initialCameraPosition: value.initialLocation,
                          zoomControlsEnabled: false,
                          myLocationEnabled: true,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),
              
              // Center marker pin with animation
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, math.sin(_pulseController.value * 2 * math.pi) * 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.primaryColor.withOpacity(0.6),
                                    AppColors.primaryColor.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Premium header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Header with back button
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgGrey,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.borderColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    color: AppColors.txtDark,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) => LinearGradient(
                                        colors: [
                                          AppColors.primaryDark,
                                          AppColors.primaryColor,
                                        ],
                                      ).createShader(bounds),
                                      child: const Text(
                                        'Select Location',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Pin your exact location',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.txtMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Premium search bar
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.bgGrey,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.borderColor,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: controller.fromLoc,
                              focusNode: controller.fromnodeloc,
                              onChanged: (String? val) {
                                if (val!.length >= 3) {
                                  _timer?.cancel();
                                  _timer = Timer(const Duration(seconds: 1), () {
                                    value.findPlaces(val);
                                  });
                                } else {
                                  value.places.clear();
                                  value.showPlaces = false;
                                  value.update();
                                }
                              },
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.txtDark,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search location...',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.txtMuted,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: AppColors.primaryColor,
                                  size: 22,
                                ),
                                suffixIcon: controller.fromLoc.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        controller.fromLoc.clear();
                                        value.places.clear();
                                        value.showPlaces = false;
                                        value.update();
                                      },
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: AppColors.txtMuted,
                                        size: 20,
                                      ),
                                    )
                                  : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Search results overlay
              if (value.showPlaces)
                Positioned(
                  top: 160,
                  left: 20,
                  right: 20,
                        child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: 350,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryColor.withOpacity(0.05),
                                AppColors.primaryLight.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.place_rounded,
                          color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Search Results',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.txtDark,
                                      ),
                                    ),
                                    Text(
                                      '${value.places.length} locations found',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.txtMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  value.showPlaces = false;
                                  value.update();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgGrey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: AppColors.txtDark,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Results list
                        Flexible(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(8),
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            separatorBuilder: (context, index) => const SizedBox(height: 4),
                            itemCount: value.places.length,
                            itemBuilder: (context, index) => GestureDetector(
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  await value.chooseLocation(value.places[index]);
                                  value.showPlaces = false;
                                  value.update();
                                },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.bgGrey,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.borderColor,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.location_on_rounded,
                                        color: AppColors.primaryColor,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        value.places[index],
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.txtDark,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: AppColors.txtMuted,
                                    ),
                                  ],
                                ),
                              ),
                          ),
                        ),
                      ),
                    ],
                    ),
                  ),
                ),
              
              // Floating action buttons
              Positioned(
                right: 20,
                bottom: 180,
                child: Column(
                  children: [
                    _buildFAB(
                      icon: Icons.my_location_rounded,
                      onTap: () => controller.getLocation(),
                    ),
                    const SizedBox(height: 12),
                    _buildFAB(
                      icon: Icons.zoom_in_rounded,
                      onTap: () async {
                        final GoogleMapController mapCtrl = await controller.mapController.future;
                        mapCtrl.animateCamera(CameraUpdate.zoomIn());
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFAB(
                      icon: Icons.zoom_out_rounded,
                      onTap: () async {
                        final GoogleMapController mapCtrl = await controller.mapController.future;
                        mapCtrl.animateCamera(CameraUpdate.zoomOut());
                      },
                    ),
                  ],
                ),
              ),
              
              // Bottom confirm button
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: GestureDetector(
                      onTapDown: (_) => _scaleController.forward(),
                      onTapUp: (_) => _scaleController.reverse(),
                      onTapCancel: () => _scaleController.reverse(),
                      onTap: () {
                        if (controller.latLng == null || controller.fromLoc.text.isEmpty) {
                          return;
                        }
                        widget.onSubmit(controller.fromLoc.text, controller.latLng!);
                      },
                      child: AnimatedBuilder(
                        animation: _scaleController,
                        builder: (context, child) {
                          final scale = 1.0 - (_scaleController.value * 0.05);
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Confirm Location',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  ),
                ),
              ],
            );
          },
      ),
    );
  }

  Widget _buildFAB({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppColors.primaryColor,
          size: 24,
        ),
      ),
    );
  }
}
