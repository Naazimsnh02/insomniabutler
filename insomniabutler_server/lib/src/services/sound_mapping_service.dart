/// Maps sound names to their full metadata for widget rendering
class SoundMappingService {
  static final Map<String, Map<String, String>> _soundDatabase = {
    'peaceful sleep': {
      'id': '1',
      'title': 'Peaceful Sleep',
      'imagePath': 'assets/images/sounds/Peaceful Sleep.png',
      'category': 'Ambient',
    },
    'soft ambient rain': {
      'id': '2',
      'title': 'Soft Ambient Rain',
      'imagePath': 'assets/images/sounds/Soft Ambient Rain.png',
      'category': 'Nature',
    },
    'tibetan bells': {
      'id': '3',
      'title': 'Tibetan Bells',
      'imagePath': 'assets/images/sounds/Tibetan Bell.png',
      'category': 'Meditative',
    },
    'baby lullaby': {
      'id': '4',
      'title': 'Baby Lullaby',
      'imagePath': 'assets/images/sounds/Baby Lullaby.png',
      'category': 'Lullaby',
    },
    'sleep lullaby': {
      'id': '5',
      'title': 'Sleep Lullaby',
      'imagePath': 'assets/images/sounds/Sleep Lullaby.png',
      'category': 'Lullaby',
    },
    'ethereal journey': {
      'id': '6',
      'title': 'Ethereal Journey',
      'imagePath': 'assets/images/sounds/Ethereal Journey.png',
      'category': 'Melodic',
    },
    'midnight calm': {
      'id': '7',
      'title': 'Midnight Calm',
      'imagePath': 'assets/images/sounds/Midnight Calm.png',
      'category': 'Melodic',
    },
    'twilight dreams': {
      'id': '8',
      'title': 'Twilight Dreams',
      'imagePath': 'assets/images/sounds/Twilight Dreams.png',
      'category': 'Melodic',
    },
    'forest whispers': {
      'id': '9',
      'title': 'Forest Whispers',
      'imagePath': 'assets/images/sounds/Forest Whispers.png',
      'category': 'Nature',
    },
    'starlight serenade': {
      'id': '10',
      'title': 'Starlight Serenade',
      'imagePath': 'assets/images/sounds/Starlight Serenade.png',
      'category': 'Melodic',
    },
  };

  /// Get full sound metadata from sound name
  static Map<String, String>? getSoundMetadata(String soundName) {
    final normalized = soundName.toLowerCase().trim();
    return _soundDatabase[normalized];
  }

  /// Check if a sound exists
  static bool soundExists(String soundName) {
    return _soundDatabase.containsKey(soundName.toLowerCase().trim());
  }
}
