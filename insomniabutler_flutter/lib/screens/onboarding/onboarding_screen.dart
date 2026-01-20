import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'onboarding_content_screens.dart';
import 'onboarding_interactive_screens.dart';
import 'setup_screen.dart';
import 'auth_screen.dart';

/// Main Onboarding Flow Controller
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({Key? key, required this.onComplete})
    : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 7;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _skipToEnd() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // Ensure no background color bleeds through
      body: Stack(
        children: [
          // Page View (Full Screen - covers status bar)
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            physics: const NeverScrollableScrollPhysics(),
            children: [
              WelcomeScreen(onNext: _nextPage),
              ProblemScreen(onNext: _nextPage),
              SolutionScreen(onNext: _nextPage),
              DemoScreen(onNext: _nextPage),
              PermissionsScreen(
                onNext: _nextPage,
                onSkip: _nextPage,
              ),
              SetupScreen(onComplete: _nextPage),
              AuthScreen(onComplete: widget.onComplete),
            ],
          ),

          // Bottom Overlay (Dots)
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalPages,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      gradient: _currentPage == index
                          ? AppColors.gradientPrimary
                          : null,
                      color: _currentPage == index
                          ? null
                          : AppColors.textTertiary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(AppBorderRadius.full),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
