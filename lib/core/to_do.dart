// اوعي تنسي تهيش ال homeScreenLandscape

// عيد هندلة الاذكار تاني وصفحة الاذكار واشكالها وشوف ابوعبدالرحمن عاوز ايه فيها

//// to do :
/// كبر العداد 
/// ظبط مكان الtemperature
/// خلي كله small في ال copyright 
/// موضوع لوحة المفاتيح 
/// ادارة اعلانات المسجد  مكان اللوحات العرض وكل الاشياء اللي فيها نفس الاسم
/// وشيل تفعيل لوحات العرض اللي بره 
/// timer للاعلان اللي مكان الرئيسية
/// خيارات اضافية تكون اول واحدة في الخيارات بعد اسم المسجدp
// / تقويم مواقيت الهحري ظبط الالوان  وضيف السنوات القادمة وامكانية تعديلها و تعديل الصلوات يكون مباشر ويكون واحد زي + و ـ  ايوة ضيف + و -  ,, السنة لحد ٢٠٣٠
/// ظبط الاسهم اللي مش مظبوطة
/// دعاء بعد الاذان ظبطه
/// كبر العداد ويكون اوقات الصلاة والعداد اهم حاجة ولو عاوز تشيل شئ او تعدل شئ عشان العداد يكون كبير
/// وضع اسماء الصلوات في المنتصف في العرض العمودي
/// الشاشة السوداء يشوف ينعكس شكله : ممكن يكون فيها اضاءة او شئ او نسيب الخلفية فقط او اعملها شاشة مخصصة سادة او بسيطة زي الشاشة الاساسية او اقصد الخلفية الاساسية
/// بص وضع الصلاة والشغل بتعها يشتغل في وقتها حتي لو انا مش فاتح التطبيق
/// شوف لو ينفع تحفظ  شئ خاص
/// اذا اردت مواقيت الصلاة بتاعة الدمام مثلا ممكن احفظها تروح للمسجد جاهزة بدل ما يعدل هناك 
// / ادارة مواقيت الصلاة حسبت توقيت أم القري  ,,مكان توقيت الهجري







// import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
// import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
// import 'package:azan/core/helpers/dhikr_hive_helper.dart';
// import 'package:azan/core/helpers/managed_azkar_hive_helper.dart';
// import 'package:azan/core/helpers/slide_hive_helper.dart';
// import 'package:azan/core/theme/app_theme.dart';
// import 'package:azan/core/utils/cache_helper.dart';
// import 'package:azan/core/utils/constants.dart';
// import 'package:azan/core/utils/device_kind_helper.dart';
// import 'package:azan/core/utils/mqscale.dart';
// import 'package:azan/generated/codegen_loader.g.dart';
// import 'package:azan/views/splash/splash_screen.dart';
// import 'package:dio/dio.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   final dio = Dio(); // أو DioService بتاعك
//   AppCubit.configure(dio: dio);
//   // await appCubit.init();
//   kind = await DeviceKindHelper.detectBeforeRunApp();

//   await CacheHelper.init();
//   if (!CacheHelper.getFirstAppOpen()) {
//     await CacheHelper.setFixedDhikr(fixedDhikr);
//   }
//   await EasyLocalization.ensureInitialized();
//   await Hive.initFlutter();
//   await DhikrHiveHelper.ensureInitialAzkar(azkar);
//   await ManagedAzkarHiveHelper.ensureInitialAzkarSets();
//   await SlideHiveHelper.ensureInitialSlides(ayat);

//   runApp(
//     EasyLocalization(
//       path: 'assets/Lang',
//       supportedLocales: const [Locale('en'), Locale('ar'), Locale('bn')],
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

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   UiRotationCubit cubit = UiRotationCubit();
//   @override
//   void initState() {
//     cubit = UiRotationCubit();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (isLargeScreen(kind) && !CacheHelper.getFirstAppOpen()) {
//         cubit.changeIsLandscape(true);
//       }
//     });

//     // widget ensure initialized

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // return

