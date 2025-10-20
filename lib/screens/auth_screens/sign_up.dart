import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/auth_controllers/sign_up_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/screens/other_screens/pick_location_controller.dart';
import 'package:back_packers/utils/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  var controller = Get.put(SignUpController());
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;
  late AnimationController _progressController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _shimmerAnimation;

  bool _firstNameFocused = false;
  bool _lastNameFocused = false;
  bool _emailFocused = false;
  bool _locationFocused = false;
  bool _phoneFocused = false;
  bool _passwordFocused = false;
  bool _confirmPasswordFocused = false;

  double _formProgress = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Float animation
    _floatController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    
    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    // Shimmer for button
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
    
    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    
    // Focus listeners
    _addFocusListeners();
    
    // Update progress on text changes
    controller.controllerFirstName.addListener(_updateProgress);
    controller.controllerLastName.addListener(_updateProgress);
    controller.controllerEmail.addListener(_updateProgress);
    controller.locationController.addListener(_updateProgress);
    controller.controllerPhone.addListener(_updateProgress);
    controller.controllerPassword.addListener(_updateProgress);
    controller.controllerConfirmPassword.addListener(_updateProgress);
  }

  void _addFocusListeners() {
    controller.focusNodeFirstName.addListener(() {
      setState(() => _firstNameFocused = controller.focusNodeFirstName.hasFocus);
    });
    controller.focusNodeLastName.addListener(() {
      setState(() => _lastNameFocused = controller.focusNodeLastName.hasFocus);
    });
    controller.focusNodeEmail.addListener(() {
      setState(() => _emailFocused = controller.focusNodeEmail.hasFocus);
    });
    controller.locationNode.addListener(() {
      setState(() => _locationFocused = controller.locationNode.hasFocus);
    });
    controller.focusNodePhone.addListener(() {
      setState(() => _phoneFocused = controller.focusNodePhone.hasFocus);
    });
    controller.focusNodePassword.addListener(() {
      setState(() => _passwordFocused = controller.focusNodePassword.hasFocus);
    });
    controller.focusNodeConfirm.addListener(() {
      setState(() => _confirmPasswordFocused = controller.focusNodeConfirm.hasFocus);
    });
  }

  void _updateProgress() {
    int filledFields = 0;
    if (controller.controllerFirstName.text.isNotEmpty) filledFields++;
    if (controller.controllerLastName.text.isNotEmpty) filledFields++;
    if (controller.controllerEmail.text.isNotEmpty) filledFields++;
    if (controller.locationController.text.isNotEmpty) filledFields++;
    if (controller.controllerPhone.text.isNotEmpty) filledFields++;
    if (controller.controllerPassword.text.isNotEmpty) filledFields++;
    if (controller.controllerConfirmPassword.text.isNotEmpty) filledFields++;
    
    final newProgress = filledFields / 7;
    if (newProgress != _formProgress) {
      setState(() {
        _formProgress = newProgress;
      });
      _progressController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _floatController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
          children: [
          // Clean gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryColor.withOpacity(0.02),
                  Colors.white,
                  Colors.white,
                  AppColors.primaryColor.withOpacity(0.01),
                ],
              ),
            ),
          ),
          
          // Subtle decorative elements
          ..._buildMinimalDecoration(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar with progress
                _buildTopBar(),
                
                // Scrollable form
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_fadeController, _slideController]),
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: ht(20)),
                            
                            // Title
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Transform.translate(
                                offset: Offset(0, _slideAnimation.value),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) => LinearGradient(
                                        colors: [
                                          AppColors.primaryColor,
                                          AppColors.primaryDark,
                                        ],
                                      ).createShader(bounds),
                                      child: const Text(
              'Create Account',
                                        style: TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: ht(8)),
            Text(
                                      'Join the community of travelers',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.txtGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            SizedBox(height: ht(32)),
                            
                            // Form fields
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: GetBuilder<SignUpController>(
                                builder: (value) {
              return Column(
                children: [
                                      // Name row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildCompactField(
                                              controller: controller.controllerFirstName,
                                              focusNode: controller.focusNodeFirstName,
                                              label: 'First Name',
                                              hint: 'John',
                                              icon: Icons.person_outline,
                                              isFocused: _firstNameFocused,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildCompactField(
                                              controller: controller.controllerLastName,
                                              focusNode: controller.focusNodeLastName,
                                              label: 'Last Name',
                                              hint: 'Doe',
                                              icon: Icons.person_outline,
                                              isFocused: _lastNameFocused,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      SizedBox(height: ht(16)),
                                      
                                      // Email
                                      _buildCompactField(
                                        controller: controller.controllerEmail,
                                        focusNode: controller.focusNodeEmail,
                                        label: 'Email Address',
                                        hint: 'your.email@example.com',
                                        icon: Icons.email_outlined,
                                        keyboardType: TextInputType.emailAddress,
                                        isFocused: _emailFocused,
                                      ),
                                      
                                      SizedBox(height: ht(16)),
                                      
                                      // Location
                                      _buildCompactField(
                                        controller: controller.locationController,
                                        focusNode: controller.locationNode,
                                        label: 'Location',
                                        hint: 'Select your location',
                                        icon: Icons.location_on_outlined,
                                        isFocused: _locationFocused,
                                        readOnly: true,
                                        onTap: () {
                                          Get.to(() => PickLocation(onSubmit: (loc, latlang) {
                                            Get.back();
                                            controller.latlng = latlang;
                                            controller.locationController.text = loc ?? '';
                                          }));
                                        },
                                      ),
                                      
                                      SizedBox(height: ht(16)),
                                      
                                      // Phone
                                      _buildCompactField(
                                        controller: controller.controllerPhone,
                                        focusNode: controller.focusNodePhone,
                                        label: 'Phone Number',
                                        hint: '+1 234 567 8900',
                                        icon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                        isFocused: _phoneFocused,
                                      ),
                                      
                                      SizedBox(height: ht(16)),
                                      
                                      // Password
                                      _buildCompactField(
                                        controller: controller.controllerPassword,
                                        focusNode: controller.focusNodePassword,
                                        label: 'Password',
                                        hint: '••••••••',
                                        icon: Icons.lock_outline_rounded,
                                        obscureText: controller.obscure,
                                        isFocused: _passwordFocused,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            controller.obscure = !controller.obscure;
                                            controller.update();
                                          },
                                          icon: Icon(
                                            controller.obscure 
                                              ? Icons.visibility_outlined 
                                              : Icons.visibility_off_outlined,
                                            color: AppColors.iconColor,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      
                                      SizedBox(height: ht(16)),
                                      
                                      // Confirm Password
                                      _buildCompactField(
                                        controller: controller.controllerConfirmPassword,
                                        focusNode: controller.focusNodeConfirm,
                                        label: 'Confirm Password',
                                        hint: '••••••••',
                                        icon: Icons.lock_outline_rounded,
                                        obscureText: controller.obscure,
                                        isFocused: _confirmPasswordFocused,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            controller.obscure = !controller.obscure;
                                            controller.update();
                                          },
                                          icon: Icon(
                                            controller.obscure 
                                              ? Icons.visibility_outlined 
                                              : Icons.visibility_off_outlined,
                                            color: AppColors.iconColor,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      
                                      SizedBox(height: ht(20)),
                                      
                                      // Terms & Conditions
                                      InkWell(
                    onTap: () {
                      controller.changeTerms();
                    },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.bgGrey,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: value.terms 
                                                ? AppColors.primaryColor.withOpacity(0.3)
                                                : AppColors.borderColor,
                                              width: 1,
                                            ),
                                          ),
                    child: Row(
                      children: [
                                              AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  gradient: value.terms 
                                                    ? AppColors.primaryGradient 
                                                    : null,
                                                  color: value.terms 
                                                    ? null 
                                                    : Colors.white,
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: value.terms 
                                                      ? Colors.transparent 
                                                      : AppColors.borderColor,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: value.terms
                                                  ? const Icon(
                                                      Icons.check_rounded,
                                                      size: 16,
                                                      color: Colors.white,
                                                    )
                                                  : null,
                                              ),
                                              const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                                                  'I accept the terms & conditions',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.txtDark,
                                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                                      ),
                                      
                                      SizedBox(height: ht(28)),
                                      
                                      // Create account button
                                      _buildShimmerButton(),
                                      
                                      SizedBox(height: ht(24)),
                                      
                                      // Sign in prompt
                                      Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                                              'Already have an account?',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.txtGrey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Get.back(),
                                              style: TextButton.styleFrom(
                                                foregroundColor: AppColors.primaryColor,
                                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                              ),
                                              child: const Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                                      
                                      SizedBox(height: ht(30)),
                                    ],
                                  );
                                },
                              ),
                  ),
                ],
              );
                      },
                    ),
                  ),
                ),
          ],
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // Back button
              FadeTransition(
                opacity: _fadeAnimation,
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.bgGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.txtDark,
                      size: 22,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Progress indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.bgGrey,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                    child: Row(
                    mainAxisSize: MainAxisSize.min,
      children: [
                      Icon(
                        Icons.checklist_rounded,
                        size: 18,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 6),
                        Text(
                        '${(_formProgress * 100).toInt()}% Complete',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                ),
              ),
            ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Animated progress bar
          FadeTransition(
            opacity: _fadeAnimation,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.borderColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    height: 5,
                    width: (MediaQuery.of(context).size.width - 40) * _formProgress,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.4),
                          blurRadius: 8,
                        ),
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

  Widget _buildCompactField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required bool isFocused,
    String? errorText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final hasError = errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.txtDark,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isFocused ? Colors.white : AppColors.bgGrey,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError 
                ? AppColors.errorRed 
                : (isFocused ? AppColors.primaryColor : AppColors.borderColor),
              width: (isFocused || hasError) ? 2 : 1,
            ),
            boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: hasError 
                      ? AppColors.errorRed.withOpacity(0.1)
                      : AppColors.primaryColor.withOpacity(0.1),
                    blurRadius: 16,
                    spreadRadius: 3,
                  ),
                ]
              : hasError
                ? [
                    BoxShadow(
                      color: AppColors.errorRed.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.txtDark,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: AppColors.txtMuted,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  icon,
                  color: hasError 
                    ? AppColors.errorRed
                    : (isFocused ? AppColors.primaryColor : AppColors.iconColor),
                  size: 20,
                ),
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
        
        // Error message with animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: hasError ? 22 : 0,
          child: hasError
            ? Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 13,
                      color: AppColors.errorRed,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        errorText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.errorRed,
                          height: 1.2,
              ),
            ),
          ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildShimmerButton() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 12),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Shimmer effect
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Transform.translate(
                    offset: Offset(_shimmerAnimation.value * MediaQuery.of(context).size.width, 0),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                ),
              ),
            ),
              ),
              // Button content
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    if (await controller.initvalidation()) {
                      controller.createUser();
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.1),
              child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                ),
              ),
            ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildMinimalDecoration() {
    return [
      // Top-right accent
      Positioned(
        top: -100,
        right: -100,
        child: Container(
          width: 300,
          height: 300,
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
      
      // Bottom-left subtle accent
      Positioned(
        bottom: -150,
        left: -100,
        child: Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primaryLight.withOpacity(0.06),
                AppColors.primaryLight.withOpacity(0.01),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      
      // Subtle grid pattern overlay
      Positioned.fill(
        child: CustomPaint(
          painter: GridPatternPainter(
            color: AppColors.primaryColor.withOpacity(0.02),
                ),
              ),
            ),
    ];
  }
}

// Custom painter for subtle grid pattern
class GridPatternPainter extends CustomPainter {
  final Color color;
  
  GridPatternPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    const spacing = 40.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
