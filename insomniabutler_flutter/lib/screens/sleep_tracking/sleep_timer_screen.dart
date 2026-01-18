import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:async';
import '../../core/theme.dart';
import '../../widgets/primary_button.dart';
import '../../utils/haptic_helper.dart';

class SleepTimerScreen extends StatefulWidget {
  const SleepTimerScreen({Key? key}) : super(key: key);

  @override
  State<SleepTimerScreen> createState() => _SleepTimerScreenState();
}

class _SleepTimerScreenState extends State<SleepTimerScreen> {
  DateTime _startTime = DateTime.now();
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(_startTime);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.bgPrimary),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const Spacer(),
              _buildTimerDisplay(),
              const Spacer(),
              _buildActionButtons(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: AppColors.glassBg),
          ),
          Text('Silent Tracking', style: AppTextStyles.h4),
          const SizedBox(width: 48), // Spacer
        ],
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing Background Glow
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPrimary.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  duration: 4.seconds,
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                ),
            
            // Outer Ring
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentPrimary.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),

            Column(
              children: [
                const Icon(Icons.nightlight_round, size: 40, color: AppColors.accentPrimary)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 0, end: -10, duration: 2.seconds),
                const SizedBox(height: 20),
                Text(
                  _formatDuration(_elapsed),
                  style: AppTextStyles.displayLg.copyWith(
                    fontFeatures: [const FontFeature.tabularFigures()],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Elapsed Time',
                  style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 60),
        Text(
          'Rest well. Your phone is silent and tracking.',
          style: AppTextStyles.bodyLg.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 1.seconds),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: PrimaryButton(
        text: 'Wake Up & Finish',
        onPressed: () async {
          await HapticHelper.mediumImpact();
          _showWakeUpSheet();
        },
        gradient: AppColors.gradientSuccess,
        icon: Icons.sunny,
      ),
    );
  }

  void _showWakeUpSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _WakeUpFeedbackSheet(duration: _elapsed),
    );
  }
}

class _WakeUpFeedbackSheet extends StatefulWidget {
  final Duration duration;
  const _WakeUpFeedbackSheet({Key? key, required this.duration}) : super(key: key);

  @override
  State<_WakeUpFeedbackSheet> createState() => _WakeUpFeedbackSheetState();
}

class _WakeUpFeedbackSheetState extends State<_WakeUpFeedbackSheet> {
  int _quality = 3;
  String _mood = '😊';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.xxl)),
        gradient: AppColors.bgSecondary,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Good Morning!', style: AppTextStyles.h2),
          Text(
            'You slept for ${widget.duration.inHours}h ${widget.duration.inMinutes.remainder(60)}m',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('How was your sleep?', style: AppTextStyles.labelLg),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              final val = index + 1;
              final isSelected = _quality == val;
              return GestureDetector(
                onTap: () => setState(() => _quality = val),
                child: AnimatedContainer(
                  duration: 200.ms,
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentPrimary : AppColors.glassBgElevated,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.accentPrimary : AppColors.glassBorder,
                    ),
                  ),
                  child: Center(
                    child: Text('$val', 
                      style: AppTextStyles.h4.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            text: 'Save Session',
            onPressed: () {
              HapticHelper.success();
              Navigator.pop(context); // Close sheet
              Navigator.pop(context); // Close timer
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
