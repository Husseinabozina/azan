import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/iqama_progress_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@immutable
class IqamaPrayerSummaryData {
  const IqamaPrayerSummaryData({
    required this.prayerName,
    required this.adhanTime,
  });

  final String prayerName;
  final String adhanTime;
}

class IqamaFocusSection extends StatelessWidget {
  const IqamaFocusSection({
    super.key,
    required this.countdownText,
    required this.progress,
    required this.prayers,
    this.isLandscape = false,
  });

  final String countdownText;
  final double progress;
  final List<IqamaPrayerSummaryData> prayers;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    final topRow = prayers.take(3).toList();
    final bottomRow = prayers.skip(3).take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        final countdownFontSize = (maxHeight * (isLandscape ? 0.26 : 0.22))
            .clamp(54.0, isLandscape ? 144.0 : 118.0)
            .toDouble();
        final labelFontSize = (maxHeight * 0.052)
            .clamp(13.0, isLandscape ? 28.0 : 22.0)
            .toDouble();
        final tilePrayerFont = (maxHeight * (isLandscape ? 0.076 : 0.068))
            .clamp(14.0, isLandscape ? 28.0 : 22.0)
            .toDouble();
        final tileTimeFont = (maxHeight * (isLandscape ? 0.102 : 0.092))
            .clamp(19.0, isLandscape ? 39.0 : 33.0)
            .toDouble();
        final trackerWidth = maxWidth * (isLandscape ? 0.50 : 0.72);
        final trackerHeight = (maxHeight * (isLandscape ? 0.050 : 0.044))
            .clamp(14.0, 30.0)
            .toDouble();
        final rowsGap = math.max(2.0, maxHeight * 0.012);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Directionality(
              textDirection: ui.TextDirection.ltr,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  countdownText,
                  style: TextStyle(
                    fontFamily: CacheHelper.getTimesFontFamily(),
                    fontSize: countdownFontSize,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.secondaryTextColor,
                    height: 1.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: math.max(4.0, maxHeight * 0.016)),
            AutoSizeText(
              LocaleKeys.remaining_for_iqamaa.tr(),
              maxLines: 1,
              minFontSize: 10,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontFamily: CacheHelper.getTextsFontFamily(),
                fontSize: labelFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: math.max(6.0, maxHeight * 0.020)),
            IqamaProgressBar(
              progress: progress.clamp(0.0, 1.0),
              label: '',
              width: trackerWidth,
              height: trackerHeight,
            ),
            SizedBox(height: math.max(8.0, maxHeight * 0.026)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _IqamaPrayerSummaryRow(
                    items: topRow,
                    prayerFontSize: tilePrayerFont,
                    timeFontSize: tileTimeFont,
                  ),
                  SizedBox(height: rowsGap),
                  _IqamaPrayerSummaryRow(
                    items: bottomRow,
                    prayerFontSize: tilePrayerFont,
                    timeFontSize: tileTimeFont,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _IqamaPrayerSummaryRow extends StatelessWidget {
  const _IqamaPrayerSummaryRow({
    required this.items,
    required this.prayerFontSize,
    required this.timeFontSize,
  });

  final List<IqamaPrayerSummaryData> items;
  final double prayerFontSize;
  final double timeFontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: _IqamaPrayerSummaryTile(
                data: item,
                prayerFontSize: prayerFontSize,
                timeFontSize: timeFontSize,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _IqamaPrayerSummaryTile extends StatelessWidget {
  const _IqamaPrayerSummaryTile({
    required this.data,
    required this.prayerFontSize,
    required this.timeFontSize,
  });

  final IqamaPrayerSummaryData data;
  final double prayerFontSize;
  final double timeFontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: CacheHelper.getEnableGlassEffect() ? 0.06 : 0.0,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
            width: 1.w,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(
                data.prayerName,
                maxLines: 1,
                minFontSize: 10,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontFamily: CacheHelper.getTextsFontFamily(),
                  fontWeight: FontWeight.w700,
                  fontSize: prayerFontSize,
                ),
              ),
              SizedBox(height: 4.h),
              Directionality(
                textDirection: ui.TextDirection.ltr,
                child: AutoSizeText(
                  data.adhanTime,
                  maxLines: 1,
                  minFontSize: 11,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontFamily: CacheHelper.getTimesFontFamily(),
                    fontWeight: FontWeight.w800,
                    fontSize: timeFontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
