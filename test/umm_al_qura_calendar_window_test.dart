import 'package:azan/core/models/gregorian_coverage_window.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Gregorian coverage window spans current year plus next five years', () {
    final window = GregorianCoverageWindow.forToday(DateTime(2026, 5, 24));

    expect(window.startInclusive, DateTime(2026, 1, 1));
    expect(window.today, DateTime(2026, 5, 24));
    expect(window.endInclusive, DateTime(2031, 12, 31));
    expect(window.supportedGregorianYears, [
      2026,
      2027,
      2028,
      2029,
      2030,
      2031,
    ]);
  });

  test(
    'availability distinguishes past read-only, selectable, and out of range',
    () {
      final window = GregorianCoverageWindow.forToday(DateTime(2026, 5, 24));

      expect(
        window.availabilityFor(DateTime(2026, 5, 23)),
        DateAvailabilityState.pastReadOnly,
      );
      expect(
        window.availabilityFor(DateTime(2026, 5, 24)),
        DateAvailabilityState.selectable,
      );
      expect(
        window.availabilityFor(DateTime(2031, 12, 31)),
        DateAvailabilityState.selectable,
      );
      expect(
        window.availabilityFor(DateTime(2032, 1, 1)),
        DateAvailabilityState.outOfRange,
      );
    },
  );
}
