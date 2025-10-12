import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/mainScreen_controllers/navbar_controller.dart';
import 'package:back_packers/controllers/order_controller.dart';
import 'package:back_packers/globals/container_properties.dart';
import 'package:back_packers/screens/main_screens/all_jobs.dart';
import 'package:back_packers/screens/main_screens/buddies.dart';
import 'package:back_packers/screens/main_screens/chat_view/all_chats.dart';
import 'package:back_packers/screens/other_screens/map_screen.dart';
import 'package:back_packers/utils/text_styles.dart';

import '../../globals/adaptive_helper.dart';
import '../../utils/app_colors.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> with SingleTickerProviderStateMixin {
  var controller = Get.put(NavBarController());
  var user = Get.put(OrderController());

  @override
  void initState() {
    // controller.changeTab(0);
    super.initState();
    controller.animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavBarController>(
      init: NavBarController(),
      builder: (value) {
        return Container(
          decoration: ContainerProperties.shadowDecoration(),
          child: Scaffold(
            backgroundColor: AppColors.scaffoldBackgroundColor,
            body: SafeArea(
              child: Center(
                child: IndexedStack(
                  index: value.currentIndex,
                  children: [
                    Visibility(maintainState: true, visible: value.currentIndex == 0, child: const MapScreen()),
                    Visibility(maintainState: true, visible: value.currentIndex == 1, child: const Buddies()),
                    Visibility(visible: value.currentIndex == 2, child: const ChatScreen()),
                    Visibility(visible: value.currentIndex == 3, child: const AllJobs()),
                  ],
                ),
              ),
            ),
            extendBody: true,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: SizedBox(
              width: double.infinity,
              height: ht(85),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: wd(10)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.borderColor.withValues(alpha: 0.2),
                            offset: const Offset(0, -2),
                            spreadRadius: 3,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      height: ht(60),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                value.changeTab(0);
                              },
                              child: Container(
                                color: Colors.transparent,
                                alignment: Alignment.center,
                                // decoration: _dec(0, value),
                                margin: _mar(),
                                padding: padd(),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    children: [
                                      // Image.asset(
                                      //   'assets/images/ic_marker.png',
                                      //   height: 20,
                                      //   color: _iconColor(0, value),
                                      // ),
                                      Icon(Icons.search_outlined, color: AppColors.borderColor),
                                      const SizedBox(height: 5),
                                      Text("Search", style: style(0, value)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                value.changeTab(1);
                              },
                              child: Container(
                                color: Colors.transparent,
                                alignment: Alignment.center,
                                // decoration: _dec(1, value),
                                margin: _mar(),
                                padding: padd(),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    children: [
                                      // Image.asset(
                                      //   'assets/images/ic_store.png',
                                      //   height: 21,
                                      //   color: _iconColor(1, value),
                                      // ),
                                      Icon(Icons.person, color: AppColors.borderColor),
                                      const SizedBox(height: 7),
                                      Text("Buddies", style: style(1, value)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                value.changeTab(2);
                              },
                              child: Container(
                                color: Colors.transparent,
                                alignment: Alignment.center,
                                // decoration: _dec(2, value),
                                margin: _mar(),
                                padding: padd(),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    children: [
                                      Icon(Icons.chat_bubble_rounded, color: AppColors.borderColor),
                                      // Image.asset(
                                      //   'assets/images/ic_settings.png',
                                      //   height: 21,
                                      //   color: _iconColor(2, value),
                                      // ),
                                      const SizedBox(height: 7),
                                      Text("Chats", style: style(2, value)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                value.changeTab(3);
                              },
                              child: Container(
                                color: Colors.transparent,
                                alignment: Alignment.center,
                                // decoration: _dec(2, value),
                                margin: _mar(),
                                padding: padd(),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    children: [
                                      // Image.asset(
                                      //   'assets/images/ic_settings.png',
                                      //   height: 21,
                                      //   color: _iconColor(3, value),
                                      // ),
                                      Icon(Icons.work, color: AppColors.borderColor),
                                      const SizedBox(height: 7),
                                      Text("Jobs", style: style(3, value)),
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
                  Positioned(
                    top: 3,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: wd(10)),
                      child: Row(
                        children: [
                          Expanded(
                            child: value.currentIndex != 0
                                ? SizedBox.shrink()
                                : Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        value.changeTab(0);
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        width: 55,
                                        height: 55,
                                        margin: _mar(),
                                        padding: padd(),
                                        child: CustomPaint(
                                          painter: HexagonPainter(),
                                          child: Center(
                                            child: Icon(Icons.search_outlined, color: AppColors.colorWhite),
                                            // Image.asset(
                                            //   'assets/images/ic_marker.png',
                                            //   height: 20,
                                            //   color: _iconColorLayer(0, value),
                                            // ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: value.currentIndex != 1
                                ? SizedBox.shrink()
                                : Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        value.changeTab(1);
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        width: 55,
                                        height: 55,
                                        margin: _mar(),
                                        padding: padd(),
                                        child: CustomPaint(
                                          painter: HexagonPainter(),
                                          child: Center(
                                            child: Icon(Icons.person, color: AppColors.colorWhite),
                                            // Image.asset(
                                            //   'assets/images/ic_store.png',
                                            //   height: 20,
                                            //   color: _iconColorLayer(1, value),
                                            // ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: value.currentIndex != 2
                                ? const SizedBox.shrink()
                                : Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        value.changeTab(2);
                                      },
                                      child: Container(
                                        width: 55,
                                        height: 55,
                                        margin: _mar(),
                                        padding: padd(),
                                        child: CustomPaint(
                                          painter: HexagonPainter(),
                                          child: Center(
                                            child:
                                                // Image.asset(
                                                //   'assets/images/ic_settings.png',
                                                //   height: 20,
                                                //   color: _iconColorLayer(2, value),
                                                // ),
                                                Icon(Icons.chat_bubble_rounded, color: AppColors.colorWhite),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: value.currentIndex != 3
                                ? const SizedBox.shrink()
                                : Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        value.changeTab(3);
                                      },
                                      child: Container(
                                        width: 55,
                                        height: 55,
                                        margin: _mar(),
                                        padding: padd(),
                                        child: CustomPaint(
                                          painter: HexagonPainter(),
                                          child: Center(
                                            child: Icon(Icons.work, color: AppColors.colorWhite),
                                            // Image.asset(
                                            //   'assets/images/ic_settings.png',
                                            //   height: 20,
                                            //   color: _iconColorLayer(3, value),
                                            // ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  TextStyle style(int i, NavBarController value) {
    return regularText(size: 10, color: controller.currentIndex != i ? HexColor('#667085') : AppColors.primaryColor);
  }

  EdgeInsets padd() => const EdgeInsets.symmetric(horizontal: 3);

  EdgeInsets _mar() => EdgeInsets.only(top: ht(5), bottom: 2);

}

class HexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors
          .primaryColor // Change this color to the desired color
      ..style = PaintingStyle.fill;

    double centerX = size.width / 2;
    double centerY = size.height / 2;

    double radius = size.width / 2;

    Path path = Path();

    for (int i = 0; i < 6; i++) {
      double angle = (pi / 3) * i - pi / 2; // Adjusted angle to start from the top
      double x = centerX + radius * cos(angle);
      double y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
