import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/cv_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/container_properties.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/models/application_model.dart';
import 'package:back_packers/models/doc_model.dart';
import 'package:back_packers/models/item_model.dart';
import 'package:back_packers/screens/other_screens/select_cv.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/appbars.dart';
import 'package:back_packers/widgets/primary_button.dart';
import 'dart:math' as math;

class AppliedJobDetails extends StatefulWidget {
  final ItemModel itemModel;
  final bool showApplyButton;
  final bool isReported;

  const AppliedJobDetails(
      {super.key,
      required this.itemModel,
      this.showApplyButton = false,
      this.isReported = false});

  @override
  State<AppliedJobDetails> createState() => _AppliedJobDetailsState();
}

class _AppliedJobDetailsState extends State<AppliedJobDetails> with TickerProviderStateMixin {
  late AnimationController _headerAnimController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    
    // Configure status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    
    // Header animation
    _headerAnimController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    // Floating animation
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    // Reset status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    
    _headerAnimController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // Premium header
          _buildPremiumHeader(),
          
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Job title and category
                  _buildJobTitleSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Job details cards
                  _buildJobDetailsCards(),
                  
                  const SizedBox(height: 24),
                  
                  // Apply button section
                  _buildApplyButtonSection(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
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
              // Floating elements
              ..._buildFloatingElements(),
              
              // Main header content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top row with back button and report button
                    Row(
          children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Report button
                        !widget.isReported
                            ? GestureDetector(
                                onTap: () {
                                  _showReportConfirmationModal();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Text(
                                    'Report',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'Reported',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Job icon and title
                    Row(
                      children: [
                        // Job icon
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
                        
                        const SizedBox(width: 16),
                        
                        // Title and subtitle
                        Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                              const Text(
                                'Job Details',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                  Text(
                                widget.itemModel.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
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

  List<Widget> _buildFloatingElements() {
    return [
      // Floating briefcase
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
                child: const Icon(
                  Icons.business_center_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            );
          },
        ),
      ),
      
      // Floating work icon
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
                child: const Icon(
                  Icons.work_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  Widget _buildJobTitleSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          // Job title and category
                  Row(
                    children: [
              Expanded(
                child: Text(
                  widget.itemModel.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.txtDark,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  widget.itemModel.category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Location
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppColors.primaryColor,
                size: 16,
              ),
              const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.itemModel.location,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.txtGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          
          const SizedBox(height: 12),
          
          // Hourly Rate
                  Row(
                    children: [
              Icon(
                Icons.attach_money_rounded,
                color: AppColors.primaryColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Hourly Rate: \$${widget.itemModel.hourlyRate.isNotEmpty && widget.itemModel.hourlyRate != '0' ? widget.itemModel.hourlyRate : 'Not specified'}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.txtGrey,
                  ),
                ),
              ),
            ],
                      ),
                    ],
                  ),
    );
  }

  Widget _buildJobDetailsCards() {
    return Column(
      children: [
        // Description card
        _buildDetailCard(
          title: 'Job Description',
          content: widget.itemModel.description,
          icon: Icons.description_rounded,
        ),
        
        const SizedBox(height: 16),
        
        // Details card
        _buildDetailCard(
          title: 'Job Details',
          content: '',
          icon: Icons.info_rounded,
          child: Column(
            children: [
              _buildDetailRow('Hourly Rate', '\$${widget.itemModel.hourlyRate.isNotEmpty && widget.itemModel.hourlyRate != '0' ? widget.itemModel.hourlyRate : 'Not specified'}'),
              const SizedBox(height: 12),
              _buildDetailRow('Location', widget.itemModel.location),
                ],
              ),
            ),
      ],
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String content,
    required IconData icon,
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.txtDark,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (child != null)
            child
          else
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.txtGrey,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.txtDark,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.txtGrey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButtonSection() {
    if (widget.isReported) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot<ApplicantModel>>(
                    stream: Database.checkJobAppliedOrNot(widget.itemModel.id),
                    builder: (context, snap) {
                      if (snap.hasError) {
          return const Center(
                            child: Text(
              'Error loading application status',
              style: TextStyle(color: Colors.red),
            ),
          );
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snap.data!.docs.isEmpty) {
          return _buildApplyButton();
        }
        return _buildAppliedButton();
      },
    );
  }

  Widget _buildApplyButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.to(() => SelectCvs(itemModel: widget.itemModel));
          },
          child: const Center(
            child: Text(
              'Apply for this Job',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppliedButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.grey,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Already Applied',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportConfirmationModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0xFFF8F9FA),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.report_problem_rounded,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'Report Job',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  'Are you sure you want to report this job? This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Report Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.of(context).pop();
                          final jobId = widget.itemModel.id;
                          final userId = Get.find<UserDetail>().userId;
                          await reportJob(jobId, userId);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red,
                                Colors.red[700]!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Report',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> hasUserReported(String jobId, String userId) async {
    DocumentSnapshot reportSnapshot =
        await FirebaseFirestore.instance.collection('items').doc(jobId).get();
    final data = reportSnapshot.data() as Map;
    final reports = data['reportedBy'] ?? [];
    if (reports.isNotEmpty) {
      final isExist = reports.where((report) => report['userId'] == userId);
      return isExist.isNotEmpty;
    } else {
      return false;
    }
  }

  Future<void> reportJob(String jobId, String userId) async {
    EasyLoading.show();
    debugPrint("job id is : $jobId, and user Id is : $userId");
    bool alreadyReported = await hasUserReported(jobId, userId);
    // debugPrint("job posted status : ------------------> $alreadyReported");
    if (!alreadyReported) {
      await FirebaseFirestore.instance.collection('items').doc(jobId).update({
        'reportedBy': FieldValue.arrayUnion([
          {
            'userId': userId,
            'reportedAt': DateTime.now(),
            'reason': 'reason',
          }
        ])
      });
      EasyLoading.dismiss();
      EasyLoading.showToast('Your report has been sent');
      await checkAndDeleteJobIfReportedMultipleTimes(jobId);
      Get.back();
    } else {
      print('User has already reported this job.');
      EasyLoading.showToast('You have sent the report already');
      EasyLoading.dismiss();
    }
  }

  Future<void> checkAndDeleteJobIfReportedMultipleTimes(String jobId) async {
    try {
      DocumentSnapshot reportSnapshot =
          await FirebaseFirestore.instance.collection('items').doc(jobId).get();
      // final data = reportSnapshot.data() as Map;
      // debugPrint("report snapshot is : ${data['reports'].length}");
      final data = reportSnapshot.data() as Map;
      final reports = data['reportedBy'] ?? [];
      debugPrint("report snapshot is : ${reports.length}");
      if (reports.length >= 15) {
        await FirebaseFirestore.instance
            .collection('items')
            .doc(jobId)
            .delete();
        print('Job deleted due to multiple reports.');
        EasyLoading.showToast('Job deleted due to multiple reports.');
      }
    } catch (err) {
      debugPrint("error while checking reports : $err");
    }
  }
}
