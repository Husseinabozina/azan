import 'package:azan/core/helpers/prayer_calendar_helper.dart';

class PrayerCalendarDay {
  static const int prayerCount = 6;

  final String cityKey;
  final String gregorianYmd;
  final List<int> generatedAdhanMinutes;
  final Map<int, int> manualAdhanMinutesByPrayerId;
  final Map<int, int> manualIqamaMinutesByPrayerId;
  final int generatedAtMs;
  final int updatedAtMs;

  const PrayerCalendarDay({
    required this.cityKey,
    required this.gregorianYmd,
    required this.generatedAdhanMinutes,
    required this.manualAdhanMinutesByPrayerId,
    required this.manualIqamaMinutesByPrayerId,
    required this.generatedAtMs,
    required this.updatedAtMs,
  });

  factory PrayerCalendarDay.generated({
    required String cityKey,
    required DateTime date,
    required List<int> generatedAdhanMinutes,
    DateTime? generatedAt,
  }) {
    final stamp = (generatedAt ?? DateTime.now()).millisecondsSinceEpoch;
    return PrayerCalendarDay(
      cityKey: cityKey,
      gregorianYmd: PrayerCalendarHelper.ymdForDate(date),
      generatedAdhanMinutes: _normalizeGeneratedList(generatedAdhanMinutes),
      manualAdhanMinutesByPrayerId: const {},
      manualIqamaMinutesByPrayerId: const {},
      generatedAtMs: stamp,
      updatedAtMs: stamp,
    );
  }

  DateTime get gregorianDate => PrayerCalendarHelper.dateFromYmd(gregorianYmd);

  bool get hasManualOverrides =>
      manualAdhanMinutesByPrayerId.isNotEmpty ||
      manualIqamaMinutesByPrayerId.isNotEmpty;

  bool hasPrayerOverride(int prayerId) {
    return manualAdhanMinutesByPrayerId.containsKey(prayerId) ||
        manualIqamaMinutesByPrayerId.containsKey(prayerId);
  }

  int? generatedMinutesForPrayerId(int prayerId) {
    final index = prayerId - 1;
    if (index < 0 || index >= generatedAdhanMinutes.length) {
      return null;
    }
    return generatedAdhanMinutes[index];
  }

  DateTime? generatedDateTimeForPrayerId(int prayerId) {
    final minutes = generatedMinutesForPrayerId(prayerId);
    if (minutes == null) return null;
    return PrayerCalendarHelper.dateTimeFromMinutes(gregorianDate, minutes);
  }

  int? manualAdhanMinutesForPrayerId(int prayerId) {
    return manualAdhanMinutesByPrayerId[prayerId];
  }

  int? manualIqamaMinutesForPrayerId(int prayerId) {
    return manualIqamaMinutesByPrayerId[prayerId];
  }

  DateTime? manualAdhanDateTimeForPrayerId(int prayerId) {
    final minutes = manualAdhanMinutesForPrayerId(prayerId);
    if (minutes == null) return null;
    return PrayerCalendarHelper.dateTimeFromMinutes(gregorianDate, minutes);
  }

  DateTime? manualIqamaDateTimeForPrayerId(int prayerId) {
    final minutes = manualIqamaMinutesForPrayerId(prayerId);
    if (minutes == null) return null;
    return PrayerCalendarHelper.dateTimeFromMinutes(gregorianDate, minutes);
  }

