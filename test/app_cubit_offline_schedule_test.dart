import 'dart:io';

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/helpers/prayer_calendar_helper.dart';
import 'package:azan/core/helpers/prayer_calendar_hive_helper.dart';
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
    tempDir = await Directory.systemTemp.createTemp('app_cubit_offline');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
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

  testWidgets('saved bundle city hydrates today from the official bundle', (
    tester,
  ) async {
    final cubit = AppCubit(dio: Dio());
    BuildContext? buildContext;

    await tester.pumpWidget(
      buildHarness(
        Builder(
          builder: (context) {
            buildContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await cubit.initializePrayerTimes(context: buildContext!);
    });
    await tester.pumpAndSettle();

    expect(cubit.getCity()?.bundleId, 'mecca');
    expect(cubit.hasPrayerSchedule, isTrue);

    final prayers = cubit.prayers(buildContext!);
    expect(prayers.first.dateTime, isNotNull);

    final stored = await PrayerCalendarHiveHelper.getDay(
      cityKey: PrayerCalendarHelper.cityKeyFor(city: cubit.getCity()),
      date: PrayerCalendarHelper.dateOnly(DateTime.now()),
    );
    expect(stored, isNotNull);
    expect(stored!.officialSourceToken, isNotNull);
  });
}
