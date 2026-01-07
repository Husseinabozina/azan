import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum DeviceKind { phone, tablet, tv, desktop, web }

class DeviceKindHelper {
  static const MethodChannel _channel = MethodChannel('azan/device_kind');

  // تقدر تعدّل الأرقام دي حسب شاشاتك
  static const double _tabletDpThreshold = 600; // Tablet
  static const double _tvDpThreshold = 900; // TV fallback (شاشة كبيرة جدًا)

  /// ✅ تشتغل قبل runApp (بدون BuildContext)
  static Future<DeviceKind> detectBeforeRunApp() async {
    if (kIsWeb) return DeviceKind.web;

    final platform = defaultTargetPlatform;

    // Desktop platforms
    if (platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux) {
      return DeviceKind.desktop;
    }

    // احسب dp قبل runApp
    final view = PlatformDispatcher.instance.views.first;
    final shortestPx = view.physicalSize.shortestSide;
    final dpr = view.devicePixelRatio;
    final shortestDp = shortestPx / dpr;

    // Android TV detection (الأدق)
    if (platform == TargetPlatform.android) {
      final isTv = await _isAndroidTv();
      if (isTv) return DeviceKind.tv;

      // ✅ Fallback: لو الشاشة كبيرة جدًا اعتبره TV
      if (shortestDp >= _tvDpThreshold) return DeviceKind.tv;
    }

    // Phone vs Tablet
    return shortestDp >= _tabletDpThreshold
        ? DeviceKind.tablet
        : DeviceKind.phone;
  }

  static Future<bool> _isAndroidTv() async {
    try {
      final res = await _channel.invokeMethod<bool>('isAndroidTv');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }
}
