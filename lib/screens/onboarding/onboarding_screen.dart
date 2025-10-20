import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/screens/auth_screens/login.dart';
import 'package:back_packers/utils/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _pageOffset = 0.0;
  
  late AnimationController _blobController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _iconController;
  
  late Animation<double> _blobAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotateAnimation;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.explore_rounded,
      title: 'Find Your\nTravel Tribe',
      description: 'Connect with backpackers nearby. Share stories, split costs, and make lifelong friends on the road.',
      gradient: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
      accentColor: Color(0xFF7C3AED),
    ),
    OnboardingData(
      icon: Icons.business_center_rounded,
      title: 'Work While\nYou Wander',
      description: 'Find flexible jobs anywhere. Bartend in Bali, teach in Thailand, or code in Colombia.',
      gradient: [Color(0xFF10B981), Color(0xFF059669)],
      accentColor: Color(0xFF10B981),
    ),
    OnboardingData(
      icon: Icons.forum_rounded,
      title: 'Stay In\nThe Loop',
      description: 'Real-time chat with your crew. Share locations, photos, and plan your next adventure together.',
      gradient: [Color(0xFF6D28D9), Color(0xFF5B21B6)],
      accentColor: Color(0xFF6D28D9),
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0;
      });
    });
    
    // Blob morphing animation
    _blobController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    
    _blobAnimation = Tween<double>(begin: 0, end: 1).animate(_blobController);
    
    // Particle floating animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    // Text stagger animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Icon animation
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    
    _iconRotateAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOutCubic),
    );
    
    _playPageAnimation();
  }

  void _playPageAnimation() {
    _textController.reset();
    _iconController.reset();
    _textController.forward();
    _iconController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _blobController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _playPageAnimation();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Get.off(() => LoginScreen(), 
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  _pages[_currentPage].gradient[1].withOpacity(0.05),
                ],
              ),
            ),
          ),
          
          // Animated blob shapes
          ...List.generate(6, (index) => _buildBlob(index)),
          
          // Floating particles
          ...List.generate(20, (index) => _buildParticle(index)),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar with skip
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Animated page counter
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: 0.6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _pages[_currentPage].accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _pages[_currentPage].accentColor.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            '${_currentPage + 1}/${_pages.length}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _pages[_currentPage].accentColor,
                            ),
                          ),
                        ),
                      ),
                      
                      // Skip button
                      TextButton(
                        onPressed: _navigateToLogin,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.txtGrey,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content with parallax effect
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index], index);
                    },
                  ),
                ),
                
                // Custom animated progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: _buildCustomProgressBar(),
                ),
                
                // Navigation button
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                  child: _buildNavigationButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data, int index) {
    final parallax = (_pageOffset - index).abs();
    final isCurrentPage = index == _currentPage;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_textController, _iconController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, parallax * 50),
          child: Opacity(
            opacity: isCurrentPage ? 1.0 : 0.3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon with glow effect
                  Transform.scale(
                    scale: _iconScaleAnimation.value,
                    child: Transform.rotate(
                      angle: _iconRotateAnimation.value,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: data.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: data.accentColor.withOpacity(0.3),
                              blurRadius: 60,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Animated ring
                            Center(
                              child: AnimatedBuilder(
                                animation: _blobController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 1.0 + (_blobAnimation.value * 0.1),
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Icon
                            Center(
                              child: Icon(
                                data.icon,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: ht(60)),
                  
                  // Animated title with stagger
                  FadeTransition(
                    opacity: _textController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _textController,
                        curve: Curves.easeOutCubic,
                      )),
                      child: Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.txtDark,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: ht(24)),
                  
                  // Animated description
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _textController,
                      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _textController,
                        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
                      )),
                      child: Text(
                        data.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.txtGrey,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: ht(40)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomProgressBar() {
    return Stack(
      children: [
        // Background track
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.borderColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        // Animated progress with gradient
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          height: 6,
          width: MediaQuery.of(context).size.width * (_currentPage + 1) / _pages.length - 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _pages[_currentPage].gradient,
            ),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: _pages[_currentPage].accentColor.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _pages[_currentPage].gradient,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _pages[_currentPage].accentColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _nextPage,
          borderRadius: BorderRadius.circular(30),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _currentPage == _pages.length - 1 
                    ? Icons.arrow_forward_rounded 
                    : Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlob(int index) {
    final size = 200.0 + (index * 50);
    final offset = (index * math.pi * 2) / 6;
    
    return AnimatedBuilder(
      animation: _blobController,
      builder: (context, child) {
        final angle = (_blobAnimation.value * 2 * math.pi) + offset;
        final x = math.cos(angle) * 50;
        final y = math.sin(angle) * 30;
        
        return Positioned(
          top: 100 + (index * 80.0) + y,
          left: -50 + (index * 40.0) + x,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _pages[_currentPage].accentColor.withOpacity(0.05),
                  _pages[_currentPage].accentColor.withOpacity(0.01),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticle(int index) {
    final random = math.Random(index);
    final startX = random.nextDouble() * MediaQuery.of(context).size.width;
    final duration = 10 + random.nextInt(10);
    
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final progress = (_particleController.value + (index * 0.05)) % 1.0;
        final y = progress * MediaQuery.of(context).size.height;
        final x = startX + (math.sin(progress * math.pi * 4) * 30);
        final opacity = (1 - progress).clamp(0.0, 0.3);
        
        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pages[_currentPage].accentColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;
  final Color accentColor;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.accentColor,
  });
}
