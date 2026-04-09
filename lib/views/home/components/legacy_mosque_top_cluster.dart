import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/views/home/components/mosque_shape_registry.dart';
import 'package:flutter/material.dart';

@immutable
class LegacyMosqueTopClusterSpec {
  const LegacyMosqueTopClusterSpec({
    required this.topInsetRatio,
    required this.clusterWidthFactor,
    required this.weekdayWidthFactor,
    required this.hijriWidthFactor,
    required this.metaWidthFactor,
    required this.weekdayHeight,
    required this.hijriHeight,
    required this.metaHeight,
    required this.gapAfterWeekday,
    required this.gapAfterHijri,
    required this.clusterHorizontalPadding,
    required this.metaColumnGap,
    required this.hijriSidePadding,
    required this.weekdayVerticalPadding,
    required this.hijriVerticalPadding,
    required this.metaVerticalPadding,
    required this.countdownBottomGap,
  });

  final double topInsetRatio;
  final double clusterWidthFactor;
  final double weekdayWidthFactor;
  final double hijriWidthFactor;
  final double metaWidthFactor;
  final double weekdayHeight;
  final double hijriHeight;
  final double metaHeight;
  final double gapAfterWeekday;
  final double gapAfterHijri;
  final double clusterHorizontalPadding;
  final double metaColumnGap;
  final double hijriSidePadding;
  final double weekdayVerticalPadding;
  final double hijriVerticalPadding;
  final double metaVerticalPadding;
  final double countdownBottomGap;

  double get totalHeight =>
      weekdayHeight +
      gapAfterWeekday +
      hijriHeight +
      gapAfterHijri +
      metaHeight;
}

LegacyMosqueTopClusterSpec legacyTopClusterSpecForProfile(
  MosqueArchProfile profile,
) {
  switch (profile) {
    case MosqueArchProfile.denseArch:
      return LegacyMosqueTopClusterSpec(
        topInsetRatio: 0.033,
        clusterWidthFactor: 0.80,
        weekdayWidthFactor: 0.75,
        hijriWidthFactor: 0.96,
        metaWidthFactor: 0.92,
        weekdayHeight: 54.h,
        hijriHeight: 60.h,
        metaHeight: 86.h,
        gapAfterWeekday: 4.h,
        gapAfterHijri: 7.h,
        clusterHorizontalPadding: 4.w,
        metaColumnGap: 12.w,
        hijriSidePadding: 74.w,
        weekdayVerticalPadding: 5.h,
        hijriVerticalPadding: 5.h,
        metaVerticalPadding: 4.h,
        countdownBottomGap: 4.h,
      );
    case MosqueArchProfile.wideArch:
      return LegacyMosqueTopClusterSpec(
        topInsetRatio: 0.029,
        clusterWidthFactor: 0.88,
        weekdayWidthFactor: 0.79,
        hijriWidthFactor: 0.96,
        metaWidthFactor: 0.94,
        weekdayHeight: 54.h,
        hijriHeight: 60.h,
        metaHeight: 86.h,
        gapAfterWeekday: 4.h,
        gapAfterHijri: 7.h,
        clusterHorizontalPadding: 6.w,
        metaColumnGap: 14.w,
        hijriSidePadding: 72.w,
        weekdayVerticalPadding: 5.h,
        hijriVerticalPadding: 5.h,
        metaVerticalPadding: 4.h,
        countdownBottomGap: 4.h,
      );
  }
}

@visibleForTesting
TextStyle legacyMosqueWeekdayTextStyle() {
  return TextStyle(
    fontSize: 30.sp,
    fontWeight: FontWeight.bold,
    color: AppTheme.primaryTextColor,
    fontFamily: CacheHelper.getTextsFontFamily(),
    height: 1.18,
  );
}

@visibleForTesting
TextStyle legacyMosqueHijriTextStyle() {
  return TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: AppTheme.secondaryTextColor,
    fontFamily: CacheHelper.getTextsFontFamily(),
    height: 1.16,
  );
}

@visibleForTesting
TextStyle legacyMosqueGregorianTextStyle() {
  return TextStyle(
    fontSize: 28.sp,
    color: AppTheme.primaryTextColor,
    fontFamily: CacheHelper.getTextsFontFamily(),
    height: 1.14,
  );
}

