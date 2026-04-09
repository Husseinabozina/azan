import 'package:azan/core/models/display_announcement.dart';
import 'package:azan/core/models/display_board_schedule.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:hive/hive.dart';

class DisplayBoardHiveHelper {
  static const String _boxName = 'display_board_box';
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

  static Map<String, dynamic> _styleDefaultsMap() {
    return {
      'titleFontFamily': CacheHelper.getDisplayBoardTitleFontFamily(),
      'bodyFontFamily': CacheHelper.getDisplayBoardBodyFontFamily(),
      'titleBold': CacheHelper.getDisplayBoardTitleBold(),
      'titleItalic': CacheHelper.getDisplayBoardTitleItalic(),
      'bodyBold': CacheHelper.getDisplayBoardBodyBold(),
      'bodyItalic': CacheHelper.getDisplayBoardBodyItalic(),
      'titleSize': CacheHelper.getDisplayBoardTitleSize(),
      'bodySize': CacheHelper.getDisplayBoardBodySize(),
      'titleColorIndex': CacheHelper.getDisplayBoardTitleColorIndex(),
      'bodyColorIndex': CacheHelper.getDisplayBoardBodyColorIndex(),
    };
  }

  static bool _needsStyleMigration(Map<String, dynamic> item) {
    return !item.containsKey('titleFontFamily') ||
        !item.containsKey('bodyFontFamily') ||
        !item.containsKey('titleBold') ||
        !item.containsKey('titleItalic') ||
        !item.containsKey('bodyBold') ||
        !item.containsKey('bodyItalic') ||
        !item.containsKey('titleSize') ||
        !item.containsKey('bodySize') ||
        !item.containsKey('titleColorIndex') ||
        !item.containsKey('bodyColorIndex') ||
        !item.containsKey('schedule');
  }

  static DisplayAnnouncement _announcementFromRaw(Map<String, dynamic> raw) {
    final defaults = _styleDefaultsMap();
    return DisplayAnnouncement.fromMap({...defaults, ...raw});
  }

