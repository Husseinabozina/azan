import 'package:azan/core/models/prayer.dart';

bool isHighlightedPrayerRow({
  required Prayer prayer,
  required Prayer? nextPrayer,
  required Prayer? currentPrayer,
  required bool isBetweenAdhanAndIqama,
  required Duration? remainingToIqama,
}) {
  if (_shouldKeepCurrentPrayerHighlighted(
    currentPrayer: currentPrayer,
    isBetweenAdhanAndIqama: isBetweenAdhanAndIqama,
    remainingToIqama: remainingToIqama,
  )) {
    return _isSamePrayerOccurrence(prayer, currentPrayer!);
  }

  return isNextPrayerRow(prayer, nextPrayer);
}

bool isNextPrayerRow(Prayer prayer, Prayer? nextPrayer) {
  final prayerTime = prayer.dateTime;
  final nextPrayerTime = nextPrayer?.dateTime;
  if (prayerTime == null || nextPrayerTime == null) return false;

  if (prayer.id != nextPrayer!.id) return false;
  if (_isSameDay(prayerTime, nextPrayerTime)) return true;

  return _isTomorrowFajrWrap(prayerTime, nextPrayerTime, prayer.id);
}

bool _shouldKeepCurrentPrayerHighlighted({
  required Prayer? currentPrayer,
  required bool isBetweenAdhanAndIqama,
  required Duration? remainingToIqama,
}) {
  if (!isBetweenAdhanAndIqama || currentPrayer?.dateTime == null) {
    return false;
  }

  return remainingToIqama == null || remainingToIqama > Duration.zero;
}

bool _isSamePrayerOccurrence(Prayer prayer, Prayer currentPrayer) {
  final prayerTime = prayer.dateTime;
  final currentPrayerTime = currentPrayer.dateTime;
  if (prayerTime == null || currentPrayerTime == null) return false;
  return prayer.id == currentPrayer.id &&
      _isSameDay(prayerTime, currentPrayerTime);
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool _isTomorrowFajrWrap(DateTime rowTime, DateTime nextTime, int prayerId) {
  if (prayerId != 1 || !nextTime.isAfter(rowTime)) return false;

  final tomorrow = DateTime(rowTime.year, rowTime.month, rowTime.day + 1);
  return nextTime.year == tomorrow.year &&
      nextTime.month == tomorrow.month &&
      nextTime.day == tomorrow.day;
}
