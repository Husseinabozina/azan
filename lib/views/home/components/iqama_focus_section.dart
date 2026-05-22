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
        final isTightLandscape = isLandscape && maxHeight < 250.0;
        final countdownSlotHeight = (maxHeight * (isLandscape ? 0.28 : 0.24))
            .clamp(isTightLandscape ? 34.0 : 48.0, isLandscape ? 96.0 : 118.0)
            .toDouble();
        final countdownFontSize = (countdownSlotHeight * 0.96)
            .clamp(isTightLandscape ? 30.0 : 46.0, isLandscape ? 144.0 : 118.0)
            .toDouble();
        final labelSlotHeight = (maxHeight * (isLandscape ? 0.10 : 0.085))
            .clamp(16.0, isLandscape ? 30.0 : 26.0)
            .toDouble();
        final labelFontSize = (labelSlotHeight * 0.72)
            .clamp(10.0, isLandscape ? 22.0 : 19.0)
            .toDouble();
        final tilePrayerFont = (maxHeight * (isLandscape ? 0.070 : 0.064))
            .clamp(11.0, isLandscape ? 26.0 : 22.0)
            .toDouble();
        final tileTimeFont = (maxHeight * (isLandscape ? 0.092 : 0.086))
            .clamp(14.0, isLandscape ? 36.0 : 33.0)
            .toDouble();
        final trackerWidth = (maxWidth * (isLandscape ? 0.16 : 0.28))
            .clamp(58.0, isLandscape ? 150.0 : 130.0)
            .toDouble();
        final trackerHeight = (maxHeight * (isLandscape ? 0.050 : 0.044))
            .clamp(isTightLandscape ? 9.0 : 14.0, 30.0)
            .toDouble();
        final countdownTrackerGap = (maxWidth * 0.014).clamp(6.0, 14.0);
        final gapTiny = (maxHeight * 0.012).clamp(2.0, 5.0).toDouble();
        final gapMedium = (maxHeight * 0.020).clamp(4.0, 8.0).toDouble();
        final rowsGap = (maxHeight * 0.012).clamp(2.0, 6.0).toDouble();

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: countdownSlotHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                textDirection: ui.TextDirection.ltr,
                children: [
                  Flexible(
                    child: Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          countdownText,
                          maxLines: 1,
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
                  ),
                  SizedBox(width: countdownTrackerGap),
                  SizedBox(
                    width: trackerWidth,
                    height: trackerHeight,
                    child: IqamaProgressBar(
                      progress: progress.clamp(0.0, 1.0),
                      label: '',
                      width: trackerWidth,
                      height: trackerHeight,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: gapTiny),
            SizedBox(
              height: labelSlotHeight,
              child: Center(
                child: AutoSizeText(
                  LocaleKeys.remaining_for_iqamaa.tr(),
                  maxLines: 1,
                  minFontSize: 8,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontFamily: CacheHelper.getTextsFontFamily(),
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
              ),
            ),
            SizedBox(height: gapMedium),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _IqamaPrayerSummaryRow(
                      items: topRow,
                      prayerFontSize: tilePrayerFont,
                      timeFontSize: tileTimeFont,
                    ),
                  ),
                  SizedBox(height: rowsGap),
                  Expanded(
                    child: _IqamaPrayerSummaryRow(
                      items: bottomRow,
                      prayerFontSize: tilePrayerFont,
                      timeFontSize: tileTimeFont,
                    ),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final outerVerticalPadding = (maxHeight * 0.035)
            .clamp(0.0, 2.h)
            .toDouble();
        final innerVerticalPadding = (maxHeight * 0.080)
            .clamp(1.0, 7.h)
            .toDouble();
        final textGap = (maxHeight * 0.055).clamp(1.0, 4.h).toDouble();

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 6.w,
            vertical: outerVerticalPadding,
          ),
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
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: innerVerticalPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          data.prayerName,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.primaryTextColor,
                            fontFamily: CacheHelper.getTextsFontFamily(),
                            fontWeight: FontWeight.w700,
                            fontSize: prayerFontSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: textGap),
                  Expanded(
                    child: Center(
                      child: Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            data.adhanTime,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontFamily: CacheHelper.getTimesFontFamily(),
                              fontWeight: FontWeight.w800,
                              fontSize: timeFontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
