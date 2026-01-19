import 'dart:async';

import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LiveClockRow extends StatefulWidget {
  final double timeFontSize;
  final double periodFontSize;
  final bool use24Format;
  final Color? textColor;
  final bool withIndicator;

  const LiveClockRow({
    super.key,
    required this.timeFontSize,
    required this.periodFontSize,
    this.use24Format = false,
    this.textColor,
    this.withIndicator = true,
  });

  @override
  State<LiveClockRow> createState() => _LiveClockRowState();
}

class _LiveClockRowState extends State<LiveClockRow> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formattedTime() {
    int hour = _now.hour;
    final minute = _now.minute;
    final second = _now.second;

    // ✅ هل نعرض الثواني؟ (00:00:00)
    final showSeconds = CacheHelper.getIsFullTimeEnabled();

    String hStr;
    String mStr = minute.toString().padLeft(2, '0');
    String sStr = second.toString().padLeft(2, '0');

    if (widget.use24Format) {
      // 24 ساعة
      hStr = hour.toString().padLeft(2, '0');
    } else {
      // 12 ساعة
      hour = hour % 12;
      if (hour == 0) hour = 12;
      hStr = hour.toString().padLeft(2, '0');
    }

    // ⏱ لو full time → hh:mm:ss / لو مش مفعّل → hh:mm
    final rawTime = showSeconds ? '$hStr:$mStr:$sStr' : '$hStr:$mStr';

    return LocalizationHelper.isArAndArNumberEnable(context)
        ? DateHelper.toArabicDigits(rawTime)
        : DateHelper.toWesternDigits(rawTime);
  }

  String? _periodLabel(BuildContext context) {
    // في 24 ساعة ما نعرضش AM/PM
    if (widget.use24Format) return null;

    final isAm = _now.hour < 12;
    return isAm ? LocaleKeys.am_label.tr() : LocaleKeys.pm_label.tr();
  }

  @override
  Widget build(BuildContext context) {
    final period = _periodLabel(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formattedTime(),
          style: TextStyle(
            fontFamily: CacheHelper.getTimeFontFamily(),
            fontSize: widget.timeFontSize,
            fontWeight: FontWeight.bold,
            color: widget.textColor ?? AppTheme.secondaryTextColor,
          ),
        ),
        if (widget.withIndicator) HorizontalSpace(width: 10),
        if (widget.withIndicator)
          Text(
            period ?? '',
            style: TextStyle(
              fontFamily: CacheHelper.getTimeFontFamily(),
              fontWeight: FontWeight.bold,

              fontSize: widget.periodFontSize,
              color: widget.textColor ?? AppTheme.primaryTextColor,
            ),
          ),
      ],
    );
  }
}
