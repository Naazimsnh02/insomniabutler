import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';

/// Onboarding Screen 1: Welcome
class WelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;

  const WelcomeScreen({Key? key, required this.onNext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.containerPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Illustration
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
                      child: Image.asset(
                        'assets/onboarding_welcome.png',
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    // Content Card
                    SizedBox(
                      width: double.infinity,
                      child: GlassCard(
                        child: Column(
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
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: AppSpacing.lg),
                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'I know this feeling',
                        onPressed: onNext,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}

/// Onboarding Screen 2: The Problem
class ProblemScreen extends StatelessWidget {
  final VoidCallback onNext;

  const ProblemScreen({Key? key, required this.onNext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.containerPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Illustration
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
                      child: Image.asset(
                        'assets/onboarding_problem.png',
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    // Content Card
                    SizedBox(
                      width: double.infinity,
                      child: GlassCard(
                        child: Column(
                          children: [
                            Text(
                              "You've tried everything",
                              style: AppTextStyles.h1,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildTryItem('☁️', 'Counting sheep'),
                            _buildTryItem('🎵', 'Sleep sounds'),
                            _buildTryItem('😮‍💨', 'Breathing exercises'),
                            _buildTryItem('📱', 'Closing your eyes harder'),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'But the thoughts are still there,\nunresolved, demanding attention.',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: AppSpacing.lg),
                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: "There's a better way",
                        onPressed: onNext,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildTryItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.md),
          Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}

/// Onboarding Screen 3: The Solution
class SolutionScreen extends StatelessWidget {
  final VoidCallback onNext;

  const SolutionScreen({Key? key, required this.onNext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.containerPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Illustration
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
                      child: Image.asset(
                        'assets/onboarding_solution.png',
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    // Content Card
                    SizedBox(
                      width: double.infinity,
                      child: GlassCard(
                        child: Column(
                          children: [
                            Text(
                              'Meet Your Butler',
                              style: AppTextStyles.displayMd,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              "Insomnia Butler doesn't just distract you.\nIt actively clears your mental clutter.",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildFeature('✨', 'Categorizes anxious thoughts'),
                            _buildFeature('🧘', 'Guides cognitive reframing'),
                            _buildFeature('📝', 'Parks worries for tomorrow'),
                            _buildFeature('💤', 'Helps you actually rest'),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: AppSpacing.lg),
                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'Show me how',
                        onPressed: onNext,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildFeature(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
