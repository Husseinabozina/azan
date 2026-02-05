class AzanAdjustSettings {
  final bool ramadanIshaPlus30;
  final bool summerPlusHour;

  /// -60 / 0 / +60 (انت حر توسعها بس ده اللي احنا شغالين بيه)
  final int manualAllShiftMinutes;

  /// 6 عناصر بالترتيب: fajr,sunrise,dhuhr,asr,maghrib,isha
  final List<int> perPrayerMinutes;

  const AzanAdjustSettings({
    required this.ramadanIshaPlus30,
    required this.summerPlusHour,
    required this.manualAllShiftMinutes,
    required this.perPrayerMinutes,
  });

  factory AzanAdjustSettings.defaults() => const AzanAdjustSettings(
    ramadanIshaPlus30: true,
    summerPlusHour: false,
    manualAllShiftMinutes: 0,
    perPrayerMinutes: [0, 0, 0, 0, 0, 0],
  );

  AzanAdjustSettings copyWith({
    bool? ramadanIshaPlus30,
    bool? summerPlusHour,
    int? manualAllShiftMinutes,
    List<int>? perPrayerMinutes,
  }) {
    return AzanAdjustSettings(
      ramadanIshaPlus30: ramadanIshaPlus30 ?? this.ramadanIshaPlus30,
      summerPlusHour: summerPlusHour ?? this.summerPlusHour,
      manualAllShiftMinutes:
          manualAllShiftMinutes ?? this.manualAllShiftMinutes,
      perPrayerMinutes: perPrayerMinutes ?? this.perPrayerMinutes,
    );
  }

  /// ✅ تأمين الطول + clamping
  AzanAdjustSettings normalized() {
    // manual shift: خلّيه -60/0/+60 بس
    int ms = manualAllShiftMinutes;
    if (ms != -60 && ms != 0 && ms != 60) ms = 0;

    final list = List<int>.from(perPrayerMinutes);
    while (list.length < 6) list.add(0);
    if (list.length > 6) list.removeRange(6, list.length);

    // clamp كل صلاة (مثلاً -180..+180)
    for (var i = 0; i < list.length; i++) {
      list[i] = list[i].clamp(-180, 180);
    }

    return copyWith(manualAllShiftMinutes: ms, perPrayerMinutes: list);
  }

  Map<String, dynamic> toJson() => {
    "ramadanIshaPlus30": ramadanIshaPlus30,
    "summerPlusHour": summerPlusHour,
    "manualAllShiftMinutes": manualAllShiftMinutes,
    "perPrayerMinutes": perPrayerMinutes,
  };

  factory AzanAdjustSettings.fromJson(Map<String, dynamic> json) {
    final list = (json["perPrayerMinutes"] is List)
        ? (json["perPrayerMinutes"] as List)
              .map((e) => (e as num).toInt())
              .toList()
        : <int>[0, 0, 0, 0, 0, 0];

    return AzanAdjustSettings(
      ramadanIshaPlus30: (json["ramadanIshaPlus30"] as bool?) ?? true,
      summerPlusHour: (json["summerPlusHour"] as bool?) ?? false,
      manualAllShiftMinutes:
          (json["manualAllShiftMinutes"] as num?)?.toInt() ?? 0,
      perPrayerMinutes: list,
    ).normalized();
  }
}