@visibleForTesting
TextStyle legacyMosqueCountdownTextStyle({required bool isUrgent}) {
  return TextStyle(
    fontFamily: CacheHelper.getTimesFontFamily(),
    fontSize: 34.sp,
    fontWeight: FontWeight.bold,
    color: isUrgent ? Colors.red : AppTheme.secondaryTextColor,
    height: 1.16,
  );
}

@visibleForTesting
TextStyle legacyMosqueLeftForTextStyle() {
  return TextStyle(
    fontSize: 19.sp,
    color: AppTheme.primaryTextColor,
    fontFamily: CacheHelper.getTextsFontFamily(),
    height: 1.16,
  );
}

@visibleForTesting
double legacyMosqueMeasureSingleLineHeight({
  required String text,
  required TextStyle style,
  required TextDirection textDirection,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text.isEmpty ? ' ' : text, style: style),
    textDirection: textDirection,
    maxLines: 1,
  )..layout();
  return painter.height;
}

class LegacyMosqueTopCluster extends StatelessWidget {
  const LegacyMosqueTopCluster({
    super.key,
    required this.spec,
    required this.weekdayText,
    required this.hijriText,
    required this.gregorianText,
    required this.countdownText,
    required this.leftForText,
    required this.isCounterUrgent,
    this.weatherWidget,
    this.onHijriTap,
  });

  final LegacyMosqueTopClusterSpec spec;
  final String weekdayText;
  final String hijriText;
  final String gregorianText;
  final String countdownText;
  final String leftForText;
  final bool isCounterUrgent;
  final Widget? weatherWidget;
  final VoidCallback? onHijriTap;