  static List<DisplayAnnouncement> _readAllFromBox(Box box) {
    final rawList =
        box.get(_itemsKey, defaultValue: <dynamic>[]) as List<dynamic>;

    return rawList
        .map(
          (item) =>
              _announcementFromRaw(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  static List<DisplayAnnouncement> normalizeAnnouncements(
    List<DisplayAnnouncement> list,
  ) {
    final sorted = [...list]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return List<DisplayAnnouncement>.generate(sorted.length, (index) {
      final item = sorted[index];
      return item.copyWith(sortOrder: index);
    });
  }

  static List<DisplayAnnouncement> _normalizePinnedState(
    List<DisplayAnnouncement> list, {
    int? preferredPinnedId,
  }) {
    final normalized = normalizeAnnouncements(list);

    if (preferredPinnedId != null) {
      return normalized
          .map(
            (item) => item.copyWith(
              pinned: item.id == preferredPinnedId,
              active: item.id == preferredPinnedId ? true : item.active,
            ),
          )
          .toList();
    }

    bool foundPinned = false;
    return normalized.map((item) {
      final shouldPin = !foundPinned && item.pinned && item.active;
      if (shouldPin) foundPinned = true;
      return item.copyWith(pinned: shouldPin);
    }).toList();
  }

  static Future<void> _writeAllToBox(
    Box box,
    List<DisplayAnnouncement> list,
  ) async {
    final normalized = _normalizePinnedState(list);
    await box.put(_itemsKey, normalized.map((e) => e.toMap()).toList());
  }

  static int _generateNextId(List<DisplayAnnouncement> current) {
    if (current.isEmpty) return 1;
    final maxId = current
        .map((item) => item.id)
        .reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  static Future<List<DisplayAnnouncement>> getAllAnnouncements() async {
    final box = await _openBox();
    final rawList =
        box.get(_itemsKey, defaultValue: <dynamic>[]) as List<dynamic>;
    final rawMaps = rawList
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    final announcements = rawMaps.map(_announcementFromRaw).toList();
    final normalized = normalizeAnnouncements(announcements);

    if (rawMaps.any(_needsStyleMigration)) {
      await box.put(_itemsKey, normalized.map((e) => e.toMap()).toList());
    }

    return normalized;
  }

  static Future<List<DisplayAnnouncement>> getActiveAnnouncements() async {
    final all = await getAllAnnouncements();
    return all.where((item) => item.active).toList();
  }

  static Future<DisplayAnnouncement> addAnnouncement({
    required String title,
    required String body,
    bool active = true,
    bool pinned = false,
    String? titleFontFamily,
    String? bodyFontFamily,
    bool? titleBold,
    bool? titleItalic,
    bool? bodyBold,
    bool? bodyItalic,
    int? titleSize,
    int? bodySize,
    int? titleColorIndex,
    int? bodyColorIndex,
    DisplayBoardSchedule? schedule,
  }) async {
    final box = await _openBox();
    final current = _readAllFromBox(box);
    final created = DisplayAnnouncement(
      id: _generateNextId(current),
      title: title,
      body: body,
      active: active,
      pinned: pinned,
      sortOrder: current.length,
      titleFontFamily:
          titleFontFamily ?? CacheHelper.getDisplayBoardTitleFontFamily(),
      bodyFontFamily:
          bodyFontFamily ?? CacheHelper.getDisplayBoardBodyFontFamily(),
      titleBold: titleBold ?? CacheHelper.getDisplayBoardTitleBold(),
      titleItalic: titleItalic ?? CacheHelper.getDisplayBoardTitleItalic(),
      bodyBold: bodyBold ?? CacheHelper.getDisplayBoardBodyBold(),
      bodyItalic: bodyItalic ?? CacheHelper.getDisplayBoardBodyItalic(),
      titleSize: titleSize ?? CacheHelper.getDisplayBoardTitleSize(),
      bodySize: bodySize ?? CacheHelper.getDisplayBoardBodySize(),
      titleColorIndex:
          titleColorIndex ?? CacheHelper.getDisplayBoardTitleColorIndex(),
      bodyColorIndex:
          bodyColorIndex ?? CacheHelper.getDisplayBoardBodyColorIndex(),
      schedule: schedule,
    );

    current.add(created);
    final normalized = pinned
        ? _normalizePinnedState(current, preferredPinnedId: created.id)
        : _normalizePinnedState(current);
    await box.put(_itemsKey, normalized.map((e) => e.toMap()).toList());
    return created;
  }

  static Future<void> updateAnnouncement(DisplayAnnouncement updated) async {
    final box = await _openBox();
    final current = _readAllFromBox(box);
    final index = current.indexWhere((item) => item.id == updated.id);
    if (index == -1) return;

    final safeUpdated = updated.copyWith(
      active: updated.pinned ? true : updated.active,
    );
    current[index] = safeUpdated;
    final normalized = safeUpdated.pinned
        ? _normalizePinnedState(current, preferredPinnedId: safeUpdated.id)
        : _normalizePinnedState(current);
    await box.put(_itemsKey, normalized.map((e) => e.toMap()).toList());
  }

  static Future<void> deleteAnnouncement(int id) async {
    final box = await _openBox();
    final current = _readAllFromBox(box);
    current.removeWhere((item) => item.id == id);
    await _writeAllToBox(box, current);
  }

  static Future<void> reorderAnnouncements(int oldIndex, int newIndex) async {
    final box = await _openBox();
    final current = normalizeAnnouncements(_readAllFromBox(box));
    if (oldIndex < 0 || oldIndex >= current.length) return;
    if (newIndex < 0 || newIndex >= current.length) return;

    final item = current.removeAt(oldIndex);
    current.insert(newIndex, item);
    await _writeAllToBox(box, current);
  }

  static Future<void> togglePinnedAnnouncement(int id) async {
    final box = await _openBox();
    final current = normalizeAnnouncements(_readAllFromBox(box));
    final index = current.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final target = current[index];
    final normalized = target.pinned
        ? current.map((item) => item.copyWith(pinned: false)).toList()
        : _normalizePinnedState(current, preferredPinnedId: id);

    await box.put(_itemsKey, normalized.map((e) => e.toMap()).toList());
  }

  static Future<void> moveAnnouncement(int id, int delta) async {
    final box = await _openBox();
    final current = normalizeAnnouncements(_readAllFromBox(box));
    final index = current.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final targetIndex = (index + delta).clamp(0, current.length - 1);
    if (targetIndex == index) return;

    final item = current.removeAt(index);
    current.insert(targetIndex, item);
    await _writeAllToBox(box, current);
  }

  static Future<void> moveAnnouncementUp(int id) async {
    await moveAnnouncement(id, -1);
  }

  static Future<void> moveAnnouncementDown(int id) async {
    await moveAnnouncement(id, 1);
  }

  static Future<void> clearAll() async {
    final box = await _openBox();
    await box.delete(_itemsKey);
  }
}

DisplayAnnouncement? resolveDisplayAnnouncementForFrame(
  List<DisplayAnnouncement> items,
  int frameIndex,
) {
  if (items.isEmpty) return null;

  final sorted = DisplayBoardHiveHelper.normalizeAnnouncements(
    items,
  ).where((item) => item.active).toList();
  if (sorted.isEmpty) return null;

  final pinned = sorted.cast<DisplayAnnouncement?>().firstWhere(
    (item) => item?.pinned == true,
    orElse: () => null,
  );
  if (pinned != null) return pinned;

  return sorted[frameIndex % sorted.length];
}
