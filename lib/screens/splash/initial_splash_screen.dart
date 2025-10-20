import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/screens/main_screens/bottom_bar_screen.dart';
import 'package:back_packers/screens/splash/splash_screen.dart';
import 'package:back_packers/utils/app_colors.dart';

class InitialSplashScreen extends StatefulWidget {
  final bool isLoggedIn;
  
  const InitialSplashScreen({super.key, this.isLoggedIn = false});

  @override
  State<InitialSplashScreen> createState() => _InitialSplashScreenState();
}

class _InitialSplashScreenState extends State<InitialSplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _waveController;
  late AnimationController _rotateController;
  late AnimationController _textController;
  late AnimationController _fadeOutController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();
    
    // Logo animations - Dramatic entrance
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    
    _logoRotateAnimation = Tween<double>(
      begin: math.pi * 2,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    ));
    
    // Particle explosion animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Wave animation (continuous)
    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    // Rotate animation for rings
    _rotateController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));
    
    _textSlideAnimation = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));
    
    // Fade out animation (entire screen)
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeOutController,
      curve: Curves.easeInCubic,
    ));
    
    // Start animations sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Logo appears
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _logoController.forward();
    
    // Particles explode
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _particleController.forward();
    
    // Text appears
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) _textController.forward();
    
    // Wait for total 5 seconds, then fade out
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      _fadeOutController.forward().then((_) {
        // Navigate based on login status
        if (widget.isLoggedIn) {
          Get.off(() => NavBarScreen(), transition: Transition.fade);
        } else {
          Get.off(() => const SplashScreen(), transition: Transition.fade);
        }
      });
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    _rotateController.dispose();
    _textController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeOutController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeOutAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    AppColors.primaryColor.withOpacity(0.05),
                    Colors.white,
                    AppColors.primaryLight.withOpacity(0.03),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Animated wave patterns
                  ..._buildWavePatterns(),
                  
                  // Rotating gradient rings
                  ..._buildRotatingRings(),
                  
                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Particle explosion around logo
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _logoController,
                            _particleController,
                          ]),
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Explosive particles
                                ..._buildExplosiveParticles(),
                                
                                // Orbiting particles
                                ..._buildOrbitingParticles(),
                                
                                // Main logo with rotation and scale
                                Transform.rotate(
                                  angle: _logoRotateAnimation.value,
                                  child: Transform.scale(
                                    scale: _logoScaleAnimation.value,
                                    child: Opacity(
                                      opacity: _logoOpacityAnimation.value,
                                      child: Container(
                                        width: 160,
                                        height: 160,
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          borderRadius: BorderRadius.circular(40),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryColor.withOpacity(0.4),
                                              blurRadius: 60,
                                              spreadRadius: 20,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/splash_img.png',
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.contain,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Animated text
                        AnimatedBuilder(
                          animation: _textController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _textOpacityAnimation.value,
                              child: Transform.translate(
                                offset: Offset(0, _textSlideAnimation.value),
                                child: Column(
                                  children: [
                                    // App name with shimmer effect
                                    _buildShimmerText(
                                      'BackPack Buddies',
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // Tagline
                                    Text(
                                      'Your Adventure Starts Here',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.txtGrey,
                                        letterSpacing: 1,
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
                  
                  // Loading indicator at bottom
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textOpacityAnimation.value,
                          child: Center(
                            child: _buildLoadingIndicator(),
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
    );
  }

  Widget _buildShimmerText(String text, {required double fontSize, required FontWeight fontWeight}) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                AppColors.primaryDark,
                AppColors.primaryColor,
                AppColors.primaryLight,
                AppColors.primaryColor,
                AppColors.primaryDark,
              ],
              stops: [
                0.0,
                _waveController.value - 0.3,
                _waveController.value,
                _waveController.value + 0.3,
                1.0,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
              tileMode: TileMode.mirror,
            ).createShader(bounds);
          },
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildExplosiveParticles() {
    return List.generate(16, (index) {
      final angle = (index * math.pi * 2) / 16;
      final distance = 200 * _particleController.value;
      final opacity = (1 - _particleController.value).clamp(0.0, 1.0);
      
      return Transform.translate(
        offset: Offset(
          math.cos(angle) * distance,
          math.sin(angle) * distance,
        ),
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildOrbitingParticles() {
    return List.generate(12, (index) {
      final angle = (index * math.pi * 2) / 12;
      final orbitRadius = 100.0;
      final rotationAngle = angle + (_rotateController.value * 2 * math.pi);
      
      return Transform.translate(
        offset: Offset(
          math.cos(rotationAngle) * orbitRadius,
          math.sin(rotationAngle) * orbitRadius,
        ),
        child: Opacity(
          opacity: _logoOpacityAnimation.value * 0.8,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildWavePatterns() {
    return List.generate(3, (index) {
      final size = 400.0 + (index * 100);
      final offset = index * 120.0;
      
      return AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return Positioned(
            left: MediaQuery.of(context).size.width / 2 - size / 2,
            top: MediaQuery.of(context).size.height / 2 - size / 2 + offset,
            child: Transform.scale(
              scale: 0.5 + (_waveController.value * 0.5),
              child: Opacity(
                opacity: (1 - _waveController.value) * 0.3,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildRotatingRings() {
    return List.generate(4, (index) {
      final size = 200.0 + (index * 60);
      
      return AnimatedBuilder(
        animation: _rotateController,
        builder: (context, child) {
          return Positioned(
            left: MediaQuery.of(context).size.width / 2 - size / 2,
            top: MediaQuery.of(context).size.height / 2 - size / 2,
            child: Transform.rotate(
              angle: (_rotateController.value * 2 * math.pi) * (index.isEven ? 1 : -1),
              child: Opacity(
                opacity: (0.15 - (index * 0.03)) * _logoOpacityAnimation.value,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return Column(
          children: [
            // Custom circular progress
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                children: [
                  // Background circle
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderColor.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                  ),
                  // Animated arc
                  Transform.rotate(
                    angle: _rotateController.value * 2 * math.pi,
                    child: CustomPaint(
                      size: const Size(40, 40),
                      painter: ArcPainter(
                        color: AppColors.primaryColor,
                        progress: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Loading your experience...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.txtGrey,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom painter for loading arc
class ArcPainter extends CustomPainter {
  final Color color;
  final double progress;
  
  ArcPainter({required this.color, required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

