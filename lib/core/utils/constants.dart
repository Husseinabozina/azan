import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/models/diker.dart';
import 'package:azan/core/utils/device_kind_helper.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

const String fixedDhikr = "حَسْبُنَا اللّهُ وَنِعْمَ الْوَكِيلُ";

// ✅ Fonts الجديدة (لازم تطابق family في pubspec بالظبط)
const String ksaFont = "KSA";
const String tahaFont = "TAHA";
const String sultanFont = "SULTAN";
const String fodaFont = "FODA";
const String uthmanicFont = "Othmani Regular";
const String uthmanicHafsFont = "uthmanic_hafs_v20";
const String uthmanicHafsV22Font = "UthmanicHafs_V22";
const String uthmanTNv2Font = "UthmanTN_v2-0";
const String uthmanTNBv2Font = "UthmanTNB_v2-0";
const String uthmanTN1v20Font = "uthman_tn1_ver20";
const String uthmanTN1Bv20Font = "uthman_tn1b_ver20";

// ===== CLOCK / TIMES =====
const String freeSerifBoldFont = "FreeSerifBold";
const String freeSansFont = "FreeSans";
const String freeSansBoldFont = "FreeSansBold";
const String fontoFont = "FONTO";
const String stcFont = "STC";

// ===== TEXT =====
const String amiriFont = "Amiri";
const String amiriBoldFont = "AmiriBold";
const String andalusFont = "Andalus";

// جميع الخطوط المتاحة داخل التطبيق في مكان واحد.
const List<String> allAppFonts = [
  freeSerifBoldFont,
  freeSansFont,
  freeSansBoldFont,
  fontoFont,
  stcFont,
  amiriFont,
  amiriBoldFont,
  andalusFont,
  ksaFont,
  tahaFont,
  sultanFont,
  fodaFont,
];

// نفس قائمة الخطوط لكل الأقسام (الوقت/الساعة/النصوص/الأذكار).
const List<String> azkarFonts = allAppFonts;
const List<String> timeFonts = allAppFonts;
const List<String> timesFonts = allAppFonts;
const List<String> textsFonts = allAppFonts;
var kind;

bool isLargeScreen(DeviceKind kind) {
  return kind == DeviceKind.tv ||
      kind == DeviceKind.desktop ||
      kind == DeviceKind.web ||
      kind == DeviceKind.tablet;
}

// const String
List<String> get prayers => [
  LocaleKeys.fajr.tr(),
  LocaleKeys.sunrise.tr(),
  DateHelper.isFriday() ? LocaleKeys.friday.tr() : LocaleKeys.dhuhr.tr(),
  LocaleKeys.asr.tr(),
  LocaleKeys.maghrib.tr(),
  LocaleKeys.isha.tr(),
];

List<String> prayerTimes = [
  "9:00 am",
  "10:00 am",
  "12:00 pm",
  "2:00 pm",
  "4:00 pm",
  "6:00 pm",
];
const String kUiQuarterTurnsKey = 'ui_qt';
Widget nextScreen(BuildContext context) => HomeScreen();
const double prayerFactor = 3;
final List<Dhikr> azkar = [
  // صلاة على النبي ﷺ - يوم الجمعة بس
  Dhikr(
    text: "اللهم صلِّ وسلِّم على نبينا محمد",
    schedule: DhikrSchedule.weekly(weekdays: [DateTime.friday]),
  ),

  // أذكار عامة يومية
  Dhikr(text: "سُبحان الله وبحمده", schedule: DhikrSchedule.daily()),
  Dhikr(
    text:
        "قال ﷺ اللهم ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار",
    schedule: DhikrSchedule.daily(),
  ),
  Dhikr(
    text: "قال ﷺ كفى بالمرء كَذِبًا أن يُحَدِّث بكل ما سمع",
    schedule: DhikrSchedule.daily(),
  ),
  Dhikr(
    text: "قال ﷺ من يُرِدِ اللهُ به خيرًا يُصِبْ منه",
    schedule: DhikrSchedule.daily(),
  ),
  Dhikr(
    text: "قال ﷺ لا يلدغ المؤمن من جُحر واحدٍ مرتين",
    schedule: DhikrSchedule.daily(),
  ),
  Dhikr(
    text: "قال ﷺ الدنيا سجن المؤمن وجنة الكافر",
    schedule: DhikrSchedule.daily(),
  ),
  Dhikr(
    text: "قال ﷺ حُجبت النار بالشهوات، وحجبت الجنة بالمكاره",
    schedule: DhikrSchedule.daily(),
  ),
  Dhikr(
    text: "قال ﷺ لَلـَّهُ أشدُّ فرحاً بتوبة أحدكم من أحدكم بضالته إذا وجدها",
    schedule: DhikrSchedule.daily(),
  ),
  Dhikr(
    text: "قال ﷺ من تاب قبل أن تطلع الشمس من مغربها تاب الله عليه",
    schedule: DhikrSchedule.daily(),
  ),
  Dhikr(
    text: "قال ﷺ لا تَحْقِرَنَّ من المعروف شيئاً ولو أن تلقى أخاك بوجه طلق",
    schedule: DhikrSchedule.daily(),
  ),
  Dhikr(
    text: "قال ﷺ المؤمن للمؤمن كالبنيان يشد بعضه بعضًا",
    schedule: DhikrSchedule.daily(),
  ),
];

