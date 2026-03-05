import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/models/diker.dart';
import 'package:hive/hive.dart';

/// نفس منطق DhikrHiveHelper لكن خاص بشرائح/آيات منتصف الشاشة.
class SlideHiveHelper {
  static const String _boxName = 'slides_box';
  static const String _itemsKey = 'items';

  static Future<Box> _openBox() async {
    return Hive.openBox(_boxName);
  }

  static List<Dhikr> _readAllFromBox(Box box) {
    final rawList =
        box.get(_itemsKey, defaultValue: <dynamic>[]) as List<dynamic>;

    return rawList
        .map((item) => Dhikr.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  static Future<void> _writeAllToBox(Box box, List<Dhikr> list) async {
    final normalized = list.map((d) => d.copyWith(id: list.indexOf(d))).toList();
    await box.put(_itemsKey, normalized.map((d) => d.toMap()).toList());
  }

  static int _generateNextId(List<Dhikr> current) {
    if (current.isEmpty) return 1;
    final maxId = current.map((d) => d.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  static Future<void> ensureInitialSlides(List<String> defaultSlides) async {
    final box = await _openBox();
    if (box.containsKey(_itemsKey)) return;

    final seed = <Dhikr>[];
    for (var i = 0; i < defaultSlides.length; i++) {
      seed.add(
        Dhikr(
          id: i + 1,
          text: defaultSlides[i],
          schedule: DhikrSchedule.daily(),
        ),
      );
    }

    await _writeAllToBox(box, seed);
  }

  static Future<List<Dhikr>> getAllSlides() async {
    final box = await _openBox();
    return _readAllFromBox(box);
  }

  static Future<List<Dhikr>> getSlidesForDay(DateTime date) async {
    final all = await getAllSlides();
    return all.where((d) => d.active && d.isForDay(date)).toList();
  }

  static Future<Dhikr> addSlide(String text, {DhikrSchedule? schedule}) async {
    final box = await _openBox();
    final current = _readAllFromBox(box);

    final newSlide = Dhikr(
      id: _generateNextId(current),
      text: text,
      schedule: schedule,
    );

    current.add(newSlide);
    await _writeAllToBox(box, current);
    return newSlide;
  }

  static Future<void> updateSlide(Dhikr updated) async {
    final box = await _openBox();
    final current = _readAllFromBox(box);
    final index = current.indexWhere((d) => d.id == updated.id);
    if (index == -1) return;

    current[index] = updated;
    await _writeAllToBox(box, current);
  }

  static Future<void> deleteSlide(int id) async {
    final box = await _openBox();
    final current = _readAllFromBox(box);
    current.removeWhere((d) => d.id == id);
    await _writeAllToBox(box, current);
  }

  static Future<void> clearAll() async {
    final box = await _openBox();
    await box.delete(_itemsKey);
  }
}
