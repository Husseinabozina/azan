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

    test('morning loader filters manually selected prayer windows', () async {
      const customText = 'ذكر صباح يظهر بعد الظهر للاختبار';
      await ManagedAzkarHiveHelper.addEntry(
        type: AzkarType.morning,
        text: customText,
        applicablePrayerIds: const [3],
      );

      final fajrResolved = await loadAzkarSet(AzkarType.morning, prayerId: 1);
      final dhuhrResolved = await loadAzkarSet(AzkarType.morning, prayerId: 3);

      expect(
        fajrResolved.entries.any((entry) => entry.text == customText),
        isFalse,
      );
      expect(
        dhuhrResolved.entries.any((entry) => entry.text == customText),
        isTrue,
      );
    });

    test('evening loader filters manually selected prayer windows', () async {
      const customText = 'ذكر مساء يظهر بعد العصر للاختبار';
      await ManagedAzkarHiveHelper.addEntry(
        type: AzkarType.evening,
        text: customText,
        applicablePrayerIds: const [4],
      );

      final maghribResolved = await loadAzkarSet(
        AzkarType.evening,
        prayerId: 5,
      );
      final asrResolved = await loadAzkarSet(AzkarType.evening, prayerId: 4);

      expect(
        maghribResolved.entries.any((entry) => entry.text == customText),
        isFalse,
      );
      expect(
        asrResolved.entries.any((entry) => entry.text == customText),
        isTrue,
      );
    });

    test('loader returns manual order after prayer filtering', () async {
      const firstText = 'ذكر صباح مرتب أول';
      const secondText = 'ذكر صباح مرتب ثاني';
      final first = await ManagedAzkarHiveHelper.addEntry(
        type: AzkarType.morning,
        text: firstText,
        applicablePrayerIds: const [3],
      );
      final second = await ManagedAzkarHiveHelper.addEntry(
        type: AzkarType.morning,
        text: secondText,
        applicablePrayerIds: const [3],
      );

      await ManagedAzkarHiveHelper.moveEntryWithinType(
        type: AzkarType.morning,
        entryId: second.id,
        delta: -1,
      );

      final resolved = await loadAzkarSet(AzkarType.morning, prayerId: 3);
      expect(resolved.entries.map((entry) => entry.text), [
        second.text,
        first.text,
      ]);
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
          resolved.entries[0].description,
          'الاستغفار والتسبيح بعد الصلاة',
        );
        expect(resolved.entries[4].description, 'آية الكرسي بعد كل صلاة');
        expect(
          resolved.entries[5].description,
          'المعوذات بعد كل صلاة، وتكرر بعد الفجر والمغرب ثلاث مرات',
        );
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
