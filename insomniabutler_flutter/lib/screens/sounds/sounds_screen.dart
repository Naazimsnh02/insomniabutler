import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/sleep_sound.dart';
import '../../services/audio_player_service.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../utils/haptic_helper.dart';
import 'widgets/sound_skeleton.dart';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({super.key});

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  final AudioPlayerService _audioService = AudioPlayerService();
  SoundCategory? _selectedCategory; // null means 'All'
  Set<String> _favoriteIds = {};
  bool _showFavoritesOnly = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFromCache();
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedCategory = prefs.getString('last_sound_category');
    
    setState(() {
      _favoriteIds = (prefs.getStringList('favorite_sounds') ?? []).toSet();
      if (cachedCategory != null) {
        _selectedCategory = SoundCategory.values.firstWhere(
          (e) => e.toString() == cachedCategory,
          orElse: () => SoundCategory.melodic,
        );
      }
    });

    // Simulated network delay for professional transition
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _toggleFavorite(String id) async {
    HapticHelper.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
    await prefs.setStringList('favorite_sounds', _favoriteIds.toList());
  }

  final List<SleepSound> _allSounds = [
    SleepSound(
      id: '1',
      title: 'Peaceful Sleep',
      assetPath: 'assets/sounds/sleep/peaceful-sleep-188311.mp3',
      category: SoundCategory.ambient,
      description: 'Deep ambient tones for restful sleep.',
      imagePath: 'assets/images/sounds/Peaceful Sleep.png',
    ),
    SleepSound(
      id: '2',
      title: 'Soft Ambient Rain',
      assetPath:
          'assets/sounds/sleep/relaxing-sleep-music-with-soft-ambient-rain-369762.mp3',
      category: SoundCategory.nature,
      description: 'Gentle rain falling on a quiet evening.',
      imagePath: 'assets/images/sounds/Soft Ambient Rain.png',
    ),
    SleepSound(
      id: '3',
      title: 'Tibetan Bells',
      assetPath: 'assets/sounds/sleep/sleep-inducing-tibetan-bells-388638.mp3',
      category: SoundCategory.meditative,
      description: 'Calming bells for deep meditation.',
      imagePath: 'assets/images/sounds/Tibetan Bell.png',
    ),
    SleepSound(
      id: '4',
      title: 'Baby Lullaby',
      assetPath: 'assets/sounds/sleep/lullaby-baby-sleep-music-456277.mp3',
      category: SoundCategory.lullaby,
      description: 'Sweet melodies for the little ones.',
      imagePath: 'assets/images/sounds/Baby Lullaby.png',
    ),
    SleepSound(
      id: '5',
      title: 'Sleep Lullaby',
      assetPath: 'assets/sounds/sleep/sleep-lullaby-142090.mp3',
      category: SoundCategory.lullaby,
      description: 'Soft lullaby to drift away.',
      imagePath: 'assets/images/sounds/Sleep Lullaby.png',
    ),
    SleepSound(
      id: '6',
      title: 'Ethereal Journey',
      assetPath: 'assets/sounds/sleep/sleep-music-vol12-190199.mp3',
      category: SoundCategory.melodic,
      description: 'Vol 12: A melodic journey into dreams.',
      imagePath: 'assets/images/sounds/Ethereal Journey.png',
    ),
    SleepSound(
      id: '7',
      title: 'Midnight Calm',
      assetPath: 'assets/sounds/sleep/sleep-music-vol14-195424.mp3',
      category: SoundCategory.melodic,
      description: 'Vol 14: Deep midnight serenity.',
      imagePath: 'assets/images/sounds/Midnight Calm.png',
    ),
    SleepSound(
      id: '8',
      title: 'Twilight Dreams',
      assetPath: 'assets/sounds/sleep/sleep-music-vol17-195423.mp3',
      category: SoundCategory.melodic,
      description: 'Vol 17: Soft twilight melodies.',
      imagePath: 'assets/images/sounds/Twilight Dreams.png',
    ),
    SleepSound(
      id: '9',
      title: 'Forest Whispers',
      assetPath: 'assets/sounds/sleep/sleep-music-vol6-182813.mp3',
      category: SoundCategory.nature,
      description: 'Vol 6: Gentle nature whispers.',
      imagePath: 'assets/images/sounds/Forest Whispers.png',
    ),
    SleepSound(
      id: '10',
      title: 'Starlight Serenade',
      assetPath: 'assets/sounds/sleep/sleep-music-vol7-182815.mp3',
      category: SoundCategory.melodic,
      description: 'Vol 7: Melodic starlight serenade.',
      imagePath: 'assets/images/sounds/Starlight Serenade.png',
    ),
  ];

  List<SleepSound> get _filteredSounds {
    if (_showFavoritesOnly) {
      return _allSounds.where((s) => _favoriteIds.contains(s.id)).toList();
    }
    if (_selectedCategory == null) return _allSounds;
    return _allSounds.where((s) => s.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Decorative background elements
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentPrimary.withOpacity(0.04),
            ),
          ).animate().fadeIn(duration: 1200.ms),
        ),
        Positioned(
          top: 300,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentLavender.withOpacity(0.03),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 1200.ms),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              _buildHeader(),
              _buildCategorySelector(),
              Expanded(
                child: _isLoading ? const SoundSkeleton() : _buildSoundGrid(),
              ),
              const SizedBox(height: 100), // Space for global playback bar
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sleep Sounds',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.0,
                ),
              ).animate().fadeIn().slideX(begin: -0.1, end: 0),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.accentPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _showFavoritesOnly
                        ? 'Your curated favorites'
                        : 'Perfect for deep restoration',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
          Row(
            children: [
              _buildFavoriteToggle(),
              const SizedBox(width: 12),
              _buildTimerButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteToggle() {
    return GestureDetector(
      onTap: () {
        HapticHelper.lightImpact();
        setState(() => _showFavoritesOnly = !_showFavoritesOnly);
      },
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 14,
        color: _showFavoritesOnly
            ? AppColors.accentError.withOpacity(0.2)
            : AppColors.bgSecondary.withOpacity(0.4),
        border: Border.all(
          color: _showFavoritesOnly
              ? AppColors.accentError.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
        ),
        child: Icon(
          _showFavoritesOnly
              ? Icons.favorite_rounded
              : Icons.favorite_outline_rounded,
          color: _showFavoritesOnly ? AppColors.accentError : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTimerButton() {
    return GestureDetector(
      onTap: () => _showTimerPicker(),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 14,
        color: AppColors.bgSecondary.withOpacity(0.4),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        child: const Icon(Icons.timer_outlined, color: Colors.white, size: 20),
      ),
    );
  }

  void _showTimerPicker() {
    HapticHelper.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TimerPickerSheet(
        onTimerSelected: (duration) {
          _audioService.setSleepTimer(duration);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Audio will fade out in ${duration.inMinutes} minutes'),
              backgroundColor: AppColors.bgSecondary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    if (_showFavoritesOnly) return const SizedBox(height: 16);

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: SoundCategory.values.length + 1,
        itemBuilder: (context, index) {
          final isAllChip = index == 0;
          final category = isAllChip ? null : SoundCategory.values[index - 1];
          final isSelected = _selectedCategory == category;
          final label = isAllChip ? 'All Sounds' : category!.displayName;

          return GestureDetector(
            onTap: () async {
              HapticHelper.lightImpact();
              setState(() => _selectedCategory = category);
              final prefs = await SharedPreferences.getInstance();
              if (category != null) {
                prefs.setString('last_sound_category', category.toString());
              } else {
                prefs.remove('last_sound_category');
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.gradientPrimary : null,
                color: isSelected ? null : AppColors.bgSecondary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected 
                    ? AppColors.accentPrimary.withOpacity(0.6) 
                    : Colors.white.withOpacity(0.12),
                  width: 1.2,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.accentPrimary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildSoundGrid() {
    final sounds = _filteredSounds;
    if (sounds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showFavoritesOnly
                    ? Icons.favorite_border_rounded
                    : Icons.music_note_outlined,
                size: 48,
                color: AppColors.textTertiary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _showFavoritesOnly
                  ? 'No favorite sounds yet'
                  : 'No sounds found',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        final sound = sounds[index];
        return _buildSoundCard(sound, index);
      },
    );
  }

  Widget _buildSoundCard(SleepSound sound, int index) {
    return StreamBuilder<SleepSound?>(
      stream: _audioService.currentSoundStream,
      initialData: _audioService.currentSound,
      builder: (context, snapshot) {
        final isCurrent = snapshot.data?.id == sound.id;
        return StreamBuilder<bool>(
          stream: _audioService.isPlayingStream,
          initialData: _audioService.isPlaying,
          builder: (context, playingSnapshot) {
            final isPlaying = isCurrent && (playingSnapshot.data ?? false);
            final isFavorite = _favoriteIds.contains(sound.id);

            return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 1.2,
                    ),
                    boxShadow: isCurrent ? [
                      BoxShadow(
                        color: AppColors.accentPrimary.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ] : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      children: [
                        // Clear Image Background
                        if (sound.imagePath != null)
                          Positioned.fill(
                            child: Image.asset(
                              sound.imagePath!,
                              fit: BoxFit.cover,
                            ),
                          ),

                        // Gradient Overlay for readability
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.1),
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Card Content
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticHelper.mediumImpact();
                              if (isCurrent && isPlaying) {
                                _audioService.pause();
                              } else {
                                _audioService.play(sound);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Premium Play Button
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                            child: Icon(
                                              isPlaying
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Premium Favorite Button
                                      GestureDetector(
                                        onTap: () => _toggleFavorite(sound.id),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isFavorite
                                                ? Icons.favorite_rounded
                                                : Icons.favorite_outline_rounded,
                                            color: isFavorite
                                                ? AppColors.accentError
                                                : Colors.white.withOpacity(0.8),
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),

                                  // Title Area
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        sound.title,
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        sound.category.displayName,
                                        style: AppTextStyles.caption.copyWith(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Active Indicator Glow
                        if (isPlaying)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.accentCyan,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentCyan,
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.5, 1.5),
                              duration: 800.ms,
                            ),
                          ),
                      ],
                    ),
                  ),
                )
                .animate().fadeIn(delay: (index * 50).ms).scale(
                  begin: const Offset(0.9, 0.9),
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                );
          },
        );
      },
    );
  }
}

class _TimerPickerSheet extends StatelessWidget {
  final Function(Duration) onTimerSelected;

  const _TimerPickerSheet({required this.onTimerSelected});

  @override
  Widget build(BuildContext context) {
    final times = [
      {'label': '15 minutes', 'value': 15, 'emoji': '🕒'},
      {'label': '30 minutes', 'value': 30, 'emoji': '⏳'},
      {'label': '45 minutes', 'value': 45, 'emoji': '🌑'},
      {'label': '1 hour', 'value': 60, 'emoji': '🌌'},
      {'label': '2 hours', 'value': 120, 'emoji': '💤'},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Sleep Timer',
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Audio will gently fade out',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ...times.map(
            (time) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 16),
                borderRadius: 20,
                color: AppColors.bgPrimary.withOpacity(0.4),
                onTap: () {
                  HapticHelper.mediumImpact();
                  onTimerSelected(Duration(minutes: time['value'] as int));
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(time['emoji'] as String, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    Text(
                      time['label'] as String,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
