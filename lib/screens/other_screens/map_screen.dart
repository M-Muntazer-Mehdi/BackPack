import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:back_packers/controllers/mainScreen_controllers/store_controller.dart';
import 'package:back_packers/screens/main_screens/store.dart';
import 'package:back_packers/screens/profile/account.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/widgets/custom_bottom_option_sheet.dart';
import 'package:back_packers/screens/other_screens/pick_location_controller.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  StoreController controller = Get.put(StoreController());
  late AnimationController _filterController;
  late AnimationController _buttonMorphController;
  late AnimationController _particleController;
  late AnimationController _headerAnimController;
  late AnimationController _floatController;
  
  late Animation<double> _filterSlideAnimation;
  late Animation<double> _filterOpacityAnimation;
  late Animation<double> _buttonScaleAnimation;
  
  bool _isFiltersExpanded = true;
  
  // Scroll tracking for category list
  final ScrollController _categoryScrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    
    // Filter slide animation
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
      value: 1.0, // Start in open state
    );
    
    _filterSlideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _filterController,
      curve: Curves.easeOutCubic,
    ));
    
    _filterOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _filterController,
      curve: Curves.easeOut,
    ));
    
    // Button morph animation
    _buttonMorphController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: 1.0, // Start in active state
    );
    
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _buttonMorphController,
      curve: Curves.easeOutBack,
    ));
    
    // Particle burst animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
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
    
    // Listen to scroll changes
    _categoryScrollController.addListener(_updateScrollArrows);
  }
  
  void _updateScrollArrows() {
    setState(() {
      // Show left arrow if scrolled away from start
      _showLeftArrow = _categoryScrollController.hasClients && 
          _categoryScrollController.offset > 10;
      
      // Show right arrow if not at end
      _showRightArrow = _categoryScrollController.hasClients &&
          _categoryScrollController.offset < 
          _categoryScrollController.position.maxScrollExtent - 10;
    });
  }
  
  void _scrollToStart() {
    _categoryScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }
  
  void _scrollToEnd() {
    _categoryScrollController.animateTo(
      _categoryScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    // Reset status bar to default
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    
    _filterController.dispose();
    _buttonMorphController.dispose();
    _particleController.dispose();
    _headerAnimController.dispose();
    _floatController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      _isFiltersExpanded = !_isFiltersExpanded;
      if (_isFiltersExpanded) {
        _filterController.forward();
        _buttonMorphController.forward();
        _particleController.forward(from: 0);
      } else {
        _filterController.reverse();
        _buttonMorphController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (logic) {
      return Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
          children: [
              // Google Map
            GoogleMap(
                myLocationButtonEnabled: false,
              onMapCreated: (GoogleMapController c) async {
                logic.mapController.complete(c);
                logic.getLocation();
              },
              markers: Set<Marker>.of(logic.markers.values),
              initialCameraPosition: logic.initialLocation,
              zoomControlsEnabled: false,
                myLocationEnabled: true,
                compassEnabled: false,
                mapToolbarEnabled: false,
              ),
              
              // Fixed compact header (always visible)
              _buildFixedHeader(),
              
              // Sliding compact filter drawer
              _buildSlidingFilterDrawer(logic),
              
              // Unique morphing toggle button
              _buildUniqueMorphingButton(),
              
              // Floating action buttons
              _buildFloatingActions(logic),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFixedHeader() {
    return Positioned(
              top: 0,
              left: 0,
              right: 0,
      child: AnimatedBuilder(
        animation: Listenable.merge([_headerAnimController, _floatController]),
        builder: (context, child) {
          return ClipRect(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top * 0.01,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Purple blur effect circles
                  Positioned(
                    top: -50,
                    right: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryColor.withOpacity(0.2),
                            AppColors.primaryColor.withOpacity(0.1),
                            AppColors.primaryColor.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    left: -50,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryLight.withOpacity(0.15),
                            AppColors.primaryLight.withOpacity(0.08),
                            AppColors.primaryLight.withOpacity(0.04),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Animated blur circles
                  AnimatedBuilder(
                    animation: _headerAnimController,
                    builder: (context, child) {
                      return Positioned(
                        top: 10 + (math.sin(_headerAnimController.value * 2 * math.pi) * 10),
                        right: 60 + (math.cos(_headerAnimController.value * 2 * math.pi) * 20),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primaryColor.withOpacity(0.12),
                                AppColors.primaryColor.withOpacity(0.06),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                
                // Main header content
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        // Animated floating logo
                        Transform.translate(
                          offset: Offset(0, math.sin(_floatController.value * 2 * math.pi) * 2),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.explore_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Title with motivation line
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    AppColors.primaryDark,
                                    AppColors.primaryColor,
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'Explore',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Adventure awaits around every corner',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryColor.withOpacity(0.7),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Animated profile button
                        _buildAnimatedProfileButton(),
                      ],
                    ),
                  ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAnimatedProfileButton() {
    return GetBuilder<UserDetail>(
      builder: (value) {
        return GestureDetector(
          onTap: () => Get.to(() => const MyAccount()),
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, math.sin(_floatController.value * 2 * math.pi + math.pi) * 2),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: value.image == ''
                      ? Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryColor,
                          size: 20,
                        )
                      : Image.network(
                          value.image,
                          fit: BoxFit.cover,
                        ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSlidingFilterDrawer(StoreController logic) {
    return AnimatedBuilder(
      animation: _filterController,
      builder: (context, child) {
        return Positioned(
          top: 154, // Below fixed header
          left: 12,
          right: 12,
          child: Transform.translate(
            offset: Offset(0, _filterSlideAnimation.value * 180),
            child: Opacity(
              opacity: _filterOpacityAnimation.value,
              child: IgnorePointer(
                ignoring: _filterController.value < 0.1, // Disable interaction when closed
                child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.15),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 3,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative circles in background
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryLight.withOpacity(0.1),
                              AppColors.primaryLight.withOpacity(0.02),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                  decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryColor.withOpacity(0.08),
                              AppColors.primaryColor.withOpacity(0.02),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(18),
                  child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                          // Premium header
                      Row(
                        children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.filter_list_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
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
                                        'Filters',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Customize your search',
                                      style: TextStyle(
                                        fontSize: 11,
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
                          
                          // Divider with gradient
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.borderColor.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Compact categories with scroll indicators
                          Stack(
                            children: [
                              SizedBox(
                                height: 38,
                                child: ListView.separated(
                                  controller: _categoryScrollController,
                                  separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: logic.categories.keys.toList().length,
                                  itemBuilder: (ctx, index) {
                                    final isSelected = logic.selectedCat == index;
                                    final categoryName = logic.categories.keys.toList()[index];
                                    
                            return GestureDetector(
                                      onTap: () => logic.changeCategory(index),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: isSelected ? AppColors.primaryGradient : null,
                                          color: isSelected ? null : AppColors.bgGrey,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primaryColor.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                            : [],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getCategoryIcon(categoryName),
                                              size: 16,
                                              color: isSelected ? Colors.white : AppColors.txtDark,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              categoryName,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected ? Colors.white : AppColors.txtDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              
                              // Left sleek arrow button (clickable - scroll to start)
                              if (_showLeftArrow)
                                Positioned(
                                  left: -4,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: _scrollToStart,
                                      child: AnimatedBuilder(
                                        animation: _floatController,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: 1.0 + (math.sin(_floatController.value * 2 * math.pi) * 0.05),
                                            child: Container(
                                              width: 28,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    AppColors.primaryColor,
                                                    AppColors.primaryLight,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.primaryColor.withOpacity(0.3),
                                                    blurRadius: 15,
                                                    offset: const Offset(-2, 2),
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  // Pulsing shimmer overlay
                                                  Positioned.fill(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(20),
                                                        gradient: LinearGradient(
                                                          begin: Alignment.centerLeft,
                                                          end: Alignment.centerRight,
                                                          colors: [
                                                            Colors.white.withOpacity(
                                                              0.2 * (1 - _floatController.value)
                                                            ),
                                                            Colors.transparent,
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Icon
                                                  Center(
                                                    child: Icon(
                                                      Icons.chevron_left_rounded,
                                                      size: 20,
                                                      color: Colors.white,
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
                              
                              // Right sleek arrow button (clickable - scroll to end)
                              if (_showRightArrow)
                                Positioned(
                                  right: -4,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: _scrollToEnd,
                                      child: AnimatedBuilder(
                                        animation: _floatController,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: 1.0 + (math.sin(_floatController.value * 2 * math.pi + math.pi) * 0.05),
                                            child: Container(
                                              width: 28,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    AppColors.primaryLight,
                                                    AppColors.primaryColor,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.primaryColor.withOpacity(0.3),
                                                    blurRadius: 15,
                                                    offset: const Offset(2, 2),
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  // Pulsing shimmer overlay
                                                  Positioned.fill(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(20),
                                                        gradient: LinearGradient(
                                                          begin: Alignment.centerLeft,
                                                          end: Alignment.centerRight,
                                                          colors: [
                                                            Colors.transparent,
                                                            Colors.white.withOpacity(
                                                              0.2 * _floatController.value
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Icon
                                                  Center(
                                                    child: Icon(
                                                      Icons.chevron_right_rounded,
                                                      size: 20,
                                                      color: Colors.white,
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
                            ],
                          ),
                          
                          const SizedBox(height: 14),
                          
                          // Compact location controls
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildCompactControl(
                                  icon: Icons.radar_rounded,
                                  value: '${logic.radius}km',
                                  onTap: () {
                                    customBottomSheet(
                                      logic.radiusList.map((e) => '$e km').toList(),
                                      -1,
                                      (index) => logic.changeRadius(index),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 4,
                                child: _buildCompactControl(
                                  icon: Icons.location_on_rounded,
                                  value: logic.location.isEmpty ? 'Current' : logic.location,
                              onTap: () {
                                    Get.to(() => PickLocation(onSubmit: (loc, latlang) {
                                      Get.back();
                                      logic.latLng = latlang;
                                      logic.location = loc ?? '';
                                      logic.update();
                                    }));
                                  },
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
          ),
        ),
        );
      },
    );
  }

  Widget _buildUniqueMorphingButton() {
    return Positioned(
      top: 140,
      right: 12,
      child: GestureDetector(
        onTap: _toggleFilters,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _buttonMorphController,
            _particleController,
          ]),
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Particle burst effect
                ...List.generate(8, (index) {
                  final angle = (index * math.pi * 2) / 8;
                  final distance = 30 * _particleController.value;
                  final opacity = (1 - _particleController.value).clamp(0.0, 1.0);
                  
                  return Transform.translate(
                    offset: Offset(
                      math.cos(angle) * distance,
                      math.sin(angle) * distance,
                    ),
                    child: Opacity(
                      opacity: opacity,
              child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor,
                                        ),
                                      ),
                              ),
                            );
                          }),
                
                // Main morphing button
                Transform.scale(
                  scale: _buttonScaleAnimation.value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isFiltersExpanded ? 44 : 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: _isFiltersExpanded 
                        ? AppColors.primaryGradient 
                        : null,
                      color: _isFiltersExpanded ? null : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _isFiltersExpanded 
                          ? Colors.transparent 
                          : AppColors.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isFiltersExpanded
                            ? AppColors.primaryColor.withOpacity(0.4)
                            : AppColors.primaryColor.withOpacity(0.15),
                          blurRadius: _isFiltersExpanded ? 20 : 12,
                          offset: Offset(0, _isFiltersExpanded ? 6 : 3),
                          spreadRadius: _isFiltersExpanded ? 2 : 0,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Animated icon
                        Center(
                          child: AnimatedRotation(
                            duration: const Duration(milliseconds: 400),
                            turns: _isFiltersExpanded ? 0.5 : 0,
                            child: Icon(
                              Icons.tune_rounded,
                              size: 22,
                              color: _isFiltersExpanded 
                                ? Colors.white 
                                : AppColors.primaryColor,
                            ),
                          ),
                        ),
                        
                        // Pulsing ring when active
                        if (_isFiltersExpanded)
                          Center(
                            child: AnimatedBuilder(
                              animation: _buttonMorphController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + (_buttonMorphController.value * 0.2),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5 * (1 - _buttonMorphController.value)),
                                        width: 2,
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'All':
        return Icons.grid_view_rounded;
      case 'Jobs':
        return Icons.work_rounded;
      case 'Accommodation':
        return Icons.hotel_rounded;
      case 'Buddies':
        return Icons.people_rounded;
      default:
        return Icons.category_rounded;
    }
  }


  Widget _buildCompactControl({
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.primaryColor.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 15,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    icon == Icons.radar_rounded ? 'Radius' : 'Location',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.iconColor,
                      letterSpacing: 0,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.txtDark,
                      letterSpacing: 0,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActions(StoreController logic) {
    return Positioned(
      right: 12,
      bottom: 100,
      child: Column(
        children: [
          _buildFAB(
            icon: Icons.my_location_rounded,
            onTap: () => logic.getLocation(),
          ),
          const SizedBox(height: 10),
          _buildFAB(
            icon: Icons.add_rounded,
            onTap: () async {
              final GoogleMapController mapCtrl = await logic.mapController.future;
              mapCtrl.animateCamera(CameraUpdate.zoomIn());
            },
          ),
          const SizedBox(height: 10),
          _buildFAB(
            icon: Icons.remove_rounded,
            onTap: () async {
              final GoogleMapController mapCtrl = await logic.mapController.future;
              mapCtrl.animateCamera(CameraUpdate.zoomOut());
            },
          ),
        ],
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppColors.primaryColor,
          size: 22,
        ),
      ),
    );
  }
}
