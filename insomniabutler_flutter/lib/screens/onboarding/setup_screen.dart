import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/glass_card.dart';

/// Onboarding Screen 6: Setup/Personalization
class SetupScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SetupScreen({super.key, required this.onComplete});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final List<String> _selectedGoals = [];
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);

  final List<Map<String, String>> _goals = [
    {'emoji': '⏰', 'text': 'Fall asleep faster'},
    {'emoji': '💤', 'text': 'Sleep through the night'},
    {'emoji': '🌅', 'text': 'Wake up refreshed'},
    {'emoji': '📈', 'text': 'All of the above'},
  ];

  void _toggleGoal(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  Future<void> _selectBedtime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _bedtime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentPrimary,
              onPrimary: Colors.white,
              surface: Color(0xFF1A1E3E),
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _bedtime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Deep Night Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.bgMainGradient,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                        'Almost there',
                        style: AppTextStyles.h2,
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Personalize your dashboard for the best results.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppSpacing.xxl),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your sleep goal:',
                            style: AppTextStyles.labelLg.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ).animate().fadeIn(delay: 300.ms),
                          const SizedBox(height: AppSpacing.md),
                          ..._goals.asMap().entries.map((entry) {
                            return _buildGoalCard(entry.value)
                                .animate()
                                .fadeIn(delay: (400 + (entry.key * 100)).ms)
                                .slideX(begin: 0.1, end: 0);
                          }),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            'Usual bedtime:',
                            style: AppTextStyles.labelLg.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ).animate().fadeIn(delay: 800.ms),
                          const SizedBox(height: AppSpacing.md),
                          _buildBedtimeSelector()
                              .animate()
                              .fadeIn(delay: 900.ms)
                              .slideY(begin: 0.2, end: 0),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // CTA Button
                  SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          text: 'Start sleeping better',
                          onPressed: widget.onComplete,
                          gradient: AppColors.gradientSuccess,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 1100.ms)
                      .scale(curve: Curves.easeOutBack),
                  const SizedBox(height: 100), // Space for indicators
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Map<String, String> goal) {
    final isSelected = _selectedGoals.contains(goal['text']);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentPrimary.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: GlassCard(
          onTap: () => _toggleGoal(goal['text']!),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 20,
          ),
          borderRadius: 16,
          color: isSelected
              ? AppColors.accentPrimary.withOpacity(0.12)
              : AppColors.bgSecondary.withOpacity(0.3),
          border: Border.all(
            color: isSelected
                ? AppColors.accentPrimary.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  goal['emoji']!,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  goal['text']!,
                  style: AppTextStyles.body.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 22,
                ).animate().scale(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBedtimeSelector() {
    return GlassCard(
      onTap: _selectBedtime,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 16,
      color: AppColors.bgSecondary.withOpacity(0.3),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Bedtime',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _bedtime.format(context),
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.accentPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textTertiary,
                size: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
