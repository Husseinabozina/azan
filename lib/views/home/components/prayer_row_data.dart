import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';
import 'package:azan/views/home/components/glass_pill.dart';
import 'package:flutter/material.dart';

class PrayerRowData {
  final String prayerName;
  final String adhanTime;
  final String iqamaTime;
  final bool dimmed;

  PrayerRowData({
    required this.prayerName,
    required this.adhanTime,
    required this.iqamaTime,
    required this.dimmed,
  });
}

class PrayerGlassRow extends StatelessWidget {
  const PrayerGlassRow({
    super.key,
    required this.data,
    required this.enableGlass,
    required this.textStylePrayer,
    required this.textStyleAdhan,
    required this.textStyleIqama,
    required this.rowHeight,
    this.outerMargin, // ✅ جديد
  });

  final PrayerRowData data;
  final bool enableGlass;
  final TextStyle textStylePrayer;
  final TextStyle textStyleAdhan;
  final TextStyle textStyleIqama;
  final double rowHeight;

  final EdgeInsets? outerMargin;

  @override
  Widget build(BuildContext context) {
    final opacity = data.dimmed ? 0.45 : 1.0;

    final vPad = rowHeight * 0.18; // بدون clamp زي ما طلبت

    Widget cellText(String s, TextStyle st) {
      return Opacity(
        opacity: opacity,
        child: FittedBox(
          // ✅ يحمي من قص النص لو rowHeight صغير
          fit: BoxFit.scaleDown,
          child: Text(s, style: st, maxLines: 1),
        ),
      );
    }

    return SizedBox(
      // width: 200,
      child: GlassPill(
        enabled: enableGlass,
        scaleHeight: false,
        height: rowHeight,
        margin: outerMargin ?? EdgeInsets.zero, // ✅ هنا
        padding: EdgeInsetsDirectional.fromSTEB(16.w, vPad, 16.w, vPad),
        child: Prayer3Cols(
          prayer: cellText(data.prayerName, textStylePrayer),
          adhan: cellText(data.adhanTime, textStyleAdhan),
          iqama: cellText(data.iqamaTime, textStyleIqama),
        ),
      ),
    );
  }
}

class Prayer3Cols extends StatelessWidget {
  const Prayer3Cols({
    super.key,
    required this.prayer,
    required this.adhan,
    required this.iqama,
  });

  final Widget prayer; // ✅ start
  final Widget adhan; // ✅ center
  final Widget iqama; // ✅ end

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(alignment: AlignmentDirectional.center, child: prayer),
        ),
        Expanded(child: Center(child: adhan)),
        Expanded(
          child: Align(alignment: AlignmentDirectional.center, child: iqama),
        ),
      ],
    );
  }
}
