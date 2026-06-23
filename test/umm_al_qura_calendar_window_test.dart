import 'package:azan/core/helpers/prayer_calendar_helper.dart';
import 'package:azan/core/models/gregorian_coverage_window.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'supported window spans current Hijri year through final Hijri year',
    () {
      final window = PrayerCalendarHelper.currentSupportedScheduleWindow(
        now: DateTime(2026, 5, 24),
        offsetDays: 0,
      );

      expect(window.todayGregorian, DateTime(2026, 5, 24));
      expect(window.gregorianForwardAnchorInclusive, DateTime(2031, 12, 31));
      expect(window.supportedHijriYears.first, window.currentHijriYear);
      expect(window.supportedHijriYears.last, window.finalSupportedHijriYear);
      expect(window.supportedHijriYears, isNotEmpty);
    },
  );

  test(
    'availability distinguishes past read-only, selectable, and out of range',
    () {
      final window = PrayerCalendarHelper.currentSupportedScheduleWindow(
        now: DateTime(2026, 5, 24),
        offsetDays: 0,
      );

      expect(
        window.availabilityFor(DateTime(2026, 5, 23)),
        DateAvailabilityState.pastReadOnly,
      );
      expect(
        window.availabilityFor(DateTime(2026, 5, 24)),
        DateAvailabilityState.selectable,
      );
      expect(
        window.availabilityFor(window.endInclusive),
        DateAvailabilityState.selectable,
      );
      expect(
        window.availabilityFor(
          window.endInclusive.add(const Duration(days: 1)),
        ),
        DateAvailabilityState.outOfRange,
      );
    },
  );
}
