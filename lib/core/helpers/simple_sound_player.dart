import 'package:just_audio/just_audio.dart';

class SimpleSoundPlayer {
  static final SimpleSoundPlayer _instance = SimpleSoundPlayer._internal();
  factory SimpleSoundPlayer() => _instance;

  SimpleSoundPlayer._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playAdhanPing(String azanSource) async {
    await _playAsset(azanSource);
  }

  Future<void> playIqamaPing(String iqamaSource) async {
    await _playAsset(iqamaSource);
  }

  Future<void> _playAsset(String path) async {
    try {
      await _player.setAsset(path);
      await _player.play();
    } catch (e) {
      // ما نكسّرش الأبلكيشن لو في مشكلة في الصوت
      // تقدر تستبدلها بـ log حسب ما تحب
      // debugPrint('Error playing sound: $e');
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
