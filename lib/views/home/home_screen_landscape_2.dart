import 'dart:async';
import 'package:azan/core/components/global_copyright_footer.dart';

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/display_board_schedule_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/helpers/simple_sound_player.dart';
import 'package:azan/core/models/next_Iqama.dart';
import 'package:azan/core/models/home_display_mode.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/dialoge_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/additional_settings/components/azkar_time_helper.dart';
import 'package:azan/views/home/azan_prayer_screen.dart';
import 'package:azan/views/home/components/RotatingAyahBanner.dart';
import 'package:azan/views/home/components/azkar_view.dart';
import 'package:azan/views/home/components/black_screen_info_overlay.dart';
import 'package:azan/views/home/components/clock_and_left_time_widget.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:azan/views/home/components/home_appbar.dart';
import 'package:azan/views/home/components/iqama_focus_section.dart';
import 'package:azan/views/home/components/iqama_last_minute_countdown_overlay.dart';
import 'package:azan/views/home/components/prayer_row_data.dart';
import 'package:azan/views/home/home_screen.dart';
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
  bool _isRoutingByDisplayMode = false;

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

  void _syncHomeBlackScreenFlag(bool visible) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      cubit.setHomeBlackScreenVisible(visible);
    });
  }

  void _syncDisplayBoardMode(DateTime now) {
    if (_isRoutingByDisplayMode || !mounted) return;

    final manualMode = CacheHelper.getHomeDisplayMode();
    final effectiveMode = DisplayBoardScheduleResolver.effectiveDisplayMode(
      manualMode: manualMode,
      items: cubit.displayAnnouncementList ?? const [],
      now: now,
    );
    final scheduledBoardActive =
        DisplayBoardScheduleResolver.hasScheduledAnnouncementsDue(
          cubit.displayAnnouncementList ?? const [],
          now,
        );

    if (effectiveMode != HomeDisplayMode.displayBoard) {
      return;
    }

    if (manualMode == HomeDisplayMode.displayBoard || scheduledBoardActive) {
      _isRoutingByDisplayMode = true;
      AppNavigator.pushAndRemoveUntil(context, const HomeScreen());
    }
  }

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
    unawaited(cubit.assignSlides());
    unawaited(cubit.assignDisplayAnnouncements());

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
      _checkAndPlayPrayerSound(now);
      performAdhanActions(context);
      _azkarOverlay.tick(now: now);
      _syncDisplayBoardMode(now);

      // ✅ تحقق من الوصول لوقت الإقامة لفتح شاشة الإقامة مباشرة
      final remainingToIqama = cubit.remainingToIqama();
      if (cubit.isBetweenAdhanAndIqama &&
          !cubit.startAzanAtIqamaPhase &&
          remainingToIqama != null &&
          remainingToIqama <= Duration.zero) {
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
    _syncDisplayBoardMode(DateTime.now());

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
    unawaited(cubit.assignSlides());
    unawaited(cubit.assignDisplayAnnouncements());

    // ✅ شغل التايمرز بعد ما الأساسيات خلصت
    _startTimers();
  }

  String _localizedDurationText(Duration duration) {
    final raw = duration.formatDuration();
    return LocalizationHelper.isArAndArNumberEnable()
        ? DateHelper.toArabicDigits(raw)
        : DateHelper.toWesternDigits(raw);
  }

  List<IqamaPrayerSummaryData> _iqamaPrayerItems(BuildContext context) {
    final prayers = List<prayerModel.Prayer>.from(cubit.prayers(context))
      ..sort((a, b) => a.id.compareTo(b.id));

    return prayers.where((p) => p.id >= 1 && p.id <= 6).map((p) {
      final baseTimeStr = CacheHelper.getUse24HoursFormat()
          ? (p.time24 ?? p.time)
          : (p.time ?? p.time24);
      final adhanTime = baseTimeStr != null
          ? DateHelper.displayHHmmNoPeriod(baseTimeStr, context)
          : '--:--';
      return IqamaPrayerSummaryData(prayerName: p.title, adhanTime: adhanTime);
    }).toList();
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

    final azanSource = cubit.getAzanSoundSource;
    final prayers = cubit.prayers(context);
    for (final prayer in prayers) {
      final DateTime? adhanTime = prayer.dateTime;
      if (adhanTime == null) continue;

      if (_isSameMinute(adhanTime, DateTime.now())) {
        final int id = prayer.id;
        int iqamaOffsetMinutes = 10;
        final iqamaMinutes = cubit.iqamaMinutes;
        if (iqamaMinutes != null && id > 0 && id <= iqamaMinutes.length) {
          iqamaOffsetMinutes = iqamaMinutes[id - 1];
        }
        final iqamaTime = adhanTime.add(Duration(minutes: iqamaOffsetMinutes));

        if (!_playedAdhanToday.contains(id) && azanSource.isNotEmpty) {
          _playedAdhanToday.add(id);
          unawaited(
            _soundPlayer.playAsset(azanSource).then((success) {
              if (!success) {
                _playedAdhanToday.remove(id);
              }
            }),
          );
        }

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

  void _checkAndPlayPrayerSound(DateTime now) {
    if (cubit.prayerTimes == null || cubit.iqamaMinutes == null) return;

    final prayers = cubit.prayers(context);
    final iqamaMinutes = cubit.iqamaMinutes!;
    final iqamaSource = cubit.getIqamaSoundSource;

    // ✅ تحقق من الـ source أولاً
    if (iqamaSource.isEmpty) {
      return;
    }

    for (final prayer in prayers) {
      final int id = prayer.id;
      final DateTime? adhanTime = prayer.dateTime;
      if (adhanTime == null) continue;

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
          // احجز العلامة فورًا لمنع إعادة التشغيل في نفس الدقيقة
          _playedIqamaToday.add(id);
          unawaited(
            _soundPlayer.playAsset(iqamaSource).then((success) {
              if (!success) {
                _playedIqamaToday.remove(id);
              }
            }),
          );
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

    await showAppDialog(
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
              return DialogContentCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: DialogPalette.bodyTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onMinus,
                      icon: const Icon(
                        Icons.remove_circle_outline_rounded,
                        color: DialogPalette.primaryButtonBackground,
                      ),
                    ),
                    Text(
                      '$value',
                      style: TextStyle(
                        color: DialogPalette.titleTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    IconButton(
                      onPressed: onPlus,
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: DialogPalette.primaryButtonBackground,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'دقيقة',
                      style: TextStyle(
                        color: DialogPalette.mutedTextColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              );
            }

            return UniversalDialogShell(
              customMaxWidth: 420.w,
              child: SizedBox(
                width: 420.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const DialogTitle('إعدادات الأذكار'),
                    SizedBox(height: 12.h),
                    SwitchListTile(
                      value: morningEnabled,
                      activeColor: DialogPalette.primaryButtonBackground,
                      title: Text(
                        'تفعيل أذكار الصباح',
                        style: TextStyle(
                          color: DialogPalette.bodyTextColor,
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
                      activeColor: DialogPalette.primaryButtonBackground,
                      title: Text(
                        'تفعيل أذكار المساء',
                        style: TextStyle(
                          color: DialogPalette.bodyTextColor,
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
                    SizedBox(height: 16.h),
                    DialogButtonRow(
                      leftButton: DialogButton(
                        text: 'إلغاء',
                        variant: DialogButtonVariant.secondary,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      rightButton: DialogButton(
                        text: 'حفظ',
                        onPressed: () async {
                          await CacheHelper.setMorningAzkarEnabled(morningEnabled);
                          await CacheHelper.setEveningAzkarEnabled(eveningEnabled);
                          await CacheHelper.setMorningAzkarWindowMinutes(
                            morningMinutes,
                          );
                          await CacheHelper.setEveningAzkarWindowMinutes(
                            eveningMinutes,
                          );
                          unawaited(cubit.assignAdhkar());
                          if (mounted) setState(() {});
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
    cubit.setHomeBlackScreenVisible(false);
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
    final theme = Theme.of(context);
    final noShadowTheme = theme.copyWith(
      textTheme: AppTheme.withoutTextShadow(theme.textTheme),
      primaryTextTheme: AppTheme.withoutTextShadow(theme.primaryTextTheme),
    );
    return Theme(
      data: noShadowTheme,
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: const GlobalCopyrightFooter(),
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
              if (!shouldShow || rawEid == null || rawEid.length < 2)
                return null;

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
                  if (AppTheme.backgroundReadabilityOverlayAlpha > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ColoredBox(
                          color: Colors.black.withValues(
                            alpha: AppTheme.backgroundReadabilityOverlayAlpha,
                          ),
                        ),
                      ),
                    ),
                  SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double height = constraints.maxHeight;
                        final double width = constraints.maxWidth;

                        // ✅ كل حاجة responsive من الـ width و height
                        final double hPadding = width * 0.008; // 0.8% من العرض
                        final double itemSpacing =
                            width * 0.006; // 0.6% من العرض

                        final appBarH = height * 0.09;
                        final liveClockRowH = height * 0.32;
                        final ayatH = height * 0.11;
                        final prayerRowH = height * 0.31;

                        final double totalSpacing =
                            (rows.length - 1) * itemSpacing;
                        final double itemWidth =
                            (width - totalSpacing - (hPadding * 2)) /
                            rows.length;
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
                              height: appBarH,
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: 4.w,
                                  end: 4.w,
                                ),
                                child: HomeAppBar(
                                  onDrawerTap: () =>
                                      scaffoldKey.currentState?.openDrawer(),
                                  titleFontSize: 20 * scale,
                                ),
                              ),
                            ),
                            Container(
                              height: liveClockRowH,
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.01,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ClockAndLeftTimeWidget(
                                      nextPrayerFuture: _nextPrayerFuture,
                                      width: width,
                                      letfTimeText: "",
                                      isIqamaActive:
                                          cubit.isBetweenAdhanAndIqama,
                                      onHijriTap: () async {
                                        await CacheHelper.stepHijriOffsetCycle();
                                        await AppCubit.get(
                                          context,
                                        ).getTodayHijriDate(context);
                                        if (!mounted) return;
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (CacheHelper.getSlidesEnabled())
                              RotatingAyahBanner(
                                maxLines: 1,
                                ayat:
                                    (cubit.todaysSlides != null &&
                                        cubit.todaysSlides!.isNotEmpty)
                                    ? cubit.todaysSlides!
                                          .map((e) => e.text)
                                          .toList()
                                    : ayat,
                                height: ayatH,
                                maxFontSize: 30.sp,
                                minFontSize: 12.sp,
                                interval: Duration(
                                  seconds:
                                      CacheHelper.getSlidesDisplaySeconds(),
                                ),
                                randomOrder: CacheHelper.getSlidesRandomOrder(),
                                fontFamily: CacheHelper.getAzkarFontFamily(),
                                textColor: AppTheme.primaryTextColor,
                              ),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final remainingToIqama = cubit
                                      .remainingToIqama();
                                  final showIqamaFocus =
                                      cubit.isBetweenAdhanAndIqama &&
                                      remainingToIqama != null &&
                                      remainingToIqama.inSeconds > 0;

                                  if (showIqamaFocus) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.06,
                                      ),
                                      child: IqamaFocusSection(
                                        countdownText: _localizedDurationText(
                                          remainingToIqama,
                                        ),
                                        progress: cubit.iqamaProgress(),
                                        prayers: _iqamaPrayerItems(context),
                                        isLandscape: true,
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: [
                                      const Spacer(),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: hPadding,
                                        ),
                                        child: Row(
                                          children: List.generate(rows.length, (
                                            index,
                                          ) {
                                            return Padding(
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                    end:
                                                        index != rows.length - 1
                                                        ? itemSpacing
                                                        : 0,
                                                  ),
                                              child: PrayerLandScapeItem(
                                                row: rows[index],
                                                width: itemWidth,
                                                height: prayerRowH,
                                                onBackgroundChanged: () {
                                                  if (!mounted) return;
                                                  setState(() {});
                                                },
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            AzkarSlider(
                              adhkar: cubit.todaysAdkar != null
                                  ? cubit.todaysAdkar!
                                        .map((e) => e.text)
                                        .toList()
                                  : [],
                              height: azkarH,

                              maxFontSize: scale * 26,
                              minFontSize: scale * 19,
                              fontFamily: CacheHelper.getAzkarFontFamily(),
                            ),
                            SizedBox(height: 4.h),
                          ],
                        );
                      },
                    ),
                  ),

                  FutureBuilder<bool>(
                    future: _hideFuture,
                    builder: (context, snapshot) {
                      final currentPrayerId = cubit.currentPrayer?.id;
                      final hideAfterCurrentPrayerEnabled = currentPrayerId == 6
                          ? CacheHelper.getHideScreenAfterIshaaEnabled()
                          : currentPrayerId == 2
                          ? CacheHelper.getHideScreenAfterSunriseEnabled()
                          : false;
                      final shouldHide =
                          hideAfterCurrentPrayerEnabled &&
                          (snapshot.data == true);

                      final azanActive =
                          (cubit.currentPrayer != null &&
                          cubit.currentPrayer!.id != 2 &&
                          cubit.showPrayerAzanPage);
                      final remainingToIqama = cubit.remainingToIqama();
                      final showLastMinuteCountdown =
                          CacheHelper.getShowIqamaCountdownLastMinuteOnly() &&
                          cubit.isBetweenAdhanAndIqama &&
                          remainingToIqama != null &&
                          remainingToIqama > Duration.zero &&
                          remainingToIqama <= const Duration(seconds: 60);
                      final hideFooterOnBlack =
                          shouldHide ||
                          showLastMinuteCountdown ||
                          cubit.isAzanBlackScreenVisible;
                      _syncHomeBlackScreenFlag(hideFooterOnBlack);
                      final remainingSeconds = showLastMinuteCountdown
                          ? ((remainingToIqama.inMilliseconds + 999) ~/ 1000)
                                .clamp(1, 60)
                          : 0;
                      final secondsText = showLastMinuteCountdown
                          ? (LocalizationHelper.isArAndArNumberEnable()
                                ? DateHelper.toArabicDigits(
                                    remainingSeconds.toString(),
                                  )
                                : remainingSeconds.toString())
                          : '';

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
                          else if (showLastMinuteCountdown) {
                            overlay = IqamaLastMinuteCountdownOverlay(
                              secondsText: secondsText,
                            );
                          }
                          // 3) ثالث أولوية: black screen
                          else if (shouldHide) {
                            overlay = BlackScreenInfoOverlay(
                              key: const ValueKey('black_screen'),
                            );
                          }
                          // 4) رابع أولوية: Azkar
                          else if (w != null) {
                            overlay = GestureDetector(
                              key: ValueKey(
                                'azkar-${w.type.name}-${w.prayerId ?? 0}',
                              ),
                              behavior: HitTestBehavior.opaque,
                              onTap: _azkarOverlay.dismissForNow,
                              child: AzkarView(
                                azkarType: w.type,
                                prayerId: w.prayerId,
                              ),
                            );
                          }

                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 1500),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, anim) {
                              final scale = Tween<double>(
                                begin: 0.985,
                                end: 1.0,
                              ).animate(anim);
                              return FadeTransition(
                                opacity: anim,
                                child: ScaleTransition(
                                  scale: scale,
                                  child: child,
                                ),
                              );
                            },
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
    required this.onBackgroundChanged,
  });

  final PrayerRowData row;
  final double width;
  final double height;
  final VoidCallback onBackgroundChanged;

  Future<void> _handleBackgroundChange(String tappedValue) async {
    if (row.prayerName == LocaleKeys.fajr.tr() &&
        tappedValue == row.prayerName) {
      final currentIndex = CacheHelper.getBackgroundThemeIndex();
      final nextIndex = currentIndex == 0
          ? CacheHelper.getAllBackgrounds().length - 1
          : currentIndex - 1;
      await CacheHelper.setBackgroundChangeMode(BackgroundChangeMode.manual);
      await CacheHelper.setBackgroundThemeIndex(nextIndex);
      onBackgroundChanged();
    } else if (row.prayerName == LocaleKeys.fajr.tr() &&
        tappedValue == row.adhanTime) {
      final currentIndex = CacheHelper.getBackgroundThemeIndex();
      final nextIndex =
          currentIndex == CacheHelper.getAllBackgrounds().length - 1
          ? 0
          : currentIndex + 1;
      await CacheHelper.setBackgroundChangeMode(BackgroundChangeMode.manual);
      await CacheHelper.setBackgroundThemeIndex(nextIndex);
      onBackgroundChanged();
    }
  }

  Widget _buildTappableCell({
    required String text,
    required TextStyle style,
    bool enableTap = false,
  }) {
    final child = Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, style: style),
      ),
    );

    if (!enableTap) return child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async => _handleBackgroundChange(text),
      child: child,
    );
  }

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
                  child: _buildTappableCell(
                    text: row.adhanTime,
                    enableTap: row.prayerName == LocaleKeys.fajr.tr(),
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
                Flexible(
                  child: _buildTappableCell(
                    text: row.prayerName,
                    enableTap: row.prayerName == LocaleKeys.fajr.tr(),
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

                Flexible(
                  child: _buildTappableCell(
                    text: row.iqamaTime,
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
              ]
            : [
                Flexible(
                  child: _buildTappableCell(
                    text: row.prayerName,
                    enableTap: row.prayerName == LocaleKeys.fajr.tr(),
                    style: TextStyle(
                      color: _color(row.dimmed, AppTheme.primaryTextColor),
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
                Flexible(
                  child: _buildTappableCell(
                    text: row.adhanTime,
                    enableTap: row.prayerName == LocaleKeys.fajr.tr(),
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
                Flexible(
                  child: _buildTappableCell(
                    text: row.iqamaTime,
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
              ],
      ),
    );
  }
}
