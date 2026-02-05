import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/components/flash_dialoge.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/helpers/location_helper.dart';
import 'package:azan/core/helpers/simple_sound_player.dart';
import 'package:azan/core/models/next_Iqama.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/selection_dialoge.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/azan_prayer_screen.dart';
import 'package:azan/views/home/components/RotatingAyahBanner.dart';
import 'package:azan/views/home/components/azan_time_tile.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:azan/views/home/components/home_appbar.dart';
import 'package:azan/views/home/components/home_star_hint.dart';
import 'package:azan/views/home/components/live_clock_row.dart';
import 'package:azan/views/home/components/prayer_row_data.dart';
import 'package:azan/views/home/components/prayer_times_header_row.dart';
import 'package:azan/views/home/components/prayer_times_table.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';
// import 'package:azan/core/utils/screenutil_flip_ext.dart';
// import 'package:azan/core/utils/screenutil_flip_ext.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:azan/core/models/prayer.dart' as prayerModel;
import 'package:fl_chart/fl_chart.dart';

class HomeScreenMobile extends StatefulWidget {
  const HomeScreenMobile({super.key});

  @override
  State<HomeScreenMobile> createState() => HomeScreenMobileState();
}

class HomeScreenMobileState extends State<HomeScreenMobile> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  AppCubit get cubit => AppCubit.get(context);
  late DateTime _lastDate;

  // ✅ الصوت
  final SimpleSoundPlayer _soundPlayer = SimpleSoundPlayer();

  // ✅ عشان ما يكررش الصوت لنفس الصلاة في نفس اليوم
  final Set<int> _playedAdhanToday = <int>{};
  final Set<int> _playedIqamaToday = <int>{};

  // ✅ Timers
  Timer? _tickTimer; // كل ثانية للساعة/الصوت/فتح شاشة الأذان
  Timer? _minuteTimer; // كل دقيقة لتحديث futures

  // ✅ Futures (ما تتولدش في build)
  Future<bool> _hideFuture = Future.value(false);
  Future<prayerModel.Prayer?> _nextPrayerFuture = Future.value(null);

  bool isloading = false;

  // =========================
  //  Helpers
  // =========================

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSameMinute(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute;

  Future<void> _assignHijriDate() async {
    await cubit.getTodayHijriDate(context);
  }

  void _onNewDay() {
    _playedAdhanToday.clear();
    _playedIqamaToday.clear();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _initDayData();
    });
  }

  void _initDayData() {
    unawaited(_assignHijriDate());

    final city = cubit.getCity()?.nameEn ?? '';
    unawaited(cubit.initializePrayerTimes(city: city, context: context));
    unawaited(cubit.loadTodayMaxTemp(country: 'Saudi Arabia', city: city));
    unawaited(cubit.getIqamaTime());
    unawaited(cubit.assignAdhkar());

    // بعد تحديثات اليوم (حتى لو async)، جدّد الـ futures
    _refreshMinuteFutures();
  }

  // =========================
  //  Minute refresh (futures)
  // =========================

  void _refreshMinuteFutures() {
    // ⚠️ لازم cubit يكون متعين + prayerTimes تكون جاهزة
    _hideFuture = isAfterFixedTimeForIshaaOrSunrise(context: context);

    _nextPrayerFuture = cubit.nextPrayer(context).then((p) {
      // ✅ حدث nextPrayerVar هنا خارج build (من غير emit) عشان كود الإقامة بتاعك
      cubit.nextPrayerVar = p;
      return p;
    });
  }

  // =========================
  //  Timers
  // =========================

  void _startTimers() {
    _tickTimer?.cancel();
    _minuteTimer?.cancel();

    // ✅ أول مرة قبل ما التايمرز تبدأ
    _refreshMinuteFutures();

    // ✅ كل ثانية: ساعة + صوت + دخول شاشة الأذان + check day rollover
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      setState(
        () {},
      ); // لو عايز الساعة تتحرك وكل الواجهة تتبني (ممكن نخففها بعدين)

      _checkAndPlayPrayerSound(DateTime.now());
      performAdhanActions(context);

      final now = DateTime.now();
      if (!_isSameDay(now, _lastDate)) {
        _lastDate = now;
        _onNewDay();
      }
    });

    // ✅ كل دقيقة: حدّث futures مرة واحدة
    _minuteTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {
        _refreshMinuteFutures();
      });
    });
  }

  // =========================
  //  Main work
  // =========================

  Future<void> homeScreenWork() async {
    if (!mounted) return;
    setState(() => isloading = true);

    _lastDate = DateTime.now();

    final city = cubit.getCity()?.nameEn ?? '';
    await _assignHijriDate();

    // ✅ استنى الأساسيات فقط
    (await Future.wait([
      cubit.getIqamaTime(),
      cubit.initializePrayerTimes(city: city, context: context),
    ]));

    if (!mounted) return;
    setState(() => isloading = false);

    // ✅ الباقي في الخلفية
    // unawaited(_assignHijriDate());
    unawaited(cubit.loadTodayMaxTemp(country: 'Saudi Arabia', city: city));
    unawaited(cubit.assignAdhkar());

    // ✅ شغل التايمرز بعد ما الأساسيات خلصت
    _startTimers();
  }

  @override
  void initState() {
    super.initState();
    AppCubit.get(context).homeScreenMobile = this;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (!mounted) return;
      homeScreenWork();
    });
  }

  // =========================
  //  Actions you already have
  // =========================

  void performAdhanActions(BuildContext context) {
    if (cubit.prayerTimes == null) return;

    final prayers = cubit.prayers(context);
    for (final prayer in prayers) {
      final DateTime? adhanTime = prayer.dateTime;
      if (adhanTime == null) continue;

      if (_isSameMinute(adhanTime, DateTime.now())) {
        setState(() {
          cubit.currentPrayer = prayer;
          CacheHelper.setCurrentPrayerKey(prayer.title);

          cubit.showPrayerAzanPage = true;
        });
      }
    }
  }

  void _checkAndPlayPrayerSound(DateTime now) {
    if (cubit.prayerTimes == null || cubit.iqamaMinutes == null) return;

    final prayers = cubit.prayers(context);
    final iqamaMinutes = cubit.iqamaMinutes!;
    final azanSource = cubit.getAzanSoundSource;
    final iqamaSource = cubit.getIqamaSoundSource;

    for (final prayer in prayers) {
      final int id = prayer.id;
      final DateTime? adhanTime = prayer.dateTime;
      if (adhanTime == null) continue;

      // 1️⃣ وقت الأذان
      if (!_playedAdhanToday.contains(id) && _isSameMinute(adhanTime, now)) {
        _playedAdhanToday.add(id);
        _soundPlayer.playAdhanPing(azanSource);
      }

      // 2️⃣ وقت الإقامة
      if (iqamaMinutes.length >= id) {
        final DateTime iqamaTime = adhanTime.add(
          Duration(minutes: iqamaMinutes[id - 1]),
        );

        // ✅ حماية من null بدل nextPrayerVar!
        final nextVarTime = cubit.nextPrayerVar?.dateTime;
        final currentTime = cubit.currentPrayer?.dateTime;

        if (currentTime != null &&
            nextVarTime != null &&
            iqamaTime.isBefore(nextVarTime) &&
            iqamaTime.isAfter(currentTime)) {
          cubit.nextAdhan = NextAdhan(
            title: cubit.nextPrayerVar!.title,
            adhanType: AdhanType.iqamaa,
          );
        } else {
          cubit.nextAdhan = NextAdhan(
            title: cubit.nextPrayerVar?.title ?? '',
            adhanType: AdhanType.adhan,
          );
        }

        if (!_playedIqamaToday.contains(id) && _isSameMinute(iqamaTime, now)) {
          _playedIqamaToday.add(id);
          _soundPlayer.playIqamaPing(iqamaSource);
        }
      }
    }
  }

  // =========================
  //  Your hide logic (as-is)
  // =========================

  Future<bool> isAfterFixedTimeForIshaaOrSunrise({
    required BuildContext context,
    Duration stopBeforeNextPrayerBy = const Duration(hours: 2),
  }) async {
    if (cubit.currentPrayer == null) return false;

    final prayer = cubit.currentPrayer;
    final prayerTime = prayer?.dateTime;
    if (prayer == null || prayerTime == null) return false;

    const ishaaId = 6;
    const sunriseId = 2;

    final int offsetMinutes;
    if (prayer.id == ishaaId) {
      offsetMinutes = CacheHelper.getHideScreenAfterIshaaMinutes();
    } else if (prayer.id == sunriseId) {
      offsetMinutes = CacheHelper.getHideScreenAfterSunriseMinutes();
    } else {
      return false;
    }

    final now = DateTime.now();
    final start = prayerTime.add(Duration(minutes: offsetMinutes));
    if (now.isBefore(start)) return false;

    final next = await cubit.nextPrayer(context);
    final nextTime = next?.dateTime;
    if (nextTime == null) return true;

    final end = nextTime.subtract(stopBeforeNextPrayerBy);
    if (!end.isAfter(start)) return false;

    return now.isBefore(end);
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _minuteTimer?.cancel();
    _soundPlayer.dispose();
    super.dispose();
  }

  Widget temperatureWidget({
    required BuildContext context,
    required String tempText, // بعد ما تعمل Arabic digits لو محتاج
  }) {
    final style = TextStyle(
      fontSize: 30.sp,
      fontWeight: FontWeight.bold,
      color: AppTheme.secondaryTextColor,
    );

    return Text("$tempText°", style: style);

    //  Text.rich(
    //   TextSpan(
    //     children: [
    //       TextSpan(text: tempText, style: style),

    //       // النقطة (علامة الدرجة)
    //       WidgetSpan(
    //         alignment: PlaceholderAlignment.top,
    //         child: Transform.translate(
    //           offset: tempText.contains('-')
    //               ? Offset(25.w, -25.h)
    //               : Offset(39.w, -33.h), // عدّلها مرة وخلاص
    //           child: Container(
    //             width: 8.r,
    //             height: 8.r,
    //             decoration: BoxDecoration(
    //               color: AppTheme.primaryTextColor,
    //               shape: BoxShape.circle,
    //             ),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    //   maxLines: 1,
    //   overflow: TextOverflow.visible,
    // );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<bool> pastIqamaFlags = cubit.prayers(context).map((p) {
      if (p.dateTime == null ||
          cubit.iqamaMinutes == null ||
          cubit.iqamaMinutes!.length < p.id) {
        return false;
      }

      final iqamaTime = p.dateTime!.add(
        Duration(minutes: cubit.iqamaMinutes![p.id - 1]),
      );

      return iqamaTime.isBefore(now);
    }).toList();
    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(context: context),

      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {
          if (state is FetchPrayerTimesFailure) {
            showFlashMessage(
              message: state.message,
              type: FlashMessageType.error,
              context: context,
            );
          }
        },
        builder: (context, state) {
          final enableGlass =
              CacheHelper.getEnableGlassEffect(); // 👈 لو عايزه “true = glass شغال”

          final headerStyle = TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
            fontFamily: CacheHelper.getTextsFontFamily(),
          );

          final prayerStyle = TextStyle(
            fontFamily: CacheHelper.getTimesFontFamily(),
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          );

          final adhanStyle = TextStyle(
            fontFamily: CacheHelper.getTimesFontFamily(),
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryTextColor,
          );

          final iqamaStyle = TextStyle(
            fontFamily: CacheHelper.getTimesFontFamily(),
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          );

          final rows = List.generate(cubit.prayers(context).length, (index) {
            final p = cubit.prayers(context)[index];

            final dimmed =
                index < pastIqamaFlags.length && pastIqamaFlags[index];

            final adhanStr = CacheHelper.getUse24HoursFormat()
                ? (p.time24 ?? '--:--')
                : (p.time ?? '--:--');

            final iqamaStr = (p.time != null && cubit.iqamaMinutes != null)
                ? DateHelper.addMinutesToTimeStringWithSettings(
                    p.time!,
                    cubit.iqamaMinutes![p.id - 1],
                    context,
                  )
                : '--:--';

            return PrayerRowData(
              prayerName: p.title,
              adhanTime: adhanStr,
              iqamaTime: iqamaStr,
              dimmed: dimmed,
            );
          });
          return Stack(
            children: [
              Image.asset(
                CacheHelper.getSelectedBackground(),

                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fill,
              ),

              Padding(
                padding: EdgeInsets.only(
                  // top: MediaQuery.of(context).padding.top,
                  // bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: EdgeInsets.only(),
                  child: isloading
                      ? Center(
                          child: Column(
                            children: [
                              SizedBox(
                                // height: 32.h,
                                child: HomeAppBar(
                                  onDrawerTap: () {
                                    scaffoldKey.currentState?.openDrawer();
                                  },
                                ),
                              ),

                              // Spacer(flex: 2),
                              VerticalSpace(height: 300),
                              Center(
                                child: SizedBox(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: AppTheme.primaryTextColor,
                                      ),
                                      VerticalSpace(height: 8),
                                      Text(
                                        LocaleKeys.loading.tr(),
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      :
                        // // SizedBox(
                        // //     width: 1.sw,
                        // //     height: 1.sh,
                        // //     // child: Column(
                        // //     //   children: [
                        // //     //     Container(
                        // //     //       color: Colors.red,
                        // //     //       height: 100.w,
                        // //     //       width: 448,
                        // //     //     ),
                        // //     //     // Container(
                        // //     //     //   color: Colors.red,
                        // //     //     //   height: 100.h,
                        // //     //     //   width: 50.w,
                        // //     //     // ),
                        // //     //     // Container(
                        // //     //     //   color: Colors.red,
                        // //     //     //   height: 100.h,
                        // //     //     //   width: 50.w,
                        // //     //     // ),
                        // //     //     // // Text(
                        // //     //     // //   'home screen mobile',
                        // //     //     // //   style: TextStyle(
                        // //     //     // //     fontSize: 50.sp,
                        // //     //     // //     fontWeight: FontWeight.bold,
                        // //     //     // //     color: AppTheme.primaryTextColor,
                        // //     //     // //   ),
                        // //     //     // // ),
                        // //     //     // Container(
                        // //     //     //   height: 93.h,
                        // //     //     //   width: 50.w,
                        // //     //     //   color: Colors.red,
                        // //     //     // ),
                        // //     //   ],
                        // //     // ),
                        // //     //  Column(
                        // //     //   children: [
                        // //     //     // Container(
                        // //     //     //   color: Colors.red,
                        // //     //     //   height: 540.h,
                        // //     //     //   width: 960.w,
                        // //     //     // ),
                        // //     //     Container(
                        // //     //       color: Colors.red,
                        // //     //       height: 852.h,
                        // //     //       width: 393.w,
                        // //     //     ),
                        // //     //     // Container(
                        // //     //     //   color: Colors.red,
                        // //     //     //   height: ScreenUtil().setHeight(200),
                        // //     //     //   width: ScreenUtil().setWidth(200),
                        // //     //     // ),
                        // //     //     // Container(
                        // //     //     //   color: Colors.red,
                        // //     //     //   // height: ScreenUtil().setWidth(200),
                        // //     //     //   width: ScreenUtil().setWidth(200),
                        // //     //     // ),
                        // //     //     // Container(
                        // //     //     //   color: Colors.red,
                        // //     //     //   height: ScreenUtil().setWidth(200),
                        // //     //     //   width: ScreenUtil().setWidth(200),
                        // //     //     // ),
                        // //     //     // Container(
                        // //     //     //   color: Colors.red,
                        // //     //     //   // height: ScreenUtil().setWidth(200),
                        // //     //     //   width: ScreenUtil().setWidth(200),
                        // //     //     // ),
                        // //     //     // Container(
                        // //     //     //   color: Colors.red,
                        // //     //     //   height: ScreenUtil().setWidth(200),
                        // //     //     //   width: ScreenUtil().setWidth(200),
                        // //     //     // ),
                        // //     //     // Container(
                        // //     //     //   color: Colors.red,
                        // //     //     //   height: ScreenUtil().setWidth(200),
                        // //     //     //   width: ScreenUtil().setWidth(200),
                        // //     //     // ),
                        // //     //     // Container(
                        // //     //     //   color: Colors.red,
                        // //     //     //   height: ScreenUtil().setWidth(200),
                        // //     //     //   width: ScreenUtil().setWidth(200),
                        // //     //     // ),
                        // //     //     // Container(
                        // //     //     //   color: Colors.red,
                        // //     //     //   height: ScreenUtil().setWidth(200),
                        // //     //     //   width: ScreenUtil().setWidth(200),
                        // //     //     // ),
                        // //     //     // Container(
                        // //     //     //   color: Colors.red,
                        // //     //     //   height: 200.h,
                        // //     //     //   width: double.infinity,
                        // //     //     // ),
                        // //     //     // Container(
                        // //     //     //   color: Colors.red,
                        // //     //     //   height: 200.h,
                        // //     //     //   width: double.infinity,
                        // //     //     // ),
                        // //     //     // Container(
                        // //     //     //   color: Colors.red,
                        // //     //     //   height: 200.h,
                        // //     //     //   width: 1.sw,
                        // //     //     // ),
                        // //     //     // Container(
                        // //     //     //   color: Colors.red,
                        // //     //     //   height: 200.h,
                        // //     //     //   width: double.infinity,
                        // //     //     // ),
                        // //     //   ],
                        // //     // ),
                        // //   ),
                        // Container(
                        //   height: 852.h,
                        //   width: 1.sw,
                        //   color: Colors.red,
                        // ),
                        Column(
                          children: [
                            SizedBox(
                              // height: 32.h,
                              child: HomeAppBar(
                                onDrawerTap: () {
                                  scaffoldKey.currentState?.openDrawer();
                                },
                              ),
                            ),
                            // Spacer(flex: 2),

                            // Text(
                            //   context.locale.languageCode == 'en'
                            //       ? AppCubit.get(
                            //           context,
                            //         ).getCity()!.nameEn
                            //       : AppCubit.get(
                            //           context,
                            //         ).getCity()!.nameAr,
                            //   style: TextStyle(
                            //     fontSize: 14.sp,
                            //     color: AppTheme.secondaryTextColor,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            // Spacer(flex: 1),
                            GestureDetector(
                              onTap: () {},
                              child: SizedBox(
                                height: 42.h,
                                child: FittedBox(
                                  child: Text(
                                    LocalizationHelper.isArabic()
                                        ? DateTime.now().weekdayNameAr
                                        : DateTime.now().weekday.toWeekDay(),
                                    style: TextStyle(
                                      // fontSize: 100.sp, // from height h
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // VerticalSpace(height: 10.h),
                            // Spacer(),
                            // Spacer(flex: 1),
                            // VerticalSpace(height: 5),
                            GestureDetector(
                              onTap: () async {
                                await CacheHelper.stepHijriOffsetCycle();
                                await AppCubit.get(
                                  context,
                                ).getTodayHijriDate(context);
                              },
                              child: Container(
                                height: 55.h,

                                child: FittedBox(
                                  child: Builder(
                                    builder: (_) {
                                      final text = cubit.hijriDate;
                                      if (text == null || text.isEmpty) {
                                        return Text(
                                          "--:--",
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.secondaryTextColor,
                                          ),
                                        );
                                      }

                                      // ناخد آخر 4 chars (السنة)
                                      final int yearLen = 4;
                                      final String yearPart =
                                          text.length >= yearLen
                                          ? text.substring(
                                              text.length - yearLen,
                                            )
                                          : text;

                                      final String prefixPart =
                                          text.length >= yearLen
                                          ? text.substring(
                                              0,
                                              text.length - yearLen,
                                            )
                                          : "";

                                      return RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: prefixPart,
                                              style: TextStyle(
                                                // fontSize: 25.sp,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    AppTheme.secondaryTextColor,
                                              ),
                                            ),
                                            TextSpan(
                                              text: yearPart,
                                              style: TextStyle(
                                                // fontSize: 25.sp,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    AppTheme.secondaryTextColor,
                                                letterSpacing: .4
                                                    .w, // 👈 هنا المسافة بين أرقام السنة
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            VerticalSpace(height: 10),
                            Container(
                              height: 100.h,
                              width: double.infinity,

                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 24.w,
                                  right: 24.w,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    FittedBox(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          temperatureWidget(
                                            context: context,
                                            tempText: cubit.maxTemp == null
                                                ? "--"
                                                : LocalizationHelper.isArAndArNumberEnable()
                                                ? DateHelper.toArabicDigits(
                                                    cubit.maxTemp!
                                                        .toInt()
                                                        .toString(),
                                                  )
                                                : cubit.maxTemp!
                                                      .toInt()
                                                      .toString(),
                                          ),

                                          Text(
                                            LocalizationHelper.isArAndArNumberEnable()
                                                ? DateHelper.toArabicDigits(
                                                    DateFormat(
                                                      'dd/MM/yyyy',
                                                    ).format(DateTime.now()),
                                                  )
                                                : DateHelper.toWesternDigits(
                                                    DateFormat(
                                                      'dd/MM/yyyy',
                                                    ).format(DateTime.now()),
                                                  ),
                                            style: TextStyle(
                                              fontSize: 24.sp,
                                              color: AppTheme.primaryTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    FittedBox(
                                      child: FutureBuilder<prayerModel.Prayer?>(
                                        future: _nextPrayerFuture,
                                        builder: (context, asyncSnapshot) {
                                          // if (asyncSnapshot.data !=
                                          //     null) {
                                          //   cubit.assignNextPrayerVar(
                                          //     asyncSnapshot.data,
                                          //   );
                                          // }
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                asyncSnapshot.data?.dateTime ==
                                                        null
                                                    ? "--:--"
                                                    : LocalizationHelper.isArAndArNumberEnable()
                                                    ? DateHelper.toArabicDigits(
                                                        asyncSnapshot
                                                            .data!
                                                            .dateTime!
                                                            .difference(
                                                              DateTime.now(),
                                                            )
                                                            .formatDuration(),
                                                      )
                                                    : asyncSnapshot
                                                          .data!
                                                          .dateTime!
                                                          .difference(
                                                            DateTime.now(),
                                                          )
                                                          .formatDuration(),
                                                style: TextStyle(
                                                  fontFamily:
                                                      CacheHelper.getTimesFontFamily(),
                                                  fontSize: 30.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      (CacheHelper.getIsChangeCounterEnabled() &&
                                                          asyncSnapshot
                                                                  .data
                                                                  ?.dateTime !=
                                                              null &&
                                                          asyncSnapshot
                                                                  .data!
                                                                  .dateTime!
                                                                  .difference(
                                                                    DateTime.now(),
                                                                  )
                                                                  .inSeconds <=
                                                              90)
                                                      ? Colors.red
                                                      : AppTheme
                                                            .secondaryTextColor,
                                                ),
                                              ),

                                              Text(
                                                LocalizationHelper.isArabic()
                                                    ? LocaleKeys.left_for.tr() +
                                                          (asyncSnapshot
                                                                  .data
                                                                  ?.title
                                                                  .substring(
                                                                    1,
                                                                  ) ??
                                                              "")
                                                    : LocaleKeys.left_for.tr() +
                                                          " " +
                                                          (asyncSnapshot
                                                                  .data
                                                                  ?.title ??
                                                              ""),
                                                style: TextStyle(
                                                  fontSize: 24.sp,
                                                  color:
                                                      AppTheme.primaryTextColor,
                                                  fontFamily:
                                                      CacheHelper.getTimesFontFamily(),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Spacer(flex: 1),
                            Container(
                              height: 100.h,

                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: 10.w,
                                  left: 10.w,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  // crossAxisAlignment:
                                  //     CrossAxisAlignment.end,
                                  children: [
                                    if (CacheHelper.getShowFitrEid())
                                      Flexible(
                                        flex: 15,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FittedBox(
                                              child: Text(
                                                LocaleKeys.eid_al_fitr.tr(),
                                                style: TextStyle(
                                                  fontSize: 24.sp,
                                                  color:
                                                      AppTheme.primaryTextColor,
                                                  fontFamily:
                                                      CacheHelper.getTimesFontFamily(),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            VerticalSpace(height: 5),
                                            FittedBox(
                                              child: Text(
                                                CacheHelper.getFitrEid()?[0] ??
                                                    '--/--/--',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: AppTheme
                                                      .secondaryTextColor,
                                                  fontFamily:
                                                      CacheHelper.getTimesFontFamily(),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            VerticalSpace(height: 5),

                                            FittedBox(
                                              child: Text(
                                                CacheHelper.getFitrEid()?[1] ??
                                                    '--:--',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: AppTheme
                                                      .secondaryTextColor,
                                                  fontFamily:
                                                      CacheHelper.getTimesFontFamily(),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Flexible(
                                      flex: 75,
                                      child: Container(
                                        // height: 100.h,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: 10.w,
                                            right: 10.w,
                                          ),
                                          child: BlocBuilder<UiRotationCubit, bool>(
                                            builder: (context, state) {
                                              return GestureDetector(
                                                onTap: () {
                                                  final UiRotationCubit
                                                  cubit = context
                                                      .read<UiRotationCubit>();
                                                  cubit.changeIsLandscape(
                                                    state == true
                                                        ? false
                                                        : true,
                                                  );
                                                },
                                                child: Container(
                                                  // alignment: Alignment
                                                  //     .bottomCenter,

                                                  // height: 100.h,
                                                  alignment: Alignment.center,
                                                  child: FittedBox(
                                                    child: LiveClockRow(
                                                      timeFontSize: 79.sp,
                                                      periodFontSize: 24.sp,
                                                      use24Format:
                                                          CacheHelper.getUse24HoursFormat(),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (CacheHelper.getShowAdhaEid())
                                      Flexible(
                                        flex: 15,

                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          // mainAxisAlignment:
                                          //     MainAxisAlignment
                                          //         .center,
                                          children: [
                                            FittedBox(
                                              child: Text(
                                                LocaleKeys.eid_al_adha.tr(),
                                                style: TextStyle(
                                                  fontSize: 24.sp,
                                                  color:
                                                      AppTheme.primaryTextColor,
                                                  fontFamily:
                                                      CacheHelper.getTimesFontFamily(),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            VerticalSpace(height: 5),
                                            FittedBox(
                                              child: Text(
                                                CacheHelper.getAdhaEid()?[0] ??
                                                    '--/--/--',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: AppTheme
                                                      .secondaryTextColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      CacheHelper.getTimesFontFamily(),
                                                ),
                                              ),
                                            ),
                                            VerticalSpace(height: 5),

                                            FittedBox(
                                              child: Text(
                                                CacheHelper.getAdhaEid()?[1] ??
                                                    '--:--',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme
                                                      .secondaryTextColor,
                                                  fontFamily:
                                                      CacheHelper.getTimesFontFamily(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            // Spacer(flex: 1),
                            Container(
                              child: RotatingAyahBanner(
                                ayat: ayat, // ✅ اللي انت جايبه
                                height: 60.h,
                                // availableHeight: 90.h, // لو عايز نفس منطقك القديم
                                maxFontSize: 20.sp,
                                minFontSize: 12.sp,
                                interval: const Duration(
                                  seconds: 20,
                                ), // أو CacheHelper.getSliderTime()
                                fontFamily: CacheHelper.getTextsFontFamily(),
                                textColor: AppTheme.primaryTextColor,
                              ),
                            ),
                            VerticalSpace(height: 20),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: SizedBox(
                                  width: .84.sw,

                                  child: PrayerTimesTable(
                                    rows: rows,
                                    enableGlass: enableGlass,
                                    headerStyle: headerStyle,
                                    prayerStyle: prayerStyle,
                                    adhanStyle: adhanStyle,
                                    iqamaStyle: iqamaStyle,
                                  ),
                                ),
                              ),
                            ),

                            // Column(
                            //   children: [
                            //     // عناوين الأعمدة (اختياري تحطها فوق)
                            //     Padding(
                            //       padding: const EdgeInsets.symmetric(
                            //         horizontal: 16,
                            //       ),
                            //       child: Row(
                            //         children: [
                            //           Expanded(
                            //             child: Align(
                            //               alignment: Alignment.centerLeft,
                            //               child: Text(
                            //                 LocaleKeys.iqama_time.tr(),
                            //               ),
                            //             ),
                            //           ),
                            //           Expanded(
                            //             child: Center(
                            //               child: Text(
                            //                 LocaleKeys.adhan_time.tr(),
                            //               ),
                            //             ),
                            //           ),
                            //           Expanded(
                            //             child: Align(
                            //               alignment: Alignment.centerRight,
                            //               child: Text(LocaleKeys.prayer.tr()),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //     // const SizedBox(height: 10),

                            //     // ✅ Rows
                            //     Column(
                            //       children: [
                            //         PrayerTimesHeaderRow(style: headerStyle),
                            //         SizedBox(height: 10.h),

                            //         SizedBox(
                            //           height: 200.h,
                            //           child: Container(
                            //             // color: Colors.red,
                            //             child: Column(
                            //               children: [
                            //                 ...rows.map(
                            //                   (r) => PrayerGlassRow(
                            //                     data: r,
                            //                     enableGlass: enableGlass,
                            //                     textStylePrayer: prayerStyle,
                            //                     textStyleAdhan: adhanStyle,
                            //                     textStyleIqama: iqamaStyle,
                            //                     rowHeight: 15
                            //                         .h, // لو عايز أكبر: 66 أو 70
                            //                   ),
                            //                 ),
                            //               ],
                            //             ),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ],
                            // ),

                            // Spacer(flex: 1),
                            if (CacheHelper.getSliderOpened())
                              Container(
                                child: AzkarSlider(
                                  adhkar: cubit.todaysAdkar != null
                                      ? cubit.todaysAdkar!
                                            .map((e) => e.text)
                                            .toList()
                                      : [],
                                  height: 90.h,
                                  maxFontSize: 20.sp,
                                  minFontSize: 11.sp,
                                ),
                              ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.w, right: 10.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    LocaleKeys.copy_right_for_sadja.tr() + " |",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppTheme.primaryTextColor,
                                    ),
                                  ),

                                  HorizontalSpace(width: 2),
                                  Text(
                                    AppCubit.get(context).getCity() != null
                                        ? 'SA, ${AppCubit.get(context).getCity()!.nameEn}'
                                        : "",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppTheme.primaryTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // if (cubit.currentPrayer != null && cubit.showPrayerAzanPage)
              SizedBox(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1500),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child:
                      (cubit.currentPrayer != null && cubit.showPrayerAzanPage)
                      ? AzanPrayerScreen(
                          key: const ValueKey('azan-test'),
                          currentPrayer: cubit.currentPrayer!,
                        )
                      : SizedBox.shrink(),
                ),
              ),
              FutureBuilder<bool>(
                future: _hideFuture,
                builder: (context, snapshot) {
                  final shouldHide = snapshot.data == true;

                  // لو لسه بيحمّل أو الشرط مش متحقق أو الفيتشر مقفولة
                  if (!CacheHelper.getHideScreenAfterIshaaEnabled() ||
                      !shouldHide) {
                    return const SizedBox.shrink();
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 1500),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Container(
                      key: const ValueKey('black_screen'),
                      height: 1.sh,
                      width: 1.sw,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class PrayerText extends StatelessWidget {
  const PrayerText({super.key, required this.title, this.dimmed = false});

  final String title;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: CacheHelper.getTimesFontFamily(),

        fontSize: 25.sp,
        fontWeight: FontWeight.bold,
        color: CacheHelper.getIsPreviousPrayersDimmed()
            ? (dimmed
                  ? AppTheme.primaryTextColor.withOpacity(0.4)
                  : AppTheme.primaryTextColor)
            : AppTheme.primaryTextColor,
      ),
    );
  }
}

class AzkarSlider extends StatefulWidget {
  final List<String> adhkar;
  final double height;
  final double maxFontSize;
  final double minFontSize;

  const AzkarSlider({
    super.key,
    required this.adhkar,
    required this.height,
    required this.maxFontSize,
    required this.minFontSize,
  });

  @override
  State<AzkarSlider> createState() => _AzkarSliderState();
}

class _AzkarSliderState extends State<AzkarSlider> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  Timer? _ticker;
  DateTime _nextFlip = DateTime.now();

  void _scheduleNext() {
    _nextFlip = DateTime.now().add(
      Duration(seconds: CacheHelper.getSliderTime()),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scheduleNext();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || widget.adhkar.isEmpty) return;

      if (DateTime.now().isBefore(_nextFlip)) return;

      _currentPage = (_currentPage + 1) % widget.adhkar.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      _scheduleNext(); // 👈 بياخد القيمة الجديدة فورًا
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.adhkar.isEmpty) {
      return const SizedBox.shrink();
    }

    return
    // CacheHelper.getpalestinianFlag()
    //     ?
    SizedBox(
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: widget.height,
              width: 1.sw - 70.w,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.adhkar.length,
                itemBuilder: (context, index) {
                  final text = widget.adhkar[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 16.w, left: 5.w),
                    child: AdaptiveTextWidget(
                      text: text,
                      maxFontSize: widget.maxFontSize,
                      minFontSize: widget.minFontSize,
                      availableHeight: widget.height,
                    ),
                  );
                },
              ),
            ),
          ),

          // Padding(
          //   padding: EdgeInsetsDirectional.only(end: 5.w),
          //   child: Column(
          //     children: [
          //       if (CacheHelper.getpalestinianFlag())
          //         Image.asset(
          //           Assets.images.palastine.path,
          //           width: 45.w,
          //           height: 45.h,
          //         ),
          //       VerticalSpace(height: 5),
          if (CacheHelper.getEnableCheckInternetConnection())
            BottomStarHint(text: LocaleKeys.connected.tr()),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
    // :
    // SizedBox(
    //     height: widget.height,
    //     child: PageView.builder(
    //       controller: _pageController,
    //       itemCount: widget.adhkar.length,
    //       itemBuilder: (context, index) {
    //         final text = widget.adhkar[index];
    //         return Padding(
    //           padding: EdgeInsets.only(right: 16.w, left: 16.w),
    //           child: AdaptiveTextWidget(
    //             text: text,
    //             maxFontSize: widget.maxFontSize,
    //             minFontSize: widget.minFontSize,
    //             availableHeight: widget.height,
    //           ),
    //         );
    //       },
    //     ),
    //   );
  }
}

class AdaptiveTextWidget extends StatelessWidget {
  final String text;
  final double maxFontSize;
  final double minFontSize;
  final double availableHeight;
  final String? fontFamily;

  const AdaptiveTextWidget({
    required this.text,
    required this.maxFontSize,
    required this.minFontSize,
    required this.availableHeight,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double currentFontSize = maxFontSize;
        int lines = 1;

        // نجرب نحسب عدد الأسطر عند الحجم الأقصى
        final textPainter = TextPainter(
          textDirection: material.TextDirection.rtl,
          textAlign: TextAlign.center,
        );

        // نبدأ بالحجم الأقصى ونشوف كام سطر هيطلع
        while (currentFontSize >= minFontSize) {
          textPainter.text = TextSpan(
            text: text,
            style: TextStyle(
              fontSize: currentFontSize,
              fontWeight: FontWeight.bold,
              height: 1, // line height
              fontFamily: CacheHelper.getAzkarFontFamily(),
            ),
          );
          textPainter.layout(maxWidth: width);

          lines = textPainter.computeLineMetrics().length;
          final textHeight = textPainter.height;

          // لو السطور 2 أو أقل والنص داخل في المساحة المتاحة، خلاص كده تمام
          if (lines <= 2 && textHeight <= availableHeight) {
            break;
          }

          // لو السطور أكتر من 2، نصغر الخط شوية
          if (lines > 2) {
            currentFontSize -= 1;
          } else if (textHeight > availableHeight) {
            // لو الارتفاع أكبر من المتاح، نصغر الخط
            currentFontSize -= 0.5;
          } else {
            break;
          }

          // نتأكد إننا ما نزلناش عن الحد الأدنى
          if (currentFontSize < minFontSize) {
            currentFontSize = minFontSize;
            break;
          }
        }

        // نرسم النص النهائي
        return Container(
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: currentFontSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
                fontFamily: fontFamily ?? CacheHelper.getAzkarFontFamily(),

                // height: 1.5,
              ),

              textAlign: TextAlign.center,
              textDirection: material.TextDirection.rtl,
              maxLines: lines > 2 ? null : 2,
              overflow: lines > 2 ? TextOverflow.visible : null,
            ),
          ),
        );
      },
    );
  }
}

class TemperatureGauge extends StatelessWidget {
  final double temperature;
  final double minTemp;
  final double maxTemp;

  TemperatureGauge({
    required this.temperature,
    this.minTemp = -20,
    this.maxTemp = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 100,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          maxY: maxTemp,
          minY: minTemp,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: temperature,
                  color: temperature > 30 ? Colors.red : Colors.blue,
                  width: 30,
                  borderRadius: BorderRadius.circular(15),
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
}
