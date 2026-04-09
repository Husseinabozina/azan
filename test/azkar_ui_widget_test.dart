import 'dart:io';

import 'package:azan/core/helpers/managed_azkar_hive_helper.dart';
import 'package:azan/core/models/azkar_type.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/views/home/components/azkar_content.dart';
import 'package:azan/views/home/components/azkar_presentation_view.dart';
import 'package:azan/views/home/components/azkar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  Future<AzkarPresentationView> pumpUntilResolved(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 10));
      final presentation = tester.widget<AzkarPresentationView>(
        find.byType(AzkarPresentationView),
      );
      if (presentation.resolvedSet.entries.isNotEmpty) {
        return presentation;
      }
    }

    return tester.widget<AzkarPresentationView>(
      find.byType(AzkarPresentationView),
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await CacheHelper.init();

    await Hive.close();
    tempDir = await Directory.systemTemp.createTemp('managed_azkar_widget');
    Hive.init(tempDir.path);
    await ManagedAzkarHiveHelper.ensureInitialAzkarSets();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget buildHarness(Widget child, {required Size size}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: MQScaleInit(designSize: size, minTextAdapt: true, child: child),
      ),
    );
  }

  testWidgets('shared renderer builds safely in portrait and landscape', (
    tester,
  ) async {
    final resolved = await loadAzkarSet(AzkarType.morning);

    await tester.pumpWidget(
      buildHarness(
        AzkarPresentationView(
          resolvedSet: resolved,
          entry: resolved.entries.first,
          entryIndex: 0,
          totalEntries: resolved.entries.length,
        ),
        size: const Size(393, 852),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AzkarPresentationView), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.text('آية الكرسى - البقرة 255'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      buildHarness(
        AzkarPresentationView(
          resolvedSet: resolved,
          entry: resolved.entries.first,
          entryIndex: 0,
          totalEntries: resolved.entries.length,
        ),
        size: const Size(960, 540),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AzkarPresentationView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AzkarView keeps fajr-specific after-prayer content', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        const AzkarView(azkarType: AzkarType.afterPrayer, prayerId: 1),
        size: const Size(393, 852),
      ),
    );
    final presentation = await pumpUntilResolved(tester);
    expect(presentation.resolvedSet.entries.length, 8);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('AzkarView removes prayer-specific extras for dhuhr', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        const AzkarView(azkarType: AzkarType.afterPrayer, prayerId: 3),
        size: const Size(393, 852),
      ),
    );
    final presentation = await pumpUntilResolved(tester);
    expect(presentation.resolvedSet.entries.length, 6);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  test('managed morning azkar content reflects edited Hive text', () async {
    final firstMorning = (await ManagedAzkarHiveHelper.getEntriesForType(
      AzkarType.morning,
      activeOnly: false,
    )).first;

    await ManagedAzkarHiveHelper.updateEntry(
      firstMorning.copyWith(text: 'ذكر صباح مخصص للاختبار'),
    );

    final resolved = await loadAzkarSet(AzkarType.morning);
    expect(
      resolved.entries.any((entry) => entry.text == 'ذكر صباح مخصص للاختبار'),
      isTrue,
    );
  });
}
