import 'package:azan/core/models/prayer.dart';
import 'package:azan/views/home/components/next_prayer_row_highlight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('matches the next prayer when id and day are the same', () {
    final prayer = Prayer(
      id: 6,
      title: 'العشاء',
      time: '08:06 PM',
      time24: '20:06',
      dateTime: DateTime(2026, 6, 20, 20, 6),
    );

    final nextPrayer = Prayer(
      id: 6,
      title: 'العشاء',
      time: '08:06 PM',
      time24: '20:06',
      dateTime: DateTime(2026, 6, 20, 20, 6),
    );

    expect(isNextPrayerRow(prayer, nextPrayer), isTrue);
  });

  test('matches tomorrow fajr against the visible fajr row after isha', () {
    final todayFajr = Prayer(
      id: 1,
      title: 'الفجر',
      time: '03:14 AM',
      time24: '03:14',
      dateTime: DateTime(2026, 6, 20, 3, 14),
    );

    final tomorrowFajr = Prayer(
      id: 1,
      title: 'الفجر',
      time: '03:15 AM',
      time24: '03:15',
      dateTime: DateTime(2026, 6, 21, 3, 15),
    );

    expect(isNextPrayerRow(todayFajr, tomorrowFajr), isTrue);
  });

  test('does not wrap non-fajr prayers across days', () {
    final todayIsha = Prayer(
      id: 6,
      title: 'العشاء',
      time: '08:06 PM',
      time24: '20:06',
      dateTime: DateTime(2026, 6, 20, 20, 6),
    );

    final tomorrowIsha = Prayer(
      id: 6,
      title: 'العشاء',
      time: '08:07 PM',
      time24: '20:07',
      dateTime: DateTime(2026, 6, 21, 20, 7),
    );

    expect(isNextPrayerRow(todayIsha, tomorrowIsha), isFalse);
  });
}
