import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/screens/main_screens/store.dart';
import 'package:back_packers/screens/profile/account.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/utils/text_styles.dart';

import '../../controllers/mainScreen_controllers/store_controller.dart';
import '../../globals/container_properties.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> mapController = Completer();
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  StoreController controller = Get.put(StoreController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (logic) {
      return Scaffold(
        body: SafeArea(
            child: Stack(
          children: [
            GoogleMap(
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController c) async {
                logic.mapController.complete(c);
                logic.getLocation();
              },
              markers: Set<Marker>.of(logic.markers.values),
              initialCameraPosition: logic.initialLocation,
              zoomControlsEnabled: false,
              myLocationEnabled: false,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GetBuilder<StoreController>(builder: (value) {
                return Container(
                  decoration: BoxDecoration(
                      color: AppColors.scaffoldBackgroundColor,
                      borderRadius:
                          const BorderRadius.vertical(bottom: Radius.circular(18))),
                  child: Column(
                    children: [
                      5.hp,
                      Row(
                        children: [
                          Expanded(child: categories(value)),
                          10.wp,
                          GetBuilder<UserDetail>(builder: (value) {
                            return GestureDetector(
                              onTap: () {
                                Get.to(() => const MyAccount());
                              },
                              child: CircleAvatar(
                                backgroundColor: AppColors.scaffoldGrey,
                                radius: 20,
                                child: value.image == ''
                                    ? const Icon(Icons.image)
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.network(
                                          value.image,
                                          fit: BoxFit.cover,
                                          height: double.infinity,
                                          width: double.infinity,
                                        ),
                                      ),
                              ),
                            );
                          }),
                        ],
                      ),
                      5.hp,
                      const Divider(),
                      10.hp,
                      radiusNLocation(context),
                      20.hp,
                    ],
                  ).paddingSymmetric(horizontal: 20),
                );
              }),
            ),
            // Positioned(
            //     bottom: 20,
            //     left: 0,
            //     right: 0,
            //     child: GestureDetector(
            //       onTap: () {
            //         Get.back();
            //       },
            //       child: Container(
            //         margin: const EdgeInsets.symmetric(horizontal: 10),
            //         height: ht(50),
            //         width: double.infinity,
            //         decoration:
            //             ContainerProperties.borderDecoration(radius: 100)
            //                 .copyWith(color: Colors.white),
            //         child: Row(
            //           children: [
            //             const SizedBox(
            //               width: 30,
            //             ),
            //             Expanded(
            //                 child: Text(
            //               'Show List',
            //               style: regularText(color: AppColors.primaryColor),
            //             )),
            //             Container(
            //               padding: const EdgeInsets.all(10),
            //               decoration: ContainerProperties.simpleDecoration(
            //                   radius: 100, color: AppColors.primaryColor),
            //               width: 100,
            //               height: ht(50),
            //               child: Image.asset('assets/images/ic_list.png'),
            //             )
            //           ],
            //         ),
            //       ),
            //     ))
          ],
        )),
      );
    });
  }

  SizedBox categories(StoreController value) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
          separatorBuilder: (ctx, i) => const SizedBox(
                width: 15,
              ),
          scrollDirection: Axis.horizontal,
          itemCount: value.categories.keys.toList().length,
          itemBuilder: (ctx, index) {
            return GestureDetector(
              onTap: () {
                value.changeCategory(index);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                alignment: Alignment.center,
                decoration: value.selectedCat == index
                    ? ContainerProperties.shadowDecoration(
                        radius: 10,
                        blurRadius: 5,
                        spreadRadius: 3,
                        color: AppColors.primaryColor)
                    : const BoxDecoration(
                        border:
                            Border(bottom: BorderSide(color: Colors.white))),
                child: Text(value.categories.keys.toList()[index],
                    style: headingText(color: Colors.white, size: 14)),
              ),
            );
          }),
    );
  }
}
