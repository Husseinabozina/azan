import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/views/home/components/legacy_mosque_top_cluster.dart';
import 'package:azan/views/home/components/mosque_shape_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadTestFonts();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await CacheHelper.init();
    await CacheHelper.setTextsFontFamily(amiriFont);
    await CacheHelper.setTimesFontFamily(freeSerifBoldFont);
  });

  testWidgets('authored band heights fit representative top text metrics', (
    tester,
  ) async {
    const size = Size(393, 360);
    await tester.pumpWidget(
      _buildHarness(
        profile: MosqueArchProfile.denseArch,
        withWeather: true,
        size: size,
      ),
    );
    await tester.pumpAndSettle();

    final spec = legacyTopClusterSpecForProfile(MosqueArchProfile.denseArch);
    final weekdayHeight = legacyMosqueMeasureSingleLineHeight(
      text: 'الأربعاء',
      style: legacyMosqueWeekdayTextStyle(),
      textDirection: TextDirection.rtl,
    );
    final hijriHeight = legacyMosqueMeasureSingleLineHeight(
      text: '1447 شوال 20',
      style: legacyMosqueHijriTextStyle(),
      textDirection: TextDirection.rtl,
    );
    final dateHeight = legacyMosqueMeasureSingleLineHeight(
      text: '08/04/2026',
      style: legacyMosqueGregorianTextStyle(),
      textDirection: TextDirection.rtl,
    );
    final countdownHeight = legacyMosqueMeasureSingleLineHeight(
      text: '03:23:45',
      style: legacyMosqueCountdownTextStyle(isUrgent: false),
      textDirection: TextDirection.ltr,
    );
    final leftForHeight = legacyMosqueMeasureSingleLineHeight(
      text: 'المتبقي للفجر',
      style: legacyMosqueLeftForTextStyle(),
      textDirection: TextDirection.rtl,
    );

    expect(
      weekdayHeight,
      lessThan(spec.weekdayHeight - (spec.weekdayVerticalPadding * 2)),
    );
    expect(
      hijriHeight,
      lessThan(spec.hijriHeight - (spec.hijriVerticalPadding * 2)),
    );
    expect(
      dateHeight,
      lessThan(spec.metaHeight - (spec.metaVerticalPadding * 2)),
    );
    expect(
      countdownHeight + leftForHeight + spec.countdownBottomGap,
      lessThan(spec.metaHeight - (spec.metaVerticalPadding * 2)),
    );
  });

  testWidgets('dense cluster builds safely with weather stub', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        profile: MosqueArchProfile.denseArch,
        withWeather: true,
        size: const Size(393, 360),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LegacyMosqueTopCluster), findsOneWidget);
    expect(find.text('الأربعاء'), findsOneWidget);
    expect(find.text('1447 شوال 20'), findsOneWidget);
    expect(find.text('08/04/2026'), findsOneWidget);
    expect(find.text('03:23:45'), findsOneWidget);
    expect(find.text('المتبقي للفجر'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide cluster builds safely without weather stub', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        profile: MosqueArchProfile.wideArch,
        withWeather: false,
        size: const Size(393, 360),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LegacyMosqueTopCluster), findsOneWidget);
    expect(find.text('الأربعاء'), findsOneWidget);
    expect(find.text('1447 شوال 20'), findsOneWidget);
    expect(find.text('08/04/2026'), findsOneWidget);
    expect(find.text('03:23:45'), findsOneWidget);
    expect(find.text('المتبقي للفجر'), findsOneWidget);
    expect(find.byKey(const ValueKey('weather-stub')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dense top cluster golden', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        profile: MosqueArchProfile.denseArch,
        withWeather: true,
        size: const Size(393, 360),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const ValueKey('top-cluster-surface')),
      matchesGoldenFile('goldens/legacy_mosque_top_cluster_dense.png'),
    );
  });

  testWidgets('wide top cluster golden', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        profile: MosqueArchProfile.wideArch,
        withWeather: false,
        size: const Size(393, 360),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const ValueKey('top-cluster-surface')),
      matchesGoldenFile('goldens/legacy_mosque_top_cluster_wide.png'),
    );
  });
}

Future<void> _loadTestFonts() async {
  final amiri = FontLoader('Amiri')
    ..addFont(rootBundle.load('assets/fonts/AmiriRegular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/AmiriBold.ttf'));
  final freeSerifBold = FontLoader('FreeSerifBold')
    ..addFont(rootBundle.load('assets/fonts/FreeSerifBold.ttf'));

  await Future.wait([amiri.load(), freeSerifBold.load()]);
}

Widget _buildHarness({
  required MosqueArchProfile profile,
  required bool withWeather,
  required Size size,
}) {
  final clipSpec = specFor(
    profile == MosqueArchProfile.denseArch
        ? 'assets/images/VR-2.jpg'
        : 'assets/images/VR-9.jpg',
  )!;

  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: MQScaleInit(
          designSize: size,
          minTextAdapt: true,
          child: Builder(
            builder: (context) {
              final clusterSpec = legacyTopClusterSpecForProfile(profile);
              return Center(
                child: RepaintBoundary(
                  key: const ValueKey('top-cluster-surface'),
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: ColoredBox(
                      color: const Color(0xFF8D4D27),
                      child: ClipPath(
                        clipper: MosqueBackgroundClipper(clipSpec),
                        child: ColoredBox(
                          color: const Color(0xFF0D53D5),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Column(
                                children: [
                                  SizedBox(
                                    height:
                                        constraints.maxHeight *
                                        clusterSpec.topInsetRatio,
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: clusterSpec.clusterWidthFactor,
                                    child: LegacyMosqueTopCluster(
                                      spec: clusterSpec,
                                      weekdayText: 'الأربعاء',
                                      hijriText: '1447 شوال 20',
                                      gregorianText: '08/04/2026',
                                      countdownText: '03:23:45',
                                      leftForText: 'المتبقي للفجر',
                                      isCounterUrgent: false,
                                      weatherWidget: withWeather
                                          ? const _WeatherStub()
                                          : null,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

class _WeatherStub extends StatelessWidget {
  const _WeatherStub();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('weather-stub'),
      width: 74.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFC14D),
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}
