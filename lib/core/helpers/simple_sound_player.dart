import 'package:just_audio/just_audio.dart';

class SimpleSoundPlayer {
  static final SimpleSoundPlayer _instance = SimpleSoundPlayer._internal();
  factory SimpleSoundPlayer() => _instance;

  SimpleSoundPlayer._internal();

  final AudioPlayer _player = AudioPlayer();
  int _token = 0;
  bool _isPlaying = false;
  Duration? _lastLoadedDuration;

  Duration? get lastLoadedDuration => _player.duration ?? _lastLoadedDuration;

  Future<bool> playAsset(String path) async => _playAsset(path);

  Future<void> stop() async {
    _token++;
    _isPlaying = false;
    try {
      await _player.stop();
    } catch (e) {}
  }

  Future<bool> _playAsset(String path) async {
    final int myToken = ++_token;

    try {
      // ✅ تحقق أولاً قبل أي عملية طويلة
      if (myToken != _token) {
        return false;
      }

      // ✅ تحقق من الـ path
      if (path.isEmpty || path == 'null') {
        return false;
      }

      _lastLoadedDuration = null;
      await _player.stop();

      // ✅ تحقق مرة أخرى بعد stop (الأهم!)
      if (myToken != _token) {
        return false;
      }

      await _player.setAsset(path);
      _lastLoadedDuration = _player.duration;

      // ✅ تحقق مرة أخرى بعد setAsset
      if (myToken != _token) {
        return false;
      }

      _isPlaying = true;
      await _player.play();
      if (myToken == _token) {
        _isPlaying = false;
      }

      return true;
    } catch (e, st) {
      _isPlaying = false;
      return false;
    }
  }

  Future<void> dispose() async {
    try {
      await stop();
    } catch (e) {}
  }
}
