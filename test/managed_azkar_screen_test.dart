import 'dart:io';

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/helpers/managed_azkar_hive_helper.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/codegen_loader.g.dart';
import 'package:azan/views/managed_azkar/managed_azkar_screen.dart';
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

  setUpAll(() async {
    AppCubit.configure(dio: Dio());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
    await CacheHelper.init();

    await Hive.close();
    tempDir = await Directory.systemTemp.createTemp('managed_azkar_screen');
    Hive.init(tempDir.path);
    await ManagedAzkarHiveHelper.ensureInitialAzkarSets();
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
      startLocale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      child: Builder(
        builder: (context) {
          return BlocProvider.value(
            value: AppCubit(),
            child: MaterialApp(
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
            ),
          );
        },
      ),
    );
  }

  testWidgets('managed azkar screen supports switching sections', (
    tester,
  ) async {
    await tester.pumpWidget(buildHarness(const ManagedAzkarScreen()));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('managed-azkar-type-morning')),
      findsOneWidget,
    );
    expect(find.text('أذكار الصباح'), findsWidgets);

    tester
        .widget<ChoiceChip>(
          find.byKey(const ValueKey('managed-azkar-type-evening')),
        )
        .onSelected
        ?.call(true);
    await tester.pumpAndSettle();
    expect(find.text('أذكار المساء'), findsWidgets);

    tester
        .widget<ChoiceChip>(
          find.byKey(const ValueKey('managed-azkar-type-afterPrayer')),
        )
        .onSelected
        ?.call(true);
    await tester.pumpAndSettle();
    expect(find.text('أذكار بعد الصلاة'), findsWidgets);
  });
}
