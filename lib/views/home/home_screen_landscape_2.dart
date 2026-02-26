import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/helpers/simple_sound_player.dart';
import 'package:azan/core/models/next_Iqama.dart';
import 'package:azan/core/models/prayer.dart';
import 'package:azan/core/models/prayer_display_data.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/additional_settings/components/azkar_time_helper.dart';
import 'package:azan/views/home/azan_prayer_screen.dart';
import 'package:azan/views/home/components/RotatingAyahBanner.dart';
import 'package:azan/views/home/components/azkar_view.dart';
import 'package:azan/views/home/components/clock_and_left_time_widget.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:azan/views/home/components/home_appbar.dart';
import 'package:azan/views/home/components/landscape_top.dart';
import 'package:azan/views/home/components/live_clock_row.dart';
import 'package:azan/views/home/components/prayer_row_data.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azan/core/models/prayer.dart' as prayerModel;
import 'package:jhijri/_src/_jHijri.dart';

class HomeScreenLandscape2 extends StatefulWidget {
  const HomeScreenLandscape2({super.key});

  @override
  State<HomeScreenLandscape2> createState() => _HomeScreenLandscape2State();
}

class _HomeScreenLandscape2State extends State<HomeScreenLandscape2> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  AppCubit get cubit => AppCubit();
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
    unawaited(cubit.getIqamaTime());
    unawaited(cubit.assignAdhkar());

    // ✅ الطقس: اعرض من الكاش فوراً لو موجود + هات من النت عند الحاجة فقط
    unawaited(
      cubit.maybeRefreshWeather(
        country: 'Saudi Arabia',
        city: city,
        hasInternet: () => cubit.hasInternet,
        onHomeOpen: true, // ✅ أهم سطر
      ),
    );

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

    _tickTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) {
        t.cancel();
        return;
      }

      // ✅ احفظ الوقت الحقيقي أول ما دخلت
      final now = DateTime.now();

      // ✅ اعمل الحاجات المهمة الأولى (بدون setState)
      await _checkAndPlayPrayerSound(now); // ✅ await!
      performAdhanActions(context);
      _azkarOverlay.tick(now: now);

      // ✅ تحقق من الوصول لوقت الإقامة لفتح شاشة الإقامة مباشرة
      if (cubit.isBetweenAdhanAndIqama &&
          cubit.currentIqamaTime != null &&
          !cubit.startAzanAtIqamaPhase &&
          now.isAfter(cubit.currentIqamaTime!)) {
        cubit.isBetweenAdhanAndIqama = false;
        cubit.startAzanAtIqamaPhase = true;
        cubit.showPrayerAzanPage = true;
      }

      // ✅ setState في الآخر (مش مهم لو أخذت وقت)
      setState(() {});

      // ✅ تحقق من اليوم الجديد
      if (!_isSameDay(now, _lastDate)) {
        // _refreshMinuteFutures();
        _lastDate = now;
        _onNewDay();
      }
      if (!_isSameDay(now, DateTime.now())) {
        if (!mounted) return;
        setState(() => _refreshMinuteFutures());
      }
    });

    // ✅ التايمر الثاني، يبقى كما هو
    _minuteTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => _refreshMinuteFutures());
    });
  }

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
    _azkarOverlay.tick(now: DateTime.now());

    // ✅ الباقي في الخلفية
    // unawaited(_assignHijriDate());
    // final city = cubit.getCity()?.nameEn ?? '';

    unawaited(
      cubit.maybeRefreshWeather(
        country: 'Saudi Arabia',
        city: city,
        hasInternet: () => cubit.hasInternet,
        onHomeOpen: true, // ✅ أهم سطر
      ),
    );

    cubit.startWeatherAutoSync(
      country: 'Saudi Arabia',
      city: city,
      hasInternet: () => cubit.hasInternet,
    );

    unawaited(cubit.assignAdhkar());

    // ✅ شغل التايمرز بعد ما الأساسيات خلصت
    _startTimers();
  }

  late final AzkarOverlayController _azkarOverlay;
  @override
  void initState() {
    super.initState();
    // AppCubit.get(context).homeScreenLandscape = this;
    _azkarOverlay = AzkarOverlayController();

    // _azkarOverlay.start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      homeScreenWork();
    });
  }

  // =========================
  //  Actions (كما هي)
  // =========================
  void performAdhanActions(BuildContext context) {
    if (cubit.prayerTimes == null) return;

    final prayers = cubit.prayers(context);
    for (final prayer in prayers) {
      final DateTime? adhanTime = prayer.dateTime;
      if (adhanTime == null || cubit.iqamaMinutes == null) continue;

      if (_isSameMinute(adhanTime, DateTime.now())) {
        final int id = prayer.id;
        if (id <= 0 || id > cubit.iqamaMinutes!.length) {
          continue;
        }
        final iqamaTime = adhanTime.add(
          Duration(minutes: cubit.iqamaMinutes![id - 1]),
        );

        setState(() {
          CacheHelper.setCurrentPrayerKey(prayer.title);
          cubit.startAdhanCycle(
            prayer: prayer,
            adhanTime: adhanTime,
            iqamaTime: iqamaTime,
          );
          cubit.showPrayerAzanPage = true;
        });
      }
    }
  }

  Future<void> _checkAndPlayPrayerSound(DateTime now) async {
    if (cubit.prayerTimes == null || cubit.iqamaMinutes == null) return;

    final prayers = cubit.prayers(context);
    final iqamaMinutes = cubit.iqamaMinutes!;
    final azanSource = cubit.getAzanSoundSource;
    final iqamaSource = cubit.getIqamaSoundSource;

    // ✅ تحقق من الـ source أولاً
    if (azanSource.isEmpty || iqamaSource.isEmpty) {
      return;
    }

    for (final prayer in prayers) {
      final int id = prayer.id;
      final DateTime? adhanTime = prayer.dateTime;
      if (adhanTime == null) continue;

      // ===== أذان =====
      if (!_playedAdhanToday.contains(id) && _isSameMinute(adhanTime, now)) {
        // ✅ await على النتيجة
        final success = await _soundPlayer.playAsset(azanSource);

        // ✅ ضف العلامة فقط لو نجح
        if (success) {
          _playedAdhanToday.add(id);
        } else {}
      }

      // ===== إقامة =====
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
          // ✅ await
          final success = await _soundPlayer.playAsset(iqamaSource);

          if (success) {
            _playedIqamaToday.add(id);
          } else {}
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

  ({int day, int month, int year}) _todayHijriParts() {
    final offsetDays = CacheHelper.getHijriOffsetDays();
    final g = DateTime.now().add(Duration(days: offsetDays));
    final h = JHijri(fDate: g);

    return (day: h.day, month: h.month, year: h.year);
  }

  bool _isTodayHijri({required int day, required int month}) {
    final h = _todayHijriParts();
    return h.day == day && h.month == month;
  }

  bool get _isFitrDayHijri => _isTodayHijri(day: 1, month: 10);
  bool get _isAdhaDayHijri => _isTodayHijri(day: 10, month: 12);

  Future<void> _openAzkarTimingSettings() async {
    bool morningEnabled = CacheHelper.getMorningAzkarEnabled();
    bool eveningEnabled = CacheHelper.getEveningAzkarEnabled();
    int morningMinutes = CacheHelper.getMorningAzkarWindowMinutes();
    int eveningMinutes = CacheHelper.getEveningAzkarWindowMinutes();

    int clampMinutes(int v) => v.clamp(1, 600); // 1..600 دقيقة

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Widget minutesRow({
              required String title,
              required int value,
              required VoidCallback onMinus,
              required VoidCallback onPlus,
            }) {
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onMinus,
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                  Text(
                    '$value',
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  IconButton(
                    onPressed: onPlus,
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'دقيقة',
                    style: TextStyle(
                      color: AppTheme.primaryTextColor.withOpacity(.8),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              );
            }

            return AlertDialog(
              backgroundColor: Colors.black.withOpacity(0.85),
              title: Text(
                'إعدادات الأذكار',
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 420.w, // مناسب لعرض TV
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      value: morningEnabled,
                      activeColor: AppTheme.secondaryTextColor,
                      title: Text(
                        'تفعيل أذكار الصباح',
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onChanged: (v) => setLocal(() => morningEnabled = v),
                    ),
                    minutesRow(
                      title: 'مدة نافذة أذكار الصباح',
                      value: morningMinutes,
                      onMinus: () => setLocal(() {
                        morningMinutes = clampMinutes(morningMinutes - 5);
                      }),
                      onPlus: () => setLocal(() {
                        morningMinutes = clampMinutes(morningMinutes + 5);
                      }),
                    ),
                    SizedBox(height: 12.h),
                    SwitchListTile(
                      value: eveningEnabled,
                      activeColor: AppTheme.secondaryTextColor,
                      title: Text(
                        'تفعيل أذكار المساء',
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onChanged: (v) => setLocal(() => eveningEnabled = v),
                    ),
                    minutesRow(
                      title: 'مدة نافذة أذكار المساء',
                      value: eveningMinutes,
                      onMinus: () => setLocal(() {
                        eveningMinutes = clampMinutes(eveningMinutes - 5);
                      }),
                      onPlus: () => setLocal(() {
                        eveningMinutes = clampMinutes(eveningMinutes + 5);
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(color: AppTheme.primaryTextColor),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await CacheHelper.setMorningAzkarEnabled(morningEnabled);
                    await CacheHelper.setEveningAzkarEnabled(eveningEnabled);
                    await CacheHelper.setMorningAzkarWindowMinutes(
                      morningMinutes,
                    );
                    await CacheHelper.setEveningAzkarWindowMinutes(
                      eveningMinutes,
                    );

                    // ✅ عشان لو محتوى الأذكار بيتغير حسب الوقت
                    unawaited(cubit.assignAdhkar());

                    if (mounted) setState(() {});
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(
                    'حفظ',
                    style: TextStyle(color: AppTheme.secondaryTextColor),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _minuteTimer?.cancel();
    _soundPlayer.dispose();
    _azkarOverlay.dispose();
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
        listener: (context, state) {},
        builder: (context, state) {
          final prayers = cubit.prayers(context);
          final iqamaMinutes = cubit.iqamaMinutes;
          final nextFajrPrayer = cubit.nextFajrPrayer?.time24 ?? '--:--';

          // 1) الصفوف الأساسية (الصلوات المعتادة)
          final List<PrayerRowData> rows = List.generate(prayers.length, (
            index,
          ) {
            final p = prayers[index];

            final dimmed =
                index < pastIqamaFlags.length && pastIqamaFlags[index];

            final baseTimeStr = CacheHelper.getUse24HoursFormat()
                ? (p.time24 ?? p.time)
                : (p.time ?? p.time24);

            final adhanStr = baseTimeStr != null
                ? DateHelper.displayHHmmNoPeriod(baseTimeStr, context)
                : '--:--';

            final idx = p.id - 1;

            final iqamaStr =
                (baseTimeStr != null &&
                    iqamaMinutes != null &&
                    idx >= 0 &&
                    idx < iqamaMinutes.length)
                ? DateHelper.addMinutesDisplayHHmmNoPeriod(
                    baseTimeStr,
                    iqamaMinutes[idx],
                    context,
                  )
                : '--:--';

            return PrayerRowData(
              prayerName: p.title,
              adhanTime: adhanStr,
              iqamaTime: iqamaStr,
              dimmed: dimmed,
              nextFajrPrayer: nextFajrPrayer,
            );
          });

          // ===============================
          // 2) صفوف العيد (اختياريًا)
          // ===============================
          List<PrayerRowData> eidRows = [];

          PrayerRowData? buildEidRow({
            required String? rawEid,
            required bool shouldShow,
            required String fallbackName,
          }) {
            if (!shouldShow || rawEid == null || rawEid.length < 2) return null;

            final rawTime = rawEid.trim();
            if (rawTime.isEmpty || rawTime == '--:--') return null;

            // نفس منطق تنسيق الوقت المستخدم عندك
            final eidTime = DateHelper.displayHHmmNoPeriod(rawTime, context);

            // dimmed منطقي: لو وقت العيد عدى -> نعتبره dimmed
            bool eidDimmed = false;
            try {
              // هنقارن كـ HH:mm محلي مبسط لو أمكن
              // لو عندك helper يحول string -> DateTime لليوم الحالي استخدمه بدل ده
              final now = DateTime.now();

              // نجرب نفهم "HH:mm" (أو صيغة مشابهة بعد display)
              final parts = eidTime.split(':');
              if (parts.length >= 2) {
                final h = int.tryParse(
                  parts[0].replaceAll(RegExp(r'[^0-9]'), ''),
                );
                final m = int.tryParse(
                  parts[1].replaceAll(RegExp(r'[^0-9]'), ''),
                );
                if (h != null && m != null) {
                  final eidDateTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    h,
                    m,
                  );
                  eidDimmed = now.isAfter(eidDateTime);
                }
              }
            } catch (_) {
              eidDimmed = false;
            }

            return PrayerRowData(
              prayerName:
                  fallbackName, // "عيد الفطر" أو "عيد الأضحى" أو "صلاة العيد"
              adhanTime: eidTime,
              iqamaTime:
                  '', // فاضي زي ما طلبت (ممكن '--:--' لو تفضل ثبات الشكل)
              dimmed: eidDimmed,
              nextFajrPrayer: nextFajrPrayer,
            );
          }

          final adhaRow = buildEidRow(
            rawEid: CacheHelper.getAdhaEid(),
            shouldShow: CacheHelper.getShowAdhaEid() && _isAdhaDayHijri,
            fallbackName: LocaleKeys.eid_al_adha.tr(),
          );

          final fitrRow = buildEidRow(
            rawEid: CacheHelper.getFitrEid(),
            shouldShow: CacheHelper.getShowFitrEid() && _isFitrDayHijri,
            fallbackName: LocaleKeys.eid_al_fitr.tr(),
          );

          if (fitrRow != null) eidRows.add(fitrRow);
          if (adhaRow != null) eidRows.add(adhaRow);

          // ===============================
          // 3) إدراج العيد بعد الشروق
          // ===============================
          if (eidRows.isNotEmpty) {
            // الأفضل تعتمد على id=2 للشروق عندك
            final sunriseIndex = prayers.indexWhere((p) => p.id == 2);

            if (sunriseIndex != -1) {
              final insertAt = sunriseIndex + 1;
              rows.insertAll(insertAt, eidRows);
            } else {
              // fallback لو الشروق مش موجود لأي سبب
              rows.addAll(eidRows);
            }
          }
          return SizedBox(
            height: 1.sh,
            width: 1.sw,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    CacheHelper.getSelectedBackground(),
                    fit: BoxFit.cover,
                  ),
                ),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double height = constraints.maxHeight;
                      final double width = constraints.maxWidth;

                      // ✅ كل حاجة responsive من الـ width و height
                      final double hPadding = width * 0.008; // 0.8% من العرض
                      final double itemSpacing = width * 0.006; // 0.6% من العرض

                      final topH = height * 0.10;
                      final liveClockRowH = height * 0.28;
                      final ayatH = height * 0.11;
                      final prayerRowH = height * 0.31;

                      final double totalSpacing =
                          (rows.length - 1) * itemSpacing;
                      final double itemWidth =
                          (width - totalSpacing - (hPadding * 2)) / rows.length;
                      // final double height = constraints.maxHeight; // ✅ after SafeArea
                      //   final double width = constraints.maxWidth;   // ✅ after SafeArea

                      // Your design is 960x540, SafeArea already handled
                      // So scale against your design size
                      final double scaleW = width / 960.0;
                      final double scaleH = height / 540.0;

                      // Use the smaller scale to avoid overflow
                      final double scale = scaleW < scaleH ? scaleW : scaleH;
                      final double azkarH = height * 0.1;
                      final double footerH = height * 0.050;
                      return Column(
                        children: [
                          SizedBox(
                            // color: Colors.red,
                            height: 70 * scale,
                            child: LandscapeTop(
                              onDrawerTap: () =>
                                  scaffoldKey.currentState?.openDrawer(),
                              height: topH,
                              gregDate: '2026/2/17',
                              hijriDate: cubit.hijriDate ?? '',
                              titleFontSize: 20 * scale,
                              hijiriFontSize: 25 * scale,
                            ),
                          ),
                          Container(
                            // color: Colors.yellow,
                            height: liveClockRowH,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ClockAndLeftTimeWidget(
                                    nextPrayerFuture: _nextPrayerFuture,
                                    width: width,
                                    letfTimeText: "",
                                  ),
                                ),
                                if (cubit.isBetweenAdhanAndIqama)
                                  Builder(
                                    builder: (_) {
                                      final d = cubit.remainingToIqama();
                                      if (d == null || d.inSeconds <= 0) {
                                        return const SizedBox.shrink();
                                      }
                                      final text = d.formatDuration();
                                      final localized =
                                          LocalizationHelper
                                                  .isArAndArNumberEnable()
                                              ? DateHelper.toArabicDigits(text)
                                              : DateHelper.toWesternDigits(
                                                  text,
                                                );
                                      return Padding(
                                        padding: EdgeInsets.only(top: 4.h),
                                        child: AutoSizeText(
                                          '${LocaleKeys.remaining_for_iqamaa.tr()} $localized',
                                          maxLines: 1,
                                          minFontSize: 10,
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            color:
                                                AppTheme.secondaryTextColor,
                                            fontFamily:
                                                CacheHelper.getTextsFontFamily(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),

                          RotatingAyahBanner(
                            maxLines: 1,
                            ayat: ayat, // ✅ اللي انت جايبه
                            height: ayatH,
                            // availableHeight: 90.h, // لو عايز نفس منطقك القديم
                            maxFontSize: 30.sp,
                            minFontSize: 12.sp,
                            interval: const Duration(
                              seconds: 20,
                            ), // أو CacheHelper.getSliderTime()
                            fontFamily: CacheHelper.getAzkarFontFamily(),
                            textColor: AppTheme.primaryTextColor,
                          ),
                          Spacer(),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: hPadding,
                            ), // ✅ raw
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(rows.length, (index) {
                                return Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    end: index != rows.length - 1
                                        ? itemSpacing
                                        : 0,
                                  ),
                                  child: PrayerLandScapeItem(
                                    row: rows[index],
                                    width: itemWidth,
                                    height: prayerRowH,
                                  ),
                                );
                              }),
                            ),
                          ),

                          AzkarSlider(
                            adhkar: cubit.todaysAdkar != null
                                ? cubit.todaysAdkar!.map((e) => e.text).toList()
                                : [],
                            height: azkarH,

                            maxFontSize: scale * 26,
                            minFontSize: scale * 19,
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AutoSizeText(
                                    LocaleKeys.copy_right_for_sadja.tr(),
                                    maxLines: 1,
                                    minFontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 20.sp,
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

                FutureBuilder<bool>(
                  future: _hideFuture,
                  builder: (context, snapshot) {
                    final shouldHide =
                        CacheHelper.getHideScreenAfterIshaaEnabled() &&
                        (snapshot.data == true);

                    final azanActive =
                        (cubit.currentPrayer != null &&
                        cubit.currentPrayer!.id != 2 &&
                        cubit.showPrayerAzanPage);

                    return ValueListenableBuilder<AzkarWindow?>(
                      valueListenable: _azkarOverlay,
                      builder: (_, w, __) {
                        Widget overlay = const SizedBox.shrink();

                        // 1) أعلى أولوية: AzanPrayerScreen
                        if (azanActive) {
                          overlay = AzanPrayerScreen(
                            key: const ValueKey('azan-test'),
                            currentPrayer: cubit.currentPrayer!,
                          );
                        }
                        // 2) ثاني أولوية: black screen
                        else if (shouldHide) {
                          overlay = Container(
                            key: const ValueKey('black_screen'),
                            height: 1.sh,
                            width: 1.sw,
                            color: Colors.black,
                          );
                        }
                        // 3) ثالث أولوية: Azkar
                        else if (w != null) {
                          overlay = GestureDetector(
                            key: ValueKey(
                              'azkar-${w.type.name}-${w.prayerId ?? 0}',
                            ),
                            behavior: HitTestBehavior.opaque,
                            onTap: _azkarOverlay.dismissForNow,
                            child: AzkarView(
                              azkarType: w.type,
                              // prayerId: w.prayerId,
                            ),
                          );
                        }

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 1500),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: overlay,
                        );
                      },
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

class PrayerLandScapeItem extends StatelessWidget {
  const PrayerLandScapeItem({
    super.key,
    required this.row,
    required this.width,
    required this.height,
  });

  final PrayerRowData row;
  final double width;
  final double height;
  Color _color(bool dimmed, Color color) {
    if (dimmed && CacheHelper.getIsPreviousPrayersDimmed()) {
      return color.withOpacity(0.5);
    }

    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      height: height,
      width: width,

      decoration: CacheHelper.getEnableGlassEffect()
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
                colors: [
                  Colors.white.withOpacity(0.08), // خفيف جداً
                  Colors.white.withOpacity(0.03),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            )
          : null,

      child: Column(
        children: CacheHelper.getPrayerTimeTileInCenter()
            ? [
                Flexible(
                  child: FittedBox(
                    child: Text(
                      row.adhanTime,
                      // 'الفجر',
                      style: TextStyle(
                        color: _color(row.dimmed, AppTheme.secondaryTextColor),
                        fontWeight: FontWeight.bold,
                        fontSize:
                            CacheHelper.getEnlargeAdhanAndIqamaTimeInLandeScape()
                            ? height * 0.3
                            : height * 0.2,
                        fontFamily: CacheHelper.getTimesFontFamily(),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    child: Text(
                      row.prayerName,
                      // 'الفجر',
                      style: TextStyle(
                        color: _color(row.dimmed, AppTheme.secondaryTextColor),
                        fontWeight: FontWeight.bold,
                        fontSize: height * 0.2,
                        fontFamily: CacheHelper.getTimesFontFamily(),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Flexible(
                  child: FittedBox(
                    child: Text(
                      row.iqamaTime,
                      // 'الفجر',
                      style: TextStyle(
                        color: _color(row.dimmed, AppTheme.primaryTextColor),
                        fontWeight: FontWeight.bold,
                        fontSize:
                            CacheHelper.getEnlargeAdhanAndIqamaTimeInLandeScape()
                            ? height * 0.3
                            : height * 0.2,
                        fontFamily: CacheHelper.getTimesFontFamily(),

                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]
            : [
                Flexible(
                  // flex: 10,
                  child: FittedBox(
                    child: Text(
                      row.prayerName,
                      style: TextStyle(
                        color: _color(row.dimmed, AppTheme.primaryTextColor),

                        // fontWeight: FontWeight.bold,
                        fontSize: height * 0.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  // flex: 17,
                  child: FittedBox(
                    child: Text(
                      row.adhanTime,
                      // 'الفجر',
                      style: TextStyle(
                        color: _color(row.dimmed, AppTheme.secondaryTextColor),
                        fontWeight: FontWeight.bold,
                        fontSize:
                            CacheHelper.getEnlargeAdhanAndIqamaTimeInLandeScape()
                            ? height * 0.3
                            : height * 0.2,
                        fontFamily: CacheHelper.getTimesFontFamily(),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  // flex: 17,
                  child: FittedBox(
                    child: Text(
                      row.iqamaTime,
                      // 'الفجر',
                      style: TextStyle(
                        color: _color(row.dimmed, AppTheme.primaryTextColor),

                        fontWeight: FontWeight.bold,
                        fontSize:
                            CacheHelper.getEnlargeAdhanAndIqamaTimeInLandeScape()
                            ? height * 0.3
                            : height * 0.2,
                        fontFamily: CacheHelper.getTimesFontFamily(),

                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
      ),
    );
  }
}
