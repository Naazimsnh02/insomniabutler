import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/primary_button.dart';

/// Onboarding Screen 1: Welcome
class WelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;

  const WelcomeScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image (covers status bar)
        Positioned.fill(
          child: Image.asset(
            'assets/onboarding/Welcome.png',
            fit: BoxFit.cover,
          ),
        ),
        // Dark Gradient for Readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.3, 0.6, 1],
              ),
            ),
          ),
        ),
        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxxl,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "It's 2 AM",
                  style: AppTextStyles.displayMd,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Your mind is racing.\nYour body is exhausted.\nBut sleep won\'t come.',
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Help me now',
                    onPressed: onNext,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl), // Space for dots
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Onboarding Screen 2: The Problem
class ProblemScreen extends StatelessWidget {
  final VoidCallback onNext;

  const ProblemScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            'assets/onboarding/Problem.png',
            fit: BoxFit.cover,
          ),
        ),
        // Dark Gradient for Readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.3, 0.6, 1],
              ),
            ),
          ),
        ),
        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  "Tired of trying?",
                  style: AppTextStyles.displayMd,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Counting sheep, white noise, and breathing techniques feel like chores when your thoughts are loud.',
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'There is a better way',
                    onPressed: onNext,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl), // Space for dots
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Onboarding Screen 3: The Solution
class SolutionScreen extends StatelessWidget {
  final VoidCallback onNext;

  const SolutionScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            'assets/onboarding/Solution.png',
            fit: BoxFit.cover,
          ),
        ),
        // Dark Gradient for Readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.3, 0.6, 1],
              ),
            ),
          ),
        ),
        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxxl,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Meet your Butler",
                  style: AppTextStyles.displayMd,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Offload your racing thoughts through structured reframing and quiet your mind for rest.',
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Show me how',
                    onPressed: onNext,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl), // Space for dots
              ],
            ),
          ),
        ),
      ],
    );
  }
}
