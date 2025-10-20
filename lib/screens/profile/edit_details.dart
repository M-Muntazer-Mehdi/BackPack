import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/global.dart';
import 'package:back_packers/globals/network_image.dart';
import 'package:back_packers/models/user.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/widgets/image_picker_modal.dart';
import 'package:back_packers/widgets/success_modal.dart';

class EditDetails extends StatefulWidget {
  const EditDetails({super.key});

  @override
  State<EditDetails> createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> with TickerProviderStateMixin {
  TextEditingController nameCont = TextEditingController();
  TextEditingController lastnameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController numberCont = TextEditingController();
  FocusNode nameFocus = FocusNode();
  FocusNode numberFocus = FocusNode();
  FocusNode lastname = FocusNode();
  FocusNode emailFocus = FocusNode();
  String imageUrl = '';
  var isLoading = false;
  
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    getProfile();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    nameCont.dispose();
    lastnameCont.dispose();
    emailCont.dispose();
    numberCont.dispose();
    nameFocus.dispose();
    numberFocus.dispose();
    lastname.dispose();
    emailFocus.dispose();
    super.dispose();
  }

  getProfile() async {
    try {
      isLoading = true;
      setState(() {});
      EasyLoading.show();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(Get.find<UserDetail>().userId)
          .get()
          .then((value) {
        UserModel user = UserModel.fromDocumentSnapshot(value);
        nameCont.text = user.fname;
        lastnameCont.text = user.lname;
        emailCont.text = user.email;
        numberCont.text = user.phone;
        imageUrl = user.image;
        setState(() {});
      });
      isLoading = false;
      setState(() {});
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      isLoading = false;
      setState(() {});
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: "Something went wrong. Try later",
          toastType: TOAST_TYPE.toastError);
    }
  }

  uploadImage({bool isCamera = true}) async {
    EasyLoading.show();
    File file = await selectImage(isCamera);
    Reference ref =
        FirebaseStorage.instance.ref().child("images/${DateTime.now()}");

    final UploadTask uploadTask = ref.putFile(file);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    final url = await taskSnapshot.ref.getDownloadURL();
    EasyLoading.dismiss();
    imageUrl = url;
    setState(() {});
  }

  selectImage(bool isCamera) async {
    XFile? image;

    ImagePicker picker = ImagePicker();
    image = await picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);

    File file = File(image!.path);
    return file;
  }

  bool initvalidation() {
    if (!Global.checkNull(nameCont.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please enter first name',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(nameFocus);
      return false;
    }
    if (!Global.checkNull(lastnameCont.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please enter last name',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(lastname);
      return false;
    }
    if (!Global.checkNull(numberCont.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please enter phone number',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(nameFocus);
      return false;
    }
    return true;
  }

  validateRegister() async {
    log('message');
    if (initvalidation()) {
      try {
        EasyLoading.show();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(Get.find<UserDetail>().userId)
            .update({
          'fname': nameCont.text,
          'lname': lastnameCont.text,
          'image': imageUrl,
          'phone': numberCont.text,
        });
        Get.find<UserDetail>()
            .updateProfile(nameCont.text, lastnameCont.text, imageUrl);
        EasyLoading.dismiss();
        
        // Show beautiful success modal
        await Future.delayed(const Duration(milliseconds: 100));
        SuccessModal.show(
          title: 'Success!',
          message: 'Your profile has been updated successfully',
          buttonText: 'Done',
        );
      } catch (e) {
        EasyLoading.dismiss();
      }
    } else {
      log('message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
          children: [
          // Decorative background circles
          Positioned(
            top: -80,
            right: -80,
                child: Container(
              width: 200,
              height: 200,
                  decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.1),
                    AppColors.primaryColor.withOpacity(0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryLight.withOpacity(0.08),
                    AppColors.primaryLight.withOpacity(0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Custom app bar
                  _buildCustomAppBar(),
                  
                  // Scrollable content
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        const SizedBox(height: 20),
                        
                        // Profile photo section
                        _buildProfilePhotoSection(),
                        
                        const SizedBox(height: 40),
                        
                        // Form fields
                        _buildPremiumTextField(
                          controller: nameCont,
                          focusNode: nameFocus,
                          icon: Icons.person_outline_rounded,
                          label: 'First Name',
                          hint: 'Enter your first name',
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildPremiumTextField(
                          controller: lastnameCont,
                          focusNode: lastname,
                          icon: Icons.person_outline_rounded,
                          label: 'Last Name',
                          hint: 'Enter your last name',
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildPremiumTextField(
                          controller: numberCont,
                          focusNode: numberFocus,
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          hint: 'Enter your phone number',
                          keyboardType: TextInputType.phone,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildPremiumTextField(
                          controller: emailCont,
                          focusNode: emailFocus,
                          icon: Icons.email_outlined,
                          label: 'Email',
                          hint: 'Enter your email',
                          readOnly: true,
                          enabled: false,
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Update button
                        _buildUpdateButton(),
                        
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.bgGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderColor.withOpacity(0.3),
                  width: 1,
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
                    'Edit Profile',
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
                  'Update your personal information',
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
    );
  }

  Widget _buildProfilePhotoSection() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
      children: [
          // Animated profile photo
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  math.sin(_floatController.value * 2 * math.pi) * 4,
                ),
                child: GestureDetector(
                  onTap: () {
                    ImagePickerModal.show(
                      onCamera: () => uploadImage(),
                      onGallery: () => uploadImage(isCamera: false),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 58,
                        backgroundColor: AppColors.bgGrey,
                        child: imageUrl == ''
                            ? Icon(
                                Icons.person_rounded,
                                size: 50,
                  color: AppColors.iconColor,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(58),
                                child: NetworkImageCustom(
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: double.infinity,
                                  image: imageUrl,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Camera button
          Positioned(
            bottom: 0,
            right: -5,
            child: GestureDetector(
              onTap: () {
                ImagePickerModal.show(
                  onCamera: () => uploadImage(),
                  onGallery: () => uploadImage(isCamera: false),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.txtDark,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : AppColors.bgGrey,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: focusNode.hasFocus 
                  ? AppColors.primaryColor 
                  : AppColors.borderColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            readOnly: readOnly,
            enabled: enabled,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: enabled ? AppColors.txtDark : AppColors.txtMuted,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.txtMuted,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: enabled ? AppColors.primaryGradient : null,
                  color: enabled ? null : AppColors.borderColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return GestureDetector(
      onTap: () {
        validateRegister();
      },
      child: Container(
        width: double.infinity,
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
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              'Update Profile',
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
  }
}