  @override
  Widget build(BuildContext context) {
    final weekdayBand = SizedBox(
      height: spec.weekdayHeight,
      child: Center(
        child: FractionallySizedBox(
          widthFactor: spec.weekdayWidthFactor,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spec.clusterHorizontalPadding,
              vertical: spec.weekdayVerticalPadding,
            ),
            child: Center(
              child: AutoSizeText(
                weekdayText,
                maxLines: 1,
                minFontSize: 16,
                stepGranularity: 0.5,
                textAlign: TextAlign.center,
                style: legacyMosqueWeekdayTextStyle(),
              ),
            ),
          ),
        ),
      ),
    );

    final hijriBand = SizedBox(
      height: spec.hijriHeight,
      child: Center(
        child: FractionallySizedBox(
          widthFactor: spec.hijriWidthFactor,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spec.clusterHorizontalPadding,
              vertical: spec.hijriVerticalPadding,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spec.hijriSidePadding),
              child: Center(
                child: AutoSizeText(
                  hijriText,
                  maxLines: 1,
                  minFontSize: 16,
                  stepGranularity: 0.5,
                  textAlign: TextAlign.center,
                  style: legacyMosqueHijriTextStyle(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final metaAvailableHeight =
        spec.metaHeight - (spec.metaVerticalPadding * 2);
    final countdownHeight = math.max(
      0.0,
      (metaAvailableHeight - spec.countdownBottomGap) * 0.62,
    );
    final leftForHeight = math.max(
      0.0,
      metaAvailableHeight - countdownHeight - spec.countdownBottomGap,
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        weekdayBand,
        SizedBox(height: spec.gapAfterWeekday),
        onHijriTap == null
            ? hijriBand
            : GestureDetector(onTap: onHijriTap, child: hijriBand),
        SizedBox(height: spec.gapAfterHijri),
        SizedBox(
          height: spec.metaHeight,
          child: Center(
            child: FractionallySizedBox(
              widthFactor: spec.metaWidthFactor,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spec.clusterHorizontalPadding,
                  vertical: spec.metaVerticalPadding,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _LegacyMosqueDateColumn(
                        text: gregorianText,
                        style: legacyMosqueGregorianTextStyle(),
                        topWidget: weatherWidget,
                      ),
                    ),
                    SizedBox(width: spec.metaColumnGap),
                    Expanded(
                      child: _LegacyMosqueCountdownColumn(
                        countdownText: countdownText,
                        leftForText: leftForText,
                        countdownHeight: countdownHeight,
                        leftForHeight: leftForHeight,
                        countdownBottomGap: spec.countdownBottomGap,
                        countdownStyle: legacyMosqueCountdownTextStyle(
                          isUrgent: isCounterUrgent,
                        ),
                        leftForStyle: legacyMosqueLeftForTextStyle(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return SizedBox(height: spec.totalHeight, child: content);
  }
}

class LegacyMosqueTopClusterDebugOverlay extends StatelessWidget {
  const LegacyMosqueTopClusterDebugOverlay({super.key, required this.spec});

  final LegacyMosqueTopClusterSpec spec;

  @override
  Widget build(BuildContext context) {
    final weekdayTop = 0.0;
    final weekdayBottom = spec.weekdayHeight;
    final hijriTop = weekdayBottom + spec.gapAfterWeekday;
    final hijriBottom = hijriTop + spec.hijriHeight;
    final metaTop = hijriBottom + spec.gapAfterHijri;
    final metaBottom = metaTop + spec.metaHeight;

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              ..._frameMarkers(
                frameWidth: constraints.maxWidth,
                top: 0.0,
                bottom: spec.totalHeight,
                widthFactor: 1.0,
                color: Colors.redAccent,
              ),
              ..._frameMarkers(
                frameWidth: constraints.maxWidth,
                top: weekdayTop,
                bottom: weekdayBottom,
                widthFactor: spec.weekdayWidthFactor,
                color: Colors.yellowAccent,
              ),
              ..._frameMarkers(
                frameWidth: constraints.maxWidth,
                top: hijriTop,
                bottom: hijriBottom,
                widthFactor: spec.hijriWidthFactor,
                color: Colors.cyanAccent,
              ),
              ..._frameMarkers(
                frameWidth: constraints.maxWidth,
                top: metaTop,
                bottom: metaBottom,
                widthFactor: spec.metaWidthFactor,
                color: Colors.limeAccent,
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _frameMarkers({
    required double frameWidth,
    required double top,
    required double bottom,
    required double widthFactor,
    required Color color,
  }) {
    const dotSize = 8.0;
    final topY = top;
    final bottomY = bottom - dotSize;
    final inset = ((frameWidth * (1 - widthFactor)) / 2).clamp(0.0, frameWidth);
    return [
      Positioned(
        top: topY,
        left: inset,
        child: _DebugDot(color: color, size: dotSize),
      ),
      Positioned(
        top: topY,
        right: inset,
        child: _DebugDot(color: color, size: dotSize),
      ),
      Positioned(
        top: topY,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.topCenter,
          child: _DebugDot(color: color, size: dotSize),
        ),
      ),
      Positioned(
        top: bottomY,
        left: inset,
        child: _DebugDot(color: color, size: dotSize),
      ),
      Positioned(
        top: bottomY,
        right: inset,
        child: _DebugDot(color: color, size: dotSize),
      ),
      Positioned(
        top: bottomY,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.topCenter,
          child: _DebugDot(color: color, size: dotSize),
        ),
      ),
    ];
  }
}

class _DebugDot extends StatelessWidget {
  const _DebugDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withValues(alpha: 0.45)),
      ),
    );
  }
}

class _LegacyMosqueDateColumn extends StatelessWidget {
  const _LegacyMosqueDateColumn({
    required this.text,
    required this.style,
    this.topWidget,
  });

  final String text;
  final TextStyle style;
  final Widget? topWidget;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (topWidget != null) topWidget!,
          if (topWidget != null) SizedBox(height: 4.h),
          AutoSizeText(
            text,
            maxLines: 1,
            minFontSize: 12,
            stepGranularity: 0.5,
            textAlign: TextAlign.center,
            style: style,
          ),
        ],
      ),
    );
  }
}

class _LegacyMosqueCountdownColumn extends StatelessWidget {
  const _LegacyMosqueCountdownColumn({
    required this.countdownText,
    required this.leftForText,
    required this.countdownHeight,
    required this.leftForHeight,
    required this.countdownBottomGap,
    required this.countdownStyle,
    required this.leftForStyle,
  });

  final String countdownText;
  final String leftForText;
  final double countdownHeight;
  final double leftForHeight;
  final double countdownBottomGap;
  final TextStyle countdownStyle;
  final TextStyle leftForStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: countdownHeight,
          child: Center(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: AutoSizeText(
                countdownText,
                maxLines: 1,
                minFontSize: 14,
                stepGranularity: 0.5,
                textAlign: TextAlign.center,
                style: countdownStyle,
              ),
            ),
          ),
        ),
        SizedBox(height: countdownBottomGap),
        SizedBox(
          height: leftForHeight,
          child: Center(
            child: AutoSizeText(
              leftForText,
              maxLines: 1,
              minFontSize: 10,
              stepGranularity: 0.5,
              textAlign: TextAlign.center,
              style: leftForStyle,
            ),
          ),
        ),
      ],
    );
  }
}
