import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/models/city_option.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/core/utils/selection_dialoge.dart';
import 'package:azan/generated/codegen_loader.g.dart';
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
    await CacheHelper.setLang('en');
    UiRotationCubit().changeIsLandscape(false);
  });

  Widget buildHarness(Widget child, {Size size = const Size(393, 852)}) {
    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('bn')],
      path: 'assets/Lang',
      assetLoader: const CodegenLoader(),
      startLocale: const Locale('en'),
      fallbackLocale: const Locale('en'),
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
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  testWidgets('offline city picker opens and returns the selected city', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cities = <CityOption>[
      const CityOption(
        nameAr: 'المدينة المنورة',
        nameEn: 'Medina',
        bundleId: 'medina',
        nameAliases: ['Madinah'],
      ),
      const CityOption(
        nameAr: 'مكة المكرمة',
        nameEn: 'Mecca',
        bundleId: 'mecca',
        nameAliases: ['Makkah'],
      ),
    ];

    CityOption? selectedCity;

    await tester.pumpWidget(
      buildHarness(
        Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    showSaudiCityPickerDialog(context, cities, (item) {
                      selectedCity = item as CityOption;
                    });
                  },
                  child: const Text('Open picker'),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();

    expect(find.text('Mecca'), findsOneWidget);
    expect(find.text('Medina'), findsOneWidget);

    await tester.tap(find.text('Mecca'));
    await tester.pumpAndSettle();

    expect(selectedCity?.bundleId, 'mecca');
    expect(selectedCity?.nameAliases, contains('Makkah'));
  });
}
