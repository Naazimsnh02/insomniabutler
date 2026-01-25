import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';

class BreathingExerciseWidget extends StatefulWidget {
  final int durationMinutes;

  const BreathingExerciseWidget({
    super.key,
    this.durationMinutes = 2,
  });

  @override
  State<BreathingExerciseWidget> createState() => _BreathingExerciseWidgetState();
}

class _BreathingExerciseWidgetState extends State<BreathingExerciseWidget> {
  String _phase = 'Get Ready';
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
  }

  void _startExercise() {
    setState(() {
      _isActive = true;
      _phase = 'Inhale';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Breathing Coach',
            style: AppTextStyles.h3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _isActive ? 'Follow the circle' : '${widget.durationMinutes} minute restorative exercise',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          
          if (!_isActive)
            ElevatedButton(
              onPressed: _startExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Start Exercise'),
            )
          else
            Column(
              children: [
                _buildBreathingCircle(),
                const SizedBox(height: 32),
                Text(
                  _phase,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.accentCyan,
                    letterSpacing: 2,
                  ),
                ).animate(key: ValueKey(_phase)).fadeIn().scale(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBreathingCircle() {
    // 4s Inhale, 4s Hold, 4s Exhale
    return SizedBox(
      height: 250, // Ensure enough vertical space for scale * height
      width: 250,  // Ensure enough horizontal space
      child: Center(
        child: Container(
          width: 100, // Reduced base size
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.accentCyan.withOpacity(0.4),
                AppColors.accentPrimary.withOpacity(0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentCyan.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .custom(
          duration: 12.seconds, // Total cycle: 4 In, 4 Hold, 4 Out
          builder: (context, value, child) {
            // value goes 0.0 -> 1.0 over 12s
            // 0.0 - 0.33: Inhale (Scale 1.0 -> 2.5)
            // 0.33 - 0.66: Hold (Scale 2.5)
            // 0.66 - 1.0: Exhale (Scale 2.5 -> 1.0)
            
            double scale = 1.0;
            String newPhase = _phase;
            
            if (value < 0.33) {
              double step = value / 0.33;
              scale = 1.0 + (1.5 * step);
              newPhase = 'Inhale';
            } else if (value < 0.66) {
              scale = 2.5;
              newPhase = 'Hold';
            } else {
              double step = (value - 0.66) / 0.34;
              scale = 2.5 - (1.5 * step);
              newPhase = 'Exhale';
            }

            if (newPhase != _phase) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _phase = newPhase);
              });
            }

            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
        ),
      ),
    );
}
}
