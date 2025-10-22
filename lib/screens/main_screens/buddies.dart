import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/mainScreen_controllers/store_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/chat_database.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/globals/network_image.dart';
import 'package:back_packers/models/group_chat_model.dart';
import 'package:back_packers/models/user.dart';
import 'package:back_packers/screens/main_screens/chat_view/chat_room.dart';
import 'package:back_packers/screens/main_screens/store.dart';
import 'package:back_packers/screens/other_screens/pick_location_controller.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/widgets/custom_bottom_option_sheet.dart';

class Buddies extends StatefulWidget {
  const Buddies({super.key});

  @override
  State<Buddies> createState() => _BuddiesState();
}

class _BuddiesState extends State<Buddies> with TickerProviderStateMixin {
  late AnimationController _headerAnimController;
  late AnimationController _floatController;
  late AnimationController _filterExpandController;
  bool _isFiltersExpanded = false;

  @override
  void initState() {
    super.initState();
    
    // Header gradient animation
    _headerAnimController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    // Floating animation for subtle movement
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    // Filter expand/collapse animation
    _filterExpandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
      value: 0.0, // Start collapsed (hidden)
    );
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _floatController.dispose();
    _filterExpandController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      _isFiltersExpanded = !_isFiltersExpanded;
      if (_isFiltersExpanded) {
        _filterExpandController.forward();
      } else {
        _filterExpandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: SafeArea(
        child: GetBuilder<StoreController>(
          builder: (logic) {
            return Column(
              children: [
                // Modern header
                _buildHeader(),
                
                // Toggle button for filters
                _buildFilterToggleButton(),
                
                // Collapsible location controls
                SizeTransition(
                  sizeFactor: CurvedAnimation(
                    parent: _filterExpandController,
                    curve: Curves.easeInOut,
                  ),
                  child: _buildBuddiesLocationControls(logic),
                ),
                
                const SizedBox(height: 20),
                
                // Buddies list
                Expanded(
                  child: StreamBuilder<List<DocumentSnapshot<UserModel>>>(
                    stream: Database.getNearByBuddies(
                      logic.latLng,
                      '',
                      radius: logic.radius,
                    ),
                      builder: (context, snap) {
                        if (snap.hasError) {
                        return _buildEmptyState('No Buddies Available');
                        }
                        if (!snap.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        );
                        }
                        if (snap.data!.isEmpty) {
                        return _buildEmptyState('No Buddies Nearby');
                        }

                        return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: snap.data?.length,
                            itemBuilder: (context, index) {
                              UserModel? userModel = snap.data?[index].data();
                          
                          // Filter out self and reported users
                          if (userModel?.id == Get.find<UserDetail>().userId ||
                              Get.find<UserDetail>().reportedUsers.contains(userModel?.id)) {
                            return const SizedBox.shrink();
                          }
                          
                          return _buildAnimatedBuddieCard(
                                userModel,
                            index: index,
                                myId: Get.find<UserDetail>().userId,
                              );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterToggleButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: GestureDetector(
        onTap: _toggleFilters,
        child: AnimatedBuilder(
          animation: _filterExpandController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isFiltersExpanded
                    ? [
                        AppColors.primaryColor.withOpacity(0.1),
                        AppColors.primaryColor.withOpacity(0.05),
                      ]
                    : [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.85),
                      ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: _isFiltersExpanded
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isFiltersExpanded ? Icons.tune_rounded : Icons.filter_list_rounded,
                    color: _isFiltersExpanded 
                      ? AppColors.primaryColor 
                      : Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isFiltersExpanded ? 'Hide Filters' : 'Show Filters',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _isFiltersExpanded 
                        ? AppColors.primaryColor 
                        : Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: _isFiltersExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 400),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _isFiltersExpanded 
                        ? AppColors.primaryColor 
                        : Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBuddiesLocationControls(StoreController logic) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Animated background gradient accent
            AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Positioned(
                  right: -30 + (10 * _floatController.value),
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primaryColor.withOpacity(0.08),
                          AppColors.primaryColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Main content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Radius control - Road with draggable car
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withOpacity(0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Search Radius',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              '${logic.radius} Km',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Realistic Road with car animation
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double roadWidth = constraints.maxWidth;
                            int currentIndex = logic.radiusList.indexOf(logic.radius);
                            // Match car position with marker positions
                            double totalWidth = roadWidth - 60;
                            double carPosition = 30 + (totalWidth * (currentIndex / (logic.radiusList.length - 1))) - 17.5;
                            
                            return GestureDetector(
                              onHorizontalDragUpdate: (details) {
                                double dragPosition = details.localPosition.dx;
                                int newIndex = ((dragPosition / roadWidth) * logic.radiusList.length).floor();
                                newIndex = newIndex.clamp(0, logic.radiusList.length - 1);
                                
                                if (newIndex != currentIndex) {
                                  logic.changeRadius(newIndex);
                                  HapticFeedback.lightImpact();
                                }
                              },
                              onTapUp: (details) {
                                double tapPosition = details.localPosition.dx;
                                int newIndex = ((tapPosition / roadWidth) * logic.radiusList.length).floor();
                                newIndex = newIndex.clamp(0, logic.radiusList.length - 1);
                                logic.changeRadius(newIndex);
                                HapticFeedback.mediumImpact();
                              },
                              child: Container(
                                height: 60,
                                color: Colors.transparent,
                                child: Stack(
                                  children: [
                                    // Realistic Road surface
                                    Positioned(
                                      bottom: 10,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border(
                                            top: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                                            bottom: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            // Road center line (dashed)
                                            Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: List.generate(
                                                  10,
                                                  (index) => Container(
                                                    width: roadWidth / 25,
                                                    height: 2,
                                                    decoration: BoxDecoration(
                                                      color: Colors.yellow.withOpacity(0.6),
                                                      borderRadius: BorderRadius.circular(1),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    
                                    // Distance markers (km values)
                                    ...List.generate(logic.radiusList.length, (index) {
                                      // Calculate position with proper spacing for labels
                                      double totalWidth = roadWidth - 60; // Leave more space on both ends
                                      double position = 30 + (totalWidth * (index / (logic.radiusList.length - 1)));
                                      bool isActive = index == currentIndex;
                                      
                                      return Positioned(
                                        left: position - 18, // Center the label (half of 36)
                                        bottom: 40,
                                        child: Container(
                                          width: 36,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isActive 
                                              ? Colors.white 
                                              : Colors.white.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: isActive 
                                              ? Border.all(color: Colors.white, width: 2)
                                              : null,
                                          ),
                                          child: Text(
                                            '${logic.radiusList[index]}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: isActive 
                                                ? AppColors.primaryColor 
                                                : Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                          ),
                                        ),
                                      );
                                    }),
                                    
                                    // Realistic Car on road
                                    AnimatedPositioned(
                                      duration: const Duration(milliseconds: 350),
                                      curve: Curves.easeOutCubic,
                                      left: carPosition,
                                      bottom: 13,
                                      child: AnimatedBuilder(
                                        animation: _floatController,
                                        builder: (context, child) {
                                          return Transform.translate(
                                            offset: Offset(0, -1 + (2 * _floatController.value)),
                                            child: Container(
                                              width: 35,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(6),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.3),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.directions_car,
                                                  color: AppColors.primaryColor,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Location control - Full width white card with purple accent
                  GestureDetector(
                    onTap: () {
                      Get.to(() => PickLocation(
                        onSubmit: (loc, latlng) {
                          Get.back();
                          logic.latLng = latlng;
                          logic.location = loc ?? '';
                          logic.update();
                          logic.getDataStream();
                        },
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryColor.withOpacity(0.2),
                                  AppColors.primaryColor.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Current Location',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.txtGrey,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  logic.location.isEmpty ? 'Select your location' : logic.location,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.txtDark,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.edit_location_alt_rounded,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimController,
      builder: (context, child) {
        return Container(
          clipBehavior: Clip.none,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.85),
                AppColors.primaryColor.withOpacity(0.7),
              ],
              stops: [
                0.0,
                0.5 + (0.2 * math.sin(_headerAnimController.value * 2 * math.pi)),
                1.0,
              ],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Animated floating circles decoration
              Positioned(
                right: -40 + (30 * math.sin(_headerAnimController.value * 2 * math.pi)),
                top: -20 + (20 * math.cos(_headerAnimController.value * 2 * math.pi)),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 2,
                    ),
                  ),
                ),
              ),
              
              Positioned(
                left: -20 + (20 * math.cos(_headerAnimController.value * 2 * math.pi + 1)),
                bottom: -15 + (15 * math.sin(_headerAnimController.value * 2 * math.pi + 1)),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              
              // Main content with flexible layout
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main row with icon, title, and live badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Animated icon badge
                        AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -2 + (4 * _floatController.value)),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.people_rounded,
                                  color: AppColors.primaryColor,
                                  size: 26,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        // Title section next to icon
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Find Your',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Travel Buddies',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  AnimatedBuilder(
                                    animation: _floatController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(0, -1 + (2 * _floatController.value)),
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.emoji_people_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Live badge
                        AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.95 + (0.05 * _floatController.value),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.wifi_tethering_rounded, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'Live',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
              ],
            ),
          ),
        );
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Location badge below
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: Colors.white, size: 11),
                          SizedBox(width: 4),
                          Text(
                            'Discover travelers nearby',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 60,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.txtDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search radius',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.txtGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBuddieCard(UserModel? userModel, {required int index, String? myId}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: _buildBuddieCard(userModel, myId: myId),
    );
  }

  Widget _buildBuddieCard(UserModel? userModel, {String? myId}) {
    final isBlocked = userModel?.reportedUsers.contains(myId) ?? false;
    final isApproved = userModel?.approved ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact header with photo and info side by side
          Container(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile photo
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColor.withOpacity(0.2),
                            AppColors.primaryColor.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: NetworkImageCustom(
                          image: userModel?.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Verification badge on photo
                    if (isApproved)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                // Info section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        '${userModel?.fname ?? ''} ${userModel?.lname ?? ''}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: -0.4,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Location badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 13,
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Nearby',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Email
                      Row(
                        children: [
                          Icon(
                            Icons.email_rounded,
                            size: 14,
                            color: AppColors.txtGrey,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              userModel?.email ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.txtGrey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Phone (if available)
                      if (userModel?.phone != null && userModel!.phone.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              size: 14,
                              color: AppColors.txtGrey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              userModel.phone,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.txtGrey,
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
          
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primaryColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Action button
          Padding(
            padding: const EdgeInsets.all(14),
            child: isBlocked
              ? _buildBlockedButton()
              : _buildConnectionButton(userModel),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedButton() {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.errorRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.errorRed.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block_rounded,
              size: 18,
              color: AppColors.errorRed,
            ),
            const SizedBox(width: 8),
            Text(
              'Blocked',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.errorRed,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionButton(UserModel? userModel) {
    return StreamBuilder<QuerySnapshot<ChatGroupModel>>(
                stream: Database.getChatRoomStatus(userModel?.id ?? ""),
                builder: (context, snap) {
        if (snap.hasError) return const SizedBox.shrink();
                  if (!snap.hasData) {
          return Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            ),
          );
        }

                  final querySnapshot = snap.data;
        
                  if (querySnapshot?.docs.isNotEmpty ?? false) {
          String status = querySnapshot?.docs.first.data().status ?? "accepted";
          return _buildStatusButton(status, querySnapshot!.docs.first.data());
        }
        
        return _buildConnectButton(userModel);
      },
    );
  }

  Widget _buildStatusButton(String status, ChatGroupModel chat) {
    String label;
    Gradient? gradient;
    Color? bgColor;
    Color textColor;
    IconData icon;
    bool isDisabled = false;
    
    switch (status) {
      case 'rejected':
                      label = 'Request Rejected';
        bgColor = AppColors.errorRed.withOpacity(0.1);
        textColor = AppColors.errorRed;
        icon = Icons.cancel_rounded;
        isDisabled = true;
        break;
      case 'accepted':
        label = 'Chat Now';
        bgColor = AppColors.successGreen.withOpacity(0.1);
        textColor = AppColors.successGreen;
        icon = Icons.chat_bubble_rounded;
        break;
      case 'pending':
                      label = 'Request Sent';
        bgColor = AppColors.warningYellow.withOpacity(0.1);
        textColor = AppColors.warningYellow;
        icon = Icons.schedule_rounded;
        isDisabled = true;
        break;
      default:
        label = 'Connect';
        bgColor = AppColors.primaryColor.withOpacity(0.1);
        textColor = AppColors.primaryColor;
        icon = Icons.person_add_rounded;
    }
    
    return GestureDetector(
      onTap: isDisabled ? null : () {
        Get.to(() => ChatDetailScreen(chat: chat));
      },
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          border: bgColor != null && gradient == null
            ? Border.all(
                color: textColor.withOpacity(0.3),
                width: 1.5,
              )
            : null,
          boxShadow: !isDisabled
            ? [
                BoxShadow(
                  color: (gradient != null ? AppColors.primaryColor : bgColor!).withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ]
            : [],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectButton(UserModel? userModel) {
    return GestureDetector(
      onTap: () async {
        EasyLoading.show();
        await FireDatabase.createChatRoom(userModel!).then((id) async {
          if (id != 'null') {
            var chatGroupModel = await Database.getSingleChat(id);
            if (chatGroupModel.exists) {
              Get.to(() => ChatDetailScreen(chat: chatGroupModel.data()!));
            }
          }
        });
        EasyLoading.dismiss();
      },
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_rounded, 
                size: 20, 
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Connect',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
