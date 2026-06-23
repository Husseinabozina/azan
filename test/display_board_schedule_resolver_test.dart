import 'package:azan/core/helpers/display_board_schedule_helper.dart';
import 'package:azan/core/models/display_announcement.dart';
import 'package:azan/core/models/display_board_schedule.dart';
import 'package:azan/core/models/home_display_mode.dart';
import 'package:flutter_test/flutter_test.dart';

DisplayAnnouncement _announcement({
  required int id,
  required bool active,
  DisplayBoardSchedule? schedule,
}) {
  return DisplayAnnouncement(
    id: id,
    title: 'Board $id',
    body: 'Body $id',
    active: active,
    pinned: false,
    sortOrder: id,
    titleFontFamily: 'A',
    bodyFontFamily: 'B',
    titleBold: false,
    titleItalic: false,
    bodyBold: false,
    bodyItalic: false,
    titleSize: 50,
    bodySize: 30,
    titleColorIndex: 0,
    bodyColorIndex: 1,
    schedule: schedule,
  );
}

void main() {
  group('DisplayBoardScheduleResolver', () {
    test('scheduled board is due only inside its own window', () {
      final item = _announcement(
        id: 1,
        active: true,
        schedule: DisplayBoardSchedule(
          enabled: true,
          startAt: DateTime(2026, 4, 12, 19, 0),
          endAt: DateTime(2026, 4, 13, 9, 0),
        ),
      );

      expect(
        DisplayBoardScheduleResolver.isAnnouncementScheduledNow(
          item,
          DateTime(2026, 4, 12, 18, 59),
        ),
        isFalse,
      );
      expect(
        DisplayBoardScheduleResolver.isAnnouncementScheduledNow(
          item,
          DateTime(2026, 4, 12, 23, 0),
        ),
        isTrue,
      );
      expect(
        DisplayBoardScheduleResolver.isAnnouncementScheduledNow(
          item,
          DateTime(2026, 4, 13, 9, 0),
        ),
        isFalse,
      );
    });

    test('manual dismiss blocks the same board until schedule end', () {
      final item = _announcement(
        id: 1,
        active: true,
        schedule: DisplayBoardSchedule(
          enabled: true,
          startAt: DateTime(2026, 4, 12, 19, 0),
          endAt: DateTime(2026, 4, 13, 9, 0),
          dismissedUntilEndAt: DateTime(2026, 4, 13, 9, 0),
        ),
      );

      expect(
        DisplayBoardScheduleResolver.isAnnouncementScheduledNow(
          item,
          DateTime(2026, 4, 12, 23, 0),
        ),
        isFalse,
      );
    });

    test('visible boards include only due scheduled boards in auto mode', () {
      final items = [
        _announcement(id: 1, active: true),
        _announcement(
          id: 2,
          active: true,
          schedule: DisplayBoardSchedule(
            enabled: true,
            startAt: DateTime(2026, 4, 12, 19, 0),
            endAt: DateTime(2026, 4, 12, 21, 0),
          ),
        ),
        _announcement(
          id: 3,
          active: true,
          schedule: DisplayBoardSchedule(
            enabled: true,
            startAt: DateTime(2026, 4, 12, 22, 0),
            endAt: DateTime(2026, 4, 13, 1, 0),
          ),
        ),
      ];

      final visible = DisplayBoardScheduleResolver.resolveVisibleAnnouncements(
        items,
        DateTime(2026, 4, 12, 20, 0),
        includeUnscheduled: false,
      );

      expect(visible.map((e) => e.id).toList(), [2]);
    });

    test('visible boards include unscheduled boards in manual display mode', () {
      final items = [
        _announcement(id: 1, active: true),
        _announcement(
          id: 2,
          active: true,
          schedule: DisplayBoardSchedule(
            enabled: true,
            startAt: DateTime(2026, 4, 12, 19, 0),
            endAt: DateTime(2026, 4, 12, 21, 0),
          ),
        ),
      ];

      final visible = DisplayBoardScheduleResolver.resolveVisibleAnnouncements(
        items,
        DateTime(2026, 4, 12, 20, 0),
        includeUnscheduled: true,
      );

      expect(visible.map((e) => e.id).toList(), [1, 2]);
    });

    test('effective mode opens display board when any scheduled board is due', () {
      final items = [
        _announcement(
          id: 2,
          active: true,
          schedule: DisplayBoardSchedule(
            enabled: true,
            startAt: DateTime(2026, 4, 12, 19, 0),
            endAt: DateTime(2026, 4, 12, 21, 0),
          ),
        ),
      ];

      expect(
        DisplayBoardScheduleResolver.effectiveDisplayMode(
          manualMode: HomeDisplayMode.standard,
          items: items,
          now: DateTime(2026, 4, 12, 20, 0),
        ),
        HomeDisplayMode.displayBoard,
      );
      expect(
        DisplayBoardScheduleResolver.effectiveDisplayMode(
          manualMode: HomeDisplayMode.standard,
          items: items,
          now: DateTime(2026, 4, 12, 22, 0),
        ),
        HomeDisplayMode.standard,
      );
    });
  });
}
