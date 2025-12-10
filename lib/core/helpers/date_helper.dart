import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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

  static TimeOfDay parseTime12h(String timeStr) {
    // مثال: "٠٤:٣٤ م" أو "04:34 pm"

    // 1) حوّل الأرقام العربي لإنجليزي
    var clean = toWesternDigits(timeStr).trim();

    // 2) لو فيه ص/م عربيتين حوّلهم am/pm
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

    // لو فيه فترة (am/pm) عالجها، لو مفيش اعتبره 24h وخلاص
    if (parts.length == 2) {
      final String period = parts[1]; // "am" أو "pm"
      if (period == "PM" && hour != 12) {
        hour += 12;
      } else if (period == "AM" && hour == 12) {
        hour = 0;
      }
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  static String formatTime12h(TimeOfDay time) {
    final int hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String hourStr = hour12.toString().padLeft(2, '0');
    final String minuteStr = time.minute.toString().padLeft(2, '0');
    final String periodStr = time.period == DayPeriod.am
        ? LocaleKeys.am.tr()
        : LocaleKeys.pm.tr();

    return CacheHelper.getLang() == 'en'
        ? '$hourStr:$minuteStr $periodStr'
        : toArabicDigits('${hourStr}:$minuteStr $periodStr');
  }

  static String addMinutesToTimeString(String timeStr, int minutesToAdd) {
    final time = parseTime12h(timeStr);
    final updated = addMinutesToTimeOfDay(time, minutesToAdd);
    return formatTime12h(updated);
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
}
