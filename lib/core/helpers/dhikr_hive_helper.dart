import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/models/diker.dart';
import 'package:hive/hive.dart';

class DhikrHiveHelper {
  static const String _boxName = 'azkar_box';
  static const String _itemsKey = 'items';

  /// افتح الـ Box
  static Future<Box> _openBox() async {
    return await Hive.openBox(_boxName);
  }

  /// اقرأ كل الأذكار من الـ box
  static List<Dhikr> _readAllFromBox(Box box) {
    final rawList =
        box.get(_itemsKey, defaultValue: <dynamic>[]) as List<dynamic>;

    return rawList
        .map((item) => Dhikr.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  /// اكتب ليست الأذكار في الـ box
  static Future<void> _writeAllToBox(Box box, List<Dhikr> dhikrList) async {
    await box.put(_itemsKey, dhikrList.map((d) => d.toMap()).toList());
  }

  /// id جديد: أكبر id + 1
  static int _generateNextId(List<Dhikr> current) {
    if (current.isEmpty) return 1;
    final maxId = current.map((d) => d.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  /// ✅ تستخدمها في main عشان تسيّد الأذكار الافتراضية أول مرة
  /// هنا بناخد List<Dhikr> عشان تقدر تحط معاها schedule لو حبيت
  static Future<void> ensureInitialAzkar(List<Dhikr> defaultDhikrList) async {
    final box = await _openBox();

    if (!box.containsKey(_itemsKey)) {
      await _writeAllToBox(box, defaultDhikrList);
    }
  }

  /// لو لسه حابب نسخة تعتمد على List<String> بس:
  static Future<void> ensureInitialAzkarFromTexts(
    List<String> azkarTexts,
  ) async {
    final box = await _openBox();

    if (!box.containsKey(_itemsKey)) {
      final List<Dhikr> defaultDhikrList = [];
      for (var i = 0; i < azkarTexts.length; i++) {
        defaultDhikrList.add(Dhikr(id: i + 1, text: azkarTexts[i]));
      }
      await _writeAllToBox(box, defaultDhikrList);
    }
  }

  /// ✅ كل الأذكار
  static Future<List<Dhikr>> getAllDhikr() async {
    final box = await _openBox();
    return _readAllFromBox(box);
  }

  /// ✅ أذكار اليوم (مهمة لشاشة المسجد اللي شغالة طول اليوم)
  static Future<List<Dhikr>> getDhikrForDay(DateTime date) async {
    final all = await getAllDhikr();
    return all.where((d) => d.isForDay(date)).toList();
  }

  /// Helper لأذكار النهارده مباشرة
  static Future<List<Dhikr>> getTodayDhikr() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return getDhikrForDay(today);
  }

  /// ✅ إضافة ذكر جديد (مع إمكانية تمرير schedule)
  static Future<Dhikr> addDhikr(String text, {DhikrSchedule? schedule}) async {
    final box = await _openBox();
    final current = _readAllFromBox(box);

    final newId = _generateNextId(current);
    final newDhikr = Dhikr(id: newId, text: text, schedule: schedule);

    current.add(newDhikr);
    await _writeAllToBox(box, current);

    return newDhikr;
  }

  /// ✅ تعديل ذكر
  static Future<void> updateDhikr(Dhikr updated) async {
    final box = await _openBox();
    final current = _readAllFromBox(box);

    final index = current.indexWhere((d) => d.id == updated.id);
    if (index == -1) return;

    current[index] = updated;
    await _writeAllToBox(box, current);
  }

  /// ✅ حذف ذكر
  static Future<void> deleteDhikr(int id) async {
    final box = await _openBox();
    final current = _readAllFromBox(box);

    current.removeWhere((d) => d.id == id);
    await _writeAllToBox(box, current);
  }

  /// ✅ مسح الكل
  static Future<void> clearAll() async {
    final box = await _openBox();
    await box.delete(_itemsKey);
  }
}
