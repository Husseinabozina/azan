import 'package:azan/core/helpers/prayer_calendar_helper.dart';
import 'package:azan/core/models/prayer_calendar_day.dart';
import 'package:hive/hive.dart';

class PrayerCalendarHiveHelper {
  static const String boxName = 'prayer_calendar_days_box';
  static Future<Box>? _openingBox;

  static Future<Box> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }

    final inFlight = _openingBox;
    if (inFlight != null) {
      return inFlight;
    }

    final future = Hive.openBox(boxName);
    _openingBox = future;

    try {
      return await future;
    } finally {
      if (identical(_openingBox, future)) {
        _openingBox = null;
      }
    }
  }

  static PrayerCalendarDay? _parseDay(dynamic raw) {
    if (raw is Map) {
      return PrayerCalendarDay.fromMap(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  static PrayerCalendarDay? getDaySync({
    required String cityKey,
    required DateTime date,
  }) {
    if (!Hive.isBoxOpen(boxName)) return null;
    final box = Hive.box(boxName);
    final key = PrayerCalendarHelper.dayStorageKey(
      cityKey: cityKey,
      ymd: PrayerCalendarHelper.ymdForDate(date),
    );
    return _parseDay(box.get(key));
  }

  static Future<PrayerCalendarDay?> getDay({
    required String cityKey,
    required DateTime date,
  }) async {
    final box = await _openBox();
    final key = PrayerCalendarHelper.dayStorageKey(
      cityKey: cityKey,
      ymd: PrayerCalendarHelper.ymdForDate(date),
    );
    return _parseDay(box.get(key));
  }

  static Future<void> putDay(PrayerCalendarDay day) async {
    final box = await _openBox();
    final key = PrayerCalendarHelper.dayStorageKey(
      cityKey: day.cityKey,
      ymd: day.gregorianYmd,
    );
    await box.put(key, day.toMap());
  }

  static Future<void> putDays(Iterable<PrayerCalendarDay> days) async {
    final box = await _openBox();
    final payload = <String, Map<String, dynamic>>{};
    for (final day in days) {
      final key = PrayerCalendarHelper.dayStorageKey(
        cityKey: day.cityKey,
        ymd: day.gregorianYmd,
      );
      payload[key] = day.toMap();
    }
    if (payload.isNotEmpty) {
      await box.putAll(payload);
    }
  }

  static Future<List<PrayerCalendarDay>> getDaysInRange({
    required String cityKey,
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) async {
    final box = await _openBox();
    final result = <PrayerCalendarDay>[];
    for (
      var day = PrayerCalendarHelper.dateOnly(startInclusive);
      day.isBefore(endExclusive);
      day = day.add(const Duration(days: 1))
    ) {
      final key = PrayerCalendarHelper.dayStorageKey(
        cityKey: cityKey,
        ymd: PrayerCalendarHelper.ymdForDate(day),
      );
      final parsed = _parseDay(box.get(key));
      if (parsed != null) {
        result.add(parsed);
      }
    }
    return result;
  }

  static Future<Set<String>> getExistingYmdsInRange({
    required String cityKey,
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) async {
    final days = await getDaysInRange(
      cityKey: cityKey,
      startInclusive: startInclusive,
      endExclusive: endExclusive,
    );
    return days.map((day) => day.gregorianYmd).toSet();
  }

  static Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }
}
