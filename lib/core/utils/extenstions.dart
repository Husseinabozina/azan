// lib/core/utils/responsive.dart
import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/utils/azkar_scheduling_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

extension ColoredPrint on String {
  void log() => print('\x1B[33m$this\x1B[0m');
}

class R {
  final double h;
  final double w;
  final double blockH;
  final double blockW;

  R(BoxConstraints constraints)
    : h = constraints.maxHeight,
      w = constraints.maxWidth,
      blockH = constraints.maxHeight / 100,
      blockW = constraints.maxWidth / 100;

  // أحجام نصوص تقريبية
  double get fontXL => blockH * 4;
  double get fontL => blockH * 3;
  double get fontM => blockH * 2.6;
  double get fontS => blockH * 2.2;

  // مسافات جاهزة
  double get paddingHorizontal => blockW * 6;
  double get smallGap => blockH * 1.5;
  double get mediumGap => blockH * 2.5;
  double get largeGap => blockH * 4;
}

extension ArabicWeekdayExt on DateTime {
  static const Map<int, String> _arabicWeekdays = {
    DateTime.monday: 'الاثنين',
    DateTime.tuesday: 'الثلاثاء',
    DateTime.wednesday: 'الأربعاء',
    DateTime.thursday: 'الخميس',
    DateTime.friday: 'الجمعة',
    DateTime.saturday: 'السبت',
    DateTime.sunday: 'الأحد',
  };

  String get weekdayNameAr => _arabicWeekdays[weekday] ?? '';
}

extension schedulingText on DhikrSchedule {
  toArabicText() {
    if (type == DhikrScheduleType.daily) {
      return 'يوميا';
    } else if (type == DhikrScheduleType.weekly) {
      if (weekdays!.length == 1) {
        return weekdays![0].toWeekDay().toArabicWeekDay();
      } else {
        return 'مخصص';
      }
    } else if (type == DhikrScheduleType.specificDate) {
      return DateFormat('yyyy-MM-dd').format(specificDate!);
    }
  }
}

extension convertToWeekDAay on int {
  String toWeekDay() {
    if (this == 1) {
      return 'Monday';
    } else if (this == 2) {
      return 'Tuesday';
    } else if (this == 3) {
      return 'Wednesday';
    } else if (this == 4) {
      return 'Thursday';
    } else if (this == 5) {
      return 'Friday';
    } else if (this == 6) {
      return 'Saturday';
    } else if (this == 7) {
      return 'Sunday';
    }
    return '';
  }
}

extension convertToPrayerName on int {
  String toPrayerName() {
    if (this == 0) {
      return 'الفجر';
    } else if (this == 1) {
      return 'الشروق';
    } else if (this == 2) {
      return 'الظهر';
    } else if (this == 3) {
      return 'العصر';
    } else if (this == 4) {
      return 'المغرب';
    } else if (this == 5) {
      return 'العشاء';
    }
    return '';
  }
}
// convert weekday to arabic

extension arabicWeekDay on String {
  String toArabicWeekDay() {
    if (this == 'Monday') {
      return 'الاثنين';
    } else if (this == 'Tuesday') {
      return 'الثلاثاء';
    } else if (this == 'Wednesday') {
      return 'الأربعاء';
    } else if (this == 'Thursday') {
      return 'الخميس';
    } else if (this == 'Friday') {
      return 'الجمعة';
    } else if (this == 'Saturday') {
      return 'السبت';
    } else if (this == 'Sunday') {
      return 'الأحد';
    }
    return '';
  }
}

extension DurationFormate on Duration {
  String formatDuration() {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = (inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
