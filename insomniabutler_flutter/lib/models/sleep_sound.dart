enum SoundCategory { melodic, ambient, nature, lullaby, meditative }

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
