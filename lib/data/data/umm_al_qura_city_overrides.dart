class UmmAlQuraCityOverride {
  final String nameAr;
  final String? legacyNameEn;
  final double? lat;
  final double? lon;
  final List<String> aliases;

  const UmmAlQuraCityOverride({
    required this.nameAr,
    this.legacyNameEn,
    this.lat,
    this.lon,
    this.aliases = const <String>[],
  });
}

const Map<String, UmmAlQuraCityOverride> kUmmAlQuraCityOverrides = {
  'abqaiq': UmmAlQuraCityOverride(nameAr: 'بقيق'),
  'ad-diriyah': UmmAlQuraCityOverride(
    nameAr: 'الدرعية',
    legacyNameEn: 'Diriyah',
  ),
  'addayer': UmmAlQuraCityOverride(nameAr: 'الداير', aliases: ['Ad Dayer']),
  'ahad-al-masarihah': UmmAlQuraCityOverride(nameAr: 'أحد المسارحة'),
  'ahad-rafidah': UmmAlQuraCityOverride(nameAr: 'أحد رفيدة'),
  'al-aflaj': UmmAlQuraCityOverride(nameAr: 'الأفلاج'),
  'al-aridhah': UmmAlQuraCityOverride(nameAr: 'العارضة'),
  'al-badayea': UmmAlQuraCityOverride(nameAr: 'البدائع'),
  'al-duwadimi': UmmAlQuraCityOverride(
    nameAr: 'الدوادمي',
    legacyNameEn: 'Ad Dawadimi',
  ),
  'al-edabi': UmmAlQuraCityOverride(
    nameAr: 'العيدابي',
    legacyNameEn: 'Al Eidabi',
  ),
  'al-ghat': UmmAlQuraCityOverride(nameAr: 'الغاط'),
  'al-ghazalah': UmmAlQuraCityOverride(nameAr: 'الغزالة'),
  'al-hariq': UmmAlQuraCityOverride(nameAr: 'الحريق'),
  'al-henakiyah': UmmAlQuraCityOverride(
    nameAr: 'الحناكية',
    legacyNameEn: 'Al Hanakiyah',
  ),
  'al-hofuf': UmmAlQuraCityOverride(nameAr: 'الهفوف', legacyNameEn: 'Al Hufuf'),
  'al-jubail': UmmAlQuraCityOverride(nameAr: 'الجبيل', legacyNameEn: 'Jubail'),
  'al-kharkhir': UmmAlQuraCityOverride(nameAr: 'الخرخير'),
  'al-khobar': UmmAlQuraCityOverride(nameAr: 'الخبر', legacyNameEn: 'Khobar'),
  'al-khurma': UmmAlQuraCityOverride(
    nameAr: 'الخرمة',
    legacyNameEn: 'Al Khurmah',
  ),
  'al-majmaah': UmmAlQuraCityOverride(
    nameAr: 'المجمعة',
    legacyNameEn: 'Majmaah',
  ),
  'al-makhwah': UmmAlQuraCityOverride(
    nameAr: 'المخواة',
    legacyNameEn: 'Al Mikhwah',
  ),
  'al-mithnab': UmmAlQuraCityOverride(
    nameAr: 'المذنب',
    legacyNameEn: 'Al Midhnab',
  ),
  'al-namas': UmmAlQuraCityOverride(nameAr: 'النماص', legacyNameEn: 'An Namas'),
  'al-qatif': UmmAlQuraCityOverride(nameAr: 'القطيف', legacyNameEn: 'Qatif'),
  'al-quwaiiyah': UmmAlQuraCityOverride(
    nameAr: 'القويعية',
    legacyNameEn: 'Al Quwayiyah',
  ),
  'al-reeth': UmmAlQuraCityOverride(nameAr: 'الريث', legacyNameEn: 'Ar Rayth'),
  'alasyah': UmmAlQuraCityOverride(nameAr: 'الأسياح'),
  'alharth': UmmAlQuraCityOverride(nameAr: 'الحرث'),
  'almajaridah': UmmAlQuraCityOverride(nameAr: 'المجاردة'),
  'almandaq': UmmAlQuraCityOverride(
    nameAr: 'المندق',
    legacyNameEn: 'Al Mandaq',
  ),
  'alqeyas': UmmAlQuraCityOverride(nameAr: 'القياس'),
  'alqura': UmmAlQuraCityOverride(nameAr: 'القرى'),
  'ash-shimasiyah': UmmAlQuraCityOverride(nameAr: 'الشماسية'),
  'ash-shinan': UmmAlQuraCityOverride(nameAr: 'الشنان'),
  'badr-al-janoub': UmmAlQuraCityOverride(
    nameAr: 'بدر الجنوب',
    legacyNameEn: 'Badr Al Janub',
  ),
  'baish': UmmAlQuraCityOverride(nameAr: 'بيش'),
  'baqaa': UmmAlQuraCityOverride(nameAr: 'بقعاء', legacyNameEn: 'Buqayah'),
  'belqarn': UmmAlQuraCityOverride(nameAr: 'بلقرن'),
  'dhahran-al-janub': UmmAlQuraCityOverride(
    nameAr: 'ظهران الجنوب',
    legacyNameEn: 'Dhahran',
    aliases: ['Dhahran Al Janub'],
  ),
  'dhurma': UmmAlQuraCityOverride(nameAr: 'ضرما'),
  'dumah-al-jandal': UmmAlQuraCityOverride(
    nameAr: 'دومة الجندل',
    legacyNameEn: 'Dawmat Al Jandal',
  ),
  'farasan-island': UmmAlQuraCityOverride(
    nameAr: 'فرسان',
    legacyNameEn: 'Farasan',
  ),
  'haql': UmmAlQuraCityOverride(nameAr: 'حقل'),
  'howtat-bani-tamim': UmmAlQuraCityOverride(
    nameAr: 'حوطة بني تميم',
    legacyNameEn: 'Hawtat Bani Tamim',
  ),
  'hubuna': UmmAlQuraCityOverride(nameAr: 'حبونا', legacyNameEn: 'Habuna'),
  'huraymila': UmmAlQuraCityOverride(nameAr: 'حريملاء'),
  'khafji': UmmAlQuraCityOverride(nameAr: 'الخفجي', legacyNameEn: 'Al Khafji'),
  'khaybar': UmmAlQuraCityOverride(nameAr: 'خيبر'),
  'khbash': UmmAlQuraCityOverride(nameAr: 'خباش'),
  'khulais': UmmAlQuraCityOverride(nameAr: 'خليص'),
  'mahd-al-thahab': UmmAlQuraCityOverride(
    nameAr: 'مهد الذهب',
    legacyNameEn: 'Mahd Adh Dhahab',
  ),
  'mecca': UmmAlQuraCityOverride(nameAr: 'مكة المكرمة', legacyNameEn: 'Makkah'),
  'medina': UmmAlQuraCityOverride(
    nameAr: 'المدينة المنورة',
    legacyNameEn: 'Madinah',
  ),
  'muhayil': UmmAlQuraCityOverride(
    nameAr: 'محايل',
    legacyNameEn: 'Muhayil Asir',
  ),
  'nairyah': UmmAlQuraCityOverride(
    nameAr: 'النعيرية',
    legacyNameEn: 'An Nairyiah',
  ),
  'qaryat-al-ulya': UmmAlQuraCityOverride(nameAr: 'قرية العليا'),
  'ranyah': UmmAlQuraCityOverride(nameAr: 'رنية'),
  'ras-tanura': UmmAlQuraCityOverride(nameAr: 'رأس تنورة'),
  'riyadh-al-khabra': UmmAlQuraCityOverride(nameAr: 'رياض الخبراء'),
  'rojal': UmmAlQuraCityOverride(
    nameAr: 'رجال ألمع',
    legacyNameEn: 'Rijal Almaa',
  ),
  'rumah': UmmAlQuraCityOverride(nameAr: 'رماح'),
  'shagra': UmmAlQuraCityOverride(nameAr: 'شقراء', legacyNameEn: 'Shaqra'),
  'sharorah': UmmAlQuraCityOverride(nameAr: 'شرورة', legacyNameEn: 'Sharurah'),
  'tathleeth': UmmAlQuraCityOverride(nameAr: 'تثليث'),
  'thadig': UmmAlQuraCityOverride(nameAr: 'ثادق'),
  'thar': UmmAlQuraCityOverride(nameAr: 'ثار'),
  'turbah': UmmAlQuraCityOverride(nameAr: 'تربة'),
  'umluj': UmmAlQuraCityOverride(nameAr: 'أملج', legacyNameEn: 'Amlaj'),
  'uyun-al-jawa': UmmAlQuraCityOverride(nameAr: 'عيون الجواء'),
  'wadi-ad-dawasir': UmmAlQuraCityOverride(
    nameAr: 'وادي الدواسر',
    legacyNameEn: 'Wadi Al Dawasir',
  ),
  'yadamah': UmmAlQuraCityOverride(nameAr: 'يدمة'),
};
