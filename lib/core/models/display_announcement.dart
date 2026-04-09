import 'package:azan/core/models/display_board_schedule.dart';

class DisplayAnnouncement {
  const DisplayAnnouncement({
    required this.id,
    required this.title,
    required this.body,
    required this.active,
    required this.pinned,
    required this.sortOrder,
    required this.titleFontFamily,
    required this.bodyFontFamily,
    required this.titleBold,
    required this.titleItalic,
    required this.bodyBold,
    required this.bodyItalic,
    required this.titleSize,
    required this.bodySize,
    required this.titleColorIndex,
    required this.bodyColorIndex,
    this.schedule,
  });

  final int id;
  final String title;
  final String body;
  final bool active;
  final bool pinned;
  final int sortOrder;
  final String titleFontFamily;
  final String bodyFontFamily;
  final bool titleBold;
  final bool titleItalic;
  final bool bodyBold;
  final bool bodyItalic;
  final int titleSize;
  final int bodySize;
  final int titleColorIndex;
  final int bodyColorIndex;
  final DisplayBoardSchedule? schedule;

  DisplayAnnouncement copyWith({
    int? id,
    String? title,
    String? body,
    bool? active,
    bool? pinned,
    int? sortOrder,
    String? titleFontFamily,
    String? bodyFontFamily,
    bool? titleBold,
    bool? titleItalic,
    bool? bodyBold,
    bool? bodyItalic,
    int? titleSize,
    int? bodySize,
    int? titleColorIndex,
    int? bodyColorIndex,
    DisplayBoardSchedule? schedule,
    bool clearSchedule = false,
  }) {
    return DisplayAnnouncement(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      active: active ?? this.active,
      pinned: pinned ?? this.pinned,
      sortOrder: sortOrder ?? this.sortOrder,
      titleFontFamily: titleFontFamily ?? this.titleFontFamily,
      bodyFontFamily: bodyFontFamily ?? this.bodyFontFamily,
      titleBold: titleBold ?? this.titleBold,
      titleItalic: titleItalic ?? this.titleItalic,
      bodyBold: bodyBold ?? this.bodyBold,
      bodyItalic: bodyItalic ?? this.bodyItalic,
      titleSize: titleSize ?? this.titleSize,
      bodySize: bodySize ?? this.bodySize,
      titleColorIndex: titleColorIndex ?? this.titleColorIndex,
      bodyColorIndex: bodyColorIndex ?? this.bodyColorIndex,
      schedule: clearSchedule ? null : (schedule ?? this.schedule),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'active': active,
      'pinned': pinned,
      'sortOrder': sortOrder,
      'titleFontFamily': titleFontFamily,
      'bodyFontFamily': bodyFontFamily,
      'titleBold': titleBold,
      'titleItalic': titleItalic,
      'bodyBold': bodyBold,
      'bodyItalic': bodyItalic,
      'titleSize': titleSize,
      'bodySize': bodySize,
      'titleColorIndex': titleColorIndex,
      'bodyColorIndex': bodyColorIndex,
      'schedule': schedule?.toMap(),
    };
  }

  factory DisplayAnnouncement.fromMap(Map<String, dynamic> map) {
    return DisplayAnnouncement(
      id: map['id'] as int,
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      active: map['active'] as bool? ?? true,
      pinned: map['pinned'] as bool? ?? false,
      sortOrder: map['sortOrder'] as int? ?? 0,
      titleFontFamily: (map['titleFontFamily'] as String?) ?? '',
      bodyFontFamily: (map['bodyFontFamily'] as String?) ?? '',
      titleBold: map['titleBold'] as bool? ?? false,
      titleItalic: map['titleItalic'] as bool? ?? false,
      bodyBold: map['bodyBold'] as bool? ?? false,
      bodyItalic: map['bodyItalic'] as bool? ?? false,
      titleSize: map['titleSize'] as int? ?? 0,
      bodySize: map['bodySize'] as int? ?? 0,
      titleColorIndex: map['titleColorIndex'] as int? ?? 0,
      bodyColorIndex: map['bodyColorIndex'] as int? ?? 0,
      schedule: map['schedule'] is Map
          ? DisplayBoardSchedule.fromMap(
              Map<String, dynamic>.from(map['schedule'] as Map),
            )
          : null,
    );
  }
}
