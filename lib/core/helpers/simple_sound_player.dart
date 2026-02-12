import 'package:azan/core/utils/extenstions.dart';
import 'package:just_audio/just_audio.dart';

class SimpleSoundPlayer {
  static final SimpleSoundPlayer _instance = SimpleSoundPlayer._internal();
  factory SimpleSoundPlayer() => _instance;

  SimpleSoundPlayer._internal();

  final AudioPlayer _player = AudioPlayer();
  int _token = 0;
  bool _isPlaying = false;

  Future<bool> playAsset(String path) async => _playAsset(path);

  Future<void> stop() async {
    _token++;
    _isPlaying = false;
    try {
      await _player.stop();
    } catch (e) {
      '❌ Error stopping player: $e'.log();
    }
  }

  Future<bool> _playAsset(String path) async {
    final int myToken = ++_token;

    try {
      // ✅ تحقق أولاً قبل أي عملية طويلة
      if (myToken != _token) {
        '⚠️ Token changed, aborting play'.log();
        return false;
      }

      // ✅ تحقق من الـ path
      if (path.isEmpty || path == 'null') {
        '❌ Invalid asset path: $path'.log();
        return false;
      }

      await _player.stop();

      // ✅ تحقق مرة أخرى بعد stop (الأهم!)
      if (myToken != _token) {
        '⚠️ Token changed after stop, aborting'.log();
        return false;
      }

      await _player.setAsset(path);

      // ✅ تحقق مرة أخرى بعد setAsset
      if (myToken != _token) {
        '⚠️ Token changed after setAsset, aborting'.log();
        return false;
      }

      '✅ Starting audio play: $path'.log();
      _isPlaying = true;
      await _player.play();

      '✅ Audio started successfully'.log();
      return true;
    } catch (e, st) {
      '❌ Error playing audio: $e\n$st'.log();
      _isPlaying = false;
      return false;
    }
  }

  Future<void> dispose() async {
    try {
      await stop();
      await _player.dispose();
    } catch (e) {
      '❌ Error disposing player: $e'.log();
    }
  }
}
