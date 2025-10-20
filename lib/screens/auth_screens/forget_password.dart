import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/auth_controllers/sign_up_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/utils/app_colors.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> with TickerProviderStateMixin {
  var controller = Get.put(SignUpController());
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatController;
  late AnimationController _lockController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _lockShakeAnimation;
  late Animation<double> _lockFloatAnimation;
  late Animation<double> _shimmerAnimation;

  bool _emailFocused = false;

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
    
    // Float animation for background
    _floatController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    
    // Lock animation (shake + float)
    _lockController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _lockShakeAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _lockController,
      curve: Curves.easeInOut,
    ));
    
    _lockFloatAnimation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _lockController,
      curve: Curves.easeInOut,
    ));
    
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
    
    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    
    // Focus listener
    controller.focusNodeEmail.addListener(() {
      setState(() {
        _emailFocused = controller.focusNodeEmail.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _floatController.dispose();
    _lockController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
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
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedBuilder(
                animation: Listenable.merge([_fadeController, _slideController]),
                builder: (context, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: ht(20)),
                      
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
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: ht(20)),
                      
                      // Animated lock icon
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Center(child: _buildAnimatedLock()),
                        ),
                      ),
                      
                      SizedBox(height: ht(40)),
                      
                      // Title and description
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    AppColors.primaryColor,
                                    AppColors.primaryDark,
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'Forgot Password?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: ht(16)),
                              
                    Text(
                                'Don\'t worry! Enter your email address\nand we\'ll send you a reset link',
                      textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.txtGrey,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Email input
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 0.5),
                          child: GetBuilder<SignUpController>(
                            builder: (value) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email Address',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.txtDark,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      color: _emailFocused ? Colors.white : AppColors.bgGrey,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _emailFocused ? AppColors.primaryColor : AppColors.borderColor,
                                        width: _emailFocused ? 2 : 1,
                                      ),
                                      boxShadow: _emailFocused
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryColor.withOpacity(0.1),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            ),
                                          ]
                                        : [],
                                    ),
                                    child: TextField(
                                      controller: controller.controllerEmail,
                                      focusNode: controller.focusNodeEmail,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.txtDark,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'your.email@example.com',
                                        hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: AppColors.txtMuted,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        prefixIcon: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          child: Icon(
                                            Icons.email_outlined,
                                            color: _emailFocused ? AppColors.primaryColor : AppColors.iconColor,
                                            size: 22,
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      
                      SizedBox(height: ht(24)),
                      
                      // Submit button
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildShimmerButton(),
                      ),
                      
                      SizedBox(height: ht(20)),
                      
                      // Back to login
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Center(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back_rounded,
                                  size: 18,
                                  color: AppColors.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Back to Sign In',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      SizedBox(height: ht(24)),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLock() {
    return AnimatedBuilder(
      animation: Listenable.merge([_lockController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _lockFloatAnimation.value),
          child: Transform.rotate(
            angle: _lockShakeAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.1),
                    AppColors.primaryLight.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Animated ring
                  Center(
                    child: AnimatedBuilder(
                      animation: _lockController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_lockController.value * 0.15),
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryColor.withOpacity(0.15),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Lock icon
                  Center(
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 50,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                  onTap: () {
                            controller.resestPassowrd();
                          },
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Send Reset Link',
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
