import 'package:azan/core/helpers/prayer_calendar_helper.dart';
import 'package:azan/generated/locale_keys.g.dart';

class AzkarPrayerScopeHelper {
  const AzkarPrayerScopeHelper._();

  static const int fajrId = 1;
  static const int sunriseId = 2;
  static const int dhuhrId = 3;
  static const int asrId = 4;
  static const int maghribId = 5;
  static const int ishaId = 6;
  static const int fridayId = 7;

  static const List<int> editablePrayerIds = [
    fajrId,
    dhuhrId,
    fridayId,
    asrId,
    maghribId,
    ishaId,
  ];

  static List<int> prayerIdsForDate(DateTime date) {
    return [
      fajrId,
      PrayerCalendarHelper.isFriday(date) ? fridayId : dhuhrId,
      asrId,
      maghribId,
      ishaId,
    ];
  }

  static int schedulePrayerId(int azkarPrayerId) {
    return azkarPrayerId == fridayId ? dhuhrId : azkarPrayerId;
  }

  static bool isFridayScope(int azkarPrayerId) {
    return azkarPrayerId == fridayId;
  }

  static String titleKey(int azkarPrayerId) {
    switch (azkarPrayerId) {
      case fajrId:
        return LocaleKeys.fajr;
      case dhuhrId:
        return LocaleKeys.dhuhr;
      case fridayId:
        return LocaleKeys.friday;
      case asrId:
        return LocaleKeys.asr;
      case maghribId:
        return LocaleKeys.maghrib;
      case ishaId:
        return LocaleKeys.isha;
      default:
        return LocaleKeys.prayer;
    }
  }

  static List<int> normalizePrayerIds(Iterable<int> prayerIds) {
    final normalized =
        prayerIds.where((id) => editablePrayerIds.contains(id)).toSet().toList()
          ..sort(_sortPrayerIds);
    return normalized;
  }

  static int _sortPrayerIds(int a, int b) {
    return editablePrayerIds.indexOf(a).compareTo(editablePrayerIds.indexOf(b));
  }

  static int? parsePrayerToken(String value) {
    final trimmed = value.trim();
    final numeric = int.tryParse(trimmed);
    if (numeric != null) {
      return editablePrayerIds.contains(numeric) ? numeric : null;
    }

    final key = trimmed
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_\-]+'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه');

    switch (key) {
      case 'fajr':
      case 'الفجر':
      case 'صبح':
      case 'الصبح':
        return fajrId;
      case 'dhuhr':
      case 'duhr':
      case 'zuhr':
      case 'الظهر':
        return dhuhrId;
      case 'friday':
      case 'jumua':
      case 'jumuah':
      case 'جمعة':
      case 'الجمعه':
      case 'صلاةالجمعه':
        return fridayId;
      case 'asr':
      case 'العصر':
        return asrId;
      case 'maghrib':
      case 'المغرب':
        return maghribId;
      case 'isha':
      case 'ishaa':
      case 'العشاء':
        return ishaId;
      default:
        return null;
    }
  }
}
