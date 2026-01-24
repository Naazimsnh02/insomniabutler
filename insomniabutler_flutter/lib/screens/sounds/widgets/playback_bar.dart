import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme.dart';
import '../../../models/sleep_sound.dart';
import '../../../services/audio_player_service.dart';
import '../../../widgets/glass_card.dart';

class PlaybackBar extends StatelessWidget {
  final AudioPlayerService audioService = AudioPlayerService();

  PlaybackBar({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SleepSound?>(
      stream: audioService.currentSoundStream,
      initialData: audioService.currentSound,
      builder: (context, snapshot) {
        final currentSound = snapshot.data;
        if (currentSound == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: GlassCard(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            borderRadius: 28,
            color: AppColors.bgSecondary.withOpacity(0.9),
            border: Border.all(
              color: AppColors.accentPrimary.withOpacity(0.3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: currentSound.imagePath != null
                            ? DecorationImage(
                                image: AssetImage(currentSound.imagePath!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: AppColors.accentPrimary.withOpacity(0.2),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: currentSound.imagePath == null
                          ? const Icon(
                              Icons.music_note_rounded,
                              color: AppColors.accentPrimary,
                              size: 24,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentSound.title,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentSound.category.displayName,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<bool>(
                      stream: audioService.isPlayingStream,
                      initialData: audioService.isPlaying,
                      builder: (context, playingSnapshot) {
                        final isPlaying = playingSnapshot.data ?? false;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (isPlaying) {
                                  audioService.pause();
                                } else {
                                  audioService.resume();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause_circle_filled_rounded
                                      : Icons.play_circle_filled_rounded,
                                  color: Colors.white,
                                  size: 44,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textTertiary,
                                size: 24,
                              ),
                              onPressed: () => audioService.stop(),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StreamBuilder<Duration?>(
                  stream: audioService.durationStream,
                  builder: (context, durationSnapshot) {
                    final duration = durationSnapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration?>(
                      stream: audioService.positionStream,
                      builder: (context, positionSnapshot) {
                        var position = positionSnapshot.data ?? Duration.zero;
                        if (position > duration) position = duration;

                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 5,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 12,
                                ),
                                activeTrackColor: AppColors.accentPrimary,
                                inactiveTrackColor: Colors.white.withOpacity(0.1),
                                thumbColor: Colors.white,
                              ),
                              child: Slider(
                                value: position.inMilliseconds.toDouble(),
                                max: duration.inMilliseconds.toDouble() > 0 
                                    ? duration.inMilliseconds.toDouble() 
                                    : 1.0,
                                onChanged: (value) {
                                  audioService.seek(
                                    Duration(milliseconds: value.toInt()),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 10,
                                      color: AppColors.textTertiary,
                                      fontFeatures: [const FontFeature.tabularFigures()],
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 10,
                                      color: AppColors.textTertiary,
                                      fontFeatures: [const FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: 1.0, end: 0, curve: Curves.easeOutBack, duration: 600.ms).fadeIn();
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
