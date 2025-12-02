import 'package:flutter/material.dart';

class Prayer {
  final int id;
  final String title;
  final String? time;
  final DateTime? dateTime;
  Prayer({
    required this.id,
    required this.title,
    required this.time,
    required this.dateTime,
  });

  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      id: json['id'],
      title: json['name'],
      time: json['time'],
      dateTime: json['adhanPrayer'],
    );
  }

  Prayer copywith({String? title, String? time, DateTime? dateTime}) {
    return Prayer(
      id: id,
      title: title ?? this.title,
      time: time ?? this.time,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
