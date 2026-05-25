enum DateAvailabilityState { pastReadOnly, selectable, outOfRange }

class GregorianCoverageWindow {
  final DateTime startInclusive;
  final DateTime today;
  final DateTime endInclusive;

  const GregorianCoverageWindow({
    required this.startInclusive,
    required this.today,
    required this.endInclusive,
  });

  factory GregorianCoverageWindow.forToday(DateTime now) {
    final normalized = DateTime(now.year, now.month, now.day);
    return GregorianCoverageWindow(
      startInclusive: DateTime(normalized.year, 1, 1),
      today: normalized,
      endInclusive: DateTime(normalized.year + 5, 12, 31),
    );
  }

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
    if (normalized.year == today.year && normalized.isBefore(today)) {
      return DateAvailabilityState.pastReadOnly;
    }
    return DateAvailabilityState.selectable;
  }

  List<int> get supportedGregorianYears =>
      List<int>.generate(6, (index) => startInclusive.year + index);
}
