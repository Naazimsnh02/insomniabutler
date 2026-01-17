import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'onboarding_content_screens.dart';
import 'onboarding_interactive_screens.dart';
import 'setup_screen.dart';

/// Main Onboarding Flow Controller
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 6;

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgPrimary,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Skip Button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo/Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            gradient: AppColors.gradientPrimary,
                            borderRadius: BorderRadius.circular(AppBorderRadius.md),
                          ),
                          child: const Icon(
                            Icons.bedtime,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Insomnia Butler',
                          style: AppTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // Skip Button
                    if (_currentPage < _totalPages - 1)
                      TextButton(
                        onPressed: _skipToEnd,
                        child: Text(
                          'Skip',
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Page Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
                child: Row(
                  children: List.generate(
                    _totalPages,
                    (index) => Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(
                          right: index < _totalPages - 1 ? AppSpacing.xs : 0,
                        ),
                        decoration: BoxDecoration(
                          gradient: index <= _currentPage
                              ? AppColors.gradientPrimary
                              : null,
                          color: index <= _currentPage
                              ? null
                              : AppColors.glassBg,
                          borderRadius: BorderRadius.circular(AppBorderRadius.full),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Page View
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  physics: const NeverScrollableScrollPhysics(), // Disable swipe, use buttons only
                  children: [
                    WelcomeScreen(onNext: _nextPage),
                    ProblemScreen(onNext: _nextPage),
                    SolutionScreen(onNext: _nextPage),
                    DemoScreen(onNext: _nextPage),
                    PermissionsScreen(
                      onNext: _nextPage,
                      onSkip: _nextPage,
                    ),
                    SetupScreen(onComplete: widget.onComplete),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
