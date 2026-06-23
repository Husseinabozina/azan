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

  test('inner bounds shrink as inset grows', () {
    final spec = specFor('assets/images/VR-2.jpg');
    expect(spec, isNotNull);

    final base = spec!.innerBoundsAt(0.24);
    final inset = spec.innerBoundsAt(0.24, inset: 0.03);

    expect(inset.width, lessThan(base.width));
    expect(inset.left, greaterThan(base.left));
    expect(inset.right, lessThan(base.right));
  });

  test(
    'meta inset keeps top text bounds more conservative than band inset',
    () {
      final spec = specFor('assets/images/VR-2.jpg');
      expect(spec, isNotNull);

      final bandInset = legacyMosqueBandInset(spec!.profile);
      final metaInset = legacyMosqueBandInset(spec.profile, meta: true);
      final bandBounds = spec.innerBoundsAt(0.24, inset: bandInset);
      final metaBounds = spec.innerBoundsAt(0.24, inset: metaInset);

      expect(metaInset, greaterThan(bandInset));
      expect(metaBounds.width, lessThan(bandBounds.width));
      expect(metaBounds.left, greaterThan(bandBounds.left));
      expect(metaBounds.right, lessThan(bandBounds.right));
    },
  );

  test('larger requested widths push minY downward', () {
    final spec = specFor('assets/images/VR-9.jpg');
    expect(spec, isNotNull);

    final narrow = spec!.minYForInnerWidth(0.24, inset: 0.02);
    final wide = spec.minYForInnerWidth(0.62, inset: 0.02);

    expect(wide, greaterThanOrEqualTo(narrow));
    expect(wide, lessThan(1));
  });

  test('minY is more conservative than safeTop for the same width', () {
    final spec = specFor('assets/images/VR-2.jpg');
    expect(spec, isNotNull);

    final minY = spec!.minYForInnerWidth(0.28, inset: 0.022);
    final safeTop = spec.safeTopForWidth(0.28, margin: 0.006);

    expect(minY, greaterThanOrEqualTo(safeTop));
  });

  test(
    'tightest band bounds are never wider than midpoint bounds for the same band',
    () {
      final spec = specFor('assets/images/VR-2.jpg');
      expect(spec, isNotNull);

      final top = spec!.minYForInnerWidth(0.28, inset: 0.022);
      const height = 0.045;
      final midpoint = spec.innerBoundsAt(top + (height / 2), inset: 0.022);
      final tightest = spec.tightestInnerBoundsForBand(
        top,
        height,
        inset: 0.022,
      );

      expect(tightest.width, lessThanOrEqualTo(midpoint.width));
      expect(tightest.left, greaterThanOrEqualTo(midpoint.left));
      expect(tightest.right, lessThanOrEqualTo(midpoint.right));
    },
  );

  test('apex contour stays nearly flat across the center span', () {
    final dense = specFor('assets/images/VR-2.jpg');
    final wide = specFor('assets/images/VR-9.jpg');
    expect(dense, isNotNull);
    expect(wide, isNotNull);

    final denseApex = dense!.apexY();
    final wideApex = wide!.apexY();

    expect((dense.yAt(0.46) - denseApex).abs(), lessThanOrEqualTo(0.006));
    expect((dense.yAt(0.54) - denseApex).abs(), lessThanOrEqualTo(0.006));
    expect((wide.yAt(0.46) - wideApex).abs(), lessThanOrEqualTo(0.006));
    expect((wide.yAt(0.54) - wideApex).abs(), lessThanOrEqualTo(0.006));
  });

  test(
    'legacy content helpers keep dense profile tighter than wide profile',
    () {
      expect(
        legacyMosqueBodyContentWidthFactor(MosqueArchProfile.denseArch),
        lessThan(
          legacyMosqueBodyContentWidthFactor(MosqueArchProfile.wideArch),
        ),
      );
      expect(
        legacyMosqueBandInset(MosqueArchProfile.denseArch, meta: true),
        greaterThan(legacyMosqueBandInset(MosqueArchProfile.denseArch)),
      );
      expect(
        legacyMosqueBandInset(MosqueArchProfile.wideArch, meta: true),
        greaterThan(legacyMosqueBandInset(MosqueArchProfile.wideArch)),
      );
    },
  );
}