//     return MultiBlocProvider(
//       providers: [
//         BlocProvider.value(
//           value: cubit, //
//         ),
//         BlocProvider(create: (context) => AppCubit()..init()),
//       ],
//       child: BlocConsumer<UiRotationCubit, bool>(
//         bloc: cubit,
//         listener: (context, state) {},
//         builder: (context, state) {
//           final isMobile = !isLargeScreen(kind);
//           final orientation = MediaQuery.of(context).orientation;
//           final deviceIsLandscape = orientation == Orientation.landscape;

//           // ✅ على الموبايل: خلّي isLandscape = orientation الحقيقي
//           if (isMobile) {
//             if (state != deviceIsLandscape) {
//               // مهم: منع loop
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 if (cubit.state != deviceIsLandscape) {
//                   cubit.changeIsLandscape(deviceIsLandscape);
//                 }
//               });
//             }
//           }

//           int quarter = 0;
//           late Size designSize;

//           if (isMobile) {
//             // ✅ موبايل: مفيش Rotation وهمي نهائيًا
//             quarter = 0;

//             // اختار designSize حسب orientation الحقيقي
//             designSize = deviceIsLandscape
//                 ? const Size(960, 540)
//                 : const Size(393, 852);
//           } else {
//             // ✅ LargeScreen: النظام القديم بتاعك (state هو اللي بيحدد UI rotation)
//             // state هنا معناها: "isLandscape UI"
//             if (orientation == Orientation.portrait && !state) {
//               designSize = const Size(393, 852);
//               quarter = 0;
//             } else if (orientation == Orientation.portrait && state) {
//               designSize = const Size(960, 540);
//               quarter = 1;
//             } else if (orientation == Orientation.landscape && state) {
//               designSize = const Size(960, 540);
//               quarter = 0;
//             } else {
//               designSize = const Size(393, 852);
//               quarter = 1;
//             }
//           }

//           final app = MQScaleInit(
//             key: ValueKey('${designSize.width}x${designSize.height}'),
//             designSize: designSize,
//             minTextAdapt: true,
//             child: Builder(
//               builder: (context) {
//                 final baseTheme = ThemeData(
//                   fontFamily: CacheHelper.getTextsFontFamily(),
//                 );

//                 return MaterialApp(
//                   debugShowCheckedModeBanner: false,
//                   localizationsDelegates: context.localizationDelegates,
//                   supportedLocales: context.supportedLocales,
//                   locale: context.locale,
//                   theme: baseTheme.copyWith(
//                     textTheme: AppTheme.withDefaultTextShadow(
//                       baseTheme.textTheme,
//                     ),
//                     primaryTextTheme: AppTheme.withDefaultTextShadow(
//                       baseTheme.primaryTextTheme,
//                     ),
//                   ),
//                   home: const SplashScreen(),
//                   //  AzkarView(azkarType: AzkarType.evening),
//                   // AzkarView(azkarType: AzkarType.afterPrayer),
//                 );
//               },
//             ),
//           );

//           // ✅ على الموبايل: رجّع app بدون RotatedMediaQueryX
//           if (isMobile) return app;

//           // ✅ على الشاشات الكبيرة: لف زي ما أنت عايز
//           return RotatedMediaQueryX(quarterTurns: quarter, child: app);
//         },
//       ),
//     );

//     // return RotatedBox(quarterTurns: 3, child: widget);

//     // if (!cubit.isLandscape() && isLargeScreen(kind)) {
//     // return RotatedBox(quarterTurns: 3, child: widget);
//     // } else if (!cubit.isLandscape() && !isLargeScreen(kind)) {
//     //   return widget;
//     // } else if (cubit.isLandscape() && isLargeScreen(kind)) {
//     //   return widget;
//     // } else if (cubit.isLandscape() && !isLargeScreen(kind)) {

//     // } else {
//     //   return widget;
//     // }
//   }
// }

// class RotatedMediaQueryX extends StatelessWidget {
//   const RotatedMediaQueryX({
//     super.key,
//     required this.quarterTurns,
//     required this.child,
//   });

//   final int quarterTurns; // 0,1,2,3
//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     final q = quarterTurns % 4;
//     if (q == 0) return child;

//     final baseMq =
//         MediaQuery.maybeOf(context) ??
//         MediaQueryData.fromView(
//           View.maybeOf(context) ??
//               WidgetsBinding.instance.platformDispatcher.implicitView!,
//         );

//     EdgeInsets rotateInsets(EdgeInsets e) {
//       final t = e.top, r = e.right, b = e.bottom, l = e.left;
//       // RotatedBox rotates CLOCKWISE
//       if (q == 1) return EdgeInsets.fromLTRB(b, l, t, r);
//       if (q == 2) return EdgeInsets.fromLTRB(r, b, l, t);
//       if (q == 3) return EdgeInsets.fromLTRB(t, r, b, l);
//       return e;
//     }

//     final s = baseMq.size;

//     final rotatedMq = baseMq.copyWith(
//       size: q.isOdd ? Size(s.height, s.width) : s,
//       padding: rotateInsets(baseMq.padding),
//       viewPadding: rotateInsets(baseMq.viewPadding),
//       viewInsets: rotateInsets(baseMq.viewInsets),
//       systemGestureInsets: rotateInsets(baseMq.systemGestureInsets),
//     );

//     return MediaQuery(
//       data: rotatedMq,
//       child: RotatedBox(quarterTurns: q, child: child),
//     );
//   }
// }









// بص عندك الصفحة اللي بتتعرض في homescreenmobile الصفحة اللي متناسبة معتمدة علي الخلفيات الخصوصية اللي ليها خصوصية دي ؟عارفها ,,,,المشكلة فيه2

// ════════ Exception caught by rendering library ═════════════════════════════════
// The following assertion was thrown during layout:
// A RenderFlex overflowed by 4.8 pixels on the bottom.

// The relevant error-causing widget was:
//     Column Column:file:///Users/husseinabozina/azan/lib/views/home/components/legacy_mosque_top_cluster.dart:459:14

// : To inspect this widget in Flutter DevTools, visit: http://127.0.0.1:9101/#/inspector?uri=http%3A%2F%2F127.0.0.1%3A62426%2FPXx0mzC5ub8%3D%2F&inspectorRef=inspector-0

// The overflowing RenderFlex has an orientation of Axis.vertical.
// The edge of the RenderFlex that is overflowing has been marked in the rendering with a yellow and black striped pattern. This is usually caused by the contents being too big for the RenderFlex.
// Consider applying a flex factor (e.g. using an Expanded widget) to force the children of the RenderFlex to fit within the available space instead of being sized to their natural size.
// This is considered an error condition because it indicates that there is content that cannot be seen. If the content is legitimately bigger than the available space, consider clipping it with a ClipRect widget before putting it in the flex, or using a scrollable container rather than a Flex, like a ListView.
// The specific RenderFlex in question is: RenderFlex#29b16 relayoutBoundary=up7 OVERFLOWING
//     parentData: offset=Offset(1.0, 0.0) (can use size)
//     constraints: BoxConstraints(0.0<=w<=140.9, 0.0<=h<=84.5)
//     size: Size(138.9, 84.5)
//     direction: vertical
//     mainAxisAlignment: start
//     mainAxisSize: min
//     crossAxisAlignment: center
//     verticalDirection: down
//     spacing: 0.0
//     child 1: RenderFittedBox#e08a9 relayoutBoundary=up8
//         parentData: offset=Offset(30.0, 0.0); flex=null; fit=null (can use size)
//         constraints: BoxConstraints(0.0<=w<=140.9, 0.0<=h<=Infinity)
//         size: Size(78.8, 54.0)
//         fit: scaleDown
//         alignment: Alignment.center
//         textDirection: rtl
//         child: RenderFlex#f0fd8 relayoutBoundary=up9
//             parentData: <none> (can use size)
//             constraints: BoxConstraints(unconstrained)
//             size: Size(78.8, 54.0)
//             direction: horizontal
//             mainAxisAlignment: start
//             mainAxisSize: max
//             crossAxisAlignment: center
//             textDirection: rtl
//             verticalDirection: down
//             spacing: 0.0
//             child 1: RenderConstrainedBox#c3f87 relayoutBoundary=up10
//                 parentData: offset=Offset(47.4, 11.3); flex=null; fit=null (can use size)
//                 constraints: BoxConstraints(unconstrained)
//                 size: Size(31.4, 31.4)
//                 additionalConstraints: BoxConstraints(w=31.4, h=31.4)
//                 child: RenderSemanticsAnnotations#fe511
//                     parentData: <none> (can use size)
//                     constraints: BoxConstraints(w=31.4, h=31.4)
//                     size: Size(31.4, 31.4)
//             child 2: RenderConstrainedBox#a57a9 relayoutBoundary=up10
//                 parentData: offset=Offset(39.0, 27.0); flex=null; fit=null (can use size)
//                 constraints: BoxConstraints(unconstrained)
//                 size: Size(8.4, 0.0)
//                 additionalConstraints: BoxConstraints(w=8.4, 0.0<=h<=Infinity)
//             child 3: RenderParagraph#38aaa relayoutBoundary=up10
//                 parentData: offset=Offset(0.0, 0.0); flex=null; fit=null (can use size)
//                 constraints: BoxConstraints(unconstrained)
//                 size: Size(39.0, 54.0)
//                 textAlign: start
//                 textDirection: rtl
//                 softWrap: wrapping at box width
//                 overflow: clip
//                 locale: ar
//                 maxLines: unlimited
//                 text: TextSpan
//                     debugLabel: ((tall bodyMedium 2021).merge((((blackMountainView bodyMedium).apply).apply).copyWith)).merge(unknown)
//                     inherit: false
//                     color: Color(alpha: 1.0000, red: 0.3529, green: 0.2078, blue: 0.1255, colorSpace: ColorSpace.sRGB)
//                     family: Amiri
//                     size: 37.7
//                     weight: 700
//                     letterSpacing: 0.3
//                     baseline: alphabetic
//                     height: 1.4x
//                     leadingDistribution: even
//                     decoration: Color(alpha: 1.0000, red: 0.1137, green: 0.1059, blue: 0.1255, colorSpace: ColorSpace.sRGB) TextDecoration.none
//                     "--°"
//     child 2: RenderConstrainedBox#c37ae relayoutBoundary=up8
//         parentData: offset=Offset(69.4, 54.0); flex=null; fit=null (can use size)
//         constraints: BoxConstraints(0.0<=w<=140.9, 0.0<=h<=Infinity)
//         size: Size(0.0, 4.3)
//         additionalConstraints: BoxConstraints(0.0<=w<=Infinity, h=4.3)
//     child 3: _RenderLayoutBuilder#06799 relayoutBoundary=up8
//         parentData: offset=Offset(0.0, 58.3); flex=null; fit=null (can use size)
//         constraints: BoxConstraints(0.0<=w<=140.9, 0.0<=h<=Infinity)
//         size: Size(138.9, 31.0)
//         child: RenderParagraph#dc45f relayoutBoundary=up9
//             parentData: offset=Offset(0.0, 0.0) (can use size)
//             constraints: BoxConstraints(0.0<=w<=140.9, 0.0<=h<=Infinity)
//             size: Size(138.9, 31.0)
//             textAlign: center
//             textDirection: rtl
//             softWrap: wrapping at box width
//             overflow: clip
//             locale: ar
//             maxLines: 1
//             text: TextSpan
//                 debugLabel: (((tall bodyMedium 2021).merge((((blackMountainView bodyMedium).apply).apply).copyWith)).merge(unknown)).copyWith
//                 inherit: false
//                 color: Color(alpha: 1.0000, red: 0.2275, green: 0.1412, blue: 0.0824, colorSpace: ColorSpace.sRGB)
//                 family: Amiri
//                 size: 27.0
//                 weight: 400
//                 letterSpacing: 0.3
//                 baseline: alphabetic
//                 height: 1.1x
//                 leadingDistribution: even
//                 decoration: Color(alpha: 1.0000, red: 0.1137, green: 0.1059, blue: 0.1255, colorSpace: ColorSpace.sRGB) TextDecoration.none
//                 "9 أبريل 2026"
// ◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
// ════════════════════════════════════════════════════════════════════════════════
// D/EGL_emulation(30907): app_time_stats: avg=70.58ms min=15.00ms max=194.48ms count=15.  المشكلة فيها التالي فيها لما بكون ظاهر الحرارة بيحصل كدا وعاوزك بقا تفهم الموصوع دا وتكبر حجم المتبقي للصلاة وهنا انا اقصد الوقتي المتبقي وليست كلمة المتبقي للصلاة