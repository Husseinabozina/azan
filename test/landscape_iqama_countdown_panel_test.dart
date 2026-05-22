import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/views/home/components/landscape_iqama_countdown_panel.dart';
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

  testWidgets('landscape iqama countdown panel fits beside top clock', (
    tester,
  ) async {
    for (final size in <Size>[const Size(180, 173), const Size(132, 96)]) {
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
                    width: size.width,
                    height: size.height,
                    child: const LandscapeIqamaCountdownPanel(
                      countdownText: '02:45',
                      progress: 0.64,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('02:45'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
