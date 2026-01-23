import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/glass_card.dart';

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
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.3, 0.6, 1],
              ),
            ),
          ),
        ),

        // Decorative background elements
        Positioned(
          top: 100,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentPrimary.withOpacity(0.08),
            ),
          ).animate().fadeIn(duration: 1200.ms).scale(begin: const Offset(0.8, 0.8)),
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
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  borderRadius: 32,
                  color: Colors.black.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.2,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "It's 2 AM",
                        style: AppTextStyles.displayMd.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Your mind is racing.\nYour body is exhausted.\nBut sleep won\'t come.',
                        style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.textPrimary.withOpacity(0.9),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                    ],
                  ),
                ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.95, 0.95)),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Help me now',
                    onPressed: onNext,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
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
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.3, 0.6, 1],
              ),
            ),
          ),
        ),

        // Decorative background elements
        Positioned(
          top: 150,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentLavender.withOpacity(0.06),
            ),
          ).animate().fadeIn(duration: 1200.ms).scale(begin: const Offset(0.8, 0.8)),
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
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  borderRadius: 32,
                  color: Colors.black.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.2,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Tired of trying?",
                        style: AppTextStyles.displayMd.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Counting sheep, white noise, and breathing techniques feel like chores when your thoughts are loud.',
                        style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.textPrimary.withOpacity(0.9),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                    ],
                  ),
                ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.95, 0.95)),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'There is a better way',
                    onPressed: onNext,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
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
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.3, 0.6, 1],
              ),
            ),
          ),
        ),

        // Decorative background elements
        Positioned(
          bottom: 200,
          right: -50,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentCyan.withOpacity(0.06),
            ),
          ).animate().fadeIn(duration: 1200.ms).scale(begin: const Offset(0.8, 0.8)),
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
                const Spacer(),
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  borderRadius: 32,
                  color: Colors.black.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.2,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Meet your Butler",
                        style: AppTextStyles.displayMd.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Offload your racing thoughts through structured reframing and quiet your mind for rest.',
                        style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.textPrimary.withOpacity(0.9),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                    ],
                  ),
                ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.95, 0.95)),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Show me how',
                    onPressed: onNext,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
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
