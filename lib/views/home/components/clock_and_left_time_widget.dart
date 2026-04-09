import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/models/prayer.dart';
import 'package:azan/core/models/prayer_display_data.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/core/utils/temp_icon_result.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/live_clock_row.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jhijri/_src/_jHijri.dart';

class ClockAndLeftTimeWidget extends StatelessWidget {
  const ClockAndLeftTimeWidget({
    super.key,
    required this.width,
    required this.letfTimeText,
    required this.nextPrayerFuture,
    this.isIqamaActive = false,
    this.onHijriTap,
  });

  final double width;
  final String letfTimeText;
  final Future<Prayer?> nextPrayerFuture;
  final bool isIqamaActive;
  final VoidCallback? onHijriTap;

  PrayerDisplayData _buildDisplayData(Prayer? p) {
    final dt = p?.dateTime;

    final durationStr = (dt == null)
        ? "--:--"
        : (LocalizationHelper.isArAndArNumberEnable()
              ? DateHelper.toArabicDigits(
                  dt
                      .difference(DateTime.now())
                      .formatDuration(
                        showSeconds: CacheHelper.getShowSecondsInNextPrayer(),
                      ),
                )
              : dt
                    .difference(DateTime.now())
                    .formatDuration(
                      showSeconds: CacheHelper.getShowSecondsInNextPrayer(),
                    ));

    final prayerTitle = p?.title ?? '';
    final safeTitle = (LocalizationHelper.isArabic() && prayerTitle.isNotEmpty)
        ? prayerTitle.substring(1)
        : prayerTitle;
    final leftForText = LocalizationHelper.isArabic()
        ? '${LocaleKeys.left_for.tr()}$safeTitle'
        : '${LocaleKeys.left_for.tr()} $safeTitle';

    final isRed =
        CacheHelper.getIsChangeCounterEnabled() &&
        dt != null &&
        dt.difference(DateTime.now()).inSeconds <= 90;

    return PrayerDisplayData(
      durationStr: durationStr,
      leftForText: leftForText,
      isRed: isRed,
    );
  }

  String _withLocaleDigits(String value) {
    return LocalizationHelper.isArAndArNumberEnable()
        ? DateHelper.toArabicDigits(value)
        : DateHelper.toWesternDigits(value);
  }

  _DateSideData _gregorianData() {
    final now = DateTime.now();
    final lang = CacheHelper.getLang().trim().isEmpty
        ? 'en'
        : CacheHelper.getLang();
    return _DateSideData(
      day: _withLocaleDigits(now.day.toString().padLeft(2, '0')),
      lineOne: DateFormat('MMMM', lang).format(now),
      lineTwo: _withLocaleDigits(now.year.toString()),
    );
  }

  _DateSideData _hijriData() {
    final offsetDays = CacheHelper.getHijriOffsetDays();
    final adjusted = DateTime.now().add(Duration(days: offsetDays));
    final h = JHijri(fDate: adjusted);
    return _DateSideData(
      day: _withLocaleDigits(h.day.toString().padLeft(2, '0')),
      lineOne: h.monthName,
      lineTwo: _withLocaleDigits(h.year.toString()),
    );
  }

