import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DateHelper {
  static const List<String> _western = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
  ];
  static const List<String> _eastern = [
    '٠',
    '١',
    '٢',
    '٣',
    '٤',
    '٥',
    '٦',
    '٧',
    '٨',
    '٩',
  ];

  /// من إنجليزي -> أرقام عربية
  static String toArabicDigits(String input) {
    var result = input;
    for (var i = 0; i < _western.length; i++) {
      result = result.replaceAll(_western[i], _eastern[i]);
    }
    return result;
  }

  /// من أرقام عربية -> إنجليزي
  static String toWesternDigits(String input) {
    var result = input;
    for (var i = 0; i < _eastern.length; i++) {
      result = result.replaceAll(_eastern[i], _western[i]);
    }
    return result;
  }

  /// بارسر يدعم:
  /// - "٠٤:٣٤ م" / "04:34 pm" (12h)
  /// - "17:20" (24h)
  static TimeOfDay parseTime12h(String timeStr) {
    // 1) حوّل الأرقام العربي لإنجليزي
    var clean = toWesternDigits(timeStr).trim();

    // 2) لو فيه ص/م عربيتين حوّلهم AM/PM
    clean = clean
        .replaceAll('ص', 'AM')
        .replaceAll('م', 'PM')
        .replaceAll('ص.', 'AM')
        .replaceAll('م.', 'PM');

    final parts = clean.toLowerCase().split(
      RegExp(r'\s+'),
    ); // ["04:34", "pm"] مثلاً

    if (parts.isEmpty || parts.length > 2) {
      throw FormatException('Invalid time format: $timeStr');
    }

    final hm = parts[0].split(':');
    if (hm.length != 2) {
      throw FormatException('Invalid time format: $timeStr');
    }

    int hour = int.parse(hm[0]);
    final int minute = int.parse(hm[1]);

    // لو فيه فترة (am/pm) عالجها، لو مفيش اعتبره 24h
    if (parts.length == 2) {
      final String period = parts[1]; // "am" أو "pm"
      if (period.toUpperCase() == "PM" && hour != 12) {
        hour += 12;
      } else if (period.toUpperCase() == "AM" && hour == 12) {
        hour = 0;
      }
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  /// فورمات 12 ساعة فقط
  static String formatTime12h(TimeOfDay time, BuildContext context) {
    final int hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String hourStr = hour12.toString().padLeft(2, '0');
    final String minuteStr = time.minute.toString().padLeft(2, '0');
    final String periodStr = time.period == DayPeriod.am
        ? LocalizationHelper.isArAndArNumberEnable(context)
              ? LocaleKeys.am.tr()
              : 'AM'
        : LocalizationHelper.isArAndArNumberEnable(context)
        ? LocaleKeys.pm.tr()
        : 'PM';

    final raw = '$hourStr:$minuteStr $periodStr';

    return LocalizationHelper.isArAndArNumberEnable(context)
        ? toArabicDigits(raw)
        : raw;
  }

  /// 🔹 جديد: فورمات 24 ساعة فقط
  static String formatTime24h(TimeOfDay time, BuildContext context) {
    final String hourStr = time.hour.toString().padLeft(2, '0');
    final String minuteStr = time.minute.toString().padLeft(2, '0');
    final String raw = '$hourStr:$minuteStr';

    return LocalizationHelper.isArAndArNumberEnable(context)
        ? toArabicDigits(raw)
        : raw;
  }

  /// 🔹 جديد: يختار بين 12 / 24 ساعة حسب إعداد المستخدم في CacheHelper
  static String formatTimeWithSettings(TimeOfDay time, BuildContext context) {
    final bool use24 =
        CacheHelper.getUse24HoursFormat(); // تأكد إن دي موجودة عندك
    return use24 ? formatTime24h(time, context) : formatTime12h(time, context);
  }

  /// النسخة القديمة: دايمًا 12 ساعة
  static String addMinutesToTimeString(
    String timeStr,
    int minutesToAdd,
    BuildContext context,
  ) {
    final time = parseTime12h(timeStr);
    final updated = addMinutesToTimeOfDay(time, minutesToAdd);
    return formatTime12h(updated, context);
  }

  /// 🔹 جديد: تزود دقائق وترجع الوقت حسب إعداد 12/24
  static String addMinutesToTimeStringWithSettings(
    String timeStr,
    int minutesToAdd,
    BuildContext context,
  ) {
    final time = parseTime12h(timeStr);
    final updated = addMinutesToTimeOfDay(time, minutesToAdd);
    return formatTimeWithSettings(updated, context);
  }

  static TimeOfDay addMinutesToTimeOfDay(TimeOfDay time, int minutesToAdd) {
    final dateTime = DateTime(
      2000,
      1,
      1,
      time.hour,
      time.minute,
    ).add(Duration(minutes: minutesToAdd));

    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  static bool isFriday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.weekday == 5;
  }
}

 // if today is friday
  