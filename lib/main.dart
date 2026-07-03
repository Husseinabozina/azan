import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/helpers/dhikr_hive_helper.dart';
import 'package:azan/core/helpers/managed_azkar_hive_helper.dart';
import 'package:azan/core/helpers/slide_hive_helper.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/device_kind_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/codegen_loader.g.dart';
import 'package:azan/views/splash/splash_screen.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dio = Dio(); // أو DioService بتاعك
  AppCubit.configure(dio: dio);
  // await appCubit.init();
  kind = await DeviceKindHelper.detectBeforeRunApp();

  await CacheHelper.init();
  if (!CacheHelper.getFirstAppOpen()) {
    await CacheHelper.setFixedDhikr(fixedDhikr);
  }
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  await DhikrHiveHelper.ensureInitialAzkar(azkar);
  await ManagedAzkarHiveHelper.ensureInitialAzkarSets();
  await SlideHiveHelper.ensureInitialSlides(ayat);

  runApp(
    EasyLocalization(
      path: 'assets/Lang',
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('bn')],
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
  @override
  void initState() {
    cubit = UiRotationCubit();
    cubit.changeIsLandscape(false);

    // widget ensure initialized

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: cubit, //
        ),
        BlocProvider(create: (context) => AppCubit()..init()),
      ],
      child: BlocConsumer<UiRotationCubit, int>(
        bloc: cubit,
        listener: (context, state) {},
        builder: (context, state) {
          final orientation = MediaQuery.of(context).orientation;
          final deviceIsLandscape = orientation == Orientation.landscape;
          cubit.syncDeviceOrientation(deviceIsLandscape: deviceIsLandscape);

          final quarter = cubit.quarterTurns;
          final effectiveIsLandscape = cubit.isLandscapeForDevice(
            deviceIsLandscape,
          );

          final designSize = effectiveIsLandscape
              ? const Size(960, 540)
              : const Size(393, 852);

          final app = MQScaleInit(
            key: ValueKey('${designSize.width}x${designSize.height}-$quarter'),
            designSize: designSize,
            minTextAdapt: true,
            child: Builder(
              builder: (context) {
                final baseTheme = ThemeData(
                  fontFamily: CacheHelper.getTextsFontFamily(),
                );

                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  theme: baseTheme.copyWith(
                    textTheme: AppTheme.withDefaultTextShadow(
                      baseTheme.textTheme,
                    ),
                    primaryTextTheme: AppTheme.withDefaultTextShadow(
                      baseTheme.primaryTextTheme,
                    ),
                  ),
                  home: const SplashScreen(),
                  //  AzkarView(azkarType: AzkarType.evening),
                  // AzkarView(azkarType: AzkarType.afterPrayer),
                );
              },
            ),
          );

          // Manual quarter-turns are honored on every screen. With quarter=0,
          // phones still follow the real device orientation normally.
          if (quarter == 0) return app;

          return RotatedMediaQueryX(quarterTurns: quarter, child: app);
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

class RotatedMediaQueryX extends StatelessWidget {
  const RotatedMediaQueryX({
    super.key,
    required this.quarterTurns,
    required this.child,
  });

  final int quarterTurns; // 0,1,2,3
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final q = quarterTurns % 4;
    if (q == 0) return child;

    final baseMq =
        MediaQuery.maybeOf(context) ??
        MediaQueryData.fromView(
          View.maybeOf(context) ??
              WidgetsBinding.instance.platformDispatcher.implicitView!,
        );

    EdgeInsets rotateInsets(EdgeInsets e) {
      final t = e.top, r = e.right, b = e.bottom, l = e.left;
      // RotatedBox rotates CLOCKWISE
      if (q == 1) return EdgeInsets.fromLTRB(b, l, t, r);
      if (q == 2) return EdgeInsets.fromLTRB(r, b, l, t);
      if (q == 3) return EdgeInsets.fromLTRB(t, r, b, l);
      return e;
    }

    final s = baseMq.size;

    final rotatedMq = baseMq.copyWith(
      size: q.isOdd ? Size(s.height, s.width) : s,
      padding: rotateInsets(baseMq.padding),
      viewPadding: rotateInsets(baseMq.viewPadding),
      viewInsets: rotateInsets(baseMq.viewInsets),
      systemGestureInsets: rotateInsets(baseMq.systemGestureInsets),
    );

    return MediaQuery(
      data: rotatedMq,
      child: RotatedBox(quarterTurns: q, child: child),
    );
  }
}
