import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/views/home/components/iqama_focus_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await CacheHelper.init();
    await CacheHelper.setLang('ar');
  });

  testWidgets('landscape iqama focus fits tight home remaining areas', (
    tester,
  ) async {
    const prayers = [
      IqamaPrayerSummaryData(prayerName: 'الفجر', adhanTime: '04:16'),
      IqamaPrayerSummaryData(prayerName: 'الشروق', adhanTime: '05:29'),
      IqamaPrayerSummaryData(prayerName: 'الظهر', adhanTime: '11:59'),
      IqamaPrayerSummaryData(prayerName: 'العصر', adhanTime: '03:31'),
      IqamaPrayerSummaryData(prayerName: 'المغرب', adhanTime: '06:18'),
      IqamaPrayerSummaryData(prayerName: 'العشاء', adhanTime: '07:35'),
    ];

    for (final height in <double>[210, 190, 150, 120]) {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(960, 540)),
            child: MQScaleInit(
              designSize: const Size(960, 540),
              minTextAdapt: true,
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 820,
                    height: height,
                    child: const IqamaFocusSection(
                      countdownText: '02:45',
                      progress: 0.64,
                      prayers: prayers,
                      isLandscape: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('02:45'), findsOneWidget);
    }
  });
}
