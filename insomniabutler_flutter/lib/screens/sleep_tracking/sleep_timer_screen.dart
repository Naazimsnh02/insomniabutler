import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:async';
import '../../core/theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/glass_card.dart';
import '../../utils/haptic_helper.dart';
import '../../main.dart';
import '../../services/user_service.dart';
import '../../services/sleep_timer_service.dart';

class SleepTimerScreen extends StatefulWidget {
  const SleepTimerScreen({Key? key}) : super(key: key);

  @override
  State<SleepTimerScreen> createState() => _SleepTimerScreenState();
}

class _SleepTimerScreenState extends State<SleepTimerScreen> {
  final _timerService = SleepTimerService();
  Duration _elapsed = Duration.zero;
  late StreamSubscription _tickSubscription;

  @override
  void initState() {
    super.initState();
    _elapsed = _timerService.currentDuration;
    _tickSubscription = _timerService.onTick.listen((duration) {
      if (mounted) {
        setState(() => _elapsed = duration);
      }
    });
  }

  @override
  void dispose() {
    _tickSubscription.cancel();
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
        decoration: const BoxDecoration(gradient: AppColors.bgMainGradient),
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
          _buildIconButton(
            icon: Icons.close_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Text(
            'Silent Tracking',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 48), // Spacer
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 12,
        color: AppColors.bgSecondary.withOpacity(0.4),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
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
                    color: AppColors.accentPrimary.withOpacity(0.12),
                    blurRadius: 120,
                    spreadRadius: 30,
                  ),
                ],
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              duration: 4.seconds,
              begin: const Offset(1, 1),
              end: const Offset(1.15, 1.15),
            ),

            // Outer Ring (Glass)
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1.5,
                ),
                color: Colors.white.withOpacity(0.03),
              ),
            ),
            
            // Progress Ring (Visual Only)
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentPrimary.withOpacity(0.4),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPrimary.withOpacity(0.1),
                    blurRadius: 20,
                  )
                ],
              ),
            ).animate(onPlay: (c) => c.repeat()).rotate(duration: 20.seconds),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.nightlight_round,
                  size: 44,
                  color: AppColors.accentPrimary.withOpacity(0.9),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -10, duration: 2.seconds),
                const SizedBox(height: 16),
                Text(
                  _timerService.isRunning
                      ? _formatDuration(_elapsed)
                      : "00:00:00",
                  style: AppTextStyles.displayLg.copyWith(
                    fontFeatures: [const FontFeature.tabularFigures()],
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _timerService.isRunning ? 'TRACKING ACTIVE' : 'READY TO SLEEP',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 60),
        Text(
          _timerService.isRunning
              ? 'Rest well. Your sleep is being tracked.'
              : 'Tap start when you\'re ready to sleep.',
          style: AppTextStyles.bodyLg.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 1.seconds),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: _timerService.isRunning
          ? PrimaryButton(
              text: 'Wake Up & Finish',
              onPressed: () async {
                await HapticHelper.mediumImpact();
                _showWakeUpSheet();
              },
              gradient: AppColors.gradientSuccess,
              icon: Icons.sunny,
            )
          : PrimaryButton(
              text: 'Start Night Timer',
              onPressed: () {
                HapticHelper.mediumImpact();
                setState(() => _timerService.start());
              },
              icon: Icons.play_arrow_rounded,
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
  const _WakeUpFeedbackSheet({Key? key, required this.duration})
    : super(key: key);

  @override
  State<_WakeUpFeedbackSheet> createState() => _WakeUpFeedbackSheetState();
}

class _WakeUpFeedbackSheetState extends State<_WakeUpFeedbackSheet> {
  final _timerService = SleepTimerService();
  int _quality = 3;
  String _mood = '😊';
  bool _isSaving = false;

  Future<void> _saveSession() async {
    setState(() => _isSaving = true);
    HapticHelper.lightImpact();

    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      // Use the current time as wake time, and subtract duration for startTime
      final wakeTime = DateTime.now();
      final bedTime = wakeTime.subtract(widget.duration);

      await client.sleepSession.logManualSession(
        userId,
        bedTime,
        wakeTime,
        _quality,
      );

      HapticHelper.success();
      if (mounted) {
        _timerService.reset();
        Navigator.pop(context); // Close sheet
        Navigator.pop(context); // Close timer
      }
    } catch (e) {
      debugPrint('Error saving timer session: $e');
      HapticHelper.error();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgSecondary.withOpacity(0.8),
            AppColors.bgPrimary,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Good Morning!', 
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 4),
          Text(
            'You slept for ${widget.duration.inHours}h ${widget.duration.inMinutes.remainder(60)}m',
            style: AppTextStyles.bodyLg.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'How was your sleep?', 
                style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold)
              ),
              const Icon(Icons.auto_awesome, size: 16, color: AppColors.accentPrimary),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final val = index + 1;
              final isSelected = _quality == val;
              return GestureDetector(
                onTap: () => setState(() => _quality = val),
                child: AnimatedContainer(
                  duration: 200.ms,
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentPrimary.withOpacity(0.3)
                        : AppColors.bgSecondary.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentPrimary.withOpacity(0.6)
                          : Colors.white.withOpacity(0.1),
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColors.accentPrimary.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ] : null,
                  ),
                  child: Center(
                    child: Text(
                      '$val',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            text: _isSaving ? 'Saving...' : 'Complete Entry',
            isLoading: _isSaving,
            onPressed: () => _saveSession(),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
