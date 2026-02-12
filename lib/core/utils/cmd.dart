//  flutter pub run easy_localization:generate -S assets/translations -f keys -o locale_keys.g.dart
// flutter pub run easy_localization:generate -S assets/translations

// flutter packages pub run build_runner build
// dart pub run build_runner build --delete-conflicting-outputs

// flutter build apk --split-per-abi

// package com.example.azan

// import android.app.UiModeManager
// import android.content.Context
// import android.content.res.Configuration
// import io.flutter.embedding.android.FlutterActivity
// import io.flutter.embedding.engine.FlutterEngine
// import io.flutter.plugin.common.MethodChannel

// class MainActivity : FlutterActivity() {

//     private val channelName = "azan/device_kind"` 

//     override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//         super.configureFlutterEngine(flutterEngine)

//         MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
//             .setMethodCallHandler { call, result ->
//                 when (call.method) {
//                     "isAndroidTv" -> result.success(isAndroidTv())
//                     else -> result.notImplemented()
//                 }
//             }
//     }

//     private fun isAndroidTv(): Boolean {
//         val uiModeManager = getSystemService(Context.UI_MODE_SERVICE) as UiModeManager
//         val modeType = uiModeManager.currentModeType

//         val pm = packageManager
//         val hasLeanback = pm.hasSystemFeature("android.software.leanback")
//         val isTelevisionMode = modeType == Configuration.UI_MODE_TYPE_TELEVISION

//         // بعض الأجهزة بتعلن نفسها TV بطرق مختلفة
//         val hasTvFeature =
//             pm.hasSystemFeature("com.google.android.tv") ||
//             pm.hasSystemFeature("android.hardware.type.television")

//         return isTelevisionMode || hasLeanback || hasTvFeature
//     }
// }


// بص انا عاوزك تفهمني بالراحة بلغة اكاديمية وذكية وبسيطة : ايه بالظبط الدنيا شغالة ازاي في ال media query وفي rotatebox.  


// import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
// import 'package:azan/core/helpers/dhikr_hive_helper.dart';
// import 'package:azan/core/models/dhikr_schedule.dart';
// import 'package:azan/core/models/diker.dart';
// import 'package:azan/core/utils/cache_helper.dart';
// import 'package:azan/core/utils/constants.dart';
// import 'package:azan/core/utils/device_kind_helper.dart';
// import 'package:azan/generated/codegen_loader.g.dart';
// import 'package:azan/views/adhkar/adhkar_screen.dart';
// import 'package:azan/views/home/home_screen.dart';
// import 'package:azan/views/home/home_screen_mobile.dart';
// import 'package:azan/views/select_location/select_location_screen.dart';
// import 'package:azan/views/set_Iqama_azan_sound/set_iqama_azan_sound.dart';
// import 'package:azan/views/set_iqama/set_iqama_screen.dart';
// import 'package:dio/dio.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:azan/core/utils/screenutil_flip_ext.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   kind = await DeviceKindHelper.detectBeforeRunApp();
//   if (kind == DeviceKind.tv || kind == DeviceKind.desktop) {
//     await SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//   } else {
//     await SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//   }

//   await CacheHelper.init();
//   if (!CacheHelper.getFirstAppOpen()) {
//     await CacheHelper.setFixedDhikr(fixedDhikr);
//   }
//   await EasyLocalization.ensureInitialized();
//   await Hive.initFlutter();
//   ;
//   // افتح بوكس الأذكار
//   await DhikrHiveHelper.ensureInitialAzkar(azkar);

//   runApp(
//     EasyLocalization(
//       path: 'assets/Lang',
//       supportedLocales: const [Locale('en'), Locale('ar')],
//       saveLocale: true,
//       useOnlyLangCode: true,
//       assetLoader: const CodegenLoader(),
//       startLocale: Locale(CacheHelper.getLang()),
//       fallbackLocale: Locale(CacheHelper.getLang()),

//       child: const MyApp(),
//     ),
//   );
// }

// final RouteObserver<ModalRoute<void>> routeObserver =
//     RouteObserver<ModalRoute<void>>();

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // return

//     Widget widget = ScreenUtilInit(
//       designSize: kind == DeviceKind.tv || kind == DeviceKind.desktop
//           ? Size(852, 393)
//           : const Size(393, 852),
//       minTextAdapt: true,
//       useInheritedMediaQuery: true,
//       splitScreenMode: true,

//       builder: (context, child) {
//         return BlocProvider(
//           create: (context) => AppCubit(Dio()),
//           child: MaterialApp(
//             debugShowCheckedModeBanner: false,
//             localizationsDelegates: context.localizationDelegates,
//             supportedLocales: context.supportedLocales,
//             locale: context.locale,
//             localeResolutionCallback: (locale, supportedLocales) {
//               return supportedLocales.firstWhere(
//                 (supportedLocale) =>
//                     supportedLocale.languageCode == locale!.languageCode,
//                 orElse: () => supportedLocales.first,
//               );
//             },

//             theme: ThemeData(
//               fontFamily: CacheHelper.getTextsFontFamily(),

//               // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//             ),
//             builder: (_, child) {
//               return child!;
//             },
//             home: nextScreen,
//             // home: SetIqamaAzanSoundScreen(),
//           ),
//         );
//       },
//     );

//     if (kind == DeviceKind.tv || kind == DeviceKind.desktop) {
//       return RotatedBox(quarterTurns: 3, child: widget);
//     } else {
//       return widget;
//     }
//   }
// }
