import 'package:back_packers/widgets/cv_selection_modal.dart';
import 'package:back_packers/widgets/job_application_success_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/applyJobs_controller.dart';
import 'package:back_packers/controllers/cv_controller.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/global.dart';
import 'package:back_packers/models/application_model.dart';
import 'package:back_packers/models/doc_model.dart';
import 'package:back_packers/models/item_model.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'dart:math' as math;

class SelectCvs extends StatefulWidget {
  final ItemModel itemModel;

  const SelectCvs({super.key, required this.itemModel});

  @override
  State<SelectCvs> createState() => _SelectCvsState();
}

class _SelectCvsState extends State<SelectCvs> with TickerProviderStateMixin {
  var controller = Get.put(ApplyjobsController());
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
    
    // Initialize animation controllers
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _floatController.dispose();
    
    // Reset status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          _buildPremiumHeader(),
          Expanded(
            child: GetBuilder<ApplyjobsController>(builder: (value) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildJobInfoCard(),
                    const SizedBox(height: 24),
                    _buildCVSection(),
                    const SizedBox(height: 24),
                    _buildCoverLetterSection(),
                    const SizedBox(height: 24),
                    _buildRequirementsSection(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          children: [
            // Back button and title
            Row(
            children: [
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apply for Job',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.itemModel.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Document icon
                AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        math.sin(_floatController.value * 2 * math.pi) * 2,
                      ),
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
                          Icons.description_rounded,
                          color: Colors.white,
                          size: 20,
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
    );
  }

  Widget _buildJobInfoCard() {
    print('DEBUG: hourlyRate in select_cv: "${widget.itemModel.hourlyRate}"');
    print('DEBUG: hourlyRate isEmpty: ${widget.itemModel.hourlyRate.isEmpty}');
    print('DEBUG: hourlyRate == "0": ${widget.itemModel.hourlyRate == "0"}');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.work_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.txtDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.itemModel.category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.txtGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppColors.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.itemModel.location,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.txtGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.attach_money_rounded,
                color: AppColors.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
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

  Widget _buildCVSection() {
    return Container(
      padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
                  child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
                    children: [
                        Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blue[600]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                          child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Curriculum Vitae',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.txtDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upload or select your CV',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.txtGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCVContent(),
        ],
      ),
    );
  }

  Widget _buildCVContent() {
    if (controller.selectedCV.url == "") {
      return Column(
                            children: [
          _buildUploadButton(
            icon: Icons.upload_file_rounded,
            title: 'Upload New CV',
            subtitle: 'Choose a file from your device',
                                onTap: () {
                                  controller.uploadDocs(DocType.cv);
                                },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.txtGrey,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSelectButton(
            icon: Icons.folder_rounded,
            title: 'Choose Saved CV',
            subtitle: 'Select from your saved CVs',
                                onTap: () async {
              QuerySnapshot<DocModel> response = await Database.getMyDocsFuture(DocType.cv);
              List<QueryDocumentSnapshot<DocModel>> cvs = response.docs;
              List<DocModel> cvList = cvs.map((e) => e.data()).toList();
              
              if (cvList.isEmpty) {
                                    Global.showToastAlert(
                                        context: Get.overlayContext!,
                                        strTitle: "",
                                        strMsg: 'No saved CV available',
                  toastType: TOAST_TYPE.toastInfo,
                );
                                    return;
                                  }
              
              CVSelectionModal.show(
                cvs: cvList,
                title: 'Choose Saved CV',
                subtitle: 'Select a CV from your saved documents',
                icon: Icons.description_rounded,
                onSelect: (selectedCV) {
                  controller.selectedCV = selectedCV;
                  controller.update();
                },
              );
            },
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildSelectedFileCard(
            icon: Icons.description_rounded,
            title: controller.selectedCV.name,
            subtitle: 'CV Selected',
            onRemove: () {
              controller.selectedCV = DocModel(id: "", type: "", name: "", url: "");
                                    controller.update();
            },
          ),
        ],
      );
    }
  }

  Widget _buildCoverLetterSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
                                        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
                            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.green[600]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                child: const Icon(
                  Icons.article_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                        ),
              const SizedBox(width: 16),
              Expanded(
                          child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                    Text(
                      'Cover Letter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.txtDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upload or select your cover letter',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.txtGrey,
                      ),
                    ),
                            ],
                          ),
                        ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCoverLetterContent(),
        ],
      ),
    );
  }

  Widget _buildCoverLetterContent() {
    if (controller.selectedCoverLetter.url == "") {
      return Column(
                    children: [
          _buildUploadButton(
            icon: Icons.upload_file_rounded,
            title: 'Upload New Cover Letter',
            subtitle: 'Choose a file from your device',
                                    onTap: () {
                                      controller.uploadDocs(DocType.letter);
                                    },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.txtGrey,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSelectButton(
            icon: Icons.folder_rounded,
            title: 'Choose Saved Cover Letter',
            subtitle: 'Select from your saved cover letters',
                                    onTap: () async {
              QuerySnapshot<DocModel> response = await Database.getMyDocsFuture(DocType.letter);
              List<QueryDocumentSnapshot<DocModel>> coverLetters = response.docs;
              List<DocModel> coverLetterList = coverLetters.map((e) => e.data()).toList();
              
              if (coverLetterList.isEmpty) {
                                        Global.showToastAlert(
                                            context: Get.overlayContext!,
                                            strTitle: "",
                  strMsg: 'No saved cover letter available',
                  toastType: TOAST_TYPE.toastInfo,
                );
                                        return;
                                      }
              
              CVSelectionModal.show(
                cvs: coverLetterList,
                title: 'Choose Saved Cover Letter',
                subtitle: 'Select a cover letter from your saved documents',
                icon: Icons.article_rounded,
                onSelect: (selectedCoverLetter) {
                  controller.selectedCoverLetter = selectedCoverLetter;
                  controller.update();
                },
              );
            },
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildSelectedFileCard(
            icon: Icons.article_rounded,
            title: controller.selectedCoverLetter.name,
            subtitle: 'Cover Letter Selected',
            onRemove: () {
              controller.selectedCoverLetter = DocModel(id: "", type: "", name: "", url: "");
                                        controller.update();
            },
          ),
        ],
      );
    }
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.txtDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.txtGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.primaryColor,
              size: 16,
            ),
                                ],
                              ),
                            ),
    );
  }

  Widget _buildSelectButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
                            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
                              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.txtDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.txtGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[600],
              size: 16,
            ),
                                ],
                              ),
                            ),
    );
  }

  Widget _buildSelectedFileCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
                            Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
                              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.txtDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
                                  GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.red,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.orange[600]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requirements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.txtDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please confirm your status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.txtGrey,
                      ),
                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
          const SizedBox(height: 20),
          _buildModernCheckbox(
            title: 'I have Visa assistance',
            subtitle: 'I can help with visa applications',
                      value: controller.visaStatus,
            onChanged: () {
                        controller.handleVisaStatusChange();
                        controller.update();
                      },
          ),
          const SizedBox(height: 16),
          _buildModernCheckbox(
            title: 'I have working rights',
            subtitle: 'I am legally allowed to work',
                      value: controller.workingRights,
            onChanged: () {
                        controller.handleWorkingRightsChange();
                        controller.update();
                      },
          ),
        ],
      ),
    );
  }

  Widget _buildModernCheckbox({
    required String title,
    required String subtitle,
    required bool value,
    required VoidCallback onChanged,
  }) {
    return GestureDetector(
      onTap: onChanged,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value ? AppColors.primaryColor.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppColors.primaryColor.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? AppColors.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? AppColors.primaryColor : Colors.grey,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: value ? AppColors.primaryColor : AppColors.txtDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.txtGrey,
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

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
                    ApplicantModel applicantModel = ApplicantModel(
                        id: "",
                        coverLetter: controller.selectedCoverLetter.url,
                        jobId: widget.itemModel.id,
                        cv: controller.selectedCV.url,
                        visaStatus: controller.visaStatus,
                        workingRights: controller.workingRights,
              userId: Get.find<UserDetail>().userId,
            );
            
            // Show loading indicator
            Get.dialog(
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              barrierDismissible: false,
            );
            
            try {
              await controller.handleApplyJob(applicantModel);
              
              // Close loading dialog
              Get.back();
              
              // Show success modal
              JobApplicationSuccessModal.show(
                jobTitle: widget.itemModel.title,
                companyName: widget.itemModel.location, // Using location as company name for now
                onDone: () {
                  Get.back(); // Go back to job details or job list
                },
              );
            } catch (e) {
              // Close loading dialog
              Get.back();
              
              // Show error message
              Global.showToastAlert(
                context: Get.overlayContext!,
                strTitle: "Error",
                strMsg: "Failed to submit application. Please try again.",
                toastType: TOAST_TYPE.toastError,
              );
            }
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Submit Application',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}