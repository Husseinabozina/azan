class UmmAlQuraScheduleDay {
  final String bundleId;
  final String hijriYmd;
  final String gregorianYmd;
  final String weekdayEn;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final int sourceHijriYear;

  const UmmAlQuraScheduleDay({
    required this.bundleId,
    required this.hijriYmd,
    required this.gregorianYmd,
    required this.weekdayEn,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.sourceHijriYear,
  });

  factory UmmAlQuraScheduleDay.fromJson(
    Map<String, dynamic> json, {
    required String bundleId,
    required int sourceHijriYear,
  }) {
    return UmmAlQuraScheduleDay(
      bundleId: bundleId,
      hijriYmd: (json['hijri'] as String?) ?? '',
      gregorianYmd: (json['gregorian'] as String?) ?? '',
      weekdayEn: (json['weekday_en'] as String?) ?? '',
      fajr: (json['fajr'] as String?) ?? '',
      sunrise: (json['sunrise'] as String?) ?? '',
      dhuhr: (json['dhuhr'] as String?) ?? '',
      asr: (json['asr'] as String?) ?? '',
      maghrib: (json['maghrib'] as String?) ?? '',
      isha: (json['isha'] as String?) ?? '',
      sourceHijriYear: sourceHijriYear,
    );
  }

  List<String> get timeStrings => [fajr, sunrise, dhuhr, asr, maghrib, isha];
}