const List<String> ayat = [
  "سَيَجْعَلُ اللَّهُ بَعْدَ عُسْرٍ يُسْرًا",                                         // الطلاق ٧
  "وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ",                                  // الطلاق ٣
  "رَّبِّ أَنزِلْنِي مُنزَلًا مُّبَارَكًا وَأَنتَ خَيْرُ الْمُنزِلِينَ",              // المؤمنون ٢٩
  "رَبَّنَا اغْفِرْ لِىَ وَلِوَالِدَىَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ", // إبراهيم ٤١
  "رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا",                            // آل عمران ٨
  "رَبِّ إِنِّي لِمَا أَنزَلْتَ إِلَيَّ مِن خَيْرٍ فَقِيرٌ",                         // القصص ٢٤
  "رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا",                        // البقرة ٢٥٠
  "خُذُواْ زِينَتَكُمْ عِندَ كُلِّ مَسْجِدٍ",                                         // الأعراف ٣١
  "وَكُلُواْ وَٱشْرَبُواْ وَلَا تُسْرِفُواْ",                                          // الأعراف ٣١
  "وَتَوَكَّلْ عَلَى الْحَيِّ الَّذِي لَا يَمُوتُ",                                   // الفرقان ٥٨
  "حَسْبِيَ اللَّهُ لَا إِلَـٰهَ إِلَّا هُوَ",                                        // التوبة ١٢٩
  "إِنَّمَا الْمُؤْمِنُونَ إِخْوَةٌ",                                                  // الحجرات ١٠
  "وَٱلْعَصْرِ * إِنَّ الْإِنسَانَ لَفِى خُسْرٍ",                                     // العصر ١-٢
  "بَلْ هُوَ قُرْآنٌ مَّجِيدٌ فِى لَوْحٍ مَّحْفُوظٍ",                                // البروج ٢١-٢٢
  "وَاذْكُرِ اسْمَ رَبِّكَ وَتَبَتَّلْ إِلَيْهِ تَبْتِيلًا",                           // المزمل ٨
  "فَٱذْكُرُونِىٓ أَذْكُرْكُمْ وَٱشْكُرُوا لِىَ وَلَا تَكْفُرُونِ",                    // البقرة ١٥٢
  "قَدْ أَفْلَحَ مَن تَزَكَّى وَذَكَرَ اسْمَ رَبِّهِ فَصَلَّى",                        // الأعلى ١٤-١٥
  "وَقُل رَّبِّ زِدْنِي عِلْمًا",                                                      // طه ١١٤
];

const String duaaAfterAzan =
    "اللهمَّ ربَّ هذه الدعوةِ التَّامةِ، والصَّلاةِ القائمةِ، آتِ محمَّدًا الوسيلةَ والفضيلةَ، وابعثه مقامًا محمودًا الذي وعدتَه.";
// ادعية من الكتاب والسنة ولسيت أذكار
const List<String> duaas = [
  "اللهم صلِّ وسلِّم على نبينا محمد",
  "قال ﷺ اللهم ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار",
  "رَبَّنَا لَا تُؤَاخِذْنَا إِنْ نَسِينَا أَوْ أَخْطَأْنَا",
  "اللهم مصرِّف القلوب، صرِّف قلوبنا على طاعتك"
      "اللهم إنك عفوٌّ تحب العفو؛ فاعفُ عني"
      "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ",
  "أَنْتَ وَلِيُّنَا فَاغْفِرْ لَنَا وَارْحَمْنَا وَأَنْتَ خَيْرُ الْغَافِرِينَ",
  "اللهم اغفِرْ لي خطيئتي وجهلي، وإسرافي في أمري، وما أنت أعلمُ به مني",
  "اللهم بارِكْ لهم فيما رزقتهم، واغفر لهم وارحمهم",
  "اللهم إني أعوذ بك من شرِّ ما عملتُ، ومن شر ما لم أعمل",
];

const String unifiedNumber = "7033223111";
