import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/auth_controllers/login_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/screens/auth_screens/forget_password.dart';
import 'package:back_packers/screens/auth_screens/sign_up.dart';
import 'package:back_packers/utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  var controller = Get.put(LoginController());
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoSlideAnimation;
  late Animation<double> _formSlideAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  bool _emailFocused = false;
  bool _passwordFocused = false;
  
  String? _emailError;
  String? _passwordError;

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
    
    // Clear errors when user starts typing
    controller.controllerEmail.addListener(() {
      if (_emailError != null) {
        setState(() => _emailError = null);
      }
    });
    
    controller.controllerPassword.addListener(() {
      if (_passwordError != null) {
        setState(() => _passwordError = null);
      }
    });
    
    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    // Slide animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _logoSlideAnimation = Tween<double>(
      begin: 80,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));
    
    _formSlideAnimation = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));
    
    // Float animation for background elements
    _floatController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(
      begin: -30,
      end: 30,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    // Shimmer animation for button
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
    
    // Pulse animation for logo
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    
    // Focus listeners
    controller.focusNodeEmail.addListener(() {
      setState(() {
        _emailFocused = controller.focusNodeEmail.hasFocus;
      });
    });
    
    controller.focusNodePassword.addListener(() {
      setState(() {
        _passwordFocused = controller.focusNodePassword.hasFocus;
      });
    });
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
    
    _fadeController.dispose();
    _slideController.dispose();
    _floatController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  bool _validateForm() {
    bool isValid = true;
    
    // Email validation
    if (controller.controllerEmail.text.trim().isEmpty) {
      setState(() => _emailError = 'Please enter your email address');
      isValid = false;
    } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(controller.controllerEmail.text.trim())) {
      setState(() => _emailError = 'Please enter a valid email address');
      isValid = false;
    }
    
    // Password validation
    if (controller.controllerPassword.text.trim().isEmpty) {
      setState(() => _passwordError = 'Please enter your password');
      isValid = false;
    } else if (controller.controllerPassword.text.trim().length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      isValid = false;
    }
    
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
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
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 24,
              right: 24,
            ),
            child: AnimatedBuilder(
                animation: Listenable.merge([_fadeController, _slideController]),
                builder: (context, child) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: ht(30)),
                          
                          // Logo with particle effects
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Transform.translate(
                              offset: Offset(0, _logoSlideAnimation.value),
                              child: _buildAnimatedLogo(),
                            ),
                          ),
                          
                          SizedBox(height: ht(24)),
                          
                          // Welcome text with better animation
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Transform.translate(
                              offset: Offset(0, _logoSlideAnimation.value),
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
                                      'Welcome Back',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -1,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                  
                                  SizedBox(height: ht(8)),
                                  
                    Text(
                                    'Sign in to continue your adventure',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.txtGrey,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                      
                          // Form section with stagger
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Transform.translate(
                              offset: Offset(0, _formSlideAnimation.value),
                              child: GetBuilder<LoginController>(
                                builder: (value) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Email field with animation
                                      _buildPremiumTextField(
                                        controller: controller.controllerEmail,
                                        focusNode: controller.focusNodeEmail,
                                        label: 'Email Address',
                                        hint: 'your.email@example.com',
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType: TextInputType.emailAddress,
                                        isFocused: _emailFocused,
                                        errorText: _emailError,
                                      ),
                                      
                                      SizedBox(height: ht(18)),
                                      
                                      // Password field with animation
                                      _buildPremiumTextField(
                                        controller: controller.controllerPassword,
                                        focusNode: controller.focusNodePassword,
                                        label: 'Password',
                                        hint: '••••••••',
                                        prefixIcon: Icons.lock_outline_rounded,
                                        obscureText: controller.obscure,
                                        isFocused: _passwordFocused,
                                        errorText: _passwordError,
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
                                            size: 22,
                ),
              ),
            ),
                                      
                                      SizedBox(height: ht(14)),
                                      
                                      // Remember me and forgot password
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Remember me
                                          InkWell(
                                            onTap: () => controller.rememberMe(!value.isRememberMe),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                              child: Row(
                children: [
                                                  AnimatedContainer(
                                                    duration: const Duration(milliseconds: 200),
                                                    width: 22,
                                                    height: 22,
                                                    decoration: BoxDecoration(
                                                      gradient: value.isRememberMe 
                                                        ? AppColors.primaryGradient 
                                                        : null,
                                                      color: value.isRememberMe 
                                                        ? null 
                                                        : AppColors.bgGrey,
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(
                                                        color: value.isRememberMe 
                                                          ? Colors.transparent 
                                                          : AppColors.borderColor,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: value.isRememberMe
                                                      ? const Icon(
                                                          Icons.check_rounded,
                                                          size: 16,
                                                          color: Colors.white,
                                                        )
                                                      : null,
                                                  ),
                                                  const SizedBox(width: 10),
                  Text(
                                                    'Remember me',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: AppColors.txtGrey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          
                                          // Forgot password
                                          TextButton(
                                            onPressed: () => Get.to(() => const ForgetPassword()),
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppColors.primaryColor,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            ),
                                            child: const Text(
                                              'Forgot Password?',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      SizedBox(height: ht(20)),
                                      
                                      // Sign in button with shimmer
                                      _buildShimmerButton(),
                                      
                                      SizedBox(height: ht(20)),
                                      
                                      // Divider with "OR"
                                      Row(
                      children: [
                                          Expanded(
                                            child: Container(
                                              height: 1,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.transparent,
                                                    AppColors.borderColor,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Text(
                                              'OR',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.txtMuted,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 1,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.borderColor,
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      SizedBox(height: ht(20)),
                                      
                                      // Sign up prompt with better styling
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                                            color: AppColors.bgGrey,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: AppColors.borderColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Don\'t have an account?',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.txtGrey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              GestureDetector(
                                                onTap: () {
                              Get.to(() => const SignUpScreen());
                            },
                                                child: Text(
                                                  'Sign Up',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.primaryColor,
                                                  ),
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
                          ),
                          
                          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
      children: [
            // Particle ring around logo
            ...List.generate(8, (index) {
              final angle = (index * math.pi * 2) / 8;
              return Transform.translate(
                offset: Offset(
                  math.cos(angle + (_pulseController.value * 2 * math.pi)) * 45,
                  math.sin(angle + (_pulseController.value * 2 * math.pi)) * 45,
                ),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
            ),
          ],
        ),
      ),
              );
            }),
            
            // Main logo
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                      spreadRadius: 4,
                    ),
                  ],
                ),
              child: Center(
                child: Image.asset(
                    'assets/images/splash_image.png',
                    width: 45,
                    height: 45,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required bool isFocused,
    String? errorText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    final hasError = errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            color: isFocused ? Colors.white : AppColors.bgGrey,
            borderRadius: BorderRadius.circular(16),
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
                    blurRadius: 20,
                    spreadRadius: 5,
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.txtDark,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 15,
                color: AppColors.txtMuted,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  prefixIcon,
                  color: hasError 
                    ? AppColors.errorRed
                    : (isFocused ? AppColors.primaryColor : AppColors.iconColor),
                  size: 22,
                ),
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                ),
              ),
            ),
        
        // Error message with animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: hasError ? 24 : 0,
          child: hasError
            ? Padding(
                padding: const EdgeInsets.only(left: 16, top: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 14,
                      color: AppColors.errorRed,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        errorText,
                        style: TextStyle(
                          fontSize: 12,
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
                  onTap: () {
                    if (_validateForm()) {
                      controller.getLogin();
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
                          'Sign In',
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
