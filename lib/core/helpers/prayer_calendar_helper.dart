import 'package:azan/core/helpers/azan_adjust_model.dart';
import 'package:azan/core/models/city_option.dart';
import 'package:azan/core/models/latlng.dart';
import 'package:jhijri/_src/_jHijri.dart';

typedef HijriYearRange = ({
  int hijriYear,
  DateTime startInclusive,
  DateTime endExclusive,
});

typedef HijriDateParts = ({int day, int month, int year, String monthName});

class PrayerCalendarHelper {
  static const List<String> prayerKeysOrder = [
    'fajr',
    'sunrise',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  ];

  static const List<String> englishHijriMonths = [
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    'Shaaban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qadah',
    'Dhu al-Hijjah',
  ];

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String ymdForDate(DateTime date) {
    final normalized = dateOnly(date);
    final year = normalized.year.toString().padLeft(4, '0');
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static DateTime dateFromYmd(String ymd) {
    final parts = ymd.split('-');
    if (parts.length != 3) {
      throw FormatException('Invalid ymd: $ymd');
    }

    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static int prayerIndexForId(int prayerId) {
    if (prayerId < 1 || prayerId > prayerKeysOrder.length) {
      throw RangeError.range(prayerId, 1, prayerKeysOrder.length, 'prayerId');
    }
    return prayerId - 1;
  }

  static String prayerKeyForId(int prayerId) {
    return prayerKeysOrder[prayerIndexForId(prayerId)];
  }

  static int prayerIdForKey(String prayerKey) {
    final index = prayerKeysOrder.indexOf(prayerKey);
    if (index == -1) {
      throw ArgumentError.value(prayerKey, 'prayerKey', 'Unknown prayer key');
    }
    return index + 1;
  }

  static int minutesSinceMidnight(DateTime dateTime) {
    return (dateTime.hour * 60) + dateTime.minute;
  }

  static DateTime dateTimeFromMinutes(DateTime date, int minutes) {
    return dateOnly(date).add(Duration(minutes: minutes));
  }

  static String cityKeyFor({CityOption? city, LatLng? coordinates}) {
    final lat = coordinates?.latitude ?? city?.lat;
    final lon = coordinates?.longitude ?? city?.lon;

    if (lat != null && lon != null) {
      return '${lat.toStringAsFixed(4)},${lon.toStringAsFixed(4)}';
    }

    final fallbackName = city?.nameEn.trim();
    if (fallbackName != null && fallbackName.isNotEmpty) {
      return fallbackName.toLowerCase().replaceAll(' ', '_');
    }

    return 'unknown_city';
  }

  static String dayStorageKey({required String cityKey, required String ymd}) {
    return 'day::$cityKey::$ymd';
  }

  static HijriDateParts hijriPartsForDate(
    DateTime date, {
    required int offsetDays,
    String langCode = 'ar',
  }) {
    final adjusted = dateOnly(date).add(Duration(days: offsetDays));
    final hijri = JHijri(fDate: adjusted);
    final monthIndex = hijri.month.clamp(1, 12) - 1;
    final monthName = langCode == 'en'
        ? englishHijriMonths[monthIndex]
        : hijri.monthName;

    return (
      day: hijri.day,
      month: hijri.month,
      year: hijri.year,
      monthName: monthName,
    );
  }

  static HijriYearRange currentHijriYearRange({
    DateTime? now,
    required int offsetDays,
  }) {
    final baseNow = dateOnly(now ?? DateTime.now());
    final displayDate = baseNow.add(Duration(days: offsetDays));
    final currentHijri = JHijri(fDate: displayDate);

    return hijriYearRangeFor(
      hijriYear: currentHijri.year,
      offsetDays: offsetDays,
    );
  }

  static HijriYearRange hijriYearRangeFor({
    required int hijriYear,
    required int offsetDays,
  }) {
    final officialStart = dateOnly(
      JHijri(fYear: hijriYear, fMonth: 1, fDay: 1).dateTime,
    );
    final officialNextStart = dateOnly(
      JHijri(fYear: hijriYear + 1, fMonth: 1, fDay: 1).dateTime,
    );

    return (
      hijriYear: hijriYear,
      startInclusive: officialStart.subtract(Duration(days: offsetDays)),
      endExclusive: officialNextStart.subtract(Duration(days: offsetDays)),
    );
  }

  static bool isFriday(DateTime date) =>
      dateOnly(date).weekday == DateTime.friday;

  static bool isRamadanDate(DateTime date, {required int offsetDays}) {
    return hijriPartsForDate(date, offsetDays: offsetDays).month == 9;
  }

  static bool isSummerByLatitude(DateTime date, double? latitude) {
    final month = dateOnly(date).month;

    if (latitude == null) {
      return month >= 4 && month <= 9;
    }

    if (latitude >= 0) {
      return month >= 4 && month <= 9;
    }

    return month >= 10 || month <= 3;
  }

  static int azanAdjustmentMinutesForPrayer({
    required String prayerKey,
    required DateTime date,
    required AzanAdjustSettings settings,
    required int offsetDays,
    double? latitude,
  }) {
    var minutes = 0;

    if (settings.summerPlusHour &&
        isSummerByLatitude(dateOnly(date), latitude)) {
      minutes += 60;
    }

    minutes += settings.manualAllShiftMinutes;

    final prayerIndex = prayerKeysOrder.indexOf(prayerKey);
    if (prayerIndex >= 0 && prayerIndex < settings.perPrayerMinutes.length) {
      minutes += settings.perPrayerMinutes[prayerIndex];
    }

    if (prayerKey == 'isha' &&
        settings.ramadanIshaPlus30 &&
        isRamadanDate(dateOnly(date), offsetDays: offsetDays)) {
      minutes += 30;
    }

    return minutes;
  }

  static List<int> defaultIqamaMinutesForDate({
    required List<int> baseIqamaMinutes,
    required DateTime date,
    required int fridayMinutes,
    int defaultMinutes = 10,
  }) {
    final normalized = List<int>.filled(prayerKeysOrder.length, defaultMinutes);
    for (var i = 0; i < normalized.length; i++) {
      if (i < baseIqamaMinutes.length) {
        normalized[i] = baseIqamaMinutes[i];
      }
    }

    if (isFriday(date) && normalized.length > 2) {
      normalized[2] = fridayMinutes;
    }

    return normalized;
  }
}
