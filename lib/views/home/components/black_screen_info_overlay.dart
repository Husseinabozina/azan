import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/helpers/prayer_calendar_helper.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/views/home/components/live_clock_row.dart';
import 'package:flutter/material.dart';
import 'package:jhijri/_src/_jHijri.dart';

const Color kNearBlackScreenColor = Color(0xFF05070A);
const Color kHomeTimedOverlayTint = Color(0xB3142233);

class BlackScreenInfoOverlay extends StatefulWidget {
  const BlackScreenInfoOverlay({
    super.key,
    this.backgroundColor = kHomeTimedOverlayTint,
  });

  final Color backgroundColor;

  @override
  State<BlackScreenInfoOverlay> createState() => _BlackScreenInfoOverlayState();
}

class _BlackScreenInfoOverlayState extends State<BlackScreenInfoOverlay> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _localizedHijriDate() {
    final adjusted = _now.add(Duration(days: CacheHelper.getHijriOffsetDays()));
    final hijri = JHijri(fDate: adjusted);
    final monthName = CacheHelper.getLang() == 'en'
        ? PrayerCalendarHelper.englishHijriMonths[hijri.month - 1]
        : hijri.monthName;
    final raw = '${hijri.day} $monthName ${hijri.year}';

    return LocalizationHelper.isArAndArNumberEnable()
        ? DateHelper.toArabicDigits(raw)
        : DateHelper.toWesternDigits(raw);
  }

  @override
  Widget build(BuildContext context) {
    final showTime = CacheHelper.getShowTimeOnBlackScreen();
    final showDate = CacheHelper.getShowDateOnBlackScreen();

    return TimedHomeBackground(
      overlayColor: widget.backgroundColor,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final isPortrait = size.height >= size.width;
            final shortest = size.shortestSide;

            final horizontalPadding = isPortrait ? 24.w : 36.w;
            final verticalGap = isPortrait ? 18.h : 14.h;
            final timeFontSize =
                (isPortrait ? shortest * 0.22 : shortest * 0.18).clamp(
                  78.0,
                  240.0,
                );
            final periodFontSize = (timeFontSize * 0.24).clamp(20.0, 60.0);
            final dateFontSize =
                (isPortrait ? shortest * 0.060 : shortest * 0.042).clamp(
                  22.0,
                  68.0,
                );

            return SizedBox.expand(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showTime)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: LiveClockRow(
                            timeFontSize: timeFontSize,
                            periodFontSize: periodFontSize,
                            use24Format: CacheHelper.getUse24HoursFormat(),
                            textColor: AppTheme.homeSecondaryTextColor,
                            withIndicator: !CacheHelper.getUse24HoursFormat(),
                          ),
                        ),
                      if (showTime && showDate) SizedBox(height: verticalGap),
                      if (showDate)
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: size.width * (isPortrait ? 0.88 : 0.72),
                          ),
                          child: AutoSizeText(
                            _localizedHijriDate(),
                            maxLines: 2,
                            minFontSize: 16,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.homePrimaryTextColor,
                              fontFamily: CacheHelper.getTextsFontFamily(),
                              fontSize: dateFontSize,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.42),
                                  blurRadius: 10.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TimedHomeBackground extends StatelessWidget {
  const TimedHomeBackground({
    super.key,
    required this.child,
    this.overlayColor = kHomeTimedOverlayTint,
  });

  final Widget child;
  final Color overlayColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.images.home.path),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: overlayColor),
          if (AppTheme.backgroundReadabilityOverlayAlpha > 0)
            IgnorePointer(
              child: ColoredBox(
                color: Colors.black.withValues(
                  alpha: AppTheme.homeBackgroundReadabilityOverlayAlpha * 0.55,
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
