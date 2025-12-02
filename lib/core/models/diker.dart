import 'package:azan/core/models/dhikr_schedule.dart';

class Dhikr {
  final int id;
  final String text;
  final DhikrSchedule? schedule;
  bool active;

  Dhikr({required this.text, this.schedule, int? id, this.active = true})
    : id = id ?? DateTime.now().millisecondsSinceEpoch;

  Dhikr copyWith({String? text, int? id, DhikrSchedule? schedule}) {
    return Dhikr(
      text: text ?? this.text,
      id: id ?? this.id,
      schedule: schedule ?? this.schedule,
      active: this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'schedule': schedule?.toMap(),
      'active': active,
    };
  }

  factory Dhikr.fromMap(Map<String, dynamic> map) {
    return Dhikr(
      id: map['id'] as int,
      text: map['text'] as String,
      schedule: map['schedule'] != null
          ? DhikrSchedule.fromMap(
              Map<String, dynamic>.from(map['schedule'] as Map),
            )
          : null,
      active: map['active'] as bool,
    );
  }

  bool isForDay(DateTime date) {
    if (schedule == null) return true;
    return schedule!.isDueOn(date);
  }
}
