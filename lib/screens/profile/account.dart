import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:back_packers/screens/profile/edit_details.dart';
import 'package:back_packers/screens/profile/jobs/applied_jobs.dart';
import 'package:back_packers/screens/profile/my_cv.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'change_password.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> with TickerProviderStateMixin {
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
    super.dispose();
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
          
          // Main content - no scroll, responsive single page
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                    // Premium profile header
                    _buildPremiumProfileHeader(),
                    
                    const SizedBox(height: 16),
                    
                    // Scrollable content area
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Account Settings Section
                          _buildSectionTitle('Account Settings'),
                          const SizedBox(height: 8),
                          _buildPremiumCard(
                            children: [
                              _buildPremiumMenuItem(
                                icon: Icons.person_outline_rounded,
                                title: 'My Account',
                                subtitle: 'Make changes to your account',
                                gradientColors: [
                                  AppColors.primaryColor,
                                  AppColors.primaryLight,
                                ],
                                onTap: () => Get.to(() => const EditDetails()),
                              ),
                              _buildDivider(),
                              _buildPremiumMenuItem(
                                icon: Icons.lock_outline_rounded,
                                title: 'Change Password',
                                subtitle: 'Manage your account security',
                                gradientColors: [
                                  AppColors.primaryDark,
                                  AppColors.primaryColor,
                                ],
                                onTap: () => Get.to(() => NewPassword()),
                  ),
                ],
              ),
                          
                          const SizedBox(height: 12),
                          
                          // Career Section
                          _buildSectionTitle('Career'),
                          const SizedBox(height: 8),
                          _buildPremiumCard(
                children: [
                              _buildPremiumMenuItem(
                                icon: Icons.work_outline_rounded,
                                title: 'My Applied Jobs',
                                subtitle: 'Track your job applications',
                                gradientColors: [
                                  const Color(0xFF6B4CE6),
                                  const Color(0xFF8B6EF7),
                                ],
                                onTap: () => Get.to(() => const AppliedJobs()),
                              ),
                              _buildDivider(),
                              _buildPremiumMenuItem(
                                icon: Icons.description_outlined,
                                title: 'My CVs',
                                subtitle: 'Manage your resumes',
                                gradientColors: [
                                  const Color(0xFF5E4DCE),
                                  const Color(0xFF7B66E0),
                                ],
                                onTap: () => Get.to(() => const MyCVs()),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Danger Zone
                          _buildSectionTitle('Danger Zone'),
                          const SizedBox(height: 8),
                          _buildPremiumCard(
                            children: [
                              _buildPremiumMenuItem(
                                icon: Icons.delete_outline_rounded,
                                title: 'Delete Account',
                                subtitle: 'Permanently delete your account',
                                gradientColors: [
                                  Colors.red.shade400,
                                  Colors.red.shade600,
                                ],
                    onTap: () {
                                  showDeleteAccountDialog(context, () {});
                    },
                  ),
                ],
              ),
                          
                          const Spacer(),
          ],
        ),
      ),
                    
                    // Premium Logout Button - fixed at bottom
                    _buildPremiumLogoutButton(),
                    
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumProfileHeader() {
    return GetBuilder<UserDetail>(
      builder: (value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          clipBehavior: Clip.none,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF9D7BFF), // Light vibrant purple
                const Color(0xFF7B61FF), // Bright purple
                const Color(0xFF6C5CE7), // Medium purple
                const Color(0xFF5E4DCE), // Deep purple
                const Color(0xFF4E3FBC), // Rich purple
                const Color(0xFF3D2E9F), // Dark purple
              ],
              stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9D7BFF).withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
                spreadRadius: 3,
              ),
              BoxShadow(
                color: const Color(0xFF4E3FBC).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Decorative gradient overlay circles
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -25,
                left: -25,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.18),
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Accent circle in middle
              Positioned(
                top: 20,
                right: 60,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Main content
              Row(
                children: [
                  // Animated profile photo
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          math.sin(_floatController.value * 2 * math.pi) * 3,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                              BoxShadow(
                                color: const Color(0xFF9D7BFF).withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 34,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.primaryLight,
                              child: value.image == ''
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 34,
                                      color: Colors.white,
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(32),
                                      child: Image.network(
                                        value.image,
                                        fit: BoxFit.cover,
                                        height: double.infinity,
                                        width: double.infinity,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${value.fname} ${value.lname}",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value.email,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.95),
                            letterSpacing: 0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
              
                  // Edit button
                  GestureDetector(
                    onTap: () => Get.to(() => const EditDetails()),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.txtDark.withOpacity(0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPremiumCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildPremiumMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Gradient icon container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.txtDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                  Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.txtMuted,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.iconColor,
                size: 14,
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.borderColor.withOpacity(0.2),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumLogoutButton() {
    return GestureDetector(
              onTap: () {
        Get.find<UserDetail>().logout();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.shade400,
              Colors.red.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 15,
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

  Future<void> showDeleteAccountDialog(
      BuildContext context, VoidCallback onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Warning icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade400,
                          Colors.red.shade600,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  const Text(
            'Delete Account',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Message
                  Text(
            'Are you sure you want to delete your account? This action cannot be undone, and all your data will be permanently removed.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.txtMuted,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.bgGrey,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.borderColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.txtDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                Navigator.of(context).pop();
                deleteAccount();
              },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade400,
                                  Colors.red.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
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
          ),
        );
      },
    );
  }

  Future<void> deleteAccount() async {
    EasyLoading.show();
    User? user = FirebaseAuth.instance.currentUser;
    debugPrint("user is : $user");
    if (user != null) {
      try {
        await user.delete();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
        EasyLoading.dismiss();
        EasyLoading.showToast("Account deleted Successfully");
        await Future.delayed(
          const Duration(seconds: 2),
        );
        Get.find<UserDetail>().logout();
      } on FirebaseException catch (exception) {
        EasyLoading.dismiss();
        print("Error deleting user: ${exception.code}");
        if (exception.message != null) {
          EasyLoading.showToast(exception.message!);
        } else {
          EasyLoading.showToast("Something bad Happened Try Again");
        }
        if (exception.code == "requires-recent-login") {
          await Future.delayed(
            const Duration(seconds: 2),
          );
          Get.find<UserDetail>().logout();
        }
      }
    } else {
      EasyLoading.showToast('No user is currently signed in');
      EasyLoading.dismiss();
    }
  }
}
