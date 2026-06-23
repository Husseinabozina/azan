enum DateAvailabilityState { pastReadOnly, selectable, outOfRange }

class SupportedScheduleWindow {
  final DateTime startInclusive;
  final DateTime todayGregorian;
  final int currentHijriYear;
  final DateTime gregorianForwardAnchorInclusive;
  final int finalSupportedHijriYear;
  final DateTime endInclusive;

  const SupportedScheduleWindow({
    required this.startInclusive,
    required this.todayGregorian,
    required this.currentHijriYear,
    required this.gregorianForwardAnchorInclusive,
    required this.finalSupportedHijriYear,
    required this.endInclusive,
  });

  bool contains(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return !normalized.isBefore(startInclusive) &&
        !normalized.isAfter(endInclusive);
  }

  DateAvailabilityState availabilityFor(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    if (!contains(normalized)) {
      return DateAvailabilityState.outOfRange;
    }
    if (normalized.isBefore(todayGregorian)) {
      return DateAvailabilityState.pastReadOnly;
    }
    return DateAvailabilityState.selectable;
  }

  List<int> get supportedHijriYears => List<int>.generate(
    (finalSupportedHijriYear - currentHijriYear) + 1,
    (index) => currentHijriYear + index,
  );
}

typedef GregorianCoverageWindow = SupportedScheduleWindow;
