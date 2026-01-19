import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/models/diker.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:azan/views/home/home_screen_landscape.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:azan/views/select_location/select_location_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

const String fixedDhikr = "حَسْبُنَا اللّهُ وَنِعْمَ الْوَكِيلُ";
const String ksaFont = "KSA";
const String tajwalFont = "Tajwal";
const String tahaFont = "Taha";
const String freeSpansFont = "FreeSpans";
const String sultanFont = "Sultan";
const String fodaFont = "Foda";

const List<String> azkarFonts = [ksaFont, tahaFont, sultanFont, fodaFont];
const List<String> timeFonts = [tajwalFont, freeSpansFont, sultanFont];
const List<String> timesFonts = [tajwalFont, freeSpansFont, sultanFont];
const List<String> textsFonts = [tajwalFont, freeSpansFont, sultanFont];

var kind;
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
Widget nextScreen(BuildContext context) => !CacheHelper.getFirstAppOpen()
    ? SelectLocationScreen()
    : MediaQuery.of(context).orientation == Orientation.landscape
    ? HomeScreenLandscape()
    : HomeScreenMobile();
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

const String duaaAfterAzan =
    " الَّلهمَّ ربَّ هذه الدعوةِ التَّامةِ ، و الصَّلاةِ القائمةِ آتِ محمَّدًا الوسيلةَ و الفَضيلةَ ، و ابعثه مقامًا محمودًا الَّذي وعدته";
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
