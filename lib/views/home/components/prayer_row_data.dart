import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
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
  final bool isSpecial; // للعيد/حدث خاص

  PrayerRowData({
    required this.prayerName,
    required this.adhanTime,
    required this.iqamaTime,
    required this.dimmed,
    required this.nextFajrPrayer,
    this.isSpecial = false,
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
    this.centerPrayerColumn = false,
    this.onBackgroundChanged,
    this.outerMargin, // ✅ جديد
  });

  final PrayerRowData data;
  final bool enableGlass;
  final TextStyle textStylePrayer;
  final TextStyle textStyleAdhan;
  final TextStyle textStyleIqama;
  final double rowHeight;
  final bool centerPrayerColumn;
  final VoidCallback? onBackgroundChanged;

  final EdgeInsetsDirectional? outerMargin;

  Future<void> _handleBackgroundChange(String s) async {
    if (data.prayerName == LocaleKeys.fajr.tr() && s == LocaleKeys.fajr.tr()) {
      final currentIndex = CacheHelper.getBackgroundThemeIndex();
      final nextIndex = currentIndex == 0
          ? BackgroundThemes.all.length - 1
          : currentIndex - 1;
      await CacheHelper.setBackgroundChangeMode(BackgroundChangeMode.manual);
      await CacheHelper.setBackgroundThemeIndex(nextIndex);
      onBackgroundChanged?.call();
    } else if (data.prayerName == LocaleKeys.fajr.tr() && s == data.adhanTime) {
      final currentIndex = CacheHelper.getBackgroundThemeIndex();
      final nextIndex = currentIndex == BackgroundThemes.all.length - 1
          ? 0
          : currentIndex + 1;
      await CacheHelper.setBackgroundChangeMode(BackgroundChangeMode.manual);
      await CacheHelper.setBackgroundThemeIndex(nextIndex);
      onBackgroundChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final opacity = CacheHelper.getIsPreviousPrayersDimmed()
        ? data.dimmed
              ? 0.45
              : 1.0
        : 1.0;

    Widget cellText(String s, TextStyle st, {String? nextTime}) {
      return GestureDetector(
        onTap: () async => _handleBackgroundChange(s),
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
          centerPrayerColumn: centerPrayerColumn,
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
    this.centerPrayerColumn = false,
    this.startAlignment = AlignmentDirectional.centerStart,
    this.centerAlignment = AlignmentDirectional.center,
    this.endAlignment = AlignmentDirectional.centerEnd,
  });

  final Widget prayer; // ✅ start
  final Widget adhan; // ✅ center
  final Widget iqama; // ✅ end
  final bool centerPrayerColumn;
  final AlignmentDirectional startAlignment;
  final AlignmentDirectional centerAlignment;
  final AlignmentDirectional endAlignment;

  @override
  Widget build(BuildContext context) {
    final children = centerPrayerColumn
        ? <Widget>[
            Expanded(child: Align(alignment: startAlignment, child: adhan)),
            Expanded(child: Align(alignment: centerAlignment, child: prayer)),
            Expanded(child: Align(alignment: endAlignment, child: iqama)),
          ]
        : <Widget>[
            Expanded(child: Align(alignment: startAlignment, child: prayer)),
            Expanded(child: Align(alignment: centerAlignment, child: adhan)),
            Expanded(child: Align(alignment: endAlignment, child: iqama)),
          ];

    return Row(
      children: children,
    );
  }
}
