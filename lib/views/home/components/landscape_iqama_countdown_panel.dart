import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/iqama_progress_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LandscapeIqamaCountdownPanel extends StatelessWidget {
  const LandscapeIqamaCountdownPanel({
    super.key,
    required this.countdownText,
    required this.progress,
  });

  final String countdownText;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = math.max(1.0, constraints.maxWidth);
        final maxH = math.max(1.0, constraints.maxHeight);
        final panelWidth = maxW * 0.94;
        final gap = (maxH * 0.035).clamp(2.0, 8.0).toDouble();
        final progressHeight = (maxH * 0.070).clamp(8.0, 16.0).toDouble();
        final labelHeight = (maxH * 0.20).clamp(18.0, 36.0).toDouble();
        final countdownHeight = math.max(
          24.0,
          maxH - labelHeight - progressHeight - (gap * 2),
        );
        final countdownFontSize = (maxH * 0.66).clamp(26.0, 64.0).toDouble();
        final labelFontSize = (maxH * 0.18).clamp(10.0, 20.0).toDouble();

        return Center(
          child: SizedBox(
            width: panelWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: countdownHeight,
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: Text(
                      countdownText,
                      textDirection: ui.TextDirection.ltr,
                      maxLines: 1,
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontFamily: CacheHelper.getTimesFontFamily(),
                        fontSize: countdownFontSize,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: gap),
                SizedBox(
                  height: labelHeight,
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      LocaleKeys.remaining_for_iqamaa.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontFamily: CacheHelper.getTextsFontFamily(),
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: gap),
                SizedBox(
                  width: panelWidth * 0.86,
                  height: progressHeight,
                  child: IqamaProgressBar(
                    progress: progress.clamp(0.0, 1.0),
                    label: '',
                    width: panelWidth * 0.86,
                    height: progressHeight,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
