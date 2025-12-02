import 'package:flutter/material.dart';

class DateHelper {
  static String toArabicDigits(String input) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    var result = input;
    for (var i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], eastern[i]);
    }
    return result;
  }

  static TimeOfDay parseTime12h(String timeStr) {
    // مثال: "04:34 pm"
    final parts = timeStr.toLowerCase().trim().split(' '); // ["04:34", "pm"]
    if (parts.length != 2) {
      throw FormatException('Invalid time format: $timeStr');
    }

    final hm = parts[0].split(':'); // ["04", "34"]
    if (hm.length != 2) {
      throw FormatException('Invalid time format: $timeStr');
    }

    int hour = int.parse(hm[0]);
    final int minute = int.parse(hm[1]);
    final String period = parts[1]; // "am" or "pm"

    // تحويل 12h -> 24h
    if (period == 'pm' && hour != 12) {
      hour += 12;
    } else if (period == 'am' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  static String formatTime12h(TimeOfDay time) {
    final int hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String hourStr = hour12.toString().padLeft(2, '0');
    final String minuteStr = time.minute.toString().padLeft(2, '0');
    final String periodStr = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hourStr:$minuteStr $periodStr';
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
      1, // أي يوم عشوائي
      time.hour,
      time.minute,
    ).add(Duration(minutes: minutesToAdd));

    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }
}
