import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/sleep_sound.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  SleepSound? _currentSound;
  Timer? _sleepTimer;
  final _controller = StreamController<SleepSound?>.broadcast();

  Stream<SleepSound?> get currentSoundStream => _controller.stream;
  SleepSound? get currentSound => _currentSound;
  bool get isPlaying => _player.playing;
  Stream<bool> get isPlayingStream => _player.playingStream;
  Stream<Duration?> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Future<void> play(SleepSound sound) async {
    if (_currentSound?.id == sound.id && _player.playing) {
      return;
    }

    try {
      _currentSound = sound;
      _controller.add(_currentSound);

      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse('asset:///${sound.assetPath}'),
          tag: MediaItem(
            id: sound.id,
            album: "Sleep Sounds",
            title: sound.title,
            artUri: sound.imagePath != null
                ? Uri.parse(sound.imagePath!)
                : null,
          ),
        ),
      );
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
    _currentSound = null;
    _controller.add(null);
    _cancelTimer();
  }

  void setSleepTimer(Duration duration) {
    _cancelTimer();
    _sleepTimer = Timer(duration, () async {
      await _fadeOutAndStop();
    });
  }

  void _cancelTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
  }

  Future<void> _fadeOutAndStop() async {
    const steps = 20;
    final interval = const Duration(milliseconds: 100);
    final initialVolume = _player.volume;
    final stepVolume = initialVolume / steps;

    for (var i = 0; i < steps; i++) {
      await Future.delayed(interval);
      final newVolume = (initialVolume - (stepVolume * (i + 1))).clamp(
        0.0,
        1.0,
      );
      await _player.setVolume(newVolume);
    }

    await stop();
    await _player.setVolume(initialVolume);
  }

  void dispose() {
    _player.dispose();
    _controller.close();
    _cancelTimer();
  }
}
