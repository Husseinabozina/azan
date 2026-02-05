import 'package:azan/core/utils/screenutil_flip_ext.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PrayerTimesHeaderRow extends StatelessWidget {
  const PrayerTimesHeaderRow({
    super.key,
    required this.style,
    this.horizontalPadding = 18,
  });

  final TextStyle style;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
      child: Row(
        children: [
          Expanded(
            flex: 30,
            child: Align(
              alignment: Alignment.center,
              child: Text(LocaleKeys.iqama_time.tr(), style: style),
            ),
          ),
          Expanded(
            flex: 30,
            child: Center(
              child: Text(LocaleKeys.adhan_time.tr(), style: style),
            ),
          ),
          Expanded(
            flex: 30,
            child: Align(
              alignment: Alignment.center,
              child: Text(LocaleKeys.prayer.tr(), style: style),
            ),
          ),
        ],
      ),
    );
  }
}
