// HomeScreenLandscape.dart
import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/flash_dialoge.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/helpers/simple_sound_player.dart';
import 'package:azan/core/models/next_Iqama.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/azan_prayer_screen.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:azan/views/home/components/home_appbar.dart';
import 'package:azan/views/home/components/live_clock_row.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:azan/core/models/prayer.dart' as prayerModel;

class HomeScreenLandscape extends StatefulWidget {
  const HomeScreenLandscape({super.key});

  @override
  State<HomeScreenLandscape> createState() => HomeScreenLandscapeState();
}

class HomeScreenLandscapeState extends State<HomeScreenLandscape> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  AppCubit get cubit => AppCubit.get(context);
  late DateTime _lastDate;

  // ✅ الصوت
  final SimpleSoundPlayer _soundPlayer = SimpleSoundPlayer();

  // ✅ عشان ما يكررش الصوت لنفس الصلاة في نفس اليوم
  final Set<int> _playedAdhanToday = <int>{};
  final Set<int> _playedIqamaToday = <int>{};

  // ✅ Timers
  Timer? _tickTimer; // كل ثانية
  Timer? _minuteTimer; // كل دقيقة

  // ✅ Futures (لا تتولد في build)
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

    _refreshMinuteFutures();
  }

  void _refreshMinuteFutures() {
    _hideFuture = isAfterFixedTimeForIshaaOrSunrise(context: context);

    _nextPrayerFuture = cubit.nextPrayer(context).then((p) {
      cubit.nextPrayerVar = p;
      return p;
    });
  }

  void _startTimers() {
    _tickTimer?.cancel();
    _minuteTimer?.cancel();

    _refreshMinuteFutures();

    _tickTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      setState(() {}); // تحديث الساعة

      _checkAndPlayPrayerSound(DateTime.now());
      performAdhanActions(context);

      final now = DateTime.now();
      if (!_isSameDay(now, _lastDate)) {
        _lastDate = now;
        _onNewDay();
      }
    });

    _minuteTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() => _refreshMinuteFutures());
    });
  }

  Future<void> homeScreenWork() async {
    if (!mounted) return;
    setState(() => isloading = true);

    _lastDate = DateTime.now();
    final city = cubit.getCity()?.nameEn ?? '';

    await Future.wait([
      cubit.getIqamaTime(),
      cubit.initializePrayerTimes(city: city, context: context),
    ]);

    if (!mounted) return;
    setState(() => isloading = false);

    unawaited(_assignHijriDate());
    unawaited(cubit.loadTodayMaxTemp(country: 'Saudi Arabia', city: city));
    unawaited(cubit.assignAdhkar());

    _startTimers();
  }

  @override
  void initState() {
    super.initState();
    AppCubit.get(context).homeScreenLandscape = this;

    homeScreenWork();
  }

  // =========================
  //  Actions (كما هي)
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
  //  Hide logic (كما هي)
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

  // =========================
  //  Layout (960 x 540)
  // =========================
  static const double _kDesignH = 540.0;

  // 4 slots (sum MUST = 540)
  static const double _kTopH = 62.0;
  static const double _kSliderSlotH = 78.0; // reserved even if hidden
  static const double _kFooterH = 20.0;
  static const double _kMainH =
      _kDesignH - _kTopH - _kSliderSlotH - _kFooterH; // 380

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final prayers = cubit.prayers(context);

    // ✅ Flags للـ dim على حسب الإقامة (زي الموبايل)
    final List<bool> pastIqamaFlags = prayers.map((p) {
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
          return Stack(
            children: [
              // Background
              Positioned.fill(
                child: Image.asset(
                  CacheHelper.getSelectedBackground(),
                  fit: BoxFit.cover,
                ),
              ),

              // Main fixed-grid layout
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final safeH = c.maxHeight; // ده الحقيقي
                    final safeW = c.maxWidth;

                    // نسب من تصميم 960x540
                    final topH = safeH * (62.0 / 540.0);
                    // final sliderH = safeH * (78.0 / 540.0);
                    final footerH = safeH * (20.0 / 540.0);
                    // final mainH = safeH - topH - sliderH - footerH;

                    // Padding برضه يكون آمن (مش يكبر زيادة)
                    final padX = (safeW * 0.012).toDouble(); // ~12px على 960
                    final padY = (safeH * 0.012);

                    final sliderH = safeH * (92.0 / 540.0); // كان 78
                    final mainH =
                        safeH - topH - sliderH - footerH; // هيتقل تلقائي

                    return Column(
                      children: [
                        // SLOT 1: TopBar (fixed)
                        SizedBox(
                          height: topH,
                          child: HomeAppBar(
                            onDrawerTap: () =>
                                scaffoldKey.currentState?.openDrawer(),
                          ),
                        ),

                        // SLOT 2: Main (fixed)
                        SizedBox(
                          height: mainH,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: isloading
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(
                                          color: AppTheme.primaryTextColor,
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          LocaleKeys.loading.tr(),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // LEFT (58)
                                      Expanded(
                                        flex: 50,
                                        child: GlassPanel(
                                          padding: EdgeInsets.all(10.w),
                                          child: _PrayerTableFixed(
                                            prayers: prayers,
                                            pastIqamaFlags: pastIqamaFlags,
                                            iqamaMinutes: cubit.iqamaMinutes,
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: 12.w),

                                      // CENTER (24)
                                      Expanded(
                                        flex: 24,
                                        child: GlassPanel(
                                          padding: EdgeInsets.all(10.w),
                                          child: _CenterClockFixed(
                                            fixedDhikr:
                                                CacheHelper.getFixedDhikr(),
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: 12.w),

                                      // RIGHT (18)
                                      Expanded(
                                        flex: 24,
                                        child: GlassPanel(
                                          padding: EdgeInsets.all(10.w),
                                          child: _RightInfoFixed(
                                            cubit: cubit,
                                            nextPrayerFuture: _nextPrayerFuture,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        // SLOT 3: Slider reserved (fixed even if hidden)
                        SizedBox(
                          height: sliderH,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: padX,
                              vertical: padY,
                            ),
                            child: (!isloading && CacheHelper.getSliderOpened())
                                ? LandscapeAzkarSlider(
                                    adhkar: cubit.todaysAdkar != null
                                        ? cubit.todaysAdkar!
                                              .map((e) => e.text)
                                              .toList()
                                        : [],
                                    height: (sliderH - (padY * 2)).toDouble(),
                                    maxFontSize: 18.sp,
                                    minFontSize: 11.sp,
                                  )
                                : const SizedBox.expand(), // reserved empty space
                          ),
                        ),

                        // SLOT 4: Footer (fixed)
                        SizedBox(
                          height: footerH,
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AutoSizeText(
                                  LocaleKeys.copy_right_for_sadja.tr(),
                                  maxLines: 1,
                                  minFontSize: 8,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppTheme.primaryTextColor,
                                  ),
                                ),
                                HorizontalSpace(width: 8),
                                AutoSizeText(
                                  AppCubit.get(context).getCity() != null
                                      ? 'SA, ${AppCubit.get(context).getCity()!.nameEn}'
                                      : "",
                                  maxLines: 1,
                                  minFontSize: 8, // ✅ raw
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppTheme.primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // ✅ Overlay: AzanPrayerScreen (unchanged)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 1500),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: (cubit.currentPrayer != null && cubit.showPrayerAzanPage)
                    ? AzanPrayerScreen(
                        key: const ValueKey('azan-test'),
                        currentPrayer: cubit.currentPrayer!,
                      )
                    : const SizedBox.shrink(),
              ),

              // ✅ Overlay: Black screen (unchanged)
              FutureBuilder<bool>(
                future: _hideFuture,
                builder: (context, snapshot) {
                  final shouldHide = snapshot.data == true;

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

// =========================
//  UI widgets
// =========================

class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.24),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppTheme.primaryTextColor.withOpacity(0.12),
          width: 1.w,
        ),
      ),
      child: child,
    );
  }
}

/// LEFT panel: header + fixed rows (NO ListView, NO scroll)
class _PrayerTableFixed extends StatelessWidget {
  const _PrayerTableFixed({
    required this.prayers,
    required this.pastIqamaFlags,
    required this.iqamaMinutes,
  });

  final List<dynamic>
  prayers; // your prayer model list from cubit.prayers(context)
  final List<bool> pastIqamaFlags;
  final List<int>? iqamaMinutes;

  @override
  Widget build(BuildContext context) {
    final int n = prayers.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        const double headerH = 52;
        const double gapAfterHeader = 8.0;
        const double rowGap = 6.0;

        final double available =
            constraints.maxHeight -
            headerH -
            gapAfterHeader -
            (n > 0 ? (n - 1) * rowGap : 0);

        final double rowH = n > 0 ? (available / n) : 0.0;

        // من غير clamp: بس امنع السالب
        final double safeRowH = rowH.isFinite && rowH > 0 ? rowH : 0.0;

        return Column(
          children: [
            SizedBox(height: headerH, child: const _PrayerTableHeader()),
            SizedBox(height: gapAfterHeader),
            if (n == 0)
              Expanded(
                child: Center(
                  child: AutoSizeText(
                    "--",
                    maxLines: 1,
                    minFontSize: 10,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                      fontFamily: CacheHelper.getTimesFontFamily(),
                    ),
                  ),
                ),
              )
            else
              ...List.generate(n, (index) {
                final p = prayers[index];

                final String adhanStr = CacheHelper.getUse24HoursFormat()
                    ? (p.time24 ?? '--:--')
                    : (p.time ?? '--:--');

                final String iqamaStr =
                    (p.time != null &&
                        iqamaMinutes != null &&
                        iqamaMinutes!.length >= p.id)
                    ? DateHelper.addMinutesToTimeStringWithSettings(
                        p.time!,
                        iqamaMinutes![p.id - 1],
                        context,
                      )
                    : '--:--';

                final bool dimmed = index < pastIqamaFlags.length
                    ? pastIqamaFlags[index]
                    : false;

                return Padding(
                  padding: EdgeInsets.only(bottom: index == n - 1 ? 0 : rowGap),
                  child: SizedBox(
                    height: safeRowH,
                    child: _PrayerRow(
                      title: p.title,
                      adhan: adhanStr,
                      iqama: iqamaStr,
                      dimmed: dimmed,
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

class _PrayerTableHeader extends StatelessWidget {
  const _PrayerTableHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _HeaderCell(LocaleKeys.prayer.tr())),
        SizedBox(width: 10.w),
        Expanded(child: _HeaderCell(LocaleKeys.adhan_time.tr())),
        SizedBox(width: 10.w),
        Expanded(child: _HeaderCell(LocaleKeys.iqama_time.tr())),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 2.w,
            color: AppTheme.primaryTextColor.withOpacity(0.9),
          ),
        ),
      ),
      child: Center(
        child: AutoSizeText(
          text,
          maxLines: 1,
          minFontSize: 10, // ✅ raw (NOT sp)
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: CacheHelper.getTimesFontFamily(),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.title,
    required this.adhan,
    required this.iqama,
    required this.dimmed,
  });

  final String title;
  final String adhan;
  final String iqama;
  final bool dimmed;

  Color _color() {
    if (!CacheHelper.getIsPreviousPrayersDimmed()) {
      return AppTheme.primaryTextColor;
    }
    return dimmed
        ? AppTheme.primaryTextColor.withOpacity(0.4)
        : AppTheme.primaryTextColor;
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();

    return Row(
      children: [
        Expanded(
          child: AutoSizeText(
            title,
            maxLines: 1,
            minFontSize: 10, // ✅ raw
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: CacheHelper.getTimesFontFamily(),
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: c,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Center(
            child: AutoSizeText(
              adhan,
              maxLines: 1,
              minFontSize: 10, // ✅ raw
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: CacheHelper.getTimesFontFamily(),
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: c,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Center(
            child: AutoSizeText(
              iqama,
              maxLines: 1,
              minFontSize: 10, // ✅ raw
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: CacheHelper.getTimesFontFamily(),
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: c,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// CENTER panel: fixed layout (no FittedBox / no overflow)
class _CenterClockFixed extends StatelessWidget {
  const _CenterClockFixed({required this.fixedDhikr});
  final String fixedDhikr;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double dhikrH = 46.h;
        final double gap = 8.h;
        final double clockH = (constraints.maxHeight - dhikrH - gap);

        return Column(
          children: [
            SizedBox(
              height: clockH,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: LiveClockRow(
                    timeFontSize: 70.sp,
                    periodFontSize: 22.sp,
                    use24Format: CacheHelper.getUse24HoursFormat(),
                  ),
                ),
              ),
            ),
            SizedBox(height: gap),
            SizedBox(
              height: dhikrH,
              child: Center(
                child: AdaptiveTextWidget(
                  fontFamily: CacheHelper.getTextsFontFamily(),
                  availableHeight: dhikrH,
                  text: fixedDhikr,
                  maxFontSize: 18.sp,
                  minFontSize: 11.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// RIGHT panel: fixed segments; Eid area adapts; never overflow
class _RightInfoFixed extends StatelessWidget {
  const _RightInfoFixed({required this.cubit, required this.nextPrayerFuture});

  final AppCubit cubit;
  final Future<prayerModel.Prayer?> nextPrayerFuture;

  @override
  Widget build(BuildContext context) {
    final bool showFitr = CacheHelper.getShowFitrEid();
    final bool showAdha = CacheHelper.getShowAdhaEid();
    final int eidCount = (showFitr ? 1 : 0) + (showAdha ? 1 : 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double gap = 8.h;

        // Allocate fixed proportions safely
        final double infoH = (constraints.maxHeight * 0.34);
        final double countdownH = (constraints.maxHeight * 0.30);

        final double used = infoH + countdownH + (eidCount > 0 ? gap : 0);
        final double eidAreaH = (constraints.maxHeight - used - gap);

        final double singleEidH = eidCount == 0
            ? 0.0
            : ((eidAreaH - (eidCount - 1) * gap) / eidCount);

        return Column(
          children: [
            SizedBox(
              height: infoH,
              child: _InfoBlock(cubit: cubit),
            ),
            SizedBox(height: gap),
            Expanded(
              child: _BigCountdownPanel(nextPrayerFuture: nextPrayerFuture),
            ),

            if (eidCount > 0) SizedBox(height: gap),

            if (showFitr)
              SizedBox(
                height: singleEidH,
                child: _EidMiniBlock(
                  title: LocaleKeys.eid_al_fitr.tr(),
                  date: CacheHelper.getFitrEid()?[0] ?? '--/--/--',
                  time: CacheHelper.getFitrEid()?[1] ?? '--:--',
                ),
              ),
            if (showFitr && showAdha) SizedBox(height: gap),
            if (showAdha)
              SizedBox(
                height: singleEidH,
                child: _EidMiniBlock(
                  title: LocaleKeys.eid_al_adha.tr(),
                  date: CacheHelper.getAdhaEid()?[0] ?? '--/--/--',
                  time: CacheHelper.getAdhaEid()?[1] ?? '--:--',
                ),
              ),
          ],
        );
      },
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.cubit});
  final AppCubit cubit;

  @override
  Widget build(BuildContext context) {
    final weekday = LocalizationHelper.isArabic(context)
        ? DateTime.now().weekdayNameAr
        : DateTime.now().weekday.toWeekDay();

    final hijri = cubit.hijriDate ?? "--:--";

    final greg = LocalizationHelper.isArAndArNumberEnable(context)
        ? DateHelper.toArabicDigits(
            DateFormat('dd/MM/yyyy').format(DateTime.now()),
          )
        : DateHelper.toWesternDigits(
            DateFormat('dd/MM/yyyy').format(DateTime.now()),
          );

    final temp = cubit.maxTemp?.toInt();
    final tempStr = temp == null
        ? "--"
        : (LocalizationHelper.isArAndArNumberEnable(context)
              ? DateHelper.toArabicDigits(temp.toString())
              : temp.toString());

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (cubit.nextPrayerVar == null) return;
              AppNavigator.push(
                context,
                AzanPrayerScreen(
                  currentPrayer: cubit.nextPrayerVar!.copywith(
                    dateTime: DateTime.now(),
                  ),
                ),
              );
            },
            child: _infoLine(LocaleKeys.day.tr(), weekday),
          ),
        ),
        SizedBox(height: 6.h),
        Expanded(child: _infoLine(LocaleKeys.hijri_date.tr(), hijri)),
        SizedBox(height: 6.h),
        Expanded(child: _infoLine(LocaleKeys.gregorian_date.tr(), greg)),
        SizedBox(height: 6.h),
        Expanded(child: _infoLine(LocaleKeys.temp.tr(), '$tempStr°')),
      ],
    );
  }

  Widget _infoLine(String k, String v) {
    return AutoSizeText(
      v,
      maxLines: 1,
      minFontSize: 9, // ✅ raw (NOT sp)
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryTextColor,
      ),
    );
  }
}

class _BigCountdownPanel extends StatelessWidget {
  const _BigCountdownPanel({required this.nextPrayerFuture});
  final Future<prayerModel.Prayer?> nextPrayerFuture;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: FutureBuilder<prayerModel.Prayer?>(
        future: nextPrayerFuture,
        builder: (context, snapshot) {
          final p = snapshot.data;
          final dt = p?.dateTime;

          final durationStr = (dt == null)
              ? "--:--"
              : (LocalizationHelper.isArAndArNumberEnable(context)
                    ? DateHelper.toArabicDigits(
                        dt.difference(DateTime.now()).formatDuration(),
                      )
                    : dt.difference(DateTime.now()).formatDuration());

          final leftForText = LocalizationHelper.isArabic(context)
              ? (LocaleKeys.left_for.tr() + (p?.title.substring(1) ?? ""))
              : (LocaleKeys.left_for.tr() + " " + (p?.title ?? ""));

          final isRed =
              CacheHelper.getIsChangeCounterEnabled() &&
              dt != null &&
              dt.difference(DateTime.now()).inSeconds <= 90;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(
                durationStr,
                maxLines: 1,
                minFontSize: 12, // ✅ raw
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: CacheHelper.getTimesFontFamily(),
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: isRed ? Colors.red : AppTheme.secondaryTextColor,
                ),
              ),
              SizedBox(height: 6.h),
              AutoSizeText(
                leftForText,
                maxLines: 1,
                minFontSize: 10, // ✅ raw
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: CacheHelper.getTimesFontFamily(),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryTextColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EidMiniBlock extends StatelessWidget {
  const _EidMiniBlock({
    required this.title,
    required this.date,
    required this.time,
  });

  final String title;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(
            title,
            maxLines: 1,
            minFontSize: 10, // ✅ raw
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
          ),
          SizedBox(height: 6.h),
          AutoSizeText(
            date,
            maxLines: 1,
            minFontSize: 9, // ✅ raw
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          SizedBox(height: 4.h),
          AutoSizeText(
            time,
            maxLines: 1,
            minFontSize: 9, // ✅ raw
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
//  Slider + AdaptiveText (local, safe)
// =========================

class LandscapeAzkarSlider extends StatefulWidget {
  final List<String> adhkar;
  final double height;
  final double maxFontSize;
  final double minFontSize;

  const LandscapeAzkarSlider({
    super.key,
    required this.adhkar,
    required this.height,
    required this.maxFontSize,
    required this.minFontSize,
  });

  @override
  State<LandscapeAzkarSlider> createState() => _LandscapeAzkarSliderState();
}

class _LandscapeAzkarSliderState extends State<LandscapeAzkarSlider> {
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
    if (widget.adhkar.isEmpty) return const SizedBox.shrink();

    return GlassPanel(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: SizedBox(
        height: widget.height,
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.adhkar.length,
          itemBuilder: (context, index) {
            final text = widget.adhkar[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
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
    );
  }
}

class AdaptiveTextWidget extends StatelessWidget {
  final String text;
  final double maxFontSize;
  final double minFontSize;
  final double availableHeight;
  final String? fontFamily;

  const AdaptiveTextWidget({
    super.key,
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

        final textPainter = TextPainter(
          textDirection: material.TextDirection.rtl,
          textAlign: TextAlign.center,
        );

        while (currentFontSize >= minFontSize) {
          textPainter.text = TextSpan(
            text: text,
            style: TextStyle(
              fontSize: currentFontSize,
              fontWeight: FontWeight.bold,
              height: 1,
              fontFamily: fontFamily ?? CacheHelper.getAzkarFontFamily(),
              color: AppTheme.primaryTextColor,
            ),
          );
          textPainter.layout(maxWidth: width);

          final lines = textPainter.computeLineMetrics().length;
          final textHeight = textPainter.height;

          if (lines <= 2 && textHeight <= availableHeight) break;
          currentFontSize -= 1;
        }

        if (currentFontSize < minFontSize) currentFontSize = minFontSize;

        return Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: currentFontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
              fontFamily: fontFamily ?? CacheHelper.getAzkarFontFamily(),
            ),
            textAlign: TextAlign.center,
            textDirection: material.TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
