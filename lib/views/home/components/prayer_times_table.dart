import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/prayer_row_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PrayerTimesTable extends StatelessWidget {
  const PrayerTimesTable({
    super.key,
    required this.rows,
    required this.enableGlass,
    required this.headerStyle,
    required this.prayerStyle,
    required this.adhanStyle,
    required this.iqamaStyle,
    this.targetRowHeight,
    this.minRowHeight,
    this.allowScrollIfOverflow = true,
    this.showHeader = true,
    this.centerPrayerColumn = false,
    this.onBackgroundChanged,
  });

  final List<PrayerRowData> rows;
  final bool enableGlass;

  final TextStyle headerStyle;
  final TextStyle prayerStyle;
  final TextStyle adhanStyle;
  final TextStyle iqamaStyle;
  final double? targetRowHeight;
  final double? minRowHeight;
  final bool allowScrollIfOverflow;
  final bool showHeader;
  final bool centerPrayerColumn;
  final VoidCallback? onBackgroundChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final n = rows.length;

        final headerH = showHeader ? 26.h : 0.0;
        final spaceAfterHeader = showHeader ? 3.h : 0.0;

        // ✅ خلي gap واحد فقط (من هنا)
        final gap = 3.h;

        final layout = resolvePrayerTimesTableLayout(
          rowCount: n,
          maxHeight: constraints.maxHeight,
          headerHeight: headerH,
          spaceAfterHeader: spaceAfterHeader,
          gapHeight: gap,
          targetRowHeight: targetRowHeight,
          minRowHeight: minRowHeight,
          allowScrollIfOverflow: allowScrollIfOverflow,
        );

        final prayerStyleDyn = prayerStyle;
        final adhanStyleDyn = adhanStyle;
        final iqamaStyleDyn = iqamaStyle;

        return Column(
          children: [
            if (showHeader)
              SizedBox(
                height: headerH,
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(),
                  child: Prayer3Cols(
                    centerPrayerColumn: centerPrayerColumn,
                    endAlignment: AlignmentDirectional.center,
                    startAlignment: AlignmentDirectional.center,
                    centerAlignment: AlignmentDirectional.center,

                    prayer: _PrayerHeaderCell(
                      text: LocaleKeys.prayer.tr(),
                      style: headerStyle,
                    ),
                    adhan: _PrayerHeaderCell(
                      text: LocaleKeys.adhan_time.tr(),
                      style: headerStyle,
                    ),
                    iqama: _PrayerHeaderCell(
                      text: LocaleKeys.iqama_time.tr(),
                      style: headerStyle,
                    ),
                  ),
                ),
              ),
            if (showHeader) SizedBox(height: spaceAfterHeader),

            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                primary: false,
                physics: layout.shouldScroll
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: n,
                separatorBuilder: (_, __) => SizedBox(height: gap),
                itemBuilder: (context, index) {
                  final r = rows[index];
                  return PrayerGlassRow(
                    data: r,
                    enableGlass: enableGlass,
                    textStylePrayer: prayerStyleDyn,
                    textStyleAdhan: adhanStyleDyn,
                    textStyleIqama: iqamaStyleDyn,
                    rowHeight: layout.rowHeight,
                    centerPrayerColumn: centerPrayerColumn,
                    onBackgroundChanged: onBackgroundChanged,
                    outerMargin: EdgeInsetsDirectional.only(
                      start: 12.w,
                      end: 12.w,
                    ), // ✅ مهم: مفيش margin إضافية
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PrayerHeaderCell extends StatelessWidget {
  const _PrayerHeaderCell({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: style.copyWith(height: style.height ?? 1.22),
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: true,
              applyHeightToLastDescent: true,
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class PrayerTimesTableLayout {
  const PrayerTimesTableLayout({
    required this.rowHeight,
    required this.shouldScroll,
    required this.overflow,
  });

  final double rowHeight;
  final bool shouldScroll;
  final bool overflow;
}

@visibleForTesting
PrayerTimesTableLayout resolvePrayerTimesTableLayout({
  required int rowCount,
  required double maxHeight,
  required double headerHeight,
  required double spaceAfterHeader,
  required double gapHeight,
  required double? targetRowHeight,
  required double? minRowHeight,
  required bool allowScrollIfOverflow,
}) {
  final n = rowCount;
  final available = maxHeight - headerHeight - spaceAfterHeader;
  final safeAvailable = (available.isFinite && available > 0) ? available : 0.0;
  if (n <= 0) {
    return const PrayerTimesTableLayout(
      rowHeight: 0,
      shouldScroll: false,
      overflow: false,
    );
  }

  final totalGap = gapHeight * (n - 1);
  final fitRowH = ((safeAvailable - totalGap) / n).isFinite
      ? ((safeAvailable - totalGap) / n).clamp(0.0, double.infinity).toDouble()
      : 0.0;

  double rowH = fitRowH;
  bool overflow = false;

  final hasPolicy = targetRowHeight != null || minRowHeight != null;
  if (hasPolicy) {
    final minH = (minRowHeight ?? 0).clamp(0.0, double.infinity).toDouble();
    final targetH = (targetRowHeight ?? fitRowH)
        .clamp(minH, double.infinity)
        .toDouble();

    if (fitRowH >= targetH) {
      rowH = targetH;
    } else if (fitRowH >= minH) {
      rowH = fitRowH;
    } else {
      overflow = true;
      rowH = allowScrollIfOverflow ? minH : fitRowH;
    }
  } else {
    final contentH = (rowH * n) + totalGap;
    overflow = contentH > safeAvailable + 0.5;
  }

  final shouldScroll = overflow && allowScrollIfOverflow;
  return PrayerTimesTableLayout(
    rowHeight: rowH,
    shouldScroll: shouldScroll,
    overflow: overflow,
  );
}
