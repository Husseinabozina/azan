import 'package:azan/core/models/prayer.dart';

bool isNextPrayerRow(Prayer prayer, Prayer? nextPrayer) {
  final prayerTime = prayer.dateTime;
  final nextPrayerTime = nextPrayer?.dateTime;
  if (prayerTime == null || nextPrayerTime == null) return false;

  if (prayer.id != nextPrayer!.id) return false;
  if (_isSameDay(prayerTime, nextPrayerTime)) return true;

  return _isTomorrowFajrWrap(prayerTime, nextPrayerTime, prayer.id);
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
