import 'dart:io';

import 'package:azan/core/helpers/prayer_calendar_hive_helper.dart';
import 'package:azan/core/models/prayer_calendar_day.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('PrayerCalendarHiveHelper', () {
    late Directory tempDir;

    setUp(() async {
      await Hive.close();
      tempDir = await Directory.systemTemp.createTemp('prayer_calendar_test');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('putDay/getDay roundtrip works', () async {
      final day = PrayerCalendarDay.generated(
        cityKey: '21.4235,39.8262',
        date: DateTime(2026, 3, 25),
        generatedAdhanMinutes: [301, 361, 721, 916, 1081, 1171],
      ).withPrayerOverride(prayerId: 6, manualIqamaMinutes: 1190);

      await PrayerCalendarHiveHelper.putDay(day);
      final restored = await PrayerCalendarHiveHelper.getDay(
        cityKey: day.cityKey,
        date: day.gregorianDate,
      );

      expect(restored, isNotNull);
      expect(restored!.generatedAdhanMinutes[0], 301);
      expect(restored.manualIqamaMinutesByPrayerId[6], 1190);
    });

    test(
      'getExistingYmdsInRange returns only stored dates for the city',
      () async {
        await PrayerCalendarHiveHelper.putDays([
          PrayerCalendarDay.generated(
            cityKey: 'city-a',
            date: DateTime(2026, 3, 25),
            generatedAdhanMinutes: [1, 2, 3, 4, 5, 6],
          ),
          PrayerCalendarDay.generated(
            cityKey: 'city-a',
            date: DateTime(2026, 3, 26),
            generatedAdhanMinutes: [1, 2, 3, 4, 5, 6],
          ),
          PrayerCalendarDay.generated(
            cityKey: 'city-b',
            date: DateTime(2026, 3, 25),
            generatedAdhanMinutes: [1, 2, 3, 4, 5, 6],
          ),
        ]);

        final ymds = await PrayerCalendarHiveHelper.getExistingYmdsInRange(
          cityKey: 'city-a',
          startInclusive: DateTime(2026, 3, 25),
          endExclusive: DateTime(2026, 3, 28),
        );

        expect(ymds, {'2026-03-25', '2026-03-26'});
      },
    );
  });
}
