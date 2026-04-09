import 'dart:io';

import 'package:azan/core/helpers/managed_azkar_hive_helper.dart';
import 'package:azan/core/models/azkar_type.dart';
import 'package:azan/views/home/components/azkar_content.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('Managed azkar resolver', () {
    late Directory tempDir;

    setUp(() async {
      await Hive.close();
      tempDir = await Directory.systemTemp.createTemp('managed_azkar_resolver');
      Hive.init(tempDir.path);
      await ManagedAzkarHiveHelper.ensureInitialAzkarSets();
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('morning loader returns the morning azkar set', () async {
      final resolved = await loadAzkarSet(AzkarType.morning);

      expect(resolved.title, 'أذكار الصباح');
      expect(resolved.entries, isNotEmpty);
      expect(resolved.entries.first.reference, 'آية الكرسى - البقرة 255');
    });

    test('evening loader returns the evening azkar set', () async {
      final resolved = await loadAzkarSet(AzkarType.evening);

      expect(resolved.title, 'أذكار المساء');
      expect(resolved.entries, isNotEmpty);
      expect(resolved.entries.first.reference, 'آية الكرسى - البقرة 255');
    });

    test('after-prayer loader keeps fajr-specific entries for fajr', () async {
      final resolved = await loadAzkarSet(AzkarType.afterPrayer, prayerId: 1);

      expect(resolved.entries.length, 8);
      expect(
        resolved.entries.any((entry) => entry.reference == 'ابن ماجه'),
        isTrue,
      );
      expect(
        resolved.entries.any(
          (entry) => entry.description == 'بعد صلاة المغرب والصبح',
        ),
        isTrue,
      );
    });

    test(
      'after-prayer loader keeps maghrib shared entry and omits fajr-only entry',
      () async {
        final resolved = await loadAzkarSet(AzkarType.afterPrayer, prayerId: 5);

        expect(resolved.entries.length, 7);
        expect(
          resolved.entries.any(
            (entry) => entry.description == 'بعد صلاة المغرب والصبح',
          ),
          isTrue,
        );
        expect(
          resolved.entries.any((entry) => entry.reference == 'ابن ماجه'),
          isFalse,
        );
      },
    );

    test(
      'after-prayer loader removes fajr and maghrib specifics for other prayers',
      () async {
        final resolved = await loadAzkarSet(AzkarType.afterPrayer, prayerId: 3);

        expect(resolved.entries.length, 6);
        expect(
          resolved.entries.any(
            (entry) => entry.description == 'بعد صلاة المغرب والصبح',
          ),
          isFalse,
        );
        expect(
          resolved.entries.any((entry) => entry.reference == 'ابن ماجه'),
          isFalse,
        );
      },
    );
  });
}
