import 'package:azan/core/utils/azkar_scheduling_enums.dart';

class DhikrSchedule {
  final DhikrScheduleType type;
  final List<int>? weekdays; // ex: [DateTime.friday]
  final DateTime? specificDate; // ex: تاريخ معين

  DhikrSchedule._({required this.type, this.weekdays, this.specificDate});

  factory DhikrSchedule.none() => DhikrSchedule._(type: DhikrScheduleType.none);

  factory DhikrSchedule.daily() =>
      DhikrSchedule._(type: DhikrScheduleType.daily);

  factory DhikrSchedule.weekly({required List<int> weekdays}) =>
      DhikrSchedule._(type: DhikrScheduleType.weekly, weekdays: weekdays);

  factory DhikrSchedule.specificDate(DateTime date) =>
      DhikrSchedule._(type: DhikrScheduleType.specificDate, specificDate: date);

  bool isDueOn(DateTime date) {
    switch (type) {
      case DhikrScheduleType.none:
      case DhikrScheduleType.daily:
        return true;
      case DhikrScheduleType.weekly:
        if (weekdays == null || weekdays!.isEmpty) return false;
        return weekdays!.contains(date.weekday);
      case DhikrScheduleType.specificDate:
        if (specificDate == null) return false;
        return date.year == specificDate!.year &&
            date.month == specificDate!.month &&
            date.day == specificDate!.day;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'weekdays': weekdays,
      'specificDate': specificDate?.toIso8601String(),
    };
  }

  factory DhikrSchedule.fromMap(Map<String, dynamic> map) {
    final typeIndex = map['type'] as int? ?? 0;
    final t = DhikrScheduleType.values[typeIndex];

    return DhikrSchedule._(
      type: t,
      weekdays: (map['weekdays'] as List?)?.cast<int>(),
      specificDate: map['specificDate'] != null
          ? DateTime.parse(map['specificDate'] as String)
          : null,
    );
  }
}
