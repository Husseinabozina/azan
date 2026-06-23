import 'dart:io';

import 'package:azan/core/helpers/managed_azkar_hive_helper.dart';
import 'package:azan/core/models/azkar_type.dart';
import 'package:azan/core/models/managed_azkar_entry.dart';
import 'package:azan/data/data/after_prayers_azkar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('ManagedAzkarHiveHelper', () {
    late Directory tempDir;

    setUp(() async {
      await Hive.close();
      tempDir = await Directory.systemTemp.createTemp('managed_azkar_hive');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('seeding creates the default sets only once', () async {
      await ManagedAzkarHiveHelper.ensureInitialAzkarSets();

      final firstMorning = (await ManagedAzkarHiveHelper.getEntriesForType(
        AzkarType.morning,
        activeOnly: false,
      )).first;
      expect(firstMorning.text, isNotEmpty);

      await ManagedAzkarHiveHelper.updateEntry(
        firstMorning.copyWith(text: 'ذكر صباح معدل للاختبار'),
      );
      await ManagedAzkarHiveHelper.ensureInitialAzkarSets();

      final updatedMorning = (await ManagedAzkarHiveHelper.getEntriesForType(
        AzkarType.morning,
        activeOnly: false,
      )).first;
      expect(updatedMorning.text, 'ذكر صباح معدل للاختبار');
    });

    test(
      'supports add update and delete for managed after-prayer entries',
      () async {
        await ManagedAzkarHiveHelper.ensureInitialAzkarSets();

        final created = await ManagedAzkarHiveHelper.addEntry(
          type: AzkarType.afterPrayer,
          text: '\u200F  ذكر بعد الصلاة للاختبار  \u200E',
          applicablePrayerIds: const [3],
        );
        expect(created.text, 'ذكر بعد الصلاة للاختبار');

        final afterAdd = await ManagedAzkarHiveHelper.getEntriesForType(
          AzkarType.afterPrayer,
          activeOnly: false,
        );
        expect(
          afterAdd.any(
            (entry) => entry.id == created.id && entry.text == created.text,
          ),
          isTrue,
        );
        expect(
          afterAdd
              .firstWhere((entry) => entry.id == created.id)
              .applicablePrayerIds,
          [3],
        );

        await ManagedAzkarHiveHelper.updateEntry(
          created.copyWith(
            text: '\u202B  ذكر بعد الصلاة بعد التعديل  \u202C',
            applicablePrayerIds: const [5],
          ),
        );

        final afterUpdate = await ManagedAzkarHiveHelper.getEntriesForType(
          AzkarType.afterPrayer,
          activeOnly: false,
        );
        final updated = afterUpdate.firstWhere(
          (entry) => entry.id == created.id,
        );
        expect(updated.text, 'ذكر بعد الصلاة بعد التعديل');
        expect(updated.applicablePrayerIds, [5]);

        await ManagedAzkarHiveHelper.deleteEntry(created.id);

        final afterDelete = await ManagedAzkarHiveHelper.getEntriesForType(
          AzkarType.afterPrayer,
          activeOnly: false,
        );
        expect(afterDelete.any((entry) => entry.id == created.id), isFalse);
      },
    );

    test('setActive hides managed entries from active loaders', () async {
      await ManagedAzkarHiveHelper.ensureInitialAzkarSets();

      final firstMorning = (await ManagedAzkarHiveHelper.getEntriesForType(
        AzkarType.morning,
      )).first;

      await ManagedAzkarHiveHelper.setActive(firstMorning.id, false);

      final activeMorning = await ManagedAzkarHiveHelper.getEntriesForType(
        AzkarType.morning,
      );
      final allMorning = await ManagedAzkarHiveHelper.getEntriesForType(
        AzkarType.morning,
        activeOnly: false,
      );

      expect(
        activeMorning.any((entry) => entry.id == firstMorning.id),
        isFalse,
      );
      expect(
        allMorning.firstWhere((entry) => entry.id == firstMorning.id).active,
        isFalse,
      );
    });

    test(
      'addEntry inserts new items after the last item in the same type',
      () async {
        final box = await Hive.openBox('managed_azkar_box');
        await box.put('items', [
          const ManagedAzkarEntry(
            id: 1,
            setType: AzkarType.morning,
            text: 'صباح 1',
          ).toMap(),
          const ManagedAzkarEntry(
            id: 2,
            setType: AzkarType.evening,
            text: 'مساء 1',
          ).toMap(),
        ]);

        await ManagedAzkarHiveHelper.addEntry(
          type: AzkarType.morning,
          text: 'صباح 2',
        );

        final all = await ManagedAzkarHiveHelper.getAllEntries();
        expect(all.map((entry) => entry.text), ['صباح 1', 'صباح 2', 'مساء 1']);
      },
    );

    test('moveEntryWithinType reorders only the selected type', () async {
      final box = await Hive.openBox('managed_azkar_box');
      await box.put('items', [
        const ManagedAzkarEntry(
          id: 1,
          setType: AzkarType.morning,
          text: 'صباح 1',
        ).toMap(),
        const ManagedAzkarEntry(
          id: 2,
          setType: AzkarType.evening,
          text: 'مساء ثابت',
        ).toMap(),
        const ManagedAzkarEntry(
          id: 3,
          setType: AzkarType.morning,
          text: 'صباح 2',
        ).toMap(),
        const ManagedAzkarEntry(
          id: 4,
          setType: AzkarType.afterPrayer,
          text: 'بعد الصلاة ثابت',
        ).toMap(),
        const ManagedAzkarEntry(
          id: 5,
          setType: AzkarType.morning,
          text: 'صباح 3',
        ).toMap(),
      ]);

      await ManagedAzkarHiveHelper.moveEntryWithinType(
        type: AzkarType.morning,
        entryId: 3,
        delta: -1,
      );
      var morning = await ManagedAzkarHiveHelper.getEntriesForType(
        AzkarType.morning,
        activeOnly: false,
      );
      expect(morning.map((entry) => entry.text), [
        'صباح 2',
        'صباح 1',
        'صباح 3',
      ]);

      await ManagedAzkarHiveHelper.moveEntryWithinType(
        type: AzkarType.morning,
        entryId: 3,
        delta: -1,
      );
      morning = await ManagedAzkarHiveHelper.getEntriesForType(
        AzkarType.morning,
        activeOnly: false,
      );
      expect(morning.map((entry) => entry.text), [
        'صباح 2',
        'صباح 1',
        'صباح 3',
      ]);

      await ManagedAzkarHiveHelper.moveEntryWithinType(
        type: AzkarType.morning,
        entryId: 1,
        delta: 1,
      );
      morning = await ManagedAzkarHiveHelper.getEntriesForType(
        AzkarType.morning,
        activeOnly: false,
      );
      expect(morning.map((entry) => entry.text), [
        'صباح 2',
        'صباح 3',
        'صباح 1',
      ]);
      expect(
        (await ManagedAzkarHiveHelper.getEntriesForType(
          AzkarType.evening,
          activeOnly: false,
        )).map((entry) => entry.text),
        ['مساء ثابت'],
      );
      expect(
        (await ManagedAzkarHiveHelper.getEntriesForType(
          AzkarType.afterPrayer,
          activeOnly: false,
        )).map((entry) => entry.text),
        ['بعد الصلاة ثابت'],
      );

      await ManagedAzkarHiveHelper.moveEntryToTypeIndex(
        type: AzkarType.morning,
        entryId: 1,
        targetIndex: 0,
      );
      morning = await ManagedAzkarHiveHelper.getEntriesForType(
        AzkarType.morning,
        activeOnly: false,
      );
      expect(morning.map((entry) => entry.text), [
        'صباح 1',
        'صباح 2',
        'صباح 3',
      ]);
    });

    test(
      'sync prayer lookup supports custom morning and evening prayers',
      () async {
        await ManagedAzkarHiveHelper.ensureInitialAzkarSets();

        expect(
          ManagedAzkarHiveHelper.hasActiveEntriesForTypeAndPrayerSync(
            AzkarType.morning,
            1,
          ),
          isTrue,
        );
        expect(
          ManagedAzkarHiveHelper.hasActiveEntriesForTypeAndPrayerSync(
            AzkarType.morning,
            3,
          ),
          isFalse,
        );

        final created = await ManagedAzkarHiveHelper.addEntry(
          type: AzkarType.morning,
          text: 'ذكر صباح بعد الظهر',
          applicablePrayerIds: const [3],
        );

        expect(
          ManagedAzkarHiveHelper.hasActiveEntriesForTypeAndPrayerSync(
            AzkarType.morning,
            3,
          ),
          isTrue,
        );

        await ManagedAzkarHiveHelper.setActive(created.id, false);
        expect(
          ManagedAzkarHiveHelper.hasActiveEntriesForTypeAndPrayerSync(
            AzkarType.morning,
            3,
          ),
          isFalse,
        );
      },
    );

    test('migrates known after-prayer entries into canonical order', () async {
      final box = await Hive.openBox('managed_azkar_box');
      final firstKnown = afterPrayersAzkar[0]['zekr']!;
      final secondKnown = afterPrayersAzkar[1]['zekr']!;
      final muawidhatKnown = afterPrayersAzkar.firstWhere(
        (raw) => raw['description']!.startsWith('المعوذات'),
      )['zekr']!;
      final legacyMuawidhat = muawidhatKnown.replaceAll(
        '، وتُقْرَأُ بَعْدَ صَلاَتَيِ الفَجْرِ وَالمَغْرِبِ ثَلاثَ مَرَّاتٍ',
        '',
      );
      const customText = 'ذكر مخصص بعد الصلاة';

      await box.put('items', [
        ManagedAzkarEntry(
          id: 1,
          setType: AzkarType.afterPrayer,
          text: secondKnown,
        ).toMap(),
        const ManagedAzkarEntry(
          id: 99,
          setType: AzkarType.afterPrayer,
          text: customText,
        ).toMap(),
        ManagedAzkarEntry(
          id: 3,
          setType: AzkarType.afterPrayer,
          text: legacyMuawidhat,
        ).toMap(),
        ManagedAzkarEntry(
          id: 2,
          setType: AzkarType.afterPrayer,
          text: firstKnown,
        ).toMap(),
      ]);

      await ManagedAzkarHiveHelper.ensureInitialAzkarSets();

      final migrated = await ManagedAzkarHiveHelper.getEntriesForType(
        AzkarType.afterPrayer,
        activeOnly: false,
      );

      expect(migrated[0].text, firstKnown);
      expect(migrated[1].text, secondKnown);
      expect(migrated[2].text, legacyMuawidhat);
      expect(migrated.last.text, customText);
    });
  });
}
