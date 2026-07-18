import 'package:azan/views/additional_settings/components/azkar_time_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AzkarTimeHelper', () {
    test('Friday after-prayer window uses Friday iqama offset', () {
      final fridayAdhan = DateTime(2026, 3, 27, 12, 5);

      final start = AzkarTimeHelper.startAfterPrayerTime(
        adhanTime: fridayAdhan,
        prayerId: AzkarTimeHelper.fridayId,
        baseIqamaOffsetMinutes: 10,
        fridayIqamaOffsetMinutes: 35,
        prayerDurationMinutes: 7,
      );

      expect(start, DateTime(2026, 3, 27, 12, 47));
    });

    test('Friday date with dhuhr scope keeps regular dhuhr offset', () {
      final fridayAdhan = DateTime(2026, 3, 27, 12, 5);

      final start = AzkarTimeHelper.startAfterPrayerTime(
        adhanTime: fridayAdhan,
        prayerId: AzkarTimeHelper.dhuhrId,
        baseIqamaOffsetMinutes: 10,
        fridayIqamaOffsetMinutes: 35,
        prayerDurationMinutes: 7,
      );

      expect(start, DateTime(2026, 3, 27, 12, 22));
    });

    test('non-Friday dhuhr after-prayer window keeps regular iqama offset', () {
      final saturdayAdhan = DateTime(2026, 3, 28, 12, 5);

      final start = AzkarTimeHelper.startAfterPrayerTime(
        adhanTime: saturdayAdhan,
        prayerId: AzkarTimeHelper.dhuhrId,
        baseIqamaOffsetMinutes: 10,
        fridayIqamaOffsetMinutes: 35,
        prayerDurationMinutes: 7,
      );

      expect(start, DateTime(2026, 3, 28, 12, 22));
    });
  });
}
