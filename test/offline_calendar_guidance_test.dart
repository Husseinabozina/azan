import 'dart:io';

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/models/city_option.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/codegen_loader.g.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
    await CacheHelper.init();
    await CacheHelper.setLang('en');
    await CacheHelper.setCity(
      const CityOption(
        nameAr: 'مكة المكرمة',
        nameEn: 'Mecca',
        bundleId: 'mecca',
      ),
    );

    await Hive.close();
    tempDir = await Directory.systemTemp.createTemp('offline_guidance');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget buildHarness(Widget child) {
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
              data: const MediaQueryData(size: Size(393, 852)),
              child: MQScaleInit(
                designSize: const Size(393, 852),
                minTextAdapt: true,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  testWidgets('unsupported Hijri year emits an out-of-range guidance state', (
    tester,
  ) async {
    final cubit = AppCubit(dio: Dio());

    await tester.pumpWidget(buildHarness(const SizedBox.shrink()));
    await tester.pumpAndSettle();

    final nextUnsupportedYear =
        cubit.currentSupportedScheduleWindow.finalSupportedHijriYear + 1;
    final stateFuture = expectLater(
      cubit.stream,
      emits(isA<OfflineCalendarOutOfRange>()),
    );

    final result = await tester.runAsync(
      () => cubit.loadSupportedHijriYearPrayerCalendar(
        hijriYear: nextUnsupportedYear,
      ),
    );

    await stateFuture;
    expect(result, isEmpty);
  });
}
