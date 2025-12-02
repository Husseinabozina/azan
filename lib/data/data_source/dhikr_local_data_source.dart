import 'package:azan/core/models/diker.dart';
import 'package:hive/hive.dart';

class DhikrLocalDataSource {
  static const _boxName = 'dhikr_box';

  Future<Box> _openBox() async {
    return Hive.openBox(_boxName);
  }

  Future<void> saveDhikrList(List<Dhikr> list) async {
    final box = await _openBox();
    // بنخزن الليست كلها في key واحد
    await box.put('items', list.map((d) => d.toMap()).toList());
  }

  Future<List<Dhikr>> getDhikrList() async {
    final box = await _openBox();
    final raw = box.get('items');
    if (raw == null) return [];
    final list = (raw as List)
        .cast<Map>()
        .map((m) => Dhikr.fromMap(m.cast<String, dynamic>()))
        .toList();
    return list;
  }
}
