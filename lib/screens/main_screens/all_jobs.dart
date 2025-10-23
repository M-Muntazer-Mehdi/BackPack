import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/cv_controller.dart';
import 'package:back_packers/controllers/mainScreen_controllers/navbar_controller.dart';
import 'package:back_packers/controllers/mainScreen_controllers/store_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/models/item_model.dart';
import 'package:back_packers/screens/main_screens/store.dart';
import 'package:back_packers/screens/other_screens/pick_location_controller.dart';
import 'package:back_packers/screens/profile/jobs/job_details.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/appbars.dart';
import 'package:back_packers/widgets/primary_button.dart';

class AllJobs extends StatefulWidget {
  const AllJobs({super.key});

  @override
  State<AllJobs> createState() => _AllJobsState();
}

class _AllJobsState extends State<AllJobs> with TickerProviderStateMixin {
  var storeController = Get.put(CvController());
  var controller = Get.put(NavBarController());
  
  late AnimationController _headerAnimController;
  late AnimationController _floatController;
  late AnimationController _filterExpandController;
  bool _isFiltersExpanded = false;
  
  // Job count will be updated from actual data

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
    
    // Header gradient animation
    _headerAnimController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    // Floating animation
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    // Filter expansion animation
    _filterExpandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
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
    
    _headerAnimController.dispose();
    _floatController.dispose();
    _filterExpandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (value) {
      return Scaffold(
        backgroundColor: AppColors.bgGrey,
        extendBodyBehindAppBar: true,
        body: Column(
              children: [
            // Modern header
            _buildHeader(value),
            
            // Filter toggle button
            _buildFilterToggleButton(),
            
            // Expandable filter controls
            SizeTransition(
              sizeFactor: _filterExpandController,
              child: _buildJobFilterControls(value),
            ),
            
            const SizedBox(height: 20),
            
            // Jobs list
                Expanded(
                  child: StreamBuilder<List<DocumentSnapshot<ItemModel>>>(
                      stream: Database.getNearByJobs(value.latLng,
                          radius: value.radius),
                      builder: (context, snap) {
                        if (snap.hasError) {
                          return _buildEmptyState('Error loading jobs: ${snap.error}');
                        }
                        if (!snap.hasData) {
                          return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              ));
                        }
                        if (snap.data!.isEmpty) {
                          return _buildEmptyState('No jobs available in your area');
                        }
                        return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 100, top: 10),
                            itemCount: snap.data!.length,
                            itemBuilder: (context, index) {
                              ItemModel? jobModel = snap.data?[index].data();
                              final isReported = jobModel?.reports
                                  .where((report) =>
                                      report['userId'] ==
                                      Get.find<UserDetail>().userId)
                                  .isNotEmpty;
                              return isReported != true
                                  ? _buildJobCard(jobModel!, index)
                                  : const SizedBox.shrink();
                            },
                          );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }

  Widget _buildJobCard(ItemModel jobModel, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        shadowColor: AppColors.primaryColor.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.95),
              ],
            ),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job title and type
                Row(
                                      children: [
                    Expanded(
                      child: Text(
                        jobModel.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.txtDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                                        Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        jobModel.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Location
                Row(
                                            children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        jobModel.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.txtGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                                                  jobModel.description,
                  style: TextStyle(
                    fontSize: 14,
                                                      color: AppColors.txtGrey,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                // Salary and apply button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'Job Opportunity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => AppliedJobDetails(
                                                        itemModel: jobModel,
                                                        showApplyButton: true,
                          isReported: false,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(StoreController value) {
    return AnimatedBuilder(
      animation: _headerAnimController,
      builder: (context, child) {
        return Container(
          clipBehavior: Clip.none,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top * 0.6,
          ),
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
              // Unique job-themed floating elements
              ..._buildJobFloatingElements(),
              
              // Main content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                  Icons.work_rounded,
                                  color: AppColors.primaryColor,
                                  size: 26,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        // Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                              const Text(
                                'Jobs',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Find Your Dream Job',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1,
                                ),
                                                ),
                                              ],
                                            ),
                                          ),
                        // Search icon
                        AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.95 + (0.05 * _floatController.value),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                ),
                                child: const Icon(
                                  Icons.search_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Total opportunities available
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.work_outline_rounded,
                            color: Colors.white,
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Find jobs in your area',
                            style: const TextStyle(
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

  List<Widget> _buildJobFloatingElements() {
    return [
      // Simple floating briefcase
      Positioned(
        right: 20 + (15 * math.sin(_headerAnimController.value * 2 * math.pi)),
        top: 40 + (10 * math.cos(_headerAnimController.value * 2 * math.pi)),
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatController.value * 8),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.business_center_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ),
            );
          },
        ),
      ),
      
      // Simple floating work icon
      Positioned(
        left: 30 + (20 * math.cos(_headerAnimController.value * 1.5 * math.pi)),
        bottom: 30 + (15 * math.sin(_headerAnimController.value * 1.5 * math.pi)),
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatController.value * 6),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.work_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
          ),
        ),
      );
          },
        ),
      ),
    ];
  }

  void _toggleFilters() {
    setState(() {
      _isFiltersExpanded = !_isFiltersExpanded;
    });
    
    if (_isFiltersExpanded) {
      _filterExpandController.forward();
    } else {
      _filterExpandController.reverse();
    }
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

  Widget _buildJobFilterControls(StoreController value) {
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
        child: Padding(
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
                          '${value.radius} Km',
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
                        int currentIndex = value.radiusList.indexOf(value.radius);
                        // Match car position with marker positions
                        double totalWidth = roadWidth - 60;
                        double carPosition = 30 + (totalWidth * (currentIndex / (value.radiusList.length - 1))) - 17.5;
                        
                        return GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            double dragPosition = details.localPosition.dx;
                            int newIndex = ((dragPosition / roadWidth) * value.radiusList.length).floor();
                            newIndex = newIndex.clamp(0, value.radiusList.length - 1);
                            
                            if (newIndex != currentIndex) {
                              value.changeRadius(newIndex);
                              HapticFeedback.lightImpact();
                            }
                          },
                          onTapUp: (details) {
                            double tapPosition = details.localPosition.dx;
                            int newIndex = ((tapPosition / roadWidth) * value.radiusList.length).floor();
                            newIndex = newIndex.clamp(0, value.radiusList.length - 1);
                            value.changeRadius(newIndex);
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
                                ...List.generate(value.radiusList.length, (index) {
                                  // Calculate position with proper spacing for labels
                                  double totalWidth = roadWidth - 60; // Leave more space on both ends
                                  double position = 30 + (totalWidth * (index / (value.radiusList.length - 1)));
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
                                        '${value.radiusList[index]}',
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
              
              const SizedBox(height: 16),
              
              // Location card
              GestureDetector(
                onTap: () {
                  Get.to(() => PickLocation(
                    onSubmit: (loc, latlng) {
                      Get.back();
                      value.latLng = latlng;
                      value.location = loc ?? '';
                      value.update();
                    },
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              value.location,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.txtDark,
                            ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap to change location',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.txtGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.edit_location_alt_rounded,
                        color: AppColors.primaryColor.withOpacity(0.6),
                        size: 20,
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
  }


  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.work_off_rounded,
              size: 64,
              color: AppColors.primaryColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
                                                      color: AppColors.txtGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
