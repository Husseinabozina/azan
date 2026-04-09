import 'package:azan/core/models/prayer_calendar_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PrayerCalendarDay', () {
    test('serializes and deserializes sparse overrides', () {
      final day =
          PrayerCalendarDay.generated(
                cityKey: '21.4235,39.8262',
                date: DateTime(2026, 3, 25),
                generatedAdhanMinutes: [300, 360, 720, 915, 1080, 1170],
              )
              .withPrayerOverride(
                prayerId: 1,
                manualAdhanMinutes: 302,
                manualIqamaMinutes: 315,
              )
              .withPrayerOverride(prayerId: 3, manualIqamaMinutes: 745);

      final restored = PrayerCalendarDay.fromMap(day.toMap());

      expect(restored.cityKey, day.cityKey);
      expect(restored.gregorianYmd, day.gregorianYmd);
      expect(restored.generatedAdhanMinutes, day.generatedAdhanMinutes);
      expect(restored.manualAdhanMinutesByPrayerId[1], 302);
      expect(restored.manualIqamaMinutesByPrayerId[1], 315);
      expect(restored.manualIqamaMinutesByPrayerId[3], 745);
      expect(restored.manualAdhanMinutesByPrayerId.containsKey(3), isFalse);
    });

    test('clear operations remove only requested overrides', () {
      final seeded =
          PrayerCalendarDay.generated(
                cityKey: 'city',
                date: DateTime(2026, 3, 25),
                generatedAdhanMinutes: [1, 2, 3, 4, 5, 6],
              )
              .withPrayerOverride(
                prayerId: 2,
                manualAdhanMinutes: 99,
                manualIqamaMinutes: 120,
              )
              .withPrayerOverride(
                prayerId: 5,
                manualAdhanMinutes: 88,
                manualIqamaMinutes: 140,
              );

      final singleCleared = seeded.clearPrayerOverrides(2);
      expect(singleCleared.hasPrayerOverride(2), isFalse);
      expect(singleCleared.hasPrayerOverride(5), isTrue);

      final allCleared = seeded.clearAllOverrides();
      expect(allCleared.hasManualOverrides, isFalse);
    });
  });
}
