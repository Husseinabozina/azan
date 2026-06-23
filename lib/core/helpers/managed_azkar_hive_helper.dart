import 'package:azan/core/models/azkar_type.dart';
import 'package:azan/core/models/managed_azkar_entry.dart';
import 'package:azan/data/data/after_prayers_azkar.dart';
import 'package:azan/data/data/evening_azkar.dart';
import 'package:azan/data/data/morning_azkar.dart';
import 'package:hive/hive.dart';

class ManagedAzkarHiveHelper {
  static const String _boxName = 'managed_azkar_box';
  static const String _itemsKey = 'items';
  static const String _afterPrayerOrderMigrationKey =
      'after_prayer_order_migration_v2';
  static Future<Box>? _openingBox;
  static List<ManagedAzkarEntry>? _cachedEntries;

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
    if (box.containsKey(_itemsKey)) {
      await _migrateAfterPrayerOrderIfNeeded(box);
      _cacheEntries(_readAllFromBox(box));
      return;
    }

    await _writeAllToBox(box, _buildSeedEntries());
    await box.put(_afterPrayerOrderMigrationKey, true);
  }

  static Future<List<ManagedAzkarEntry>> getAllEntries() async {
    final box = await _openBox();
    final entries = _readAllFromBox(box);
    _cacheEntries(entries);
    return entries;
  }

  static bool hasActiveEntriesForTypeAndPrayerSync(
    AzkarType type,
    int prayerId,
  ) {
    final entries = _cachedEntries;
    if (entries == null) {
      return _isDefaultPrayerForType(type, prayerId);
    }

    return entries.any(
      (entry) =>
          entry.setType == type &&
          entry.active &&
          entry.appliesToPrayer(prayerId),
    );
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
      text: _sanitizeStoredText(text),
      applicablePrayerIds: _normalizePrayerIds(applicablePrayerIds),
    );

    _insertAfterLastEntryOfType(current, entry);
    await _writeAllToBox(box, current);
    return entry;
  }

  static Future<void> updateEntry(ManagedAzkarEntry updated) async {
    final box = await _openBox();
    final current = _readAllFromBox(box);
    final index = current.indexWhere((entry) => entry.id == updated.id);
    if (index == -1) return;

    current[index] = updated.copyWith(
      text: _sanitizeStoredText(updated.text),
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

  static Future<void> setActive(int id, bool active) async {
    final box = await _openBox();
    final current = _readAllFromBox(box);
    final index = current.indexWhere((entry) => entry.id == id);
    if (index == -1) return;

    current[index] = current[index].copyWith(active: active);
    await _writeAllToBox(box, current);
  }

  static Future<void> moveEntryWithinType({
    required AzkarType type,
    required int entryId,
    required int delta,
  }) async {
    if (delta == 0) return;

    final box = await _openBox();
    final current = _readAllFromBox(box);
    final typeEntries = current
        .where((entry) => entry.setType == type)
        .toList(growable: false);
    final sourceTypeIndex = typeEntries.indexWhere(
      (entry) => entry.id == entryId,
    );
    if (sourceTypeIndex == -1) return;

    final targetTypeIndex = sourceTypeIndex + delta.sign;
    if (targetTypeIndex < 0 || targetTypeIndex >= typeEntries.length) return;

    final sourceGlobalIndex = current.indexWhere(
      (entry) => entry.id == typeEntries[sourceTypeIndex].id,
    );
    final targetGlobalIndex = current.indexWhere(
      (entry) => entry.id == typeEntries[targetTypeIndex].id,
    );
    if (sourceGlobalIndex == -1 || targetGlobalIndex == -1) return;

    final sourceEntry = current[sourceGlobalIndex];
    current[sourceGlobalIndex] = current[targetGlobalIndex];
    current[targetGlobalIndex] = sourceEntry;

    await _writeAllToBox(box, current);
  }

  static Future<void> moveEntryToTypeIndex({
    required AzkarType type,
    required int entryId,
    required int targetIndex,
  }) async {
    final box = await _openBox();
    final current = _readAllFromBox(box);
    final typeEntries = current
        .where((entry) => entry.setType == type)
        .toList(growable: true);
    final sourceIndex = typeEntries.indexWhere((entry) => entry.id == entryId);
    if (sourceIndex == -1 || typeEntries.isEmpty) return;

    final boundedTargetIndex = targetIndex
        .clamp(0, typeEntries.length - 1)
        .toInt();
    if (sourceIndex == boundedTargetIndex) return;

    final movedEntry = typeEntries.removeAt(sourceIndex);
    typeEntries.insert(boundedTargetIndex, movedEntry);

    var typeIndex = 0;
    final reordered = current
        .map((entry) {
          if (entry.setType != type) return entry;
          return typeEntries[typeIndex++];
        })
        .toList(growable: false);

    await _writeAllToBox(box, reordered);
  }

  static Future<void> clearAll() async {
    final box = await _openBox();
    await box.delete(_itemsKey);
    _cacheEntries(const <ManagedAzkarEntry>[]);
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
    _cacheEntries(entries);
  }

  static void _cacheEntries(List<ManagedAzkarEntry> entries) {
    _cachedEntries = List<ManagedAzkarEntry>.unmodifiable(entries);
  }

  static void _insertAfterLastEntryOfType(
    List<ManagedAzkarEntry> entries,
    ManagedAzkarEntry entry,
  ) {
    final lastTypeIndex = _lastIndexWhere(
      entries,
      (candidate) => candidate.setType == entry.setType,
    );
    if (lastTypeIndex == -1 || lastTypeIndex == entries.length - 1) {
      entries.add(entry);
      return;
    }

    entries.insert(lastTypeIndex + 1, entry);
  }

  static int _lastIndexWhere(
    List<ManagedAzkarEntry> entries,
    bool Function(ManagedAzkarEntry entry) test,
  ) {
    for (var i = entries.length - 1; i >= 0; i--) {
      if (test(entries[i])) return i;
    }
    return -1;
  }

  static bool _isDefaultPrayerForType(AzkarType type, int prayerId) {
    final defaultPrayerId = ManagedAzkarEntry.defaultPrayerIdForType(type);
    return defaultPrayerId == null || defaultPrayerId == prayerId;
  }

  static int _generateNextId(List<ManagedAzkarEntry> current) {
    if (current.isEmpty) return 1;
    final maxId = current
        .map((entry) => entry.id)
        .reduce((left, right) => left > right ? left : right);
    return maxId + 1;
  }

  static Future<void> _migrateAfterPrayerOrderIfNeeded(Box box) async {
    if (box.get(_afterPrayerOrderMigrationKey) == true) return;

    final current = _readAllFromBox(box);
    final afterPrayerEntries = current
        .where((entry) => entry.setType == AzkarType.afterPrayer)
        .toList(growable: false);
    if (afterPrayerEntries.isEmpty) {
      await box.put(_afterPrayerOrderMigrationKey, true);
      return;
    }

    final knownOrder = _legacyMapsForType(
      AzkarType.afterPrayer,
    ).map((raw) => _normalizeText(raw['zekr'] ?? '')).toList(growable: false);
    final knownKeys = knownOrder.toSet();
    final byKnownText = <String, ManagedAzkarEntry>{};
    final customAfterPrayerEntries = <ManagedAzkarEntry>[];

    for (final entry in afterPrayerEntries) {
      final key = _resolveAfterPrayerKnownKey(entry, knownOrder, knownKeys);
      if (key != null && !byKnownText.containsKey(key)) {
        byKnownText[key] = entry;
      } else {
        customAfterPrayerEntries.add(entry);
      }
    }

    final reorderedAfterPrayer = <ManagedAzkarEntry>[
      for (final key in knownOrder)
        if (byKnownText[key] != null) byKnownText[key]!,
      ...customAfterPrayerEntries,
    ];

    final result = <ManagedAzkarEntry>[];
    var insertedAfterPrayer = false;
    for (final entry in current) {
      if (entry.setType != AzkarType.afterPrayer) {
        result.add(entry);
        continue;
      }
      if (!insertedAfterPrayer) {
        result.addAll(reorderedAfterPrayer);
        insertedAfterPrayer = true;
      }
    }

    await _writeAllToBox(box, result);
    await box.put(_afterPrayerOrderMigrationKey, true);
  }

  static String _normalizeText(String value) {
    return value
        .replaceAll('\r\n', '\n')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String? _resolveAfterPrayerKnownKey(
    ManagedAzkarEntry entry,
    List<String> knownOrder,
    Set<String> knownKeys,
  ) {
    final key = _normalizeText(entry.text);
    if (knownKeys.contains(key)) return key;

    // Older installs stored the Mu'awwidhat text before the new count note was
    // added, so identify the known default by its stable surah content.
    if (key.contains('قُلْ هُوَ اللَّهُ أَحَدٌ') &&
        key.contains('قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ') &&
        key.contains('قُلْ أَعُوذُ بِرَبِّ النَّاسِ')) {
      return _firstKnownKeyContaining(knownOrder, 'قُلْ هُوَ اللَّهُ أَحَدٌ');
    }

    if (key.contains('اللَّهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ')) {
      return _firstKnownKeyContaining(
        knownOrder,
        'اللَّهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ',
      );
    }

    return null;
  }

  static String? _firstKnownKeyContaining(
    List<String> knownOrder,
    String marker,
  ) {
    for (final key in knownOrder) {
      if (key.contains(marker)) return key;
    }
    return null;
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
      text: _sanitizeStoredText(raw['zekr'] ?? ''),
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

  static String _sanitizeStoredText(String value) {
    return value
        .replaceAll(
          RegExp('[\u200E\u200F\u202A-\u202E\u2066-\u2069\uFEFF]'),
          '',
        )
        .trim();
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
