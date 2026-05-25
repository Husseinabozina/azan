import 'package:azan/core/helpers/azan_adjust_model.dart';
import 'package:azan/core/helpers/prayer_calendar_helper.dart';
import 'package:azan/core/models/city_option.dart';
import 'package:azan/core/models/gregorian_coverage_window.dart';
import 'package:azan/core/models/latlng.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jhijri/_src/_jHijri.dart';

void main() {
  group('PrayerCalendarHelper', () {
    test('currentHijriYearRange wraps the displayed Hijri year', () {
      final now = DateTime(2026, 3, 25);
      final range = PrayerCalendarHelper.currentHijriYearRange(
        now: now,
        offsetDays: 0,
      );

      final todayHijri = PrayerCalendarHelper.hijriPartsForDate(
        now,
        offsetDays: 0,
        langCode: 'en',
      );
      final firstDayHijri = PrayerCalendarHelper.hijriPartsForDate(
        range.startInclusive,
        offsetDays: 0,
        langCode: 'en',
      );

      expect(todayHijri.year, range.hijriYear);
      expect(firstDayHijri.year, range.hijriYear);
      expect(firstDayHijri.month, 1);
      expect(firstDayHijri.day, 1);
      expect(
        !now.isBefore(range.startInclusive) && now.isBefore(range.endExclusive),
        isTrue,
      );
    });

    test('cityKeyFor prefers rounded coordinates', () {
      final city = CityOption(
        nameAr: 'الدمام',
        nameEn: 'Dammam',
        lat: 26.4207,
        lon: 50.0888,
        bundleId: 'dammam',
      );

      expect(PrayerCalendarHelper.cityKeyFor(city: city), 'bundle::dammam');
      expect(
        PrayerCalendarHelper.cityKeyFor(
          coordinates: LatLng(21.423456, 39.826789),
        ),
        '21.4235,39.8268',
      );
    });

    test(
      'azanAdjustmentMinutesForPrayer is date-aware for Ramadan and shifts',
      () {
        final ramadanStart = JHijri(fYear: 1447, fMonth: 9, fDay: 1).dateTime;
        const settings = AzanAdjustSettings(
          summerPlusHour: false,
          ramadanIshaPlus30: true,
          manualAllShiftMinutes: 2,
          perPrayerMinutes: [1, 0, 0, 0, 0, 3],
        );

        final minutes = PrayerCalendarHelper.azanAdjustmentMinutesForPrayer(
          prayerKey: 'isha',
          date: ramadanStart,
          settings: settings,
          offsetDays: 0,
        );

        expect(minutes, 35);
      },
    );

    test('supported window is Hijri-first and keeps past days read-only', () {
      final now = DateTime(2026, 5, 24);
      final window = PrayerCalendarHelper.currentSupportedScheduleWindow(
        now: now,
        offsetDays: 0,
      );

      final startHijri = PrayerCalendarHelper.hijriPartsForDate(
        window.startInclusive,
        offsetDays: 0,
        langCode: 'en',
      );
      final anchorHijri = PrayerCalendarHelper.hijriPartsForDate(
        window.gregorianForwardAnchorInclusive,
        offsetDays: 0,
        langCode: 'en',
      );
      final endHijri = PrayerCalendarHelper.hijriPartsForDate(
        window.endInclusive,
        offsetDays: 0,
        langCode: 'en',
      );

      expect(window.todayGregorian, now);
      expect(startHijri.year, window.currentHijriYear);
      expect(startHijri.month, 1);
      expect(startHijri.day, 1);
      expect(anchorHijri.year, window.finalSupportedHijriYear);
      expect(endHijri.year, window.finalSupportedHijriYear);
      expect(window.supportedHijriYears.first, window.currentHijriYear);
      expect(window.supportedHijriYears.last, window.finalSupportedHijriYear);
      expect(
        PrayerCalendarHelper.isDateSelectable(now, now: now, offsetDays: 0),
        isTrue,
      );
      expect(
        PrayerCalendarHelper.availabilityStateForDate(
          now.subtract(const Duration(days: 1)),
          now: now,
          offsetDays: 0,
        ),
        DateAvailabilityState.pastReadOnly,
      );
      expect(
        PrayerCalendarHelper.availabilityStateForDate(
          window.endInclusive.add(const Duration(days: 1)),
          now: now,
          offsetDays: 0,
        ),
        DateAvailabilityState.outOfRange,
      );
    });

    test(
      'defaultIqamaMinutesForDate applies Friday dhuhr override only on Friday',
      () {
        final friday = DateTime(2026, 3, 27);
        final saturday = DateTime(2026, 3, 28);
        final base = [10, 10, 12, 15, 10, 10];

        expect(
          PrayerCalendarHelper.defaultIqamaMinutesForDate(
            baseIqamaMinutes: base,
            date: friday,
            fridayMinutes: 25,
          )[2],
          25,
        );
        expect(
          PrayerCalendarHelper.defaultIqamaMinutesForDate(
            baseIqamaMinutes: base,
            date: saturday,
            fridayMinutes: 25,
          )[2],
          12,
        );
      },
    );
  });
}
