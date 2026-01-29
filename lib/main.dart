import 'dart:async';

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_state.dart';
import 'package:azan/core/helpers/dhikr_hive_helper.dart';
import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/models/diker.dart';
import 'package:azan/core/models/prayer.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/device_kind_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/generated/codegen_loader.g.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/adhkar/adhkar_screen.dart';
import 'package:azan/views/home/azan_prayer_screen.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:azan/views/select_location/select_location_screen.dart';
import 'package:azan/views/set_Iqama_azan_sound/set_iqama_azan_sound.dart';
import 'package:azan/views/set_iqama/set_iqama_screen.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  kind = await DeviceKindHelper.detectBeforeRunApp();
  // if (isLargeScreen(kind)) {
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.landscapeLeft,
  //   DeviceOrientation.landscapeRight,
  // ]);
  // } else {
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  //   // DeviceOrientation.landscapeLeft,
  //   // DeviceOrientation.landscapeRight,
  // ]);
  // }

  await CacheHelper.init();
  if (!CacheHelper.getFirstAppOpen()) {
    await CacheHelper.setFixedDhikr(fixedDhikr);
  }
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  ;
  // افتح بوكس الأذكار
  await DhikrHiveHelper.ensureInitialAzkar(azkar);

  runApp(
    EasyLocalization(
      path: 'assets/Lang',
      supportedLocales: const [Locale('en'), Locale('ar')],
      saveLocale: true,
      useOnlyLangCode: true,
      assetLoader: const CodegenLoader(),
      startLocale: Locale(CacheHelper.getLang()),
      fallbackLocale: Locale(CacheHelper.getLang()),

      child: const MyApp(),
    ),
  );
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UiRotationCubit cubit = UiRotationCubit();

  bool isStarted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!isStarted) {
      if (isLargeScreen(kind) &&
          MediaQuery.of(context).orientation == Orientation.landscape) {
        '(isLargeScreen(kind) && MediaQuery.of(context).orientation == Orientation.landscape) ${(isLargeScreen(kind) && MediaQuery.of(context).orientation == Orientation.landscape)}'
            .log();
        cubit.changeIsLandscape(true);
      }
      setState(() {
        isStarted = true;
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // return

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: cubit, //
        ),
        BlocProvider(create: (context) => AppCubit(Dio())),
      ],
      child: BlocConsumer<UiRotationCubit, bool>(
        bloc: cubit,
        listener: (context, state) {},
        builder: (context, state) {
          Size designSize = const Size(540, 960);

          if (!isLargeScreen(kind) &&
              MediaQuery.of(context).orientation == Orientation.landscape) {
            designSize = const Size(960, 540);
          } else if (!isLargeScreen(kind) &&
              MediaQuery.of(context).orientation == Orientation.portrait) {
            designSize = const Size(393, 852);
          } else if (isLargeScreen(kind) &&
              MediaQuery.of(context).orientation == Orientation.portrait &&
              !cubit.isLandscape()) {
            '111111'.log();
            designSize = const Size(393, 852);
          } else if (isLargeScreen(kind) &&
              MediaQuery.of(context).orientation == Orientation.portrait &&
              cubit.isLandscape()) {
            designSize = const Size(540, 960);
          } else if (isLargeScreen(kind) && state == false) {
            // on 2
            designSize = const Size(852, 393);
          } else if (isLargeScreen(kind) && state) {
            // on
            designSize = const Size(960, 540);
          } else if (!isLargeScreen(kind) && state) {
            designSize = const Size(540, 960);
          } else if (!isLargeScreen(kind) && state == false) {
            designSize = const Size(393, 852);
          }

          // else if (isLargeScreen&& )
          // else if (!isLargeScreen(kind))

          // if (!cubit.isLandscape() && isLargeScreen(kind)) {
          //   designSize = const Size(393, 852);
          // } else if (!cubit.isLandscape() && !isLargeScreen(kind)) {
          //   designSize = const Size(393, 852);
          // } else if (cubit.isLandscape() && isLargeScreen(kind)) {
          //   designSize = const Size(960, 540);
          // } else if (cubit.isLandscape() && !isLargeScreen(kind)) {
          //   designSize = const Size(960, 540);
          // } else {
          //   designSize = const Size(393, 852);
          // }

          final widget = ScreenUtilInit(
            key: ValueKey('${designSize.width}x${designSize.height}'),
            designSize: designSize,

            minTextAdapt: true,
            useInheritedMediaQuery: true,
            splitScreenMode: true,

            builder: (context, child) {
              designSize.toString().log();
              MediaQuery.of(context).size.toString().log();
              cubit.isLandscape().toString().log();

              return MaterialApp(
                debugShowCheckedModeBanner: false,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                localeResolutionCallback: (locale, supportedLocales) {
                  return supportedLocales.firstWhere(
                    (supportedLocale) =>
                        supportedLocale.languageCode == locale!.languageCode,
                    orElse: () => supportedLocales.first,
                  );
                },

                theme: ThemeData(
                  fontFamily: CacheHelper.getTextsFontFamily(),

                  // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                ),
                builder: (_, child) {
                  return child!;
                },
                home: HomeScreen(),
                // home: SetIqamaAzanSoundScreen(),
              );
            },
          );
          if (!isLargeScreen(kind) &&
              MediaQuery.of(context).orientation == Orientation.landscape) {
            cubit.changeIsLandscape(true);
            return RotatedBox(quarterTurns: 0, child: widget);
          } else if (!isLargeScreen(kind) &&
              MediaQuery.of(context).orientation == Orientation.portrait) {
            cubit.changeIsLandscape(false);
            return RotatedBox(quarterTurns: 0, child: widget);
          } else if (isLargeScreen(kind) &&
              MediaQuery.of(context).orientation == Orientation.portrait &&
              !cubit.isLandscape()) {
            // cubit.changeIsLandscape(false);
            return RotatedBox(quarterTurns: 0, child: widget);
          } else if (isLargeScreen(kind) &&
              MediaQuery.of(context).orientation == Orientation.portrait &&
              cubit.isLandscape()) {
            return RotatedBox(quarterTurns: 3, child: widget);
          } else if ((isLargeScreen(kind) && !cubit.isLandscape())) {
            return RotatedBox(quarterTurns: 3, child: widget);
          } else if ((!isLargeScreen(kind) && cubit.isLandscape())) {
            return RotatedBox(quarterTurns: 3, child: widget);
          }

          return widget;
        },
      ),
    );

    // return RotatedBox(quarterTurns: 3, child: widget);

    // if (!cubit.isLandscape() && isLargeScreen(kind)) {
    // return RotatedBox(quarterTurns: 3, child: widget);
    // } else if (!cubit.isLandscape() && !isLargeScreen(kind)) {
    //   return widget;
    // } else if (cubit.isLandscape() && isLargeScreen(kind)) {
    //   return widget;
    // } else if (cubit.isLandscape() && !isLargeScreen(kind)) {

    // } else {
    //   return widget;
    // }
  }
}
