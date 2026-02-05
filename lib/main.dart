import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/helpers/dhikr_hive_helper.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/device_kind_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart' as flip;
import 'package:azan/core/utils/screenutil_flip_ext.dart';
import 'package:azan/generated/codegen_loader.g.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  kind = await DeviceKindHelper.detectBeforeRunApp();

  await CacheHelper.init();
  if (!CacheHelper.getFirstAppOpen()) {
    await CacheHelper.setFixedDhikr(fixedDhikr);
  }
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
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
  @override
  void initState() {
    cubit = UiRotationCubit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isLargeScreen(kind) && !CacheHelper.getFirstAppOpen()) {
        cubit.changeIsLandscape(true);
      }
    });

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
        BlocProvider(create: (context) => AppCubit(Dio())),
      ],
      child: BlocConsumer<UiRotationCubit, bool>(
        bloc: cubit,
        listener: (context, state) {},
        builder: (context, state) {
          'state  state $state'.log();
          int quarter = 0;
          // Size(960, 540);
          // Size(393, 852);
          //  Size(852, 393);
          Size designSize = state ? const Size(960, 540) : const Size(393, 852);
          "designSize designSize ${designSize.toString()}".log();

          if (MediaQuery.of(context).orientation == Orientation.portrait &&
              !state) {
            designSize = const Size(393, 852);
            quarter = 0;
            '1'.log();
          } else if (MediaQuery.of(context).orientation ==
                  Orientation.portrait &&
              state) {
            designSize = const Size(960, 540);
            quarter = 1;
            '2'.log();
          } else if (MediaQuery.of(context).orientation ==
                  Orientation.landscape &&
              state) {
            designSize = const Size(960, 540);
            quarter = 0;
            '3'.log();
          } else if (MediaQuery.of(context).orientation ==
                  Orientation.landscape &&
              !state) {
            designSize = const Size(393, 852);
            quarter = 1;
            '4'.log();
          }
          // if (!isLargeScreen(kind) &&
          //     MediaQuery.of(context).orientation == Orientation.landscape &&
          //     state == true) {
          //   '1'.log();
          // designSize = const Size(960, 540);
          //   cubit.changeIsLandscape(true);
          // } else if (!isLargeScreen(kind) &&
          //     MediaQuery.of(context).orientation == Orientation.portrait &&
          //     !state) {
          //   '2'.log();
          //   designSize = const Size(393, 852);
          //   cubit.changeIsLandscape(false);
          // } else if (isLargeScreen(kind) &&
          //     MediaQuery.of(context).orientation == Orientation.portrait &&
          //     !state) {
          //   '3'.log();
          //   designSize = const Size(393, 852);
          // } else if (isLargeScreen(kind) &&
          //     MediaQuery.of(context).orientation == Orientation.portrait &&
          //     cubit.isLandscape()) {
          //   '4'.log();
          //   designSize = const Size(540, 960);
          // } else if (isLargeScreen(kind) && state == false) {
          //   '5'.log();
          //   // on 2
          //   designSize = const Size(852, 393);
          // } else if (isLargeScreen(kind) && state) {
          //   '6'.log();
          //   // on
          //   designSize = const Size(960, 540);
          // } else if (!isLargeScreen(kind) && state) {
          //   '7'.log();
          //   designSize = const Size(540, 960);
          // } else if (!isLargeScreen(kind) && state == false) {
          //   '8'.log();
          //   designSize = const Size(393, 852);
          // }

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
          // if (!isLargeScreen(kind) &&
          //     MediaQuery.of(context).orientation == Orientation.landscape &&
          //     !cubit.isLandscape()) {
          //   'nnn'.log();
          //   quarter = 3;
          //   // cubit.changeIsLandscape(true);
          // } else if (!isLargeScreen(kind) &&
          //     MediaQuery.of(context).orientation == Orientation.portrait) {
          //   quarter = 0;
          //   // cubit.changeIsLandscape(false);
          // } else if (isLargeScreen(kind) &&
          //     MediaQuery.of(context).orientation == Orientation.portrait &&
          //     !cubit.isLandscape()) {
          //   quarter = 0;
          //   // cubit.changeIsLandscape(false);
          // } else if (isLargeScreen(kind) &&
          //     MediaQuery.of(context).orientation == Orientation.portrait &&
          //     cubit.isLandscape()) {
          //   quarter = 3;
          // } else if ((isLargeScreen(kind) && !cubit.isLandscape())) {
          //   quarter = 3;
          // } else if ((!isLargeScreen(kind) && cubit.isLandscape())) {
          //   quarter = 3;
          // }
          // final bool portraitDesign = designSize.height > designSize.width;
          // final bool rotated90 = false;
          // flip.SUFlip.enabled = rotated90 && portraitDesign;
          final widget = RotatedMediaQueryX(
            quarterTurns: quarter,
            child: MQScaleInit(
              key: ValueKey('${designSize.width}x${designSize.height}'),
              designSize: designSize,

              minTextAdapt: true,
              // useInheritedMediaQuery: true,

              // splitScreenMode: true,
              child: MaterialApp(
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
              ),
            ),
          );

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
