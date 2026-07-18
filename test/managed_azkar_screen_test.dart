import 'dart:io';
import 'dart:ui' as ui;

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/helpers/managed_azkar_hive_helper.dart';
import 'package:azan/core/models/azkar_type.dart';
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

  Future<void> pumpManagedScreenFrame(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
  }

  testWidgets('managed azkar screen supports switching sections', (
    tester,
  ) async {
    final morningEntries = await ManagedAzkarHiveHelper.getEntriesForType(
      AzkarType.morning,
      activeOnly: false,
    );
    final firstMorning = morningEntries.first;

    await tester.pumpWidget(buildHarness(const ManagedAzkarScreen()));
    await pumpManagedScreenFrame(tester);

    expect(
      find.byKey(const ValueKey('managed-azkar-type-morning')),
      findsOneWidget,
    );
    expect(find.text('أذكار الصباح'), findsWidgets);
    expect(
      find.byKey(ValueKey('managed-azkar-entry-drag-${firstMorning.id}')),
      findsOneWidget,
    );
    expect(find.byType(ReorderableListView), findsOneWidget);
    final firstTextFinder = find.byKey(
      ValueKey('managed-azkar-entry-text-${firstMorning.id}'),
    );
    final firstText = tester.widget<Text>(firstTextFinder);
    expect(firstText.textDirection, ui.TextDirection.rtl);

    tester
        .widget<ChoiceChip>(
          find.byKey(const ValueKey('managed-azkar-type-evening')),
        )
        .onSelected
        ?.call(true);
    await pumpManagedScreenFrame(tester);
    expect(find.text('أذكار المساء'), findsWidgets);

    tester
        .widget<ChoiceChip>(
          find.byKey(const ValueKey('managed-azkar-type-afterPrayer')),
        )
        .onSelected
        ?.call(true);
    await pumpManagedScreenFrame(tester);
    expect(find.text('أذكار بعد الصلاة'), findsWidgets);
  });

  testWidgets('morning and evening editors expose prayer selector chips', (
    tester,
  ) async {
    await tester.pumpWidget(buildHarness(const ManagedAzkarScreen()));
    await pumpManagedScreenFrame(tester);

    await tester.tap(find.text('إضافة جديد').first);
    await pumpManagedScreenFrame(tester);
    expect(find.text('استيراد جماعي'), findsOneWidget);
    expect(find.text('استيراد من ملف'), findsOneWidget);
    expect(find.text('كتابة عنصر يدوي'), findsOneWidget);
    expect(find.text('لصق جماعي'), findsNothing);
    expect(find.text('الصلوات المعنية'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('managed-azkar-prayer-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('managed-azkar-prayer-6')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('managed-azkar-prayer-7')),
      findsOneWidget,
    );
    Navigator.of(
      tester.element(find.byType(ManagedAzkarScreen)),
      rootNavigator: true,
    ).pop();
    await pumpManagedScreenFrame(tester);

    tester
        .widget<ChoiceChip>(
          find.byKey(const ValueKey('managed-azkar-type-evening')),
        )
        .onSelected
        ?.call(true);
    await pumpManagedScreenFrame(tester);

    await tester.tap(find.text('إضافة جديد').first);
    await pumpManagedScreenFrame(tester);
    expect(find.text('الصلوات المعنية'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('managed-azkar-prayer-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('managed-azkar-prayer-6')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('managed-azkar-prayer-7')),
      findsOneWidget,
    );
  });
}
