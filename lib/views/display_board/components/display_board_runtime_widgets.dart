import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/helpers/prayer_calendar_helper.dart';
import 'package:azan/core/models/display_announcement.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/display_board/components/display_board_palette.dart';
import 'package:azan/views/home/components/prayer_row_data.dart';
import 'package:azan/views/home/components/glass_pill.dart';
import 'package:azan/views/home/components/live_clock_row.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/models/prayer.dart' as prayer_model;
import 'package:jhijri/_src/_jHijri.dart';

class DisplayBoardSurface extends StatelessWidget {
  const DisplayBoardSurface({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(28.r);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withValues(alpha: 0.72),
            Colors.black.withValues(alpha: 0.56),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(padding: padding ?? EdgeInsets.all(22.r), child: child),
    );
  }
}

class DisplayBoardBackdropOverlay extends StatelessWidget {
  const DisplayBoardBackdropOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.28),
              Colors.black.withValues(alpha: 0.42),
              Colors.black.withValues(alpha: 0.56),
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayBoardAnnouncementStage extends StatelessWidget {
  const DisplayBoardAnnouncementStage({
    super.key,
    required this.announcement,
    required this.isLandscape,
  });

  final DisplayAnnouncement? announcement;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    final titleColor = displayBoardPaletteColor(
      announcement?.titleColorIndex ??
          CacheHelper.getDisplayBoardTitleColorIndex(),
    );
    final bodyColor = displayBoardPaletteColor(
      announcement?.bodyColorIndex ??
          CacheHelper.getDisplayBoardBodyColorIndex(),
    );
    final titleFont = announcement?.titleFontFamily.isNotEmpty == true
        ? announcement!.titleFontFamily
        : CacheHelper.getDisplayBoardTitleFontFamily();
    final bodyFont = announcement?.bodyFontFamily.isNotEmpty == true
        ? announcement!.bodyFontFamily
        : CacheHelper.getDisplayBoardBodyFontFamily();
    final titleBold =
        announcement?.titleBold ?? CacheHelper.getDisplayBoardTitleBold();
    final titleItalic =
        announcement?.titleItalic ?? CacheHelper.getDisplayBoardTitleItalic();
    final bodyBold =
        announcement?.bodyBold ?? CacheHelper.getDisplayBoardBodyBold();
    final bodyItalic =
        announcement?.bodyItalic ?? CacheHelper.getDisplayBoardBodyItalic();
    final titleSize =
        ((announcement?.titleSize ?? CacheHelper.getDisplayBoardTitleSize()) *
                (isLandscape ? 1.22 : 1.0))
            .sp;
    final bodySize =
        ((announcement?.bodySize ?? CacheHelper.getDisplayBoardBodySize()) *
                (isLandscape ? 1.16 : 1.0))
            .sp;

    final title = announcement?.title.trim() ?? '';
    final body = announcement?.body.trim() ?? '';
    final hasAnnouncement = title.isNotEmpty || body.isNotEmpty;

    return DisplayBoardSurface(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 20.w : 18.w,
        vertical: isLandscape ? 18.h : 16.h,
      ),
      borderRadius: BorderRadius.circular(isLandscape ? 34.r : 28.r),
      child: SizedBox.expand(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: hasAnnouncement
              ? Column(
                  key: ValueKey(
                    '${announcement!.id}-${announcement!.sortOrder}',
                  ),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (title.isNotEmpty)
                      AutoSizeText(
                        title,
                        maxLines: isLandscape ? 3 : 3,
                        minFontSize: isLandscape ? 24 : 20,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: titleFont,
                          fontSize: titleSize,
                          fontWeight: titleBold
                              ? FontWeight.w800
                              : FontWeight.w500,
                          fontStyle: titleItalic
                              ? FontStyle.italic
                              : FontStyle.normal,
                          color: titleColor,
                          height: 1.02,
                        ),
                      ),
                    if (title.isNotEmpty && body.isNotEmpty)
                      SizedBox(height: isLandscape ? 14.h : 10.h),
                    if (body.isNotEmpty)
                      AutoSizeText(
                        body,
                        maxLines: isLandscape ? 6 : 6,
                        minFontSize: isLandscape ? 18 : 16,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: bodyFont,
                          fontSize: bodySize,
                          fontWeight: bodyBold
                              ? FontWeight.w700
                              : FontWeight.w400,
                          fontStyle: bodyItalic
                              ? FontStyle.italic
                              : FontStyle.normal,
                          color: bodyColor,
                          height: 1.12,
                        ),
                      ),
                  ],
                )
              : Column(
                  key: const ValueKey('empty-board-announcement'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: isLandscape ? 56.r : 44.r,
                      color: AppTheme.displayBoardAccentColor,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      LocaleKeys.display_board_empty_state.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: CacheHelper.getTextsFontFamily(),
                        fontSize: (isLandscape ? 30 : 24).sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.displayBoardSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class DisplayBoardPrayerRail extends StatelessWidget {
  const DisplayBoardPrayerRail({
    super.key,
    required this.rows,
    required this.nextPrayerFuture,
    required this.isLandscape,
    required this.isIqamaActive,
    required this.onHijriTap,
    this.clockAtSide = false,
  });

  final List<PrayerRowData> rows;
  final Future<prayer_model.Prayer?> nextPrayerFuture;
  final bool isLandscape;
  final bool isIqamaActive;
  final VoidCallback onHijriTap;
  final bool clockAtSide;

  @override
  Widget build(BuildContext context) {
    return DisplayBoardSurface(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 7.w : 6.w,
        vertical: isLandscape ? 5.h : 3.5.h,
      ),
      child: isLandscape
          ? LayoutBuilder(
              builder: (context, constraints) {
                final sideWidth = (constraints.maxWidth * 0.24)
                    .clamp(135.0, 200.0)
                    .toDouble();
                return Row(
                  children: [
                    SizedBox(
                      width: sideWidth,
                      child: _DisplayBoardCompactDateTimeColumn(
                        onHijriTap: onHijriTap,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Row(
                        children: [
                          for (var index = 0; index < rows.length; index++) ...[
                            Expanded(
                              child: _DisplayBoardPrayerCard(
                                row: rows[index],
                                isLandscape: true,
                              ),
                            ),
                            if (index != rows.length - 1) SizedBox(width: 4.w),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            )
          : Column(
              children: [
                _DisplayBoardCompactDateTimeBar(
                  isLandscape: false,
                  onHijriTap: onHijriTap,
                ),
                SizedBox(height: 1.5.h),
                Expanded(
                  child: Row(
                    children: [
                      for (var index = 0; index < rows.length; index++) ...[
                        Expanded(
                          child: _DisplayBoardPrayerCard(
                            row: rows[index],
                            isLandscape: false,
                          ),
                        ),
                        if (index != rows.length - 1) SizedBox(width: 3.w),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _DisplayBoardCompactDateTimeBar extends StatelessWidget {
  const _DisplayBoardCompactDateTimeBar({
    required this.isLandscape,
    required this.onHijriTap,
  });

  final bool isLandscape;
  final VoidCallback onHijriTap;

  String _localizeNumber(String value) {
    return LocalizationHelper.isArAndArNumberEnable()
        ? DateHelper.toArabicDigits(value)
        : DateHelper.toWesternDigits(value);
  }

  String _gregorianLabel() {
    final now = DateTime.now();
    final lang = CacheHelper.getLang().trim().isEmpty
        ? 'en'
        : CacheHelper.getLang();
    final day = _localizeNumber(now.day.toString());
    final year = _localizeNumber(now.year.toString());
    final month = DateFormat('MMM', lang).format(now);
    final weekday = DateFormat('EEE', lang).format(now);
    return '$weekday، $day $month $year';
  }

  String _hijriLabel() {
    final adjusted = DateTime.now().add(
      Duration(days: CacheHelper.getHijriOffsetDays()),
    );
    final hijri = JHijri(fDate: adjusted);
    final monthName = CacheHelper.getLang() == 'en'
        ? PrayerCalendarHelper.englishHijriMonths[hijri.month - 1]
        : hijri.monthName;
    final day = _localizeNumber(hijri.day.toString());
    final year = _localizeNumber(hijri.year.toString());
    return '$day $monthName $year';
  }

  @override
  Widget build(BuildContext context) {
    final dateStyle = TextStyle(
      fontFamily: CacheHelper.getTextsFontFamily(),
      fontSize: (isLandscape ? 12.5 : 10.5).sp,
      fontWeight: FontWeight.w700,
      color: AppTheme.displayBoardPrimaryTextColor.withValues(alpha: 0.92),
      height: 1.0,
    );

    return SizedBox(
      height: isLandscape ? 46.h : 36.h,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onHijriTap,
              child: _DateLabelPill(
                text: _hijriLabel(),
                style: dateStyle,
                textAlign: TextAlign.start,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: LiveClockRow(
                timeFontSize: (isLandscape ? 38 : 31).sp,
                periodFontSize: (isLandscape ? 13 : 11).sp,
                textColor: AppTheme.displayBoardSecondaryTextColor,
                withIndicator: !CacheHelper.getUse24HoursFormat(),
                use24Format: CacheHelper.getUse24HoursFormat(),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _DateLabelPill(
              text: _gregorianLabel(),
              style: dateStyle,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateLabelPill extends StatelessWidget {
  const _DateLabelPill({
    required this.text,
    required this.style,
    required this.textAlign,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: textAlign == TextAlign.end
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Text(text, textAlign: textAlign, style: style, maxLines: 1),
      ),
    );
  }
}

class _DisplayBoardCompactDateTimeColumn extends StatelessWidget {
  const _DisplayBoardCompactDateTimeColumn({required this.onHijriTap});

  final VoidCallback onHijriTap;

  @override
  Widget build(BuildContext context) {
    final helper = _DisplayBoardCompactDateTimeBar(
      isLandscape: true,
      onHijriTap: onHijriTap,
    );
    final dateStyle = TextStyle(
      fontFamily: CacheHelper.getTextsFontFamily(),
      fontSize: 14.5.sp,
      fontWeight: FontWeight.w700,
      color: AppTheme.displayBoardPrimaryTextColor.withValues(alpha: 0.92),
      height: 1.0,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: LiveClockRow(
                timeFontSize: 31.sp,
                periodFontSize: 11.5.sp,
                textColor: AppTheme.displayBoardSecondaryTextColor,
                withIndicator: !CacheHelper.getUse24HoursFormat(),
                use24Format: CacheHelper.getUse24HoursFormat(),
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onHijriTap,
                  child: Center(
                    child: _DateLabelPill(
                      text: helper._hijriLabel(),
                      style: dateStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Expanded(
                child: Center(
                  child: _DateLabelPill(
                    text: helper._gregorianLabel(),
                    style: dateStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DisplayBoardPrayerCard extends StatelessWidget {
  const _DisplayBoardPrayerCard({required this.row, required this.isLandscape});

  final PrayerRowData row;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    final opacity = CacheHelper.getIsPreviousPrayersDimmed() && row.dimmed
        ? 0.46
        : 1.0;
    final prayerColor = row.isSpecial
        ? AppTheme.displayBoardAccentColor
        : AppTheme.displayBoardSecondaryTextColor;

    return Opacity(
      opacity: opacity,
      child: GlassPill(
        enabled: CacheHelper.getEnableGlassEffect(),
        radius: isLandscape ? 18 : 16,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: isLandscape ? 3.w : 3.w,
          vertical: isLandscape ? 1.2.h : 1.h,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = constraints.maxHeight;
            final titleFontSize = (cardHeight * (isLandscape ? 0.285 : 0.220));
            final timeFontSize = (cardHeight * (isLandscape ? 0.255 : 0.190));
            final primaryGap = (cardHeight * (isLandscape ? 0.03 : 0.022));
            final secondaryGap = (cardHeight * (isLandscape ? 0.024 : 0.015));

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: _CompactPrayerText(
                      text: row.prayerName,
                      style: TextStyle(
                        fontFamily: CacheHelper.getTextsFontFamily(),
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w900,
                        color: prayerColor,
                        height: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: primaryGap),
                  Flexible(
                    child: _CompactPrayerText(
                      text: row.adhanTime,
                      style: TextStyle(
                        fontFamily: CacheHelper.getTimesFontFamily(),
                        fontSize: timeFontSize,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.displayBoardAccentColor,
                        height: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: secondaryGap),
                  Flexible(
                    child: _CompactPrayerText(
                      text: row.iqamaTime.isEmpty ? '--' : row.iqamaTime,
                      style: TextStyle(
                        fontFamily: CacheHelper.getTimesFontFamily(),
                        fontSize: timeFontSize,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.displayBoardPrimaryTextColor,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CompactPrayerText extends StatelessWidget {
  const _CompactPrayerText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: style,
        ),
      ),
    );
  }
}
