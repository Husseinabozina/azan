class DisplayBoardSchedule {
  const DisplayBoardSchedule({
    required this.enabled,
    this.startAt,
    this.endAt,
    this.dismissedUntilEndAt,
  });

  const DisplayBoardSchedule.disabled()
    : enabled = false,
      startAt = null,
      endAt = null,
      dismissedUntilEndAt = null;

  final bool enabled;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? dismissedUntilEndAt;

  bool get hasWindow => startAt != null && endAt != null;

  bool get isValidWindow =>
      hasWindow && endAt!.isAfter(startAt!);

  DisplayBoardSchedule copyWith({
    bool? enabled,
    DateTime? startAt,
    bool clearStartAt = false,
    DateTime? endAt,
    bool clearEndAt = false,
    DateTime? dismissedUntilEndAt,
    bool clearDismissedUntilEndAt = false,
  }) {
    return DisplayBoardSchedule(
      enabled: enabled ?? this.enabled,
      startAt: clearStartAt ? null : (startAt ?? this.startAt),
      endAt: clearEndAt ? null : (endAt ?? this.endAt),
      dismissedUntilEndAt: clearDismissedUntilEndAt
          ? null
          : (dismissedUntilEndAt ?? this.dismissedUntilEndAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'startAt': startAt?.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
      'dismissedUntilEndAt': dismissedUntilEndAt?.toIso8601String(),
    };
  }

  factory DisplayBoardSchedule.fromMap(Map<String, dynamic> map) {
    return DisplayBoardSchedule(
      enabled: map['enabled'] as bool? ?? false,
      startAt: map['startAt'] is String
          ? DateTime.tryParse(map['startAt'] as String)
          : null,
      endAt: map['endAt'] is String
          ? DateTime.tryParse(map['endAt'] as String)
          : null,
      dismissedUntilEndAt: map['dismissedUntilEndAt'] is String
          ? DateTime.tryParse(map['dismissedUntilEndAt'] as String)
          : null,
    );
  }
}
