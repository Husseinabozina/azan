import 'package:azan/core/models/prayer.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/views/home/components/clock_and_left_time_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await CacheHelper.init();
    await CacheHelper.setLang('en');
    await CacheHelper.setShowSecondsInNextPrayer(true);
  });

  testWidgets(
    'shows next prayer countdown even when legacy left time text is empty',
    (tester) async {
      final nextPrayer = Prayer(
        id: 1,
        title: 'Fajr',
        time: '05:00',
        dateTime: DateTime.now().add(const Duration(hours: 2, minutes: 5)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(960, 540)),
            child: MQScaleInit(
              designSize: const Size(960, 540),
              minTextAdapt: true,
              child: Scaffold(
                body: SizedBox(
                  width: 960,
                  height: 173,
                  child: ClockAndLeftTimeWidget(
                    width: 960,
                    letfTimeText: '',
                    nextPrayerFuture: Future<Prayer?>.value(nextPrayer),
                    showNextPrayerCountdown: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Fajr'), findsOneWidget);
      expect(find.byWidgetPredicate(_looksLikeDurationText), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shows next prayer countdown as a side landscape panel', (
    tester,
  ) async {
    final nextPrayer = Prayer(
      id: 2,
      title: 'Dhuhr',
      time: '12:00',
      dateTime: DateTime.now().add(const Duration(hours: 1, minutes: 12)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(960, 540)),
          child: MQScaleInit(
            designSize: const Size(960, 540),
            minTextAdapt: true,
            child: Scaffold(
              body: SizedBox(
                width: 210,
                height: 173,
                child: LandscapeNextPrayerCountdownPanel(
                  nextPrayerFuture: Future<Prayer?>.value(nextPrayer),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Dhuhr'), findsOneWidget);
    expect(find.byWidgetPredicate(_looksLikeDurationText), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

bool _looksLikeDurationText(Widget widget) {
  if (widget is! Text) return false;
  final text = widget.data ?? widget.textSpan?.toPlainText() ?? '';
  return RegExp(r'^\d{2}:\d{2}(:\d{2})?$').hasMatch(text);
}
