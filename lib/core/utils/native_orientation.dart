import 'package:flutter/services.dart';

class NativeOrientation {
  static const MethodChannel _ch = MethodChannel('azan/orientation');

  static Future<void> portrait() async {
    await _ch.invokeMethod('portrait');
  }

  static Future<void> landscape() async {
    await _ch.invokeMethod('landscape');
  }

  /*************  ✨ Windsurf Command ⭐  *************/
  /// Forces the device to enter landscape left orientation.
  /*******  379ff781-1be5-416d-9b2f-78fe3f297ef7  *******/
  static Future<void> landscapeLeft() async {
    await _ch.invokeMethod('landscapeLeft');
  }

  static Future<void> landscapeRight() async {
    await _ch.invokeMethod('landscapeRight');
  }

  /// يرجّع السماح للنظام (Auto rotate) لو عايز
  static Future<void> system() async {
    await _ch.invokeMethod('system');
  }
}