  Widget _badgeCell({
    required String dayText,
    required double badgeWidth,
    required double badgeHeight,
    required double dayFontSize,
    VoidCallback? onTap,
  }) {
    final child = Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: badgeWidth,
          height: badgeHeight,
          child: _ShieldDayBadge(dayText: dayText, dayFontSize: dayFontSize),
        ),
      ),
    );

    if (onTap == null) return child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }

  Widget _dateCell({
    required _DateSideData data,
    required double monthSize,
    required double yearSize,
    required TextAlign textAlign,
    VoidCallback? onTap,
    Widget? topWidget,
  }) {
    final child = Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (topWidget != null) topWidget,
            if (topWidget != null)
              SizedBox(height: math.max(1, monthSize * 0.22)),
            AutoSizeText(
              data.lineOne,
              maxLines: 1,
              minFontSize: 7,
              textAlign: textAlign,
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontFamily: CacheHelper.getTextsFontFamily(),
                fontSize: monthSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: math.max(1, monthSize * 0.20)),
            AutoSizeText(
              data.lineTwo,
              maxLines: 1,
              minFontSize: 7,
              textAlign: textAlign,
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontFamily: CacheHelper.getTextsFontFamily(),
                fontSize: yearSize,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }

  Widget _weekdayCell({
    required String weekdayAr,
    required String weekdayEn,
    required double arSize,
    required double enSize,
  }) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              weekdayAr,
              maxLines: 1,
              minFontSize: 7,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontFamily: CacheHelper.getTextsFontFamily(),
                fontWeight: FontWeight.w700,
                fontSize: arSize,
              ),
            ),
            SizedBox(height: math.max(1, enSize * 0.30)),
            AutoSizeText(
              weekdayEn,
              maxLines: 1,
              minFontSize: 7,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontFamily: CacheHelper.getTextsFontFamily(),
                fontWeight: FontWeight.w700,
                fontSize: enSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth > 0 ? constraints.maxWidth : width;
        final maxH = math.max(1.0, constraints.maxHeight);

        final subtitleText = letfTimeText.trim();
        final showSubtitle = subtitleText.isNotEmpty && maxH >= 110;
        final mainHeight = showSubtitle ? maxH * 0.83 : maxH;

        final double badgeHeight = (mainHeight * 0.42)
            .clamp(20.0, 170.0)
            .toDouble();
        final double badgeWidth = badgeHeight * 0.73;
        final double badgeDaySize = (badgeHeight * 0.43)
            .clamp(9.0, 66.0)
            .toDouble();

        final double monthSize = (mainHeight * 0.16)
            .clamp(8.0, 38.0)
            .toDouble();
        final double yearSize = (mainHeight * 0.19).clamp(9.0, 44.0).toDouble();
        final double weekdayArSize = (mainHeight * 0.18)
            .clamp(8.0, 52.0)
            .toDouble();
        final double weekdayEnSize = (mainHeight * 0.15)
            .clamp(8.0, 42.0)
            .toDouble();

        final double timeSize =
            (isIqamaActive ? mainHeight * 0.44 : mainHeight * 0.52)
                .clamp(18.0, 140.0)
                .toDouble();
        final double periodSize = (mainHeight * 0.10)
            .clamp(9.0, 30.0)
            .toDouble();

        final greg = _gregorianData();
        final hijri = _hijriData();
        final now = DateTime.now();
        final weekdayAr = now.weekdayNameAr;
        final weekdayEn = DateFormat('EEEE', 'en').format(now);
        final compactLayout = maxW < 760;
        final double clusterWidthFactor = compactLayout ? 0.92 : 0.86;
        final double clusterWidth = (maxW * clusterWidthFactor)
            .clamp(320.0, maxW)
            .toDouble();
        final int sideFlex = compactLayout ? 19 : 18;
        final int centerFlex = compactLayout ? 62 : 64;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 56,
                    child: Center(
                      child: SizedBox(
                        width: clusterWidth,
                        child: Row(
                          children: [
                            Expanded(
                              flex: sideFlex,
                              child: _badgeCell(
                                dayText: greg.day,
                                badgeWidth: badgeWidth,
                                badgeHeight: badgeHeight,
                                dayFontSize: badgeDaySize,
                              ),
                            ),
                            Expanded(
                              flex: centerFlex,
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: GestureDetector(
                                    onTap: () {
                                      CacheHelper.setIsFullTimeEnabled(
                                        !CacheHelper.getIsFullTimeEnabled(),
                                      );
                                    },
                                    child: LiveClockRow(
                                      timeFontSize: timeSize,
                                      periodFontSize: periodSize * 1.35,
                                      use24Format:
                                          CacheHelper.getUse24HoursFormat(),
                                      withIndicator:
                                          !CacheHelper.getUse24HoursFormat(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: sideFlex,
                              child: _badgeCell(
                                dayText: hijri.day,
                                badgeWidth: badgeWidth,
                                badgeHeight: badgeHeight,
                                dayFontSize: badgeDaySize,
                                onTap: onHijriTap,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: math.max(1, mainHeight * 0.03)),
                  Expanded(
                    flex: 44,
                    child: Center(
                      child: SizedBox(
                        width: clusterWidth,
                        child: Row(
                          children: [
                            Expanded(
                              flex: sideFlex,
                              child: _dateCell(
                                data: greg,
                                monthSize: monthSize,
                                yearSize: yearSize,
                                textAlign: TextAlign.center,
                                topWidget: CacheHelper.getWeatherEnabled()
                                    ? TemperatureBadge(
                                        iconSize: monthSize * 0.90,
                                        textSize: yearSize * 0.92,
                                        gapWidth: 4.w,
                                      )
                                    : null,
                              ),
                            ),
                            Expanded(
                              flex: centerFlex,
                              child: _weekdayCell(
                                weekdayAr: weekdayAr,
                                weekdayEn: weekdayEn,
                                arSize: weekdayArSize,
                                enSize: weekdayEnSize,
                              ),
                            ),
                            Expanded(
                              flex: sideFlex,
                              child: _dateCell(
                                data: hijri,
                                monthSize: monthSize,
                                yearSize: yearSize,
                                textAlign: TextAlign.center,
                                onTap: onHijriTap,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showSubtitle) SizedBox(height: math.max(1, maxH * 0.02)),
            if (showSubtitle)
              FutureBuilder<Prayer?>(
                future: nextPrayerFuture,
                builder: (context, snapshot) {
                  final data = _buildDisplayData(snapshot.data);
                  return SizedBox(
                    width: maxW * 0.75,
                    child: AutoSizeText(
                      subtitleText,
                      maxLines: 1,
                      minFontSize: 9,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: CacheHelper.getTimesFontFamily(),
                        fontWeight: FontWeight.w700,
                        fontSize: (isIqamaActive ? 17 : 20).sp,
                        color: data.isRed
                            ? Colors.red
                            : AppTheme.primaryTextColor,
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _DateSideData {
  const _DateSideData({
    required this.day,
    required this.lineOne,
    required this.lineTwo,
  });

  final String day;
  final String lineOne;
  final String lineTwo;
}

class _ShieldDayBadge extends StatelessWidget {
  const _ShieldDayBadge({required this.dayText, required this.dayFontSize});

  final String dayText;
  final double dayFontSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShieldBadgePainter(
        strokeColor: AppTheme.secondaryTextColor.withValues(alpha: 0.75),
        fillColor: Colors.white.withValues(alpha: 0.07),
      ),
      child: Center(
        child: Text(
          dayText,
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontFamily: CacheHelper.getTimesFontFamily(),
            fontSize: dayFontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class _ShieldBadgePainter extends CustomPainter {
  const _ShieldBadgePainter({
    required this.strokeColor,
    required this.fillColor,
  });

  final Color strokeColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.50, size.height * 0.02)
      ..quadraticBezierTo(
        size.width * 0.80,
        size.height * 0.05,
        size.width * 0.90,
        size.height * 0.22,
      )
      ..quadraticBezierTo(
        size.width * 0.97,
        size.height * 0.37,
        size.width * 0.95,
        size.height * 0.56,
      )
      ..lineTo(size.width * 0.95, size.height * 0.74)
      ..quadraticBezierTo(
        size.width * 0.84,
        size.height * 0.91,
        size.width * 0.50,
        size.height * 0.99,
      )
      ..quadraticBezierTo(
        size.width * 0.16,
        size.height * 0.91,
        size.width * 0.05,
        size.height * 0.74,
      )
      ..lineTo(size.width * 0.05, size.height * 0.56)
      ..quadraticBezierTo(
        size.width * 0.03,
        size.height * 0.37,
        size.width * 0.10,
        size.height * 0.22,
      )
      ..quadraticBezierTo(
        size.width * 0.20,
        size.height * 0.05,
        size.width * 0.50,
        size.height * 0.02,
      )
      ..close();

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;
    canvas.drawPath(path, fill);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = strokeColor
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _ShieldBadgePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.fillColor != fillColor;
  }
}
