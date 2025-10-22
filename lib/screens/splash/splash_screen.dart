import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/screens/auth_screens/login.dart';
import 'package:back_packers/screens/onboarding/onboarding_screen.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/primary_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _shimmerController;
  late AnimationController _rotateController;
  late AnimationController _particleController;
  late AnimationController _dragController;
  
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _featuresFadeAnimation;
  late Animation<double> _featuresSlideAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<double> _buttonSlideAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _dragAnimation;
  
  double _dragOffset = 0.0;
  bool _isDragging = false;

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
    
    // Main controller for staggered entrance animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );
    
    // Shimmer controller for button (cool professional effect)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
    
    // Rotate controller for background circles
    _rotateController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
    
    // Particle animation for logo entrance
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Logo animations - Dramatic entrance
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    
    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    
    _logoRotateAnimation = Tween<double>(
      begin: -0.3,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    
    // Text animations - Staggered
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _textSlideAnimation = Tween<double>(
      begin: 40.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    
    // Features animations
    _featuresFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _featuresSlideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    
    // Button animations - Last to appear
    _buttonFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _buttonSlideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    
    // Shimmer animation for button
    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Particle animation
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _particleController,
        curve: Curves.easeOut,
      ),
    );
    
    // Drag animation controller
    _dragController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _dragAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dragController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _controller.forward();
    _particleController.forward();
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
    
    _controller.dispose();
    _shimmerController.dispose();
    _rotateController.dispose();
    _particleController.dispose();
    _dragController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Animated background purple circles
          _buildBackgroundCircles(),
          
          // Main content
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 24,
              right: 24,
            ),
        child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // Logo with beautiful entrance animations
                  AnimatedBuilder(
                    animation: Listenable.merge([_controller, _particleController]),
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
          children: [
                          // Particle effects around logo
                          ...List.generate(8, (index) {
                            final angle = (index * math.pi * 2) / 8;
                            final distance = 120.0 * (1 - _particleAnimation.value);
                            return Transform.translate(
                              offset: Offset(
                                math.cos(angle) * distance,
                                math.sin(angle) * distance,
                              ),
                              child: Opacity(
                                opacity: (1 - _particleAnimation.value).clamp(0.0, 1.0),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryColor.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            );
                          }),
                          
                          // Main logo with dramatic entrance
                          Opacity(
                            opacity: _logoFadeAnimation.value,
                            child: Transform.scale(
                              scale: _logoScaleAnimation.value,
                              child: Transform.rotate(
                                angle: _logoRotateAnimation.value,
                                child: Container(
                                  width: ht(240),
                                  height: ht(240),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(40),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryColor.withOpacity(0.15 * _logoFadeAnimation.value),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                        offset: const Offset(0, 10),
                                      ),
                                      BoxShadow(
                                        color: AppColors.primaryColor.withOpacity(0.1 * _logoFadeAnimation.value),
                                        blurRadius: 60,
                                        spreadRadius: 20,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(32),
                                  child: Image.asset(
              'assets/images/splash_image2.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  
                  SizedBox(height: ht(50)),
                  
                  // App name with staggered animation
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textFadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, _textSlideAnimation.value),
                          child: Column(
                            children: [
                              // Gradient text
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    AppColors.primaryColor,
                                    AppColors.primaryDark,
                                    AppColors.primaryDarker,
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'BackPack Buddies',
                    textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                      color: Colors.white,
                                    letterSpacing: -0.5,
                                    height: 1.2,
                    ),
                  ),
                ),
                              
                              SizedBox(height: ht(16)),
                              
                              // Tagline
                              Text(
                                'Connect. Travel. Explore Together.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.txtGrey,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // Features with staggered animation
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _featuresFadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, _featuresSlideAnimation.value),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildFeatureItem(Icons.people_rounded, 'Community', 0),
                              SizedBox(width: wd(40)),
                              _buildFeatureItem(Icons.work_rounded, 'Opportunities', 1),
                              SizedBox(width: wd(40)),
                              _buildFeatureItem(Icons.chat_bubble_rounded, 'Connect', 2),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: ht(50)),
                  
                  // Draggable bag icon with swipe gesture
                  AnimatedBuilder(
                    animation: Listenable.merge([_controller, _dragController]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _buttonFadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, _buttonSlideAnimation.value),
                          child: _buildDraggableBagIcon(),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: ht(60)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, int index) {
    // Staggered delay for each item
    final delay = index * 0.1;
    final itemOpacity = (_featuresFadeAnimation.value - delay).clamp(0.0, 1.0);
    
    return Opacity(
      opacity: itemOpacity,
      child: Transform.scale(
        scale: 0.8 + (itemOpacity * 0.2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.txtGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableBagIcon() {
    return Center(
      child: Column(
        children: [
          // Drag instruction text
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Text(
              'Drag the bag to the right to start',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.txtGrey,
                letterSpacing: 0.3,
              ),
            ),
          ),
          
          SizedBox(height: ht(20)),
          
          // Modern futuristic button with bag icon
          Container(
            width: 320,
            height: 60,
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Animated background glow
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: RadialGradient(
                      center: Alignment.centerLeft,
                      radius: 1.5,
                      colors: [
                        AppColors.primaryColor.withOpacity(_dragOffset > 0 ? 0.3 : 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                 // Purple fill that appears when dragging
                 AnimatedContainer(
                   duration: Duration(milliseconds: 200),
                   width: _dragOffset > 0 ? _dragOffset.clamp(0, 320) : 0,
                   height: 60,
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       begin: Alignment.centerLeft,
                       end: Alignment.centerRight,
                       colors: [
                         AppColors.primaryColor.withOpacity(0.9),
                         AppColors.primaryColor.withOpacity(0.7),
                       ],
                     ),
                     borderRadius: BorderRadius.circular(10),
                     boxShadow: [
                       BoxShadow(
                         color: AppColors.primaryColor.withOpacity(0.3),
                         blurRadius: 15,
                         offset: const Offset(0, 5),
                       ),
                     ],
                   ),
                 ),
                
                // Progress border with glow effect
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.8),
                      width: (_dragOffset / 100).clamp(0.0, 1.0) * 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.4),
                        blurRadius: (_dragOffset / 100).clamp(0.0, 1.0) * 20,
                        spreadRadius: (_dragOffset / 100).clamp(0.0, 1.0) * 5,
                      ),
                    ],
                  ),
                ),
                
                // Modern bag icon with glassmorphism effect
                Positioned(
                  left: -5, // Left position
                  top: -30, // Move up so top part extends outside
                  child: GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _isDragging = true;
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _dragOffset += details.delta.dx;
                        // Limit drag to right direction only
                        if (_dragOffset < 0) _dragOffset = 0;
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        _isDragging = false;
                      });
                      
                      // Check if dragged far enough to trigger navigation
                      if (_dragOffset > 120) {
                        _dragController.forward().then((_) {
                          Get.off(() => const OnboardingScreen());
                        });
                      } else {
                        // Snap back to original position
                        _dragController.reverse();
                        setState(() {
                          _dragOffset = 0;
                        });
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _dragController,
                      builder: (context, child) {
                        final animatedOffset = _isDragging 
                            ? _dragOffset 
                            : _dragOffset * (1 - _dragAnimation.value);
                        
                        return Transform.translate(
                          offset: Offset(animatedOffset, 0),
                          child: Transform.scale(
                            scale: _isDragging ? 1.15 : 1.0,
                            child: Stack(
                              children: [
                                // Custom bag icon without any background
                                Image.asset(
                                  'assets/images/bag_pack.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                                
                                // Drag indicator with modern design
                                if (_isDragging)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryColor.withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 12,
                                        color: AppColors.primaryColor,
                                      ),
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
                
                // Modern text indicator
                if (_dragOffset > 40)
                  Positioned(
                    right: 25,
                    top: 30,
                    child: AnimatedOpacity(
                      opacity: (_dragOffset / 120).clamp(0.0, 1.0),
                      duration: Duration(milliseconds: 200),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          SizedBox(height: ht(16)),
        ],
      ),
    );
  }
  
  Widget _buildBackgroundCircles() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return Stack(
          children: [
            // Top right purple circle
            Positioned(
              top: -150,
              right: -150,
              child: Transform.rotate(
                angle: _rotateController.value * 2 * math.pi,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryLight.withOpacity(0.15),
                        AppColors.primaryLighter.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom left purple circle
            Positioned(
              bottom: -100,
              left: -100,
              child: Transform.rotate(
                angle: -_rotateController.value * 2 * math.pi,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.1),
                        AppColors.primaryLight.withOpacity(0.03),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Center accent circle
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryDark.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
