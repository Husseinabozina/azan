import 'package:hive/hive.dart';

class PrayerDurationHiveHelper {
  static const String _boxName = 'prayer_duration_box';
  static const String _minutesKey = 'prayer_durations_minutes';

  static Future<Box> _openBox() async {
    return await Hive.openBox(_boxName);
  }

  /// قراءة مدة الصلاة (بالدقائق) لكل الصلوات
  /// لو مفيش بيانات يرجع default
  static Future<List<int>> loadPrayerDurations({
    required int prayerCount,
    int defaultMinutes = 7,
  }) async {
    final box = await _openBox();
    final raw = box.get(_minutesKey);

    if (raw is List) {
      final list = raw
          .map(
            (e) => e is int ? e : int.tryParse(e.toString()) ?? defaultMinutes,
          )
          .toList();

      if (list.length < prayerCount) {
        return [
          ...list,
          ...List<int>.filled(prayerCount - list.length, defaultMinutes),
        ];
      }

      if (list.length > prayerCount) {
        return list.take(prayerCount).toList();
      }

      return list;
    }

    return List<int>.filled(prayerCount, defaultMinutes);
  }

  /// حفظ كل مدد الصلاة مرة واحدة
  static Future<void> savePrayerDurations(List<int> minutes) async {
    final box = await _openBox();
    await box.put(_minutesKey, minutes);
  }

  /// تعديل مدة صلاة واحدة بالـ index
  static Future<void> setDurationForPrayer({
    required int index,
    required int value,
    required int prayerCount,
    int defaultMinutes = 7,
  }) async {
    final current = await loadPrayerDurations(
      prayerCount: prayerCount,
      defaultMinutes: defaultMinutes,
    );

    if (index < 0 || index >= current.length) return;

    current[index] = value;
    await savePrayerDurations(current);
  }

  /// مسح الإعدادات
  static Future<void> clear() async {
    final box = await _openBox();
    await box.delete(_minutesKey);
  }
}
