import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/mainScreen_controllers/navbar_controller.dart';
import 'package:back_packers/controllers/order_controller.dart';
import 'package:back_packers/screens/main_screens/all_jobs.dart';
import 'package:back_packers/screens/main_screens/buddies.dart';
import 'package:back_packers/screens/main_screens/chat_view/all_chats.dart';
import 'package:back_packers/screens/other_screens/map_screen.dart';
import 'package:back_packers/utils/app_colors.dart';

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
    super.initState();
    controller.animationController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavBarController>(
      init: NavBarController(),
      builder: (value) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: IndexedStack(
            index: value.currentIndex,
            children: const [
              MapScreen(),
              Buddies(),
              ChatScreen(),
              AllJobs(),
            ],
          ),
          bottomNavigationBar: _buildModernBottomBar(value),
        );
      },
    );
  }

  Widget _buildModernBottomBar(NavBarController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                icon: Icons.explore_rounded,
                label: 'Explore',
                index: 0,
                controller: controller,
              ),
              _buildNavItem(
                icon: Icons.people_rounded,
                label: 'Buddies',
                index: 1,
                controller: controller,
              ),
              _buildNavItem(
                icon: Icons.chat_bubble_rounded,
                label: 'Chats',
                index: 2,
                controller: controller,
              ),
              _buildNavItem(
                icon: Icons.work_rounded,
                label: 'Jobs',
                index: 3,
                controller: controller,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required NavBarController controller,
  }) {
    final isActive = controller.currentIndex == index;
    
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.primaryGradient : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : AppColors.iconColor,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                child: Text(label),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
