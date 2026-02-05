import 'package:azan/core/utils/screenutil_flip_ext.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/prayer_row_data.dart';
import 'package:azan/views/home/components/prayer_times_header_row.dart';
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
  });

  final List<PrayerRowData> rows;
  final bool enableGlass;

  final TextStyle headerStyle;
  final TextStyle prayerStyle;
  final TextStyle adhanStyle;
  final TextStyle iqamaStyle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final n = rows.length;

        final headerH = 22.h;
        final spaceAfterHeader = 10.h;

        // ✅ خلي gap واحد فقط (من هنا)
        final gap = 10.h;

        final available = constraints.maxHeight - headerH - spaceAfterHeader;
        final safeAvailable = (available.isFinite && available > 0)
            ? available
            : 0.0;

        final rawRowH = (n == 0) ? 0.0 : (safeAvailable - gap * (n - 1)) / n;
        final rowH = (rawRowH.isFinite && rawRowH > 0) ? rawRowH : 0.0;

        final contentH = (rowH * n) + gap * (n - 1);
        final shouldScroll = contentH > safeAvailable + 0.5;

        // ✅ تكبير ذكي بدون clamp: scale نسبي من rowH
        // (لو مش عايز تكبير خالص شيل الـ 3 سطور دول وخلاص)
        final designRowH = 66.h;
        final scale = (designRowH == 0) ? 1.0 : (rowH / designRowH);

        final prayerStyleDyn = prayerStyle;
        final adhanStyleDyn = adhanStyle;
        final iqamaStyleDyn = iqamaStyle;

        return Column(
          children: [
            SizedBox(
              height: headerH,
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(),
                child: Prayer3Cols(
                  prayer: Text(LocaleKeys.prayer.tr(), style: headerStyle),
                  adhan: Text(LocaleKeys.adhan_time.tr(), style: headerStyle),
                  iqama: Text(LocaleKeys.iqama_time.tr(), style: headerStyle),
                ),
              ),
            ),
            SizedBox(height: spaceAfterHeader),

            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                primary: false,
                physics: shouldScroll
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
                    rowHeight: rowH,
                    outerMargin: EdgeInsets.zero, // ✅ مهم: مفيش margin إضافية
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
