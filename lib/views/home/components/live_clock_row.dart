import 'dart:async';

import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LiveClockRow extends StatefulWidget {
  final double timeFontSize;
  final double periodFontSize;

  const LiveClockRow({
    super.key,
    required this.timeFontSize,
    required this.periodFontSize,
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

    // نحدّث الوقت كل ثانية
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

  // صيغة 12 ساعة + أرقام عربية
  String _formattedTime() {
    int hour = _now.hour;
    final minute = _now.minute;

    // نخليها 12-ساعة
    final isAm = hour < 12;
    hour = hour % 12;
    if (hour == 0) hour = 12;

    final hStr = hour.toString().padLeft(2, '0');
    final mStr = minute.toString().padLeft(2, '0');

    final time = '$hStr:$mStr';
    return LocalizationHelper.isArabic(context)
        ? DateHelper.toArabicDigits(time)
        : DateHelper.toWesternDigits(time);
    ;
  }

  // صباحًا / مساءً

  String _periodLabel(BuildContext context) {
    final isAm = _now.hour < 12;

    // لو عندك مفتاحين في اللغات:
    return isAm ? LocaleKeys.am_label.tr() : LocaleKeys.pm_label.tr();

    // لو عندك مفتاح واحد فقط (am_label) وبيطلع صح مهما كان الوقت:
    // return LocaleKeys.am_label.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formattedTime(),
          style: TextStyle(
            fontSize: widget.timeFontSize,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryTextColor,
          ),
        ),
        HorizontalSpace(width: 10),
        Text(
          _periodLabel(context),
          style: TextStyle(
            fontSize: widget.periodFontSize,
            color: AppTheme.primaryTextColor,
          ),
        ),
      ],
    );
  }
}
