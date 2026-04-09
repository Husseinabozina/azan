import 'package:azan/views/home/components/prayer_times_table.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses target row height when available space is sufficient', () {
    final layout = resolvePrayerTimesTableLayout(
      rowCount: 6,
      maxHeight: 560,
      headerHeight: 19,
      spaceAfterHeader: 3,
      gapHeight: 3,
      targetRowHeight: 66,
      minRowHeight: 60,
      allowScrollIfOverflow: false,
    );

    expect(layout.rowHeight, 66);
    expect(layout.overflow, isFalse);
    expect(layout.shouldScroll, isFalse);
  });

  test(
    'uses fitted row height and disables scroll when overflow is disallowed',
    () {
      final layout = resolvePrayerTimesTableLayout(
        rowCount: 6,
        maxHeight: 367,
        headerHeight: 19,
        spaceAfterHeader: 3,
        gapHeight: 3,
        targetRowHeight: 66,
        minRowHeight: 60,
        allowScrollIfOverflow: false,
      );

      expect(layout.rowHeight, 55);
      expect(layout.overflow, isTrue);
      expect(layout.shouldScroll, isFalse);
    },
  );

  test('enables scrolling when overflow is allowed', () {
    final layout = resolvePrayerTimesTableLayout(
      rowCount: 6,
      maxHeight: 367,
      headerHeight: 19,
      spaceAfterHeader: 3,
      gapHeight: 3,
      targetRowHeight: 66,
      minRowHeight: 60,
      allowScrollIfOverflow: true,
    );

    expect(layout.rowHeight, 60);
    expect(layout.overflow, isTrue);
    expect(layout.shouldScroll, isTrue);
  });

  test('removing the header preserves more row height', () {
    final withHeader = resolvePrayerTimesTableLayout(
      rowCount: 6,
      maxHeight: 430,
      headerHeight: 19,
      spaceAfterHeader: 3,
      gapHeight: 3,
      targetRowHeight: 66,
      minRowHeight: 60,
      allowScrollIfOverflow: false,
    );

    final withoutHeader = resolvePrayerTimesTableLayout(
      rowCount: 6,
      maxHeight: 430,
      headerHeight: 0,
      spaceAfterHeader: 0,
      gapHeight: 3,
      targetRowHeight: 66,
      minRowHeight: 60,
      allowScrollIfOverflow: false,
    );

    expect(withoutHeader.rowHeight, greaterThan(withHeader.rowHeight));
    expect(withoutHeader.shouldScroll, isFalse);
  });
}
