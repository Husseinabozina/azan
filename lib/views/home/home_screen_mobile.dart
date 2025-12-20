import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/flash_dialoge.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/helpers/location_helper.dart';
import 'package:azan/core/helpers/simple_sound_player.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/azan_time_tile.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:azan/views/home/components/home_appbar.dart';
import 'package:azan/views/home/components/home_star_hint.dart';
import 'package:azan/views/home/components/live_clock_row.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreenMobile extends StatefulWidget {
  const HomeScreenMobile({super.key});

  @override
  State<HomeScreenMobile> createState() => HomeScreenMobileState();
}

class HomeScreenMobileState extends State<HomeScreenMobile> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late AppCubit cubit;

  String? hijriDate;
  late DateTime _lastDate;

  // ✅ الصوت
  final SimpleSoundPlayer _soundPlayer = SimpleSoundPlayer();

  // ✅ عشان ما يكررش الصوت لنفس الصلاة في نفس اليوم
  final Set<int> _playedAdhanToday = <int>{};
  final Set<int> _playedIqamaToday = <int>{};

  Timer? _timer;
  bool isloading = false;
  Future<void> _assignHijriDate() async {
    hijriDate = await cubit.getTodayHijriDate(context);
    'ldjfkld'.log();
  }

  Future<void> homeScreenWork() async {
    if (!mounted) return;
    setState(() => isloading = true);

    cubit = AppCubit.get(context);
    _lastDate = DateTime.now();

    final city = cubit.getCity()?.nameEn ?? '';

    // ✅ 1) استنى الحاجات الأساسية بس
    await Future.wait([
      cubit.getIqamaTime(),
      cubit.initializePrayerTimes(city: city, context: context),
    ]);

    if (!mounted) return;
    setState(() => isloading = false);

    // ✅ 2) الباقي اشتغله في الخلفية (من غير ما يوقف الواجهة)
    unawaited(_assignHijriDate());
    unawaited(cubit.loadTodayMaxTemp(country: 'Saudi Arabia', city: city));
    unawaited(cubit.assignAdhkar());

    _startTick();
  }

  void _startTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      // هنظبط دي في الحل رقم 2 (مش setState للشاشة كلها)
      setState(() {});
      _checkAndPlayPrayerSound(DateTime.now());

      final now = DateTime.now();
      if (!_isSameDay(now, _lastDate)) {
        _lastDate = now;
        _onNewDay();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    AppCubit.get(context).homeScreenMobile = this;
    homeScreenWork();
  }

  void _initDayData() {
    _assignHijriDate();

    final city = cubit.getCity()?.nameEn ?? '';

    cubit.initializePrayerTimes(city: city, context: context);

    cubit.loadTodayMaxTemp(country: 'Saudi Arabia', city: city);
    cubit.getIqamaTime();
    cubit.assignAdhkar();
  }

  void _onNewDay() {
    // يوم جديد → نظّف ال flags وحدث المواقيت
    _playedAdhanToday.clear();
    _playedIqamaToday.clear();
    Future.delayed(const Duration(milliseconds: 300), () {
      _initDayData();
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// ✅ دي الدالة اللي بتشيّك كل ثانية: هل دخلنا على دقيقة الأذان أو الإقامة؟
  void _checkAndPlayPrayerSound(DateTime now) {
    if (cubit.prayerTimes == null || cubit.iqamaMinutes == null) return;

    final prayers = cubit.prayers(context); // List<Prayer>
    final iqamaMinutes = cubit.iqamaMinutes!; // طولها 6 بإذن الله

    final azanSource = cubit.getAzanSoundSource;
    final iqamaSource = cubit.getIqamaSoundSource;

    for (final prayer in prayers) {
      final int id = prayer.id; // 1..6
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

        if (!_playedIqamaToday.contains(id) && _isSameMinute(iqamaTime, now)) {
          _playedIqamaToday.add(id);
          _soundPlayer.playIqamaPing(iqamaSource);
        }
      }
    }
  }

  /// مقارنة بالدقيقة بدون ثواني
  /// مقارنة بالدقيقة بدون ثواني
  bool _isSameMinute(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _soundPlayer.dispose();
    super.dispose();
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
          return SizedBox(
            // width:
            //     1.sw -
            //     MediaQuery.of(context).padding.left -
            //     MediaQuery.of(context).padding.right,
            // child:

            // Column(
            //   children: [
            //     Container(
            //       height: (852 / 4).h,
            //       width: double.infinity,
            //       color: Colors.red,
            //     ),
            //     Container(
            //       height: (852 / 4).h,
            //       width: double.infinity,
            //       color: Colors.red,
            //     ),
            //     Container(
            //       height: (852 / 4).h,
            //       width: double.infinity,
            //       color: Colors.red,
            //     ),
            //     Container(
            //       height: (852 / 4).h,
            //       width: double.infinity,
            //       color: Colors.red,
            //       child: Stack(
            //         children: [
            //           PositionedDirectional(
            //             bottom: 0,
            //             child: Text('ljdf', style: TextStyle(fontSize: 20.sp)),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
            child: Stack(
              children: [
                Image.asset(
                  CacheHelper.getSelectedBackground(),

                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                ),

                LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      height: constraints.maxHeight,
                      width: constraints.maxWidth,
                      child: FittedBox(
                        fit: BoxFit.contain,

                        child: SizedBox(
                          height: constraints.maxHeight,
                          width: constraints.maxWidth,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top + 8.h,
                              bottom:
                                  MediaQuery.of(context).padding.bottom + 5.h,
                            ),
                            child: isloading
                                ? Center(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          // height: 32.h,
                                          child: HomeAppBar(
                                            onDrawerTap: () {
                                              scaffoldKey.currentState
                                                  ?.openDrawer();
                                            },
                                          ),
                                        ),

                                        // Spacer(flex: 2),
                                        VerticalSpace(height: 300.h),
                                        Center(
                                          child: SizedBox(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  color:
                                                      AppTheme.primaryTextColor,
                                                ),
                                                VerticalSpace(height: 8.h),
                                                Text(
                                                  LocaleKeys.loading.tr(),
                                                  style: TextStyle(
                                                    fontSize: 20.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme
                                                        .primaryTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      SizedBox(
                                        // height: 32.h,
                                        child: HomeAppBar(
                                          onDrawerTap: () {
                                            scaffoldKey.currentState
                                                ?.openDrawer();
                                          },
                                        ),
                                      ),
                                      Spacer(flex: 2),

                                      Text(
                                        context.locale.languageCode == 'en'
                                            ? AppCubit.get(
                                                context,
                                              ).getCity()!.nameEn
                                            : AppCubit.get(
                                                context,
                                              ).getCity()!.nameAr,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppTheme.secondaryTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      Spacer(flex: 1),
                                      SizedBox(
                                        height: 25.h,
                                        child: FittedBox(
                                          child: Text(
                                            LocalizationHelper.isArabic(context)
                                                ? DateTime.now().weekdayNameAr
                                                : DateTime.now().weekday
                                                      .toWeekDay(),
                                            style: TextStyle(
                                              fontSize: 20.sp, // from height h
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryTextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // VerticalSpace(height: 10.h),
                                      // Spacer(),
                                      // Spacer(flex: 1),
                                      VerticalSpace(height: 5),

                                      SizedBox(
                                        height: 25.h,
                                        child: FittedBox(
                                          child: Text(
                                            hijriDate == null
                                                ? "--:--"
                                                : hijriDate!,
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  AppTheme.secondaryTextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Spacer(flex: 1),

                                      SizedBox(
                                        height: 66.17.h,
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
                                                    Container(
                                                      height: 37.17.h,
                                                      width:
                                                          cubit.maxTemp != null
                                                          ? cubit.maxTemp!
                                                                        .toInt()
                                                                        .toString()
                                                                        .length ==
                                                                    2
                                                                ? 32.w
                                                                : 25.w
                                                          : 32.w,
                                                      child: Stack(
                                                        clipBehavior: Clip.none,
                                                        children: [
                                                          PositionedDirectional(
                                                            // top:,
                                                            start: 0,
                                                            top: -5.h,
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  AppTheme
                                                                      .primaryTextColor,
                                                              radius: 5.r,
                                                            ),
                                                          ),
                                                          PositionedDirectional(
                                                            end: 0.w,
                                                            bottom: 0.h,
                                                            child: Text(
                                                              cubit.maxTemp ==
                                                                      null
                                                                  ? "--"
                                                                  : LocalizationHelper.isArAndArNumberEnable(
                                                                      context,
                                                                    )
                                                                  ? DateHelper.toArabicDigits(
                                                                      cubit
                                                                          .maxTemp!
                                                                          .toInt()
                                                                          .toString(),
                                                                    )
                                                                  : cubit
                                                                        .maxTemp!
                                                                        .toInt()
                                                                        .toString(),

                                                              style: TextStyle(
                                                                fontSize: 24.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppTheme
                                                                    .secondaryTextColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Text(
                                                      LocalizationHelper.isArAndArNumberEnable(
                                                            context,
                                                          )
                                                          ? DateHelper.toArabicDigits(
                                                              DateFormat(
                                                                'dd/MM/yyyy',
                                                              ).format(
                                                                DateTime.now(),
                                                              ),
                                                            )
                                                          : DateHelper.toWesternDigits(
                                                              DateFormat(
                                                                'dd/MM/yyyy',
                                                              ).format(
                                                                DateTime.now(),
                                                              ),
                                                            ),
                                                      style: TextStyle(
                                                        fontSize: 24.sp,
                                                        color: AppTheme
                                                            .primaryTextColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              FittedBox(
                                                child: FutureBuilder(
                                                  future: cubit.nextPrayer(
                                                    context,
                                                  ),
                                                  builder: (context, asyncSnapshot) {
                                                    return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          asyncSnapshot
                                                                      .data
                                                                      ?.dateTime ==
                                                                  null
                                                              ? "--:--"
                                                              : LocalizationHelper.isArAndArNumberEnable(
                                                                  context,
                                                                )
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
                                                            fontSize: 24.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                          LocalizationHelper.isArabic(
                                                                context,
                                                              )
                                                              ? LocaleKeys
                                                                        .left_for
                                                                        .tr() +
                                                                    (asyncSnapshot
                                                                            .data
                                                                            ?.title
                                                                            .substring(
                                                                              1,
                                                                            ) ??
                                                                        "")
                                                              : LocaleKeys
                                                                        .left_for
                                                                        .tr() +
                                                                    " " +
                                                                    (asyncSnapshot
                                                                            .data
                                                                            ?.title ??
                                                                        ""),
                                                          style: TextStyle(
                                                            fontSize: 24.sp,
                                                            color: AppTheme
                                                                .primaryTextColor,
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

                                      Spacer(flex: 1),

                                      Container(
                                        height: 110.h,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            right: 10.w,
                                            left: 10.w,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (CacheHelper.getShowFitrEid())
                                                Flexible(
                                                  flex: 15,
                                                  child: Column(
                                                    // crossAxisAlignment:
                                                    //     CrossAxisAlignment.start,
                                                    children: [
                                                      FittedBox(
                                                        child: Text(
                                                          LocaleKeys.eid_al_fitr
                                                              .tr(),
                                                          style: TextStyle(
                                                            fontSize: 24.sp,
                                                            color: AppTheme
                                                                .primaryTextColor,
                                                            fontFamily:
                                                                CacheHelper.getTimesFontFamily(),
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
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              Flexible(
                                                flex: 70,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 10.w,
                                                    right: 10.w,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        height: 58.h,
                                                        child: FittedBox(
                                                          child: LiveClockRow(
                                                            timeFontSize: 64.sp,
                                                            periodFontSize:
                                                                24.sp,
                                                            use24Format:
                                                                CacheHelper.getUse24HoursFormat(),
                                                          ),
                                                        ),
                                                      ),

                                                      // VerticalSpace(height: 10),
                                                      Flexible(
                                                        child: AdaptiveTextWidget(
                                                          fontFamily:
                                                              CacheHelper.getTextsFontFamily(),
                                                          availableHeight: 30.h,
                                                          text:
                                                              CacheHelper.getFixedDhikr(),

                                                          maxFontSize: 20.sp,
                                                          minFontSize: 12.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (CacheHelper.getShowAdhaEid())
                                                Flexible(
                                                  flex: 15,
                                                  child: Column(
                                                    // mainAxisAlignment:
                                                    //     MainAxisAlignment
                                                    //         .center,
                                                    children: [
                                                      FittedBox(
                                                        child: Text(
                                                          LocaleKeys.eid_al_adha
                                                              .tr(),
                                                          style: TextStyle(
                                                            fontSize: 24.sp,
                                                            color: AppTheme
                                                                .primaryTextColor,
                                                            fontFamily:
                                                                CacheHelper.getTimesFontFamily(),
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
                                      Spacer(flex: 2),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 24.w,
                                          right: 24.w,
                                        ),
                                        child: SizedBox(
                                          height: 282.h,

                                          width: 1.sw - 48.w,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              FittedBox(
                                                child: Column(
                                                  children: [
                                                    AzanTitleTile(
                                                      withNoAscentAndDescent:
                                                          true,
                                                      width: 30.w,
                                                      title: LocaleKeys.prayer
                                                          .tr(),
                                                      fontSize: 16.sp,
                                                    ),
                                                    VerticalSpace(height: 10),

                                                    ...List.generate(
                                                      prayers.length,
                                                      (index) {
                                                        final dimmed =
                                                            index <
                                                                pastIqamaFlags
                                                                    .length &&
                                                            pastIqamaFlags[index];

                                                        return Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                bottom: 10.h,
                                                              ),
                                                          child: PrayerText(
                                                            title:
                                                                prayers[index],
                                                            dimmed: dimmed,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              FittedBox(
                                                child: Column(
                                                  children: [
                                                    AzanTitleTile(
                                                      withNoAscentAndDescent:
                                                          true,
                                                      width: 30.w,
                                                      title: LocaleKeys.adhan
                                                          .tr(),
                                                      fontSize: 16.sp,
                                                    ),

                                                    VerticalSpace(height: 10),

                                                    ...List.generate(
                                                      cubit
                                                          .prayers(context)
                                                          .length,
                                                      (index) {
                                                        final e = cubit.prayers(
                                                          context,
                                                        )[index];
                                                        final dimmed =
                                                            index <
                                                                pastIqamaFlags
                                                                    .length &&
                                                            pastIqamaFlags[index];

                                                        final timeStr =
                                                            CacheHelper.getUse24HoursFormat()
                                                            ? e.time24 ??
                                                                  '--:--'
                                                            : e.time ?? '--:--';

                                                        return Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                bottom: 10.h,
                                                              ),
                                                          child: AzanTimeText(
                                                            time: timeStr,
                                                            dimmed: dimmed,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              FittedBox(
                                                child: Column(
                                                  children: [
                                                    AzanTitleTile(
                                                      width: 30.w,
                                                      title: LocaleKeys.iqama
                                                          .tr(),
                                                      fontSize: 16.sp,
                                                      withNoAscentAndDescent:
                                                          true,
                                                    ),
                                                    VerticalSpace(height: 10),

                                                    ...List.generate(
                                                      cubit
                                                          .prayers(context)
                                                          .length,
                                                      (index) {
                                                        final e = cubit.prayers(
                                                          context,
                                                        )[index];
                                                        final dimmed =
                                                            index <
                                                                pastIqamaFlags
                                                                    .length &&
                                                            pastIqamaFlags[index];

                                                        final iqamaTimeStr =
                                                            (e.time != null &&
                                                                cubit.iqamaMinutes !=
                                                                    null)
                                                            ? DateHelper.addMinutesToTimeStringWithSettings(
                                                                e.time!,
                                                                cubit
                                                                    .iqamaMinutes![e
                                                                        .id -
                                                                    1],
                                                                context,
                                                              )
                                                            : '--:--';

                                                        return Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                bottom: 10.h,
                                                              ),
                                                          child: AzanTimeText(
                                                            time: iqamaTimeStr,
                                                            dimmed: dimmed,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Spacer(flex: 2),
                                      if (CacheHelper.getSliderOpened())
                                        // VerticalSpace(height: 10),
                                        AzkarSlider(
                                          adhkar:
                                              // [
                                              //   "قال ﷺ اللهم ربناربناربناربناربناربناربناربناربناربناربناربناربناربناربناربناربناربناربنا آتنا في الدنيا حسنة وفي الآخرة الآخرة   الآخرة  الآخرة  الآخرة  الآخرة  الآخرة   الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة   الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة   وقنا عذاب  وقنا عذاب  وقنا عذاب  وقنا عذاب  وقنا عذاب  وقنا عذاب  وقنا عذاب  وقنا عذاب  وقنا عذاب  وقنا عذاب  وقنا عذاب  وقنا عذاب  وقنا عذاب وقنا عذاب النار",
                                              //   "قال ﷺ اللهم ربناربناربناربناربناربناربناربناربناربناربناربناربناربناربناربناربناربناربنا آتنا في الدنيا حسنة وفي الآخرة حسنة   الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة  الآخرة وقنا عذاب النار",
                                              // ],
                                              cubit.todaysAdkar != null
                                              ? cubit.todaysAdkar!
                                                    .map((e) => e.text)
                                                    .toList()
                                              : [],
                                          height: 110.h,
                                          maxFontSize: 20.sp,
                                          minFontSize: 11.sp,
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
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

        fontSize: 23.sp,
        fontWeight: FontWeight.bold,
        color: CacheHelper.getIsPreviousPrayersDimmed()
            ? AppTheme.primaryTextColor
            : dimmed
            ? AppTheme.primaryTextColor.withOpacity(0.4) // خافت
            : AppTheme.primaryTextColor, // عادي
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (!mounted || widget.adhkar.isEmpty) return;

      _currentPage = (_currentPage + 1) % widget.adhkar.length;

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
          Padding(
            padding: EdgeInsetsDirectional.only(end: 5.w),
            child: Column(
              children: [
                if (CacheHelper.getpalestinianFlag())
                  Image.asset(
                    Assets.images.palastine.path,
                    width: 45.w,
                    height: 45.h,
                  ),
                VerticalSpace(height: 5),

                if (CacheHelper.getEnableCheckInternetConnection())
                  BottomStarHint(text: LocaleKeys.connected.tr()),
              ],
            ),
          ),
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
        return Center(
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
        );
      },
    );
  }
}
