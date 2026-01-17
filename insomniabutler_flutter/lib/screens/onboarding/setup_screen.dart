import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';

/// Onboarding Screen 6: Setup/Personalization
class SetupScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SetupScreen({Key? key, required this.onComplete}) : super(key: key);

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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Almost there',
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sleep Goals
                  Text(
                    'Choose your sleep goal:',
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ..._goals.map((goal) => _buildGoalCard(goal)),
                  const SizedBox(height: AppSpacing.xl),
                  // Bedtime Selection
                  Text(
                    'What time do you usually go to bed?',
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GestureDetector(
                    onTap: _selectBedtime,
                    child: GlassCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  gradient: AppColors.gradientPrimary,
                                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                                ),
                                child: const Icon(
                                  Icons.bedtime,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                'Bedtime',
                                style: AppTextStyles.body,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                _bedtime.format(context),
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.accentPrimary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.textTertiary,
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Map<String, String> goal) {
    final isSelected = _selectedGoals.contains(goal['text']);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GestureDetector(
        onTap: () => _toggleGoal(goal['text']!),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.gradientPrimary : null,
            color: isSelected ? null : AppColors.glassBg,
            border: Border.all(
              color: isSelected ? AppColors.accentPrimary : AppColors.glassBorder,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
          child: Row(
            children: [
              Text(
                goal['emoji']!,
                style: const TextStyle(fontSize: 24),
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
                  Icons.check_circle,
                  color: Colors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
