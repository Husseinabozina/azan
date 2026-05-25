import 'dart:io';

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/codegen_loader.g.dart';
import 'package:azan/views/prayer_calendar/hijri_prayer_calendar_screen.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    await Hive.close();
    tempDir = await Directory.systemTemp.createTemp('hijri_calendar_window');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget buildHarness(Widget child, {Size size = const Size(900, 1400)}) {
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

  testWidgets('calendar uses Hijri year controls and Hijri month labels', (
    tester,
  ) async {
    final cubit = AppCubit(dio: Dio());

    await tester.runAsync(() async {
      final cities = await cubit.loadOfflineCityOptions();
      final mecca = cities.firstWhere((entry) => entry.bundleId == 'mecca');
      cubit.setCity(mecca);
      await cubit.loadSupportedHijriYearPrayerCalendar(
        hijriYear: cubit.currentSupportedScheduleWindow.currentHijriYear,
      );
    });

    await tester.pumpWidget(
      buildHarness(
        BlocProvider<AppCubit>.value(
          value: cubit,
          child: const HijriPrayerCalendarScreen(forceLargeScreenLayout: false),
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('Umm al-Qura calendar'), findsWidgets);
    expect(find.text('Gregorian year'), findsNothing);
  });
}
