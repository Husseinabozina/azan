import 'package:azan/core/models/azkar_type.dart';
import 'package:azan/core/models/managed_azkar_entry.dart';
import 'package:azan/data/data/after_prayers_azkar.dart';
import 'package:azan/data/data/evening_azkar.dart';
import 'package:azan/data/data/morning_azkar.dart';
import 'package:hive/hive.dart';

class ManagedAzkarHiveHelper {
  static const String _boxName = 'managed_azkar_box';
  static const String _itemsKey = 'items';
  static Future<Box>? _openingBox;

  static Future<Box> _openBox() async {
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

  static Future<void> ensureInitialAzkarSets() async {
    final box = await _openBox();
    if (box.containsKey(_itemsKey)) return;

    await _writeAllToBox(box, _buildSeedEntries());
  }

  static Future<List<ManagedAzkarEntry>> getAllEntries() async {
    final box = await _openBox();
    return _readAllFromBox(box);
  }

  static Future<List<ManagedAzkarEntry>> getEntriesForType(
    AzkarType type, {
    int? prayerId,
    bool activeOnly = true,
  }) async {
    final all = await getAllEntries();
    return all
        .where((entry) => entry.setType == type)
        .where((entry) => !activeOnly || entry.active)
        .where((entry) => entry.appliesToPrayer(prayerId))
        .toList(growable: false);
  }

  static Future<ManagedAzkarEntry> addEntry({
    required AzkarType type,
    required String text,
    List<int> applicablePrayerIds = const <int>[],
  }) async {
    final box = await _openBox();
    final current = _readAllFromBox(box);

    final entry = ManagedAzkarEntry(
      id: _generateNextId(current),
      setType: type,
      text: text.trim(),
      applicablePrayerIds: _normalizePrayerIds(applicablePrayerIds),
    );

    current.add(entry);
    await _writeAllToBox(box, current);
    return entry;
  }

  static Future<void> updateEntry(ManagedAzkarEntry updated) async {
    final box = await _openBox();
    final current = _readAllFromBox(box);
    final index = current.indexWhere((entry) => entry.id == updated.id);
    if (index == -1) return;

    current[index] = updated.copyWith(
      text: updated.text.trim(),
      applicablePrayerIds: _normalizePrayerIds(updated.applicablePrayerIds),
    );
    await _writeAllToBox(box, current);
  }

  static Future<void> deleteEntry(int id) async {
    final box = await _openBox();
    final current = _readAllFromBox(box);
    current.removeWhere((entry) => entry.id == id);
    await _writeAllToBox(box, current);
  }

  static Future<void> clearAll() async {
    final box = await _openBox();
    await box.delete(_itemsKey);
  }

  static List<ManagedAzkarEntry> _readAllFromBox(Box box) {
    final rawList =
        box.get(_itemsKey, defaultValue: const <dynamic>[]) as List<dynamic>;

    return rawList
        .map(
          (item) =>
              ManagedAzkarEntry.fromMap(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  static Future<void> _writeAllToBox(
    Box box,
    List<ManagedAzkarEntry> entries,
  ) async {
    await box.put(
      _itemsKey,
      entries.map((entry) => entry.toMap()).toList(growable: false),
    );
  }

  static int _generateNextId(List<ManagedAzkarEntry> current) {
    if (current.isEmpty) return 1;
    final maxId = current
        .map((entry) => entry.id)
        .reduce((left, right) => left > right ? left : right);
    return maxId + 1;
  }

  static List<ManagedAzkarEntry> _buildSeedEntries() {
    var nextId = 1;
    final entries = <ManagedAzkarEntry>[];

    for (final entry in _legacyMapsForType(AzkarType.morning)) {
      entries.add(
        _entryFromLegacyMap(id: nextId++, type: AzkarType.morning, raw: entry),
      );
    }
    for (final entry in _legacyMapsForType(AzkarType.evening)) {
      entries.add(
        _entryFromLegacyMap(id: nextId++, type: AzkarType.evening, raw: entry),
      );
    }
    for (final entry in _legacyMapsForType(AzkarType.afterPrayer)) {
      entries.add(
        _entryFromLegacyMap(
          id: nextId++,
          type: AzkarType.afterPrayer,
          raw: entry,
        ),
      );
    }

    return entries;
  }

  static List<Map<String, String>> _legacyMapsForType(AzkarType type) {
    switch (type) {
      case AzkarType.morning:
        return morningAzkar;
      case AzkarType.evening:
        return eveningAzkar;
      case AzkarType.afterPrayer:
        return afterPrayersAzkar;
    }
  }

  static ManagedAzkarEntry _entryFromLegacyMap({
    required int id,
    required AzkarType type,
    required Map<String, String> raw,
  }) {
    return ManagedAzkarEntry(
      id: id,
      setType: type,
      text: (raw['zekr'] ?? '').trim(),
      reference: _readOptional(raw['reference']),
      description: _readOptional(raw['description']),
      count: _readOptional(raw['count']),
      applicablePrayerIds: _parsePrayerIds(raw['prayerIds']),
    );
  }

  static String? _readOptional(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  static List<int> _parsePrayerIds(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const <int>[];

    return _normalizePrayerIds(
      raw
          .split(',')
          .map((value) => int.tryParse(value.trim()))
          .whereType<int>()
          .toList(growable: false),
    );
  }

  static List<int> _normalizePrayerIds(List<int> prayerIds) {
    final normalized = prayerIds.toSet().toList()..sort();
    return normalized;
  }
}
