import 'dart:io';

import 'package:azan/core/helpers/managed_azkar_hive_helper.dart';
import 'package:azan/core/models/azkar_type.dart';
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
          text: 'ذكر بعد الصلاة للاختبار',
          applicablePrayerIds: const [3],
        );

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
            text: 'ذكر بعد الصلاة بعد التعديل',
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
  });
}
