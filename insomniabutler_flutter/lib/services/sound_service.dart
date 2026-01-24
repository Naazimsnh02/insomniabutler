import '../models/sleep_sound.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final List<SleepSound> allSounds = [
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

  SleepSound? findSoundByName(String name) {
    name = name.toLowerCase();
    return allSounds.cast<SleepSound?>().firstWhere(
      (s) => s!.title.toLowerCase().contains(name),
      orElse: () => null,
    );
  }

  SleepSound? getSoundById(String id) {
    return allSounds.cast<SleepSound?>().firstWhere(
      (s) => s!.id == id,
      orElse: () => null,
    );
  }
}
