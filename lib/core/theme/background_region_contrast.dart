import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackgroundRegionPalette {
  const BackgroundRegionPalette({
    required this.foreground,
    required this.shadows,
  });

  final Color foreground;
  final List<Shadow> shadows;
}

class BackgroundRegionContrast {
  BackgroundRegionContrast._();

  static const Color _darkText = Color(0xFF2F2115);
  static const Color _lightText = Color(0xFFF7F1E5);
  static const Color _goldText = Color(0xFFFFD77A);

  static final Map<String, Future<BackgroundRegionPalette>> _topBandCache = {};
  static final Map<String, Future<BackgroundRegionPalette>> _regionCache = {};

  static BackgroundRegionPalette fallback(Color foreground) {
    return BackgroundRegionPalette(
      foreground: foreground,
      shadows: _shadowsFor(foreground),
    );
  }

  static Future<BackgroundRegionPalette> topBandPalette(
    String assetPath, {
    required Color fallbackForeground,
    double topFraction = 0.20,
  }) {
    final normalized = assetPath.replaceAll('\\', '/');
    final cacheKey = '$normalized:${topFraction.toStringAsFixed(2)}';
    return _topBandCache.putIfAbsent(cacheKey, () async {
      try {
        final sample = await _sampleAssetTopBand(
          normalized,
          topFraction: topFraction,
        );
        final foreground = _bestReadableColor(
          sample,
          preferred: fallbackForeground,
        );
        return BackgroundRegionPalette(
          foreground: foreground,
          shadows: _shadowsFor(foreground),
        );
      } catch (_) {
        return fallback(fallbackForeground);
      }
    });
  }

  static Future<BackgroundRegionPalette> appBarTitlePalette(
    String assetPath, {
    required Color fallbackForeground,
  }) {
    return regionPalette(
      assetPath,
      fallbackForeground: fallbackForeground,
      leftFraction: 0.18,
      topFraction: 0.025,
      rightFraction: 0.82,
      bottomFraction: 0.145,
    );
  }

  static Future<BackgroundRegionPalette> regionPalette(
    String assetPath, {
    required Color fallbackForeground,
    required double leftFraction,
    required double topFraction,
    required double rightFraction,
    required double bottomFraction,
  }) {
    final normalized = assetPath.replaceAll('\\', '/');
    final regionKey =
        [normalized, leftFraction, topFraction, rightFraction, bottomFraction]
            .map((value) {
              if (value is double) return value.toStringAsFixed(3);
              return value.toString();
            })
            .join(':');

    return _regionCache.putIfAbsent(regionKey, () async {
      try {
        final sample = await _sampleAssetRegion(
          normalized,
          leftFraction: leftFraction,
          topFraction: topFraction,
          rightFraction: rightFraction,
          bottomFraction: bottomFraction,
        );
        final foreground = _bestReadableColor(
          sample,
          preferred: fallbackForeground,
        );
        return BackgroundRegionPalette(
          foreground: foreground,
          shadows: _shadowsFor(foreground),
        );
      } catch (_) {
        return fallback(fallbackForeground);
      }
    });
  }

  static Future<Color> _sampleAssetTopBand(
    String assetPath, {
    required double topFraction,
  }) async {
    return _sampleAssetRegion(
      assetPath,
      leftFraction: 0,
      topFraction: 0,
      rightFraction: 1,
      bottomFraction: topFraction,
    );
  }

  static Future<Color> _sampleAssetRegion(
    String assetPath, {
    required double leftFraction,
    required double topFraction,
    required double rightFraction,
    required double bottomFraction,
  }) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 96,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return Colors.black;

    final bytes = byteData.buffer.asUint8List();
    final width = image.width;
    final height = image.height;
    final left = (width * leftFraction.clamp(0.0, 1.0)).floor();
    final right = (width * rightFraction.clamp(0.0, 1.0)).ceil();
    final top = (height * topFraction.clamp(0.0, 1.0)).floor();
    final bottom = (height * bottomFraction.clamp(0.0, 1.0)).ceil();
    final xStart = left.clamp(0, math.max(0, width - 1)).toInt();
    final xEnd = right.clamp(xStart + 1, width).toInt();
    final yStart = top.clamp(0, math.max(0, height - 1)).toInt();
    final yEnd = bottom.clamp(yStart + 1, height).toInt();

    var red = 0.0;
    var green = 0.0;
    var blue = 0.0;
    var weight = 0.0;

    for (var y = yStart; y < yEnd; y++) {
      for (var x = xStart; x < xEnd; x++) {
        final offset = ((y * width) + x) * 4;
        final alpha = bytes[offset + 3] / 255.0;
        if (alpha <= 0.02) continue;
        red += bytes[offset] * alpha;
        green += bytes[offset + 1] * alpha;
        blue += bytes[offset + 2] * alpha;
        weight += alpha;
      }
    }

    if (weight <= 0) return Colors.black;

    return Color.fromARGB(
      255,
      (red / weight).round().clamp(0, 255),
      (green / weight).round().clamp(0, 255),
      (blue / weight).round().clamp(0, 255),
    );
  }

  static Color _bestReadableColor(
    Color background, {
    required Color preferred,
  }) {
    final candidates = <Color>[
      preferred,
      _lightText,
      _darkText,
      _goldText,
      Colors.white,
      Colors.black,
    ];

    var best = candidates.first;
    var bestScore = _contrastRatio(best, background);
    for (final candidate in candidates.skip(1)) {
      final score = _contrastRatio(candidate, background);
      if (score > bestScore) {
        best = candidate;
        bestScore = score;
      }
    }

    return bestScore >= 4.5
        ? best
        : _contrastRatio(Colors.white, background) >
              _contrastRatio(Colors.black, background)
        ? Colors.white
        : Colors.black;
  }

  static List<Shadow> _shadowsFor(Color foreground) {
    final isLight =
        ThemeData.estimateBrightnessForColor(foreground) == Brightness.light;
    if (isLight) {
      return const [
        Shadow(color: Color(0xCC000000), offset: Offset(0, 1.5), blurRadius: 5),
        Shadow(color: Color(0x66000000), offset: Offset(0, 0), blurRadius: 8),
      ];
    }

    return const [
      Shadow(color: Color(0x99FFFFFF), offset: Offset(0, 1), blurRadius: 3),
      Shadow(color: Color(0x55000000), offset: Offset(0, 2), blurRadius: 5),
    ];
  }

  static double _contrastRatio(Color a, Color b) {
    final l1 = a.computeLuminance();
    final l2 = b.computeLuminance();
    final bright = math.max(l1, l2);
    final dark = math.min(l1, l2);
    return (bright + 0.05) / (dark + 0.05);
  }
}
