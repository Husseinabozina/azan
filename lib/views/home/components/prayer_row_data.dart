import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/change_%20background_settings/change_background_settings_screen.dart';
import 'package:azan/views/home/components/glass_pill.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PrayerRowData {
  final String prayerName;
  final String adhanTime;
  final String iqamaTime;
  final bool dimmed;
  final String nextFajrPrayer;

  PrayerRowData({
    required this.prayerName,
    required this.adhanTime,
    required this.iqamaTime,
    required this.dimmed,
    required this.nextFajrPrayer,
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

  final EdgeInsetsDirectional? outerMargin;

  void _handleBackgroundChange(String s) {
    if (data.prayerName == LocaleKeys.fajr.tr() && s == LocaleKeys.fajr.tr()) {
      'sssss'.log();
      if (CacheHelper.getBackgroundThemeIndex() == 0) {
        CacheHelper.setBackgroundThemeIndex(BackgroundThemes.all.length - 1);
      }

      CacheHelper.setBackgroundThemeIndex(
        CacheHelper.getBackgroundThemeIndex() - 1,
      );
    } else if (data.prayerName == LocaleKeys.fajr.tr() && s == data.adhanTime) {
      if (CacheHelper.getBackgroundThemeIndex() ==
          BackgroundThemes.all.length - 1) {
        CacheHelper.setBackgroundThemeIndex(0);
      } else {
        CacheHelper.setBackgroundThemeIndex(
          CacheHelper.getBackgroundThemeIndex() + 1,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final opacity = CacheHelper.getIsPreviousPrayersDimmed()
        ? data.dimmed
              ? 0.45
              : 1.0
        : 1.0;

    final vPad = rowHeight * 0.18; // بدون clamp زي ما طلبت

    Widget cellText(String s, TextStyle st, {String? nextTime}) {
      return GestureDetector(
        onTap: () {
          _handleBackgroundChange(s);
        },
        child: Opacity(
          opacity: opacity,
          child: FittedBox(
            // ✅ يحمي من قص النص لو rowHeight صغير
            fit: BoxFit.scaleDown,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Text(s, style: st, maxLines: 1),
                if (nextTime != null && data.prayerName == LocaleKeys.fajr.tr())
                  PositionedDirectional(
                    bottom: UiRotationCubit().isLandscape() ? -5.h : -3.h,
                    start: 0,
                    child: Text(
                      nextTime,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppTheme.secondaryTextColor,
                      ),
                      maxLines: 1,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      // width: 200,
      child: GlassPill(
        enabled: enableGlass,

        scaleHeight: false,
        height: rowHeight,
        margin: outerMargin ?? EdgeInsetsDirectional.zero, // ✅ هنا
        padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w),
        child: Prayer3Cols(
          prayer: cellText(
            data.prayerName,
            textStylePrayer,
            nextTime: data.nextFajrPrayer,
          ),
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
    this.startAlignment = AlignmentDirectional.centerStart,
    this.centerAlignment = AlignmentDirectional.center,
    this.endAlignment = AlignmentDirectional.centerEnd,
  });

  final Widget prayer; // ✅ start
  final Widget adhan; // ✅ center
  final Widget iqama; // ✅ end
  final AlignmentDirectional startAlignment;
  final AlignmentDirectional centerAlignment;
  final AlignmentDirectional endAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(alignment: startAlignment, child: prayer),
        ),
        Expanded(
          child: Align(alignment: centerAlignment, child: adhan),
        ),
        Expanded(
          child: Align(alignment: endAlignment, child: iqama),
        ),
      ],
    );
  }
}
