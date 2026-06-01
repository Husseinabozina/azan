import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/models/home_display_mode.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/codegen_loader.g.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/display_direction_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
    await CacheHelper.init();
    UiRotationCubit().selectDisplayDirection(0);
    UiRotationCubit().syncDeviceOrientation(deviceIsLandscape: true);
  });

  testWidgets('shows all four display direction choices', (tester) async {
    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('display-direction-picker')),
      findsOneWidget,
    );
    expect(find.text(LocaleKeys.display_direction_normal.tr()), findsOneWidget);
    expect(
      find.text(LocaleKeys.display_direction_rotate_right.tr()),
      findsOneWidget,
    );
    expect(
      find.text(LocaleKeys.display_direction_upside_down.tr()),
      findsOneWidget,
    );
    expect(
      find.text(LocaleKeys.display_direction_rotate_left.tr()),
      findsOneWidget,
    );
  });

  testWidgets('selecting each option applies the exact target direction', (
    tester,
  ) async {
    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    for (final quarterTurns in <int>[1, 2, 3, 0]) {
      await tester.tap(
        find.byKey(ValueKey('display-direction-option-$quarterTurns')),
      );
      await tester.pumpAndSettle();

      expect(UiRotationCubit().quarterTurns, quarterTurns);
    }
  });

  testWidgets('marks the active direction when opened', (tester) async {
    UiRotationCubit().selectDisplayDirection(2);

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('display-direction-selected-2')),
      findsOneWidget,
    );
    expect(
      find.text(LocaleKeys.display_direction_current.tr()),
      findsOneWidget,
    );
  });

  testWidgets('reopening reflects the previously selected direction', (
    tester,
  ) async {
    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('display-direction-option-3')));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('display-direction-selected-3')),
      findsOneWidget,
    );
  });

  testWidgets('changing direction preserves display-board mode preference', (
    tester,
  ) async {
    await CacheHelper.setHomeDisplayMode(HomeDisplayMode.displayBoard);

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('display-direction-option-1')));
    await tester.pumpAndSettle();

    expect(CacheHelper.getHomeDisplayMode(), HomeDisplayMode.displayBoard);
  });

  testWidgets('shows Arabic labels', (tester) async {
    await tester.pumpWidget(_buildHarness(locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('اتجاه الشاشة'), findsOneWidget);
    expect(find.text('تدوير يمين'), findsOneWidget);
  });

  testWidgets('shows English labels', (tester) async {
    await tester.pumpWidget(_buildHarness(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Screen direction'), findsOneWidget);
    expect(find.text('Rotate left'), findsOneWidget);
  });

  testWidgets('shows Bengali labels', (tester) async {
    await tester.pumpWidget(_buildHarness(locale: const Locale('bn')));
    await tester.pumpAndSettle();

    expect(find.text('স্ক্রিনের দিক'), findsOneWidget);
    expect(find.text('ডানে ঘোরান'), findsOneWidget);
  });

  testWidgets('keeps labels readable in compact and large constraints', (
    tester,
  ) async {
    await tester.pumpWidget(_buildHarness(size: const Size(320, 640)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('display-direction-option-0')),
      findsOneWidget,
    );

    await tester.pumpWidget(_buildHarness(size: const Size(960, 540)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('display-direction-option-0')),
      findsOneWidget,
    );
  });
}

Widget _buildHarness({
  Locale locale = const Locale('en'),
  Size size = const Size(393, 852),
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ar'), Locale('bn')],
    path: 'assets/Lang',
    assetLoader: const CodegenLoader(),
    startLocale: locale,
    fallbackLocale: locale,
    child: Builder(
      builder: (context) {
        return MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: MQScaleInit(
              designSize: size,
              minTextAdapt: true,
              child: const Scaffold(
                body: Center(
                  child: SingleChildScrollView(child: DisplayDirectionPicker()),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
