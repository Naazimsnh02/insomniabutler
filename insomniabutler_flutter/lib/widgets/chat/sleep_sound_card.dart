import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../models/sleep_sound.dart';
import '../../services/audio_player_service.dart';

/// Beautiful sleep sound playback card for chat
/// Shows when AI plays a sleep sound
class SleepSoundCard extends StatefulWidget {
  final String soundTitle;
  final String? soundImagePath;
  final String? category;
  final SleepSound? sound;

  const SleepSoundCard({
    super.key,
    required this.soundTitle,
    this.soundImagePath,
    this.category,
    this.sound,
  });

  @override
  State<SleepSoundCard> createState() => _SleepSoundCardState();
}

class _SleepSoundCardState extends State<SleepSoundCard>
    with SingleTickerProviderStateMixin {
  final AudioPlayerService _audioService = AudioPlayerService();
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _audioService.isPlayingStream,
      initialData: _audioService.isPlaying,
      builder: (context, playingSnapshot) {
        final isPlaying = playingSnapshot.data ?? false;

        return Container(
          constraints: const BoxConstraints(maxWidth: 340),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentPrimary.withOpacity(0.2),
                AppColors.accentPrimary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.accentPrimary.withOpacity(0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPrimary.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with category badge
              Row(
                children: [
                  const Icon(
                    Icons.music_note_rounded,
                    color: AppColors.accentPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Now Playing',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  if (widget.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accentPrimary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        widget.category!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Main content with thumbnail and info
              Row(
                children: [
                  // Thumbnail with animated border
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentPrimary.withOpacity(0.3),
                          AppColors.accentPrimary.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: isPlaying
                            ? AppColors.accentPrimary.withOpacity(0.6)
                            : AppColors.accentPrimary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: widget.soundImagePath != null
                          ? Image.asset(
                              widget.soundImagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildDefaultIcon(AppColors.accentPrimary),
                            )
                          : _buildDefaultIcon(AppColors.accentPrimary),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Sound info and controls
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.soundTitle,
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Animated waveform when playing
                        if (isPlaying)
                          SizedBox(
                            height: 24,
                            child: Row(
                              children: List.generate(
                                12,
                                (index) => Expanded(
                                  child: AnimatedBuilder(
                                    animation: _waveController,
                                    builder: (context, child) {
                                      final delay = index * 0.1;
                                      final value = ((_waveController.value +
                                                      delay) %
                                                  1.0) *
                                              2 -
                                          1;
                                      final height =
                                          (value.abs() * 16 + 4).clamp(4.0, 20.0);

                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 1.5,
                                        ),
                                        height: height,
                                        decoration: BoxDecoration(
                                          color: AppColors.accentPrimary.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Text(
                            'Looping',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Playback controls
              StreamBuilder<Duration?>(
                stream: _audioService.positionStream,
                builder: (context, positionSnapshot) {
                  return StreamBuilder<Duration?>(
                    stream: _audioService.durationStream,
                    builder: (context, durationSnapshot) {
                      final position = positionSnapshot.data ?? Duration.zero;
                      final duration =
                          durationSnapshot.data ?? const Duration(seconds: 1);
                      final progress = duration.inMilliseconds > 0
                          ? position.inMilliseconds / duration.inMilliseconds
                          : 0.0;

                      return Column(
                        children: [
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              backgroundColor:
                                  AppColors.bgSecondary.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.accentPrimary.withOpacity(0.8),
                              ),
                              minHeight: 4,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Control buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Play/Pause button
                              GestureDetector(
                                onTap: () async {
                                  if (isPlaying) {
                                    await _audioService.pause();
                                  } else {
                                    if (widget.sound != null) {
                                      await _audioService.play(widget.sound!);
                                    } else {
                                      await _audioService.resume();
                                    }
                                  }
                                },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.accentPrimary.withOpacity(0.8),
                                        AppColors.accentPrimary.withOpacity(0.6),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accentPrimary.withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Stop button
                              GestureDetector(
                                onTap: () async {
                                  await _audioService.stop();
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.bgSecondary.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.accentPrimary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.stop_rounded,
                                    color: AppColors.accentPrimary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.95, 0.95), duration: 400.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms);
      },
    );
  }

  Widget _buildDefaultIcon(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: color.withOpacity(0.6),
          size: 36,
        ),
      ),
    );
  }
}
