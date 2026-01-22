import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/sleep_sound.dart';
import '../../services/audio_player_service.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../utils/haptic_helper.dart';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({Key? key}) : super(key: key);

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  final AudioPlayerService _audioService = AudioPlayerService();
  SoundCategory? _selectedCategory; // null means 'All'
  Set<String> _favoriteIds = {};
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteIds = (prefs.getStringList('favorite_sounds') ?? []).toSet();
    });
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
      assetPath: 'assets/sounds/sleep/relaxing-sleep-music-with-soft-ambient-rain-369762.mp3',
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          _buildCategorySelector(),
          Expanded(
            child: _buildSoundGrid(),
          ),
          _buildPlaybackBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sleep Sounds',
                style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                _showFavoritesOnly ? 'Your favorite sounds' : 'Curated for your deep rest',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              ),
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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _showFavoritesOnly
              ? AppColors.accentError.withOpacity(0.2)
              : AppColors.bgSecondary.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(
            color: _showFavoritesOnly
                ? AppColors.accentError.withOpacity(0.5)
                : Colors.white10,
          ),
        ),
        child: Icon(
          _showFavoritesOnly ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
          color: _showFavoritesOnly ? AppColors.accentError : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTimerButton() {
    return GestureDetector(
      onTap: () => _showTimerPicker(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
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
      builder: (context) => _TimerPickerSheet(
        onTimerSelected: (duration) {
          _audioService.setSleepTimer(duration);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Timer set for ${duration.inMinutes} minutes'),
              backgroundColor: AppColors.bgSecondary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    if (_showFavoritesOnly) return const SizedBox(height: 16);

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: SoundCategory.values.length + 1,
        itemBuilder: (context, index) {
          final isAllChip = index == 0;
          final category = isAllChip ? null : SoundCategory.values[index - 1];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ChoiceChip(
              label: Text(isAllChip ? 'All' : _getCategoryName(category!)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  HapticHelper.lightImpact();
                  setState(() => _selectedCategory = category);
                }
              },
              backgroundColor: AppColors.bgSecondary.withOpacity(0.3),
              selectedColor: AppColors.accentPrimary.withOpacity(0.3),
              labelStyle: AppTextStyles.label.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.accentPrimary.withOpacity(0.5)
                      : Colors.white10,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getCategoryName(SoundCategory category) {
    switch (category) {
      case SoundCategory.melodic:
        return 'Melodic';
      case SoundCategory.ambient:
        return 'Ambient';
      case SoundCategory.nature:
        return 'Nature';
      case SoundCategory.lullaby:
        return 'Lullaby';
      case SoundCategory.meditative:
        return 'Meditative';
    }
  }

  Widget _buildSoundGrid() {
    final sounds = _filteredSounds;
    if (sounds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _showFavoritesOnly ? Icons.favorite_border_rounded : Icons.music_note_outlined,
              size: 64,
              color: AppColors.textTertiary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _showFavoritesOnly ? 'No favorites yet' : 'No sounds in this category',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        final sound = sounds[index];
        return _buildSoundCard(sound);
      },
    );
  }

  Widget _buildSoundCard(SleepSound sound) {
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
                borderRadius: BorderRadius.circular(24),
                boxShadow: isCurrent ? AppShadows.selectionGlow : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
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
                              Colors.black.withOpacity(0.6),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Glassy Play Button
                                  ClipOval(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Icon(
                                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Glassy Favorite Button
                                  ClipOval(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                            color: isFavorite ? AppColors.accentError : Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () => _toggleFavorite(sound.id),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              
                              // Glassy Text Area
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          sound.title,
                                          style: AppTextStyles.bodySm.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          _getCategoryName(sound.category),
                                          style: AppTextStyles.caption.copyWith(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Active Border
                    if (isCurrent)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.accentPrimary.withOpacity(0.8),
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ).animate(target: isCurrent ? 1 : 0).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.04, 1.04),
                  duration: 200.ms,
                  curve: Curves.easeOut,
                );
          },
        );
      },
    );
  }

  Widget _buildPlaybackBar() {
    return StreamBuilder<SleepSound?>(
      stream: _audioService.currentSoundStream,
      initialData: _audioService.currentSound,
      builder: (context, snapshot) {
        final currentSound = snapshot.data;
        if (currentSound == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 110),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: 24,
            color: AppColors.bgSecondary.withOpacity(0.9),
            border: Border.all(color: AppColors.accentPrimary.withOpacity(0.4)),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: currentSound.imagePath != null
                        ? DecorationImage(
                            image: AssetImage(currentSound.imagePath!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: AppColors.accentPrimary.withOpacity(0.2),
                  ),
                  child: currentSound.imagePath == null
                      ? const Icon(Icons.music_note_rounded,
                          color: AppColors.accentPrimary, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentSound.title,
                        style: AppTextStyles.bodySm.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Now Playing',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<bool>(
                  stream: _audioService.isPlayingStream,
                  initialData: _audioService.isPlaying,
                  builder: (context, playingSnapshot) {
                    final isPlaying = playingSnapshot.data ?? false;
                    return Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            if (isPlaying) {
                              _audioService.pause();
                            } else {
                              _audioService.resume();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                          onPressed: () => _audioService.stop(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ).animate().slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutBack),
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
      {'label': '15 min', 'value': 15},
      {'label': '30 min', 'value': 30},
      {'label': '45 min', 'value': 45},
      {'label': '1 hour', 'value': 60},
      {'label': '2 hours', 'value': 120},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Set Sleep Timer', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text('Audio will slowly fade out and stop',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ...times.map((time) => ListTile(
                title: Text(time['label'] as String,
                    textAlign: TextAlign.center, style: AppTextStyles.bodyLg),
                onTap: () {
                  onTimerSelected(Duration(minutes: time['value'] as int));
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.accentError)),
          ),
        ],
      ),
    );
  }
}
