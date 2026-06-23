import 'package:hive/hive.dart';

class MosqueStorage {
  static const _boxName = 'settingsBox';
  static const _keyMosqueName = 'mosque_name';

  static Box get _box => Hive.box(_boxName);

  static Future<void> setMosqueName(String name) async {
    await _box.put(_keyMosqueName, name);
  }

  static String getMosqueName() {
    return _box.get(_keyMosqueName, defaultValue: "") as String;
  }

  static Future<void> clearMosqueName() async {
    await _box.delete(_keyMosqueName);
  }
}
