import 'package:hive/hive.dart';

class IqamaHiveHelper {
  static const String _boxName = 'iqama_box';
  static const String _minutesKey = 'iqama_minutes';

  /// افتح الـ Box
  static Future<Box> _openBox() async {
    return await Hive.openBox(_boxName);
  }

  /// قراءة دقائق الإقامة لكل الصلوات
  /// لو مفيش بيانات، يرجّع Default (مثلاً 10 دقايق لكل صلاة)
  static Future<List<int>> loadIqamaMinutes({
    required int prayerCount,
    int defaultMinutes = 10,
  }) async {
    final box = await _openBox();
    final raw = box.get(_minutesKey);

    if (raw is List) {
      // نحولها List<int> بأمان
      final list = raw
          .map(
            (e) => e is int ? e : int.tryParse(e.toString()) ?? defaultMinutes,
          )
          .toList();

      // لو الليست أقصر من عدد الصلوات نكمّلها
      if (list.length < prayerCount) {
        return [
          ...list,
          ...List<int>.filled(prayerCount - list.length, defaultMinutes),
        ];
      }

      // لو أطول نقصّها على قد عدد الصلوات الحالي
      if (list.length > prayerCount) {
        return list.take(prayerCount).toList();
      }

      return list;
    }

    // لو مفيش حاجة محفوظة
    return List<int>.filled(prayerCount, defaultMinutes);
  }

  /// حفظ كل دقائق الإقامة مرة واحدة
  static Future<void> saveIqamaMinutes(List<int> minutes) async {
    final box = await _openBox();
    await box.put(_minutesKey, minutes);
  }

  /// تعديل إقامة صلاة واحدة بالـ index
  static Future<void> setIqamaForPrayer({
    required int index,
    required int value,
    required int prayerCount,
    int defaultMinutes = 10,
  }) async {
    final current = await loadIqamaMinutes(
      prayerCount: prayerCount,
      defaultMinutes: defaultMinutes,
    );

    if (index < 0 || index >= current.length) return;

    current[index] = value;
    await saveIqamaMinutes(current);
  }

  /// مسح كل إعدادات الإقامة (لو حبيت ترجعها من البداية)
  static Future<void> clear() async {
    final box = await _openBox();
    await box.delete(_minutesKey);
  }
}
