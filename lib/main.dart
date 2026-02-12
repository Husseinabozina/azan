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
import 'package:azan/views/home/components/azkar_view.dart';
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
  final dio = Dio(); // أو DioService بتاعك
  AppCubit.configure(dio: dio);
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
        BlocProvider(create: (context) => AppCubit()),
      ],
      child: BlocConsumer<UiRotationCubit, bool>(
        bloc: cubit,
        listener: (context, state) {},
        builder: (context, state) {
          final isMobile = !isLargeScreen(kind);
          final orientation = MediaQuery.of(context).orientation;
          final deviceIsLandscape = orientation == Orientation.landscape;

          // ✅ على الموبايل: خلّي isLandscape = orientation الحقيقي
          if (isMobile) {
            if (state != deviceIsLandscape) {
              // مهم: منع loop
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (cubit.state != deviceIsLandscape) {
                  cubit.changeIsLandscape(deviceIsLandscape);
                }
              });
            }
          }

          int quarter = 0;
          late Size designSize;

          if (isMobile) {
            // ✅ موبايل: مفيش Rotation وهمي نهائيًا
            quarter = 0;

            // اختار designSize حسب orientation الحقيقي
            designSize = deviceIsLandscape
                ? const Size(960, 540)
                : const Size(393, 852);
          } else {
            // ✅ LargeScreen: النظام القديم بتاعك (state هو اللي بيحدد UI rotation)
            // state هنا معناها: "isLandscape UI"
            if (orientation == Orientation.portrait && !state) {
              designSize = const Size(393, 852);
              quarter = 0;
            } else if (orientation == Orientation.portrait && state) {
              designSize = const Size(960, 540);
              quarter = 1;
            } else if (orientation == Orientation.landscape && state) {
              designSize = const Size(960, 540);
              quarter = 0;
            } else {
              designSize = const Size(393, 852);
              quarter = 1;
            }
          }

          final app = MQScaleInit(
            key: ValueKey('${designSize.width}x${designSize.height}'),
            designSize: designSize,
            minTextAdapt: true,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: ThemeData(fontFamily: CacheHelper.getTextsFontFamily()),
              home: AzkarView(azkarType: AzkarType.afterPrayer),
            ),
          );

          // ✅ على الموبايل: رجّع app بدون RotatedMediaQueryX
          if (isMobile) return app;

          // ✅ على الشاشات الكبيرة: لف زي ما أنت عايز
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
