import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/widgets/error_modal.dart' hide SuccessModal;
import 'package:back_packers/widgets/success_modal.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> with TickerProviderStateMixin {
  TextEditingController currentPasswordCont = TextEditingController();
  TextEditingController newPasswordCont = TextEditingController();
  TextEditingController confirmPasswordCont = TextEditingController();
  
  FocusNode currentPasswordNode = FocusNode();
  FocusNode newPasswordNode = FocusNode();
  FocusNode confirmPasswordNode = FocusNode();

  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
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
    currentPasswordCont.dispose();
    newPasswordCont.dispose();
    confirmPasswordCont.dispose();
    currentPasswordNode.dispose();
    newPasswordNode.dispose();
    confirmPasswordNode.dispose();
    super.dispose();
  }

  bool validatePasswords() {
    if (currentPasswordCont.text.trim().isEmpty) {
      ErrorModal.show(
        title: 'Current Password Required',
        message: 'Please enter your current password',
      );
      return false;
    }
    
    if (newPasswordCont.text.trim().isEmpty) {
      ErrorModal.show(
        title: 'New Password Required',
        message: 'Please enter your new password',
      );
      return false;
    }
    
    if (newPasswordCont.text.trim().length < 6) {
      ErrorModal.show(
        title: 'Password Too Short',
        message: 'Password must be at least 6 characters long',
      );
      return false;
    }
    
    if (confirmPasswordCont.text.trim().isEmpty) {
      ErrorModal.show(
        title: 'Confirm Password Required',
        message: 'Please confirm your new password',
      );
      return false;
    }
    
    if (newPasswordCont.text.trim() != confirmPasswordCont.text.trim()) {
      ErrorModal.show(
        title: 'Passwords Don\'t Match',
        message: 'New password and confirm password must match',
      );
      return false;
    }
    
    if (currentPasswordCont.text.trim() == newPasswordCont.text.trim()) {
      ErrorModal.show(
        title: 'Same Password',
        message: 'New password must be different from current password',
      );
      return false;
    }
    
    return true;
  }

  Future<void> changePassword() async {
    if (!validatePasswords()) return;
    
    try {
      EasyLoading.show();
      
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        EasyLoading.dismiss();
        ErrorModal.show(
          title: 'Not Logged In',
          message: 'Please log in to change your password',
        );
        return;
      }
      
      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordCont.text.trim(),
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Change password
      await user.updatePassword(newPasswordCont.text.trim());
      
      EasyLoading.dismiss();
      
      // Show success modal
      await Future.delayed(const Duration(milliseconds: 100));
      SuccessModal.show(
        title: 'Password Changed!',
        message: 'Your password has been successfully updated',
        buttonText: 'Done',
        onDismiss: () {
          Get.back();
        },
      );
      
      // Clear fields
      currentPasswordCont.clear();
      newPasswordCont.clear();
      confirmPasswordCont.clear();
      
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      
      String title = 'Error';
      String message = 'Something went wrong. Please try again.';
      
      switch (e.code) {
        case 'wrong-password':
          title = 'Incorrect Password';
          message = 'The current password you entered is incorrect';
          break;
        case 'weak-password':
          title = 'Weak Password';
          message = 'Please choose a stronger password';
          break;
        case 'requires-recent-login':
          title = 'Session Expired';
          message = 'Please log out and log in again before changing password';
          break;
        default:
          message = e.message ?? 'An error occurred. Please try again.';
      }
      
      await Future.delayed(const Duration(milliseconds: 100));
      ErrorModal.show(title: title, message: message);
    } catch (e) {
      EasyLoading.dismiss();
      await Future.delayed(const Duration(milliseconds: 100));
      ErrorModal.show(
        title: 'Error',
        message: 'Something went wrong. Please try again later.',
      );
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
                        
                        // Lock icon section
                        _buildLockIconSection(),
                        
                        const SizedBox(height: 40),
                        
                        // Current password field
                        _buildPasswordField(
                          controller: currentPasswordCont,
                          focusNode: currentPasswordNode,
                          label: 'Current Password',
                          hint: 'Enter your current password',
                          isVisible: isCurrentPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              isCurrentPasswordVisible = !isCurrentPasswordVisible;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // New password field
                        _buildPasswordField(
                          controller: newPasswordCont,
                          focusNode: newPasswordNode,
                          label: 'New Password',
                          hint: 'Enter your new password',
                          isVisible: isNewPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              isNewPasswordVisible = !isNewPasswordVisible;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Confirm password field
                        _buildPasswordField(
                          controller: confirmPasswordCont,
                          focusNode: confirmPasswordNode,
                          label: 'Confirm New Password',
                          hint: 'Re-enter your new password',
                          isVisible: isConfirmPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              isConfirmPasswordVisible = !isConfirmPasswordVisible;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Password requirements
                        _buildPasswordRequirements(),
                        
                        const SizedBox(height: 40),
                        
                        // Change password button
                        _buildChangePasswordButton(),
                        
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
                    'Change Password',
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
                  'Update your account security',
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

  Widget _buildLockIconSection() {
    return Center(
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              math.sin(_floatController.value * 2 * math.pi) * 5,
            ),
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
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
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
            color: Colors.white,
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
            obscureText: !isVisible,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.txtDark,
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
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: onVisibilityToggle,
                icon: Icon(
                  isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: AppColors.iconColor,
                  size: 20,
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

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Password Requirements',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.txtDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRequirement('At least 6 characters long'),
          const SizedBox(height: 6),
          _buildRequirement('Different from current password'),
          const SizedBox(height: 6),
          _buildRequirement('Passwords must match'),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.txtMuted,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangePasswordButton() {
    return GestureDetector(
      onTap: changePassword,
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
              Icons.shield_rounded,
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              'Change Password',
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
