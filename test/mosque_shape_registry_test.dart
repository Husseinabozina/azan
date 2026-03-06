import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/views/home/components/mosque_shape_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy VR backgrounds are fully covered by specs', () {
    expect(legacyVrBackgrounds.length, 20);

    for (final path in legacyVrBackgrounds) {
      final spec = specFor(path);
      expect(spec, isNotNull, reason: 'Missing spec for $path');
      expect(spec!.topBoundary.length, greaterThan(2));
    }
  });

  test('legacy matcher only matches VR-0..VR-19 set', () {
    expect(isLegacyVrBackground('assets/images/VR-2.jpg'), isTrue);
    expect(isLegacyVrBackground('assets/images/vr20.jpg'), isFalse);
    expect(specFor('assets/images/vr20.jpg'), isNull);
  });

  test('shape profile and safe top are valid for all legacy backgrounds', () {
    for (final path in legacyVrBackgrounds) {
      final spec = specFor(path);
      expect(spec, isNotNull, reason: 'Missing spec for $path');
      final widthFactor = spec!.profile == MosqueArchProfile.denseArch
          ? 0.66
          : 0.74;
      final safeTop = spec.safeTopForWidth(widthFactor, margin: 0.02);

      expect(safeTop, greaterThanOrEqualTo(0));
      expect(safeTop, lessThan(1));
      expect(spec.yAt(0.5), inInclusiveRange(0, safeTop));
    }
  });

  test('AppTheme contains explicit packs for VR-0..VR-19', () {
    for (int i = 0; i < 20; i++) {
      final path = 'assets/images/VR-$i.jpg';
      expect(
        AppTheme.hasThemePackForBackground(path),
        isTrue,
        reason: 'Missing ThemePack for $path',
      );
    }
  });

  test('clipper builds a valid path for a non-empty size', () {
    final spec = specFor('assets/images/VR-2.jpg');
    expect(spec, isNotNull);

    final clipper = MosqueBackgroundClipper(spec!);
    final path = clipper.getClip(const Size(1080, 1920));
    final bounds = path.getBounds();

    expect(bounds.width, greaterThan(0));
    expect(bounds.height, greaterThan(0));
  });
}
