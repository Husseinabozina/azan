import 'package:azan/core/models/diker.dart';
import 'package:hive/hive.dart';

class DhikrLocalDataSource {
  static const _boxName = 'dhikr_box';
  static Future<Box>? _openingBox;

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }

    final inFlight = _openingBox;
    if (inFlight != null) {
      return inFlight;
    }

    final future = Hive.openBox(_boxName);
    _openingBox = future;

    try {
      return await future;
    } finally {
      if (identical(_openingBox, future)) {
        _openingBox = null;
      }
    }
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
