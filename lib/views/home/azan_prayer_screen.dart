import 'dart:async';
import 'dart:math' as math;

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/models/prayer.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:azan/views/home/components/iqama_visual_cutdown.dart';
import 'package:azan/views/home/components/live_clock_row.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  Duration _timeBeforeAzanTerminate = const Duration(minutes: 4);
  Duration _timeBeforeDoaaTerminate = const Duration(minutes: 2);

  Timer? _azanTimer;
  Timer? _doaaTimer;
  Timer? _iqamaWorkTimer;
  Timer? _prayerWorkTimer;

  @override
  void initState() {
    super.initState();
    appCubit = AppCubit.get(context);
    appCubit.getPrayerDurations();

    _timeBeforeIqama = Duration(
      minutes: (appCubit.iqamaMinutes![widget.currentPrayer.id - 1] > 1)
          ? appCubit.iqamaMinutes![widget.currentPrayer.id - 1] -
                _timeBeforeDoaaTerminate.inMinutes
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
        minutes: appCubit.prayersDuration != null
            ? appCubit.prayersDuration![widget.currentPrayer.id - 1]
            : 10,
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

  double _clamp(double v, double mn, double mx) =>
      v < mn ? mn : (v > mx ? mx : v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(context: context),
      body: GestureDetector(
        onTap: () => appCubit.togglePrayerAzanPage(),
        child: BlocConsumer<AppCubit, AppState>(
          listener: (context, state) {},
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final maxH = constraints.maxHeight;
                final maxW = constraints.maxWidth;

                // ✅ لو الشاشة قصيرة (Land 360 مثلا) هندخل compact mode
                final isCompact = maxH <= 420;

                // ✅ مسافات بدل الثوابت اللي بتكسر في اللاندسكيب
                final gapS = _clamp(maxH * 0.03, 8, 18);
                final gapM = _clamp(maxH * 0.05, 12, 28);

                // ✅ أحجام الخطوط تتصغر تلقائي في compact
                final clockSize = isCompact ? 20.sp : 30.sp;
                final titleSize = isCompact ? 24.sp : 35.sp;
                final duaaSize = isCompact ? 20.sp : 30.sp;
                final hintSize = isCompact ? 14.sp : 20.sp;

                // ✅ حجم الدايرة (ده سبب الـoverflow غالبًا)
                // خليها على قد ارتفاع الشاشة
                final ringSize = _clamp(
                  maxH * (isCompact ? 0.40 : 0.45),
                  140,
                  math.min(260.0, maxW * 0.55),
                );
                final ringStroke = _clamp(ringSize * 0.07, 8, 16);

                // ✅ bottom area بتاعة close phone
                final closeImg = _clamp(
                  maxH * (isCompact ? 0.20 : 0.24),
                  70,
                  140,
                );
                final closeBottom = _clamp(
                  maxH * (isCompact ? 0.06 : 0.10),
                  12,
                  80,
                );

                final backgroundColor = _azanTerminat
                    ? Colors.black.withOpacity(0.8)
                    : Colors.transparent;

                final textColor =
                    (_isIqamaTime &&
                        CacheHelper.getEnableHidingScreenDuringPrayer())
                    ? Colors.white
                    : AppTheme.primaryTextColor;

                return SizedBox(
                  width: 1.sw,
                  child: Stack(
                    children: [
                      // Background
                      Positioned.fill(
                        child: Image.asset(
                          CacheHelper.getSelectedBackground(),
                          fit: BoxFit.fill,
                        ),
                      ),

                      // ✅ Black screen during prayer (unchanged logic)
                      if (CacheHelper.getEnableHidingScreenDuringPrayer() &&
                          _isPrayerTime)
                        AnimatedSwitcher(
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          duration: const Duration(milliseconds: 1500),
                          child: Container(
                            color: backgroundColor,
                            width: 1.sw,
                            height: 1.sh,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (CacheHelper.getShowTimeOnBlackScreen())
                                  LiveClockRow(
                                    timeFontSize: isCompact ? 22.sp : 35.sp,
                                    periodFontSize: isCompact ? 22.sp : 35.sp,
                                    textColor: Colors.white,
                                    withIndicator: false,
                                  ),
                                VerticalSpace(height: gapM),
                                if (CacheHelper.getShowDateOnBlackScreen() &&
                                    appCubit.hijriDate != null)
                                  Text(
                                    appCubit.hijriDate.toString(),
                                    style: TextStyle(
                                      fontSize: isCompact ? 22.sp : 35.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                      // ✅ BEFORE adhan terminate
                      if (!_azanTerminat)
                        SizedBox(
                          width: 1.sw,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeInOut,
                            style: TextStyle(color: textColor),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LiveClockRow(
                                  timeFontSize: clockSize,
                                  periodFontSize: clockSize,
                                  withIndicator: false,
                                ),
                                VerticalSpace(height: gapM),
                                Text(
                                  LocaleKeys.adhan_.tr(),
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                VerticalSpace(height: gapS),
                                Text(
                                  widget.currentPrayer.title,
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                      // ✅ Duaa after adhan
                      if (_azanTerminat && !_doaaTerminat)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: _clamp(maxW * 0.05, 12, 40),
                            ),
                            child: Text(
                              duaaAfterAzan,
                              style: TextStyle(
                                fontSize: duaaSize,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryTextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                      // ✅ Countdown to Iqama
                      if (_doaaTerminat && !_isIqamaTime && !_isPrayerTime)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 1500),
                          opacity: _doaaTerminat ? 1 : 0,
                          child: SizedBox(
                            width: 1.sw,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LiveClockRow(
                                  timeFontSize: isCompact ? 18.sp : 26.sp,
                                  periodFontSize: isCompact ? 18.sp : 26.sp,
                                  withIndicator: false,
                                ),
                                VerticalSpace(height: gapS),
                                if (_timeBeforeIqama != null)
                                  Column(
                                    children: [
                                      Text(
                                        LocaleKeys.remaining_for_iqamaa.tr(),
                                        style: TextStyle(
                                          fontSize: isCompact ? 14.sp : 20.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryTextColor,
                                        ),
                                      ),
                                      VerticalSpace(height: gapM),

                                      // ✅ RESPONSIVE ring size (no overflow)
                                      IqamaVisualCountdown(
                                        backgroundStrokeColor:
                                            AppTheme.accentColor,
                                        progressColor:
                                            AppTheme.primaryTextColor,
                                        dangerColor: Colors.red,
                                        warningColor: Colors.yellow,
                                        totalDuration: _timeBeforeIqama!,
                                        size: ringSize,
                                        strokeWidth: ringStroke,
                                        onFinished: () {
                                          if (!mounted) return;
                                          setState(() {
                                            _isIqamaTime = true;
                                          });
                                          iqamaaWork();
                                        },
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),

                      // ✅ Drawer button when adhan terminated
                      if (_azanTerminat)
                        Positioned(
                          top:
                              MediaQuery.of(context).padding.top +
                              _clamp(maxH * 0.02, 6, 14),
                          left: _clamp(maxW * 0.02, 10, 20),
                          child: IconButton(
                            onPressed: () =>
                                scaffoldKey.currentState?.openDrawer(),
                            icon: Icon(
                              Icons.menu,
                              color: AppTheme.accentColor,
                              size: isCompact ? 24.r : 30.r,
                            ),
                          ),
                        ),

                      // ✅ Iqama message (safe)
                      Positioned.fill(
                        child: IgnorePointer(
                          ignoring: !_isIqamaTime,
                          child: AnimatedOpacity(
                            opacity: _isIqamaTime ? 1 : 0,
                            duration: const Duration(milliseconds: 1500),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: _clamp(maxW * 0.06, 12, 50),
                                ),
                                child: Text(
                                  LocaleKeys.iqama_time_has_begun_now.tr(),
                                  style: TextStyle(
                                    fontSize: isCompact ? 18.sp : 30.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryTextColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ✅ Close phone hint (resize + safe bottom)
                      if (!_azanTerminat || _isIqamaTime)
                        Positioned(
                          bottom: closeBottom,
                          left: _clamp(maxW * 0.04, 12, 20),
                          right: _clamp(maxW * 0.04, 12, 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                Assets.images.closePhone.path,
                                height: closeImg,
                                width: closeImg,
                              ),
                              SizedBox(height: _clamp(maxH * 0.01, 4, 10)),
                              Text(
                                LocaleKeys.please_turn_off_the_phone.tr(),
                                style: TextStyle(
                                  fontSize: hintSize,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
