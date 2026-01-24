enum SoundCategory {
  melodic,
  ambient,
  nature,
  lullaby,
  meditative;

  String get displayName {
    switch (this) {
      case SoundCategory.melodic: return 'Melodic';
      case SoundCategory.ambient: return 'Ambient';
      case SoundCategory.nature: return 'Nature';
      case SoundCategory.lullaby: return 'Lullaby';
      case SoundCategory.meditative: return 'Meditative';
    }
  }
}

class SleepSound {
  final String id;
  final String title;
  final String assetPath;
  final SoundCategory category;
  final String? description;
  final String? imagePath;

  SleepSound({
    required this.id,
    required this.title,
    required this.assetPath,
    required this.category,
    this.description,
    this.imagePath,
  });
}
