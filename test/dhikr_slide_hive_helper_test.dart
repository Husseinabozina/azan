import 'dart:io';

import 'package:azan/core/helpers/dhikr_hive_helper.dart';
import 'package:azan/core/helpers/slide_hive_helper.dart';
import 'package:azan/core/models/diker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('Dhikr and slide active toggles', () {
    late Directory tempDir;

    setUp(() async {
      await Hive.close();
      tempDir = await Directory.systemTemp.createTemp('dhikr_slide_hive');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('DhikrHiveHelper.setActive updates stored adhkar', () async {
      await DhikrHiveHelper.ensureInitialAzkar([
        Dhikr(id: 1, text: 'ذكر مسجد للاختبار'),
      ]);

      final created = (await DhikrHiveHelper.getAllDhikr()).first;
      await DhikrHiveHelper.setActive(created.id, false);

      final updated = (await DhikrHiveHelper.getAllDhikr()).first;
      expect(updated.active, isFalse);
    });

    test(
      'SlideHiveHelper.setActive hides slides from active loaders',
      () async {
        await SlideHiveHelper.ensureInitialSlides(['سلايد للاختبار']);

        final created = (await SlideHiveHelper.getAllSlides()).first;
        await SlideHiveHelper.setActive(created.id, false);

        final allSlides = await SlideHiveHelper.getAllSlides();
        final activeSlides = await SlideHiveHelper.getSlidesForDay(
          DateTime.now(),
        );

        expect(allSlides.first.active, isFalse);
        expect(activeSlides, isEmpty);
      },
    );
  });
}
