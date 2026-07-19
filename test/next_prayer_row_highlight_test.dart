import 'package:azan/core/models/prayer.dart';
import 'package:azan/views/home/components/next_prayer_row_highlight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Prayer prayer({
    required int id,
    required String title,
    required DateTime dateTime,
  }) {
    return Prayer(id: id, title: title, time: '00:00', dateTime: dateTime);
  }

  test('matches the next prayer when id and day are the same', () {
    final isha = prayer(
      id: 6,
      title: 'العشاء',
      dateTime: DateTime(2026, 6, 20, 20, 6),
    );

    final nextIsha = prayer(
      id: 6,
      title: 'العشاء',
      dateTime: DateTime(2026, 6, 20, 20, 6),
    );

    expect(isNextPrayerRow(isha, nextIsha), isTrue);
  });

  test('matches tomorrow fajr against the visible fajr row after isha', () {
    final todayFajr = prayer(
      id: 1,
      title: 'الفجر',
      dateTime: DateTime(2026, 6, 20, 3, 14),
    );

    final tomorrowFajr = prayer(
      id: 1,
      title: 'الفجر',
      dateTime: DateTime(2026, 6, 21, 3, 15),
    );

    expect(isNextPrayerRow(todayFajr, tomorrowFajr), isTrue);
  });

  test('does not wrap non-fajr prayers across days', () {
    final todayIsha = prayer(
      id: 6,
      title: 'العشاء',
      dateTime: DateTime(2026, 6, 20, 20, 6),
    );

    final tomorrowIsha = prayer(
      id: 6,
      title: 'العشاء',
      dateTime: DateTime(2026, 6, 21, 20, 7),
    );

    expect(isNextPrayerRow(todayIsha, tomorrowIsha), isFalse);
  });

  test('keeps current prayer highlighted while iqama is still pending', () {
    final ishaTime = DateTime(2026, 7, 19, 20, 29);
    final fajrTomorrow = DateTime(2026, 7, 20, 4, 31);
    final isha = prayer(id: 6, title: 'العشاء', dateTime: ishaTime);
    final fajr = prayer(id: 1, title: 'الفجر', dateTime: fajrTomorrow);

    expect(
      isHighlightedPrayerRow(
        prayer: isha,
        nextPrayer: fajr,
        currentPrayer: isha,
        isBetweenAdhanAndIqama: true,
        remainingToIqama: const Duration(minutes: 7),
      ),
      isTrue,
    );
    expect(
      isHighlightedPrayerRow(
        prayer: fajr,
        nextPrayer: fajr,
        currentPrayer: isha,
        isBetweenAdhanAndIqama: true,
        remainingToIqama: const Duration(minutes: 7),
      ),
      isFalse,
    );
  });

  test('falls back to next prayer after iqama window ends', () {
    final ishaTime = DateTime(2026, 7, 19, 20, 29);
    final fajrTomorrow = DateTime(2026, 7, 20, 4, 31);
    final isha = prayer(id: 6, title: 'العشاء', dateTime: ishaTime);
    final fajr = prayer(id: 1, title: 'الفجر', dateTime: fajrTomorrow);

    expect(
      isHighlightedPrayerRow(
        prayer: isha,
        nextPrayer: fajr,
        currentPrayer: isha,
        isBetweenAdhanAndIqama: false,
        remainingToIqama: Duration.zero,
      ),
      isFalse,
    );
    expect(
      isHighlightedPrayerRow(
        prayer: fajr,
        nextPrayer: fajr,
        currentPrayer: isha,
        isBetweenAdhanAndIqama: false,
        remainingToIqama: Duration.zero,
      ),
      isTrue,
    );
  });
}
