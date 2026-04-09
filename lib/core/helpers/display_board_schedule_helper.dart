import 'package:azan/core/models/display_announcement.dart';
import 'package:azan/core/models/display_board_schedule.dart';
import 'package:azan/core/models/home_display_mode.dart';
import 'package:azan/core/helpers/display_board_hive_helper.dart';
import 'package:azan/core/utils/cache_helper.dart';

class DisplayBoardScheduleResolver {
  const DisplayBoardScheduleResolver._();

  static bool isScheduleActive(
    DisplayBoardSchedule? schedule,
    DateTime now,
  ) {
    if (schedule == null || !schedule.enabled || !schedule.isValidWindow) {
      return false;
    }

    return !now.isBefore(schedule.startAt!) && now.isBefore(schedule.endAt!);
  }

  static bool hasManualDismissForCurrentWindow(
    DisplayBoardSchedule? schedule,
    DateTime now,
  ) {
    if (!isScheduleActive(schedule, now)) return false;

    final dismissedUntilEndAt = schedule?.dismissedUntilEndAt;
    final endAt = schedule?.endAt;
    if (dismissedUntilEndAt == null || endAt == null) return false;

    return !dismissedUntilEndAt.isBefore(endAt) &&
        !now.isAfter(dismissedUntilEndAt);
  }

  static bool isAnnouncementScheduledNow(
    DisplayAnnouncement item,
    DateTime now,
  ) {
    return isScheduleActive(item.schedule, now) &&
        !hasManualDismissForCurrentWindow(item.schedule, now);
  }

  static bool hasScheduledAnnouncementsDue(
    List<DisplayAnnouncement> items,
    DateTime now,
  ) {
    return items.any(
      (item) => item.active && item.schedule != null && isAnnouncementScheduledNow(item, now),
    );
  }

  static List<DisplayAnnouncement> resolveVisibleAnnouncements(
    List<DisplayAnnouncement> items,
    DateTime now, {
    required bool includeUnscheduled,
  }) {
    return items.where((item) {
      if (!item.active) return false;
      if (item.schedule == null) return includeUnscheduled;
      return isAnnouncementScheduledNow(item, now);
    }).toList();
  }

  static HomeDisplayMode effectiveDisplayMode({
    required HomeDisplayMode manualMode,
    required List<DisplayAnnouncement> items,
    DateTime? now,
  }) {
    final instant = now ?? DateTime.now();
    if (manualMode == HomeDisplayMode.displayBoard) {
      return HomeDisplayMode.displayBoard;
    }

    return hasScheduledAnnouncementsDue(items, instant)
        ? HomeDisplayMode.displayBoard
        : HomeDisplayMode.standard;
  }

  static Future<bool> dismissScheduledAnnouncementsDueNow(
    List<DisplayAnnouncement> items, {
    DateTime? now,
  }) async {
    final instant = now ?? DateTime.now();
    bool changed = false;

    for (final item in items) {
      final schedule = item.schedule;
      if (!item.active ||
          schedule == null ||
          schedule.endAt == null ||
          !isAnnouncementScheduledNow(item, instant)) {
        continue;
      }

      changed = true;
      await DisplayBoardHiveHelper.updateAnnouncement(
        item.copyWith(
          schedule: schedule.copyWith(dismissedUntilEndAt: schedule.endAt),
        ),
      );
    }

    return changed;
  }

  static Future<void> switchBackToHomeMode({
    required List<DisplayAnnouncement> items,
    DateTime? now,
    bool dismissCurrentScheduled = false,
  }) async {
    if (dismissCurrentScheduled) {
      await dismissScheduledAnnouncementsDueNow(items, now: now);
    }

    await CacheHelper.setHomeDisplayMode(HomeDisplayMode.standard);
  }
}