  PrayerCalendarDay copyWith({
    String? cityKey,
    String? gregorianYmd,
    List<int>? generatedAdhanMinutes,
    Map<int, int>? manualAdhanMinutesByPrayerId,
    Map<int, int>? manualIqamaMinutesByPrayerId,
    int? generatedAtMs,
    int? updatedAtMs,
  }) {
    return PrayerCalendarDay(
      cityKey: cityKey ?? this.cityKey,
      gregorianYmd: gregorianYmd ?? this.gregorianYmd,
      generatedAdhanMinutes:
          generatedAdhanMinutes ?? List<int>.from(this.generatedAdhanMinutes),
      manualAdhanMinutesByPrayerId:
          manualAdhanMinutesByPrayerId ??
          Map<int, int>.from(this.manualAdhanMinutesByPrayerId),
      manualIqamaMinutesByPrayerId:
          manualIqamaMinutesByPrayerId ??
          Map<int, int>.from(this.manualIqamaMinutesByPrayerId),
      generatedAtMs: generatedAtMs ?? this.generatedAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  PrayerCalendarDay withPrayerOverride({
    required int prayerId,
    int? manualAdhanMinutes,
    int? manualIqamaMinutes,
    bool clearManualAdhan = false,
    bool clearManualIqama = false,
    DateTime? updatedAt,
  }) {
    final adhanMap = Map<int, int>.from(manualAdhanMinutesByPrayerId);
    final iqamaMap = Map<int, int>.from(manualIqamaMinutesByPrayerId);

    if (clearManualAdhan) {
      adhanMap.remove(prayerId);
    } else if (manualAdhanMinutes != null) {
      adhanMap[prayerId] = manualAdhanMinutes;
    }

    if (clearManualIqama) {
      iqamaMap.remove(prayerId);
    } else if (manualIqamaMinutes != null) {
      iqamaMap[prayerId] = manualIqamaMinutes;
    }

    return copyWith(
      manualAdhanMinutesByPrayerId: adhanMap,
      manualIqamaMinutesByPrayerId: iqamaMap,
      updatedAtMs: (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
    );
  }

  PrayerCalendarDay clearPrayerOverrides(int prayerId, {DateTime? updatedAt}) {
    final adhanMap = Map<int, int>.from(manualAdhanMinutesByPrayerId)
      ..remove(prayerId);
    final iqamaMap = Map<int, int>.from(manualIqamaMinutesByPrayerId)
      ..remove(prayerId);

    return copyWith(
      manualAdhanMinutesByPrayerId: adhanMap,
      manualIqamaMinutesByPrayerId: iqamaMap,
      updatedAtMs: (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
    );
  }

  PrayerCalendarDay clearAllOverrides({DateTime? updatedAt}) {
    return copyWith(
      manualAdhanMinutesByPrayerId: <int, int>{},
      manualIqamaMinutesByPrayerId: <int, int>{},
      updatedAtMs: (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cityKey': cityKey,
      'gregorianYmd': gregorianYmd,
      'generatedAdhanMinutes': List<int>.from(generatedAdhanMinutes),
      'manualAdhanMinutesByPrayerId': manualAdhanMinutesByPrayerId.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'manualIqamaMinutesByPrayerId': manualIqamaMinutesByPrayerId.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'generatedAtMs': generatedAtMs,
      'updatedAtMs': updatedAtMs,
    };
  }

  factory PrayerCalendarDay.fromMap(Map<String, dynamic> map) {
    return PrayerCalendarDay(
      cityKey: (map['cityKey'] as String?) ?? 'unknown_city',
      gregorianYmd: map['gregorianYmd'] as String,
      generatedAdhanMinutes: _normalizeGeneratedList(
        (map['generatedAdhanMinutes'] as List<dynamic>? ?? const <dynamic>[])
            .map((value) => _toInt(value))
            .toList(),
      ),
      manualAdhanMinutesByPrayerId: _normalizePrayerMinutesMap(
        map['manualAdhanMinutesByPrayerId'],
      ),
      manualIqamaMinutesByPrayerId: _normalizePrayerMinutesMap(
        map['manualIqamaMinutesByPrayerId'],
      ),
      generatedAtMs: _toInt(map['generatedAtMs']),
      updatedAtMs: _toInt(map['updatedAtMs']),
    );
  }

  static List<int> _normalizeGeneratedList(List<dynamic> raw) {
    final normalized = List<int>.filled(prayerCount, 0);
    for (var i = 0; i < normalized.length; i++) {
      if (i < raw.length) {
        normalized[i] = _toInt(raw[i]);
      }
    }
    return normalized;
  }

  static Map<int, int> _normalizePrayerMinutesMap(dynamic raw) {
    if (raw is! Map) return <int, int>{};

    final result = <int, int>{};
    raw.forEach((key, value) {
      final prayerId = int.tryParse(key.toString());
      if (prayerId == null || prayerId < 1 || prayerId > prayerCount) {
        return;
      }
      result[prayerId] = _toInt(value);
    });
    return result;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
