import 'dart:async';
import 'dart:math' show min, max;

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/models/prayer.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/additional_settings/components/azkar_time_helper.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:azan/views/home/components/iqama_visual_cutdown.dart';
import 'package:azan/views/home/components/live_clock_row.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';

class AzanPrayerScreen extends StatefulWidget {
  const AzanPrayerScreen({super.key, required this.currentPrayer});
  final Prayer currentPrayer;

  @override
  State<AzanPrayerScreen> createState() => _AzanPrayerScreenState();
}

class _AzanPrayerScreenState extends State<AzanPrayerScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _azanTerminat = false;
  bool _doaaTerminat = false;
  bool _isIqamaTime = false;
  bool _isPrayerTime = false;

  late AppCubit appCubit;

  Duration? _timeBeforeIqama;
  final Duration _timeBeforeAzanTerminate = Duration(
    minutes: CacheHelper.getAzanDuration(),
  );
  final Duration _timeBeforeDoaaTerminate = const Duration(minutes: 1);

  Timer? _azanTimer;
  Timer? _doaaTimer;
  Timer? _iqamaWorkTimer;
  Timer? _prayerWorkTimer;

  @override
  void initState() {
    super.initState();
    appCubit = AppCubit.get(context);
    // appCubit.getCurrentPrayerDuraion();

    _timeBeforeIqama = Duration(
      minutes: (appCubit.iqamaMinutes![widget.currentPrayer.id - 1] > 1)
          ? appCubit.iqamaMinutes![widget.currentPrayer.id - 1] -
                _timeBeforeDoaaTerminate.inMinutes -
                _timeBeforeAzanTerminate.inMinutes
          : appCubit.iqamaMinutes![widget.currentPrayer.id - 1],
    );

    _azanTimer = Timer(_timeBeforeAzanTerminate, () {
      if (!mounted) return;
      setState(() => _azanTerminat = true);

      _doaaTimer = Timer(_timeBeforeDoaaTerminate, () {
        if (!mounted) return;
        setState(() => _doaaTerminat = true);
      });
    });
  }

  void iqamaaWork() {
    _iqamaWorkTimer?.cancel();
    if (!mounted) return;

    _iqamaWorkTimer = Timer(const Duration(seconds: 7), () {
      if (!mounted) return;

      if (!CacheHelper.getEnableHidingScreenDuringPrayer()) {
        appCubit.togglePrayerAzanPage();
      } else {
        setState(() {
          _isIqamaTime = false;
          _isPrayerTime = true;
          prayerWork();
        });
      }
    });
  }

  void prayerWork() {
    _prayerWorkTimer?.cancel();
    if (!mounted) return;

    _prayerWorkTimer = Timer(
      Duration(
        minutes:
            appCubit.getPrayerDurationForId(widget.currentPrayer.id) != null
            ? appCubit.getPrayerDurationForId(widget.currentPrayer.id)
            : 7,
      ),
      () {
        if (!mounted) return;
        appCubit.togglePrayerAzanPage();
      },
    );
  }

  @override
  void dispose() {
    _azanTimer?.cancel();
    _doaaTimer?.cancel();
    _iqamaWorkTimer?.cancel();
    _prayerWorkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;

    final bool isLandscape = size.width >= size.height;
    final m = _AzanMetrics.auto(isLandscape: isLandscape);

    final backgroundColor = _azanTerminat
        ? Colors.black.withOpacity(0.94)
        : Colors.transparent;

    final textColor =
        (_isIqamaTime && CacheHelper.getEnableHidingScreenDuringPrayer())
        ? Colors.white
        : AppTheme.primaryTextColor;

    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(context: context),
      body: GestureDetector(
        onTap: () => appCubit.togglePrayerAzanPage(),
        child: BlocConsumer<AppCubit, AppState>(
          listener: (context, state) {},
          builder: (context, state) {
            return SizedBox(
              width: 1.sw,
              height: 1.sh,
              child: SafeArea(
                child: Stack(
                  children: [
                    // Background
                    Positioned.fill(
                      child: Image.asset(
                        CacheHelper.getSelectedBackground(),
                        fit: BoxFit.fill,
                      ),
                    ),

                    // ✅ Black screen during prayer
                    if (CacheHelper.getEnableHidingScreenDuringPrayer() &&
                        _isPrayerTime)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 1500),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Container(
                          color: backgroundColor,
                          width: 1.sw,
                          height: 1.sh,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (CacheHelper.getShowTimeOnBlackScreen())
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 20.w,
                                      right: 20.w,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        // AzkarTimeHelper.currentWindow(
                                        //   now:
                                        // )
                                      },
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: LiveClockRow(
                                          timeFontSize: m.blackClockSize,
                                          periodFontSize: m.blackClockSize,
                                          textColor: Colors.white,
                                          withIndicator: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              VerticalSpace(height: m.gapM),
                              if (CacheHelper.getShowDateOnBlackScreen() &&
                                  appCubit.hijriDate != null)
                                FittedBox(
                                  // FittedBox للـ date
                                  fit: BoxFit.scaleDown,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 20.w,
                                      right: 20.w,
                                    ),
                                    child: Text(
                                      appCubit.hijriDate.toString(),
                                      style: TextStyle(
                                        fontSize: m.blackDateSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                    // ✅ BEFORE adhan terminate
                    if (!_azanTerminat)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: m.centerBottomPad - 10.w,
                            left: 10.w,
                            right: 10.w,
                          ),
                          child: SingleChildScrollView(
                            // أضفت ScrollView لمنع overflow في column طويلة
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  // FittedBox للـ clock
                                  fit: BoxFit.scaleDown,
                                  child: LiveClockRow(
                                    timeFontSize: m.clockSize,
                                    periodFontSize: m.clockSize,
                                    withIndicator: false,
                                  ),
                                ),
                                VerticalSpace(height: m.gapM),
                                Text(
                                  LocaleKeys.adhan_.tr(),
                                  style: TextStyle(
                                    fontSize: m.titleSize,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                VerticalSpace(height: m.gapS),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                  ),
                                  child: Text(
                                    widget.currentPrayer.title,
                                    style: TextStyle(
                                      fontSize: m.prayerNameSize,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // ✅ Duaa after adhan
                    if (_azanTerminat && !_doaaTerminat)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: m.duaaPadX,
                            right: m.duaaPadX,
                            bottom: isLandscape ? m.centerBottomPad : 0,
                          ),
                          child: SingleChildScrollView(
                            // ScrollView للـ duaa طويل
                            child: Text(
                              duaaAfterAzan,
                              style: TextStyle(
                                fontSize: m.duaaSize,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryTextColor,
                                height: 1.25,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                    // ✅ Countdown to Iqama
                    if (_doaaTerminat && !_isIqamaTime && !_isPrayerTime)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 1500),
                        opacity: _doaaTerminat ? 1 : 0,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                              // bottom: isLandscape ? 0 : m.centerBottomPad,
                            ),
                            child: SingleChildScrollView(
                              // ScrollView للـ countdown
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FittedBox(
                                    // FittedBox للـ clock
                                    fit: BoxFit.scaleDown,
                                    child: LiveClockRow(
                                      timeFontSize: m.countdownClockSize,
                                      periodFontSize: m.countdownClockSize,
                                      withIndicator: false,
                                    ),
                                  ),
                                  VerticalSpace(height: m.gapS),
                                  if (_timeBeforeIqama != null)
                                    Container(
                                      // color: Colors.red,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 20.w,
                                            ),
                                            child: Text(
                                              LocaleKeys.remaining_for_iqamaa
                                                  .tr(),
                                              style: TextStyle(
                                                fontSize: m.remainingTextSize,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    AppTheme.primaryTextColor,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          VerticalSpace(height: m.gapM),
                                          ConstrainedBox(
                                            // ConstrainedBox للـ ring عشان ميتجاوزش height
                                            constraints: BoxConstraints(
                                              maxHeight:
                                                  0.5.sh, // max 40% من height
                                            ),
                                            child: IqamaVisualCountdown(
                                              backgroundStrokeColor:
                                                  AppTheme.accentColor,
                                              progressColor:
                                                  AppTheme.primaryTextColor,
                                              dangerColor: Colors.red,
                                              warningColor: Colors.yellow,
                                              totalDuration: _timeBeforeIqama!,
                                              size: isLandscape
                                                  ? 0.5.sw
                                                  : m.ringSize,
                                              strokeWidth: m.ringStroke,
                                              onFinished: () {
                                                if (!mounted) return;
                                                setState(
                                                  () => _isIqamaTime = true,
                                                );
                                                iqamaaWork();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ✅ Drawer button when adhan terminated
                    // if (_azanTerminat)
                    Positioned(
                      top: mq.padding.top + m.menuTop,
                      left: m.menuLeft,
                      child: IconButton(
                        onPressed: () => scaffoldKey.currentState?.openDrawer(),
                        icon: Icon(
                          Icons.menu,
                          color: AppTheme.accentColor,
                          size: m.menuIconSize,
                        ),
                      ),
                    ),

                    // ✅ Iqama message
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: !_isIqamaTime,
                        child: AnimatedOpacity(
                          opacity: _isIqamaTime ? 1 : 0,
                          duration: const Duration(milliseconds: 1100),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: m.iqamaPadX,
                                right: m.iqamaPadX,
                                bottom: m.centerBottomPad,
                              ),
                              child: isLandscape
                                  ? FittedBox(
                                      // FittedBox للـ text عشان ميتجاوزش
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        LocaleKeys.iqama_time_has_begun_now
                                            .tr(),
                                        style: TextStyle(
                                          fontSize: m.iqamaTextSize,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryTextColor,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  : Text(
                                      LocaleKeys.iqama_time_has_begun_now.tr(),
                                      style: TextStyle(
                                        fontSize: m.iqamaTextSize,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ✅ Close phone hint
                    if (!_azanTerminat || _isIqamaTime)
                      Positioned(
                        bottom: m.closeBottom,
                        left: m.closeSide,
                        right: m.closeSide,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                CacheHelper.getAzanDuration();
                              },
                              child: Image.asset(
                                Assets.images.closePhone.path,
                                height: m.closeImg,
                                width: m.closeImg,
                                fit: BoxFit.contain,
                              ),
                            ),
                            VerticalSpace(height: m.closeTextGap),
                            FittedBox(
                              // FittedBox للـ hint text
                              fit: BoxFit.scaleDown,
                              child: Text(
                                LocaleKeys.please_turn_off_the_phone.tr(),
                                style: TextStyle(
                                  fontSize: m.hintSize,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ TRULY FINAL - بنسب آمنة تشتغل مع أي available height
// ════════════════════════════════════════════════════════════════════════════

class _AzanMetrics {
  final double gapS;
  final double gapM;

  final double clockSize;
  final double titleSize;
  final double prayerNameSize;
  final double duaaSize;

  final double countdownClockSize;
  final double remainingTextSize;

  final double ringSize;
  final double ringStroke;

  final double menuTop;
  final double menuLeft;
  final double menuIconSize;

  final double iqamaPadX;
  final double iqamaTextSize;

  final double duaaPadX;

  final double closeImg;
  final double closeBottom;
  final double closeSide;
  final double closeTextGap;
  final double hintSize;

  final double blackClockSize;
  final double blackDateSize;

  final double centerBottomPad;

  const _AzanMetrics({
    required this.gapS,
    required this.gapM,
    required this.clockSize,
    required this.titleSize,
    required this.prayerNameSize,
    required this.duaaSize,
    required this.countdownClockSize,
    required this.remainingTextSize,
    required this.ringSize,
    required this.ringStroke,
    required this.menuTop,
    required this.menuLeft,
    required this.menuIconSize,
    required this.iqamaPadX,
    required this.iqamaTextSize,
    required this.duaaPadX,
    required this.closeImg,
    required this.closeBottom,
    required this.closeSide,
    required this.closeTextGap,
    required this.hintSize,
    required this.blackClockSize,
    required this.blackDateSize,
    required this.centerBottomPad,
  });

  factory _AzanMetrics.auto({required bool isLandscape}) {
    return isLandscape ? _AzanMetrics.landscape() : _AzanMetrics.portrait();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ✅ PORTRAIT - أكبر حجم ممكن (Design Size: 360 × 690)
  // ════════════════════════════════════════════════════════════════════════════
  factory _AzanMetrics.portrait() {
    final closePhoneSection = 180.h;
    final safeBottomPad = closePhoneSection + 20.h;

    return _AzanMetrics(
      gapS: 16.h,
      gapM: 28.h,

      clockSize: min(95.sp, 0.12.sh), // أضفت min لـ safety على large screens
      titleSize: 88.sp,
      prayerNameSize: 110.sp,
      duaaSize: 38.sp,
      duaaPadX: 16.w,

      countdownClockSize: 72.sp,
      remainingTextSize: 52.sp,

      ringSize: 240.r,
      ringStroke: 14.r,

      menuTop: 8.h,
      menuLeft: 12.w,
      menuIconSize: 32.r,

      iqamaPadX: 24.w,
      iqamaTextSize: 98.sp,

      closeImg: 120.r,
      closeBottom: 20.h,
      closeSide: 20.w,
      closeTextGap: 10.h,
      hintSize: 38.sp,

      blackClockSize: 130.sp,
      blackDateSize: 68.sp,

      centerBottomPad: safeBottomPad,
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ✅ LANDSCAPE - بنسب آمنة 100% (Design Size: 960 × 540)
  // ════════════════════════════════════════════════════════════════════════════
  factory _AzanMetrics.landscape() {
    // ═══ الاستراتيجية الجديدة: نسب آمنة من الـ screen height ═══

    // Close phone section - بنسب من الشاشة:
    final closeImg = 0.13.sh; // ~70h في 540h
    final closeTextGap = 0.009.sh; // ~5h
    final hintSize = 0.067.sh; // ~36sp
    final closeBottom = 0.015.sh; // ~8h

    // حساب الـ close phone height
    final closePhoneHeight =
        closeImg + closeTextGap + (hintSize * 1.2) + closeBottom;
    final safeBottomPad = closePhoneHeight + 0.02.sh; // ~10h safety

    // Gaps - بنسب آمنة (قللتها شوية لـ more space)
    final gapS = 0.011.sh; // ~6h (قللت من 0.013)
    final gapM = 0.018.sh; // ~10h (قللت من 0.022)

    // Content sizes - بنسب من الشاشة
    final countdownClockSize = 0.09.sh; // ~49sp (قللت لـ space)
    final remainingTextSize = 0.07.sh; // ~38sp (قللت)

    // Ring - نحسبه ديناميكياً بناءً على المساحة المتاحة
    final totalHeight = 1.sh;
    final usedHeight =
        safeBottomPad + countdownClockSize + gapS + remainingTextSize + gapM;
    final availableForRing = totalHeight - usedHeight;

    // نستخدم 50% فقط من المساحة المتاحة للـ ring (زودت safety من 60% إلى 50%)
    final ringSize = min(0.30.sh, availableForRing * 0.50); // قللت max من 0.35

    return _AzanMetrics(
      gapS: gapS,
      gapM: gapM,

      // ✅ أحجام كبيرة لكن آمنة - بنسب من الشاشة (قللت شوية لـ clarity على large screens)
      clockSize: min(0.15.sh, 85.sp), // ~81sp, مع cap
      titleSize: 0.13.sh, // ~70sp
      prayerNameSize: 0.16.sh, // ~86sp

      duaaSize: 0.07.sh, // ~38sp
      duaaPadX: 40.w,

      countdownClockSize: countdownClockSize, // ~49sp
      remainingTextSize: remainingTextSize, // ~38sp

      ringSize: ringSize, // dynamic ~150-170
      ringStroke: 0.02.sh, // ~11r

      menuTop: 0.011.sh,
      menuLeft: 12.w,
      menuIconSize: 0.052.sh,

      iqamaPadX: 50.w,
      iqamaTextSize: 0.14.sh, // ~76sp

      closeImg: closeImg, // ~70
      closeBottom: closeBottom, // ~8
      closeSide: 30.w,
      closeTextGap: closeTextGap, // ~5
      hintSize: hintSize, // ~36

      blackClockSize: min(0.22.sh, 120.sp), // ~119sp, cap لـ clarity
      blackDateSize: 0.11.sh, // ~59sp

      centerBottomPad: safeBottomPad,
    );
  }
}
