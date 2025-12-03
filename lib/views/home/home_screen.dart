// import 'dart:async';

// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
// import 'package:azan/core/components/vertical_space.dart';
// import 'package:azan/core/theme/app_theme.dart';
// import 'package:azan/core/utils/constants.dart';
// import 'package:azan/core/utils/extenstions.dart';
// import 'package:azan/gen/assets.gen.dart';
// import 'package:azan/generated/locale_keys.g.dart';
// import 'package:azan/views/home/components/cusotm_drawer.dart';
// import 'package:azan/views/home/components/custom_appbar.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//   late AppCubit appCubit;
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldKey,
//       drawer: CustomDrawer(),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final h = constraints.maxHeight;
//             final w = constraints.maxWidth;
//             final R r = R(constraints);
//             return Stack(
//               children: [
//                 Image.asset(
//                   Assets.images.home.path,

//                   width: double.infinity,
//                   height: double.infinity,
//                   fit: BoxFit.fill,
//                 ),

//                 PositionedDirectional(
//                   top: 0,
//                   start: 0,
//                   end: 0,

//                   child: SizedBox(
//                     height: h,
//                     child: Center(
//                       child: Column(
//                         children: [
//                           SizedBox(
//                             child: HomeAppBar(
//                               r: r,
//                               onDrawerTap: () {
//                                 scaffoldKey.currentState!.openDrawer();
//                               },
//                             ),
//                           ),
//                           Text(
//                             LocaleKeys.thursday.tr(),
//                             style: TextStyle(
//                               fontSize: h * 0.03, // from height h
//                               fontWeight: FontWeight.bold,
//                               color: AppTheme.primaryTextColor,
//                             ),
//                           ),
//                           SizedBox(height: r.blockH),
//                           // Spacer(),
//                           Text(
//                             "٦ جمادى الثاني ١٤٤٧",
//                             style: TextStyle(
//                               fontSize: h * 0.03,
//                               fontWeight: FontWeight.bold,
//                               color: AppTheme.secondaryTextColor,
//                             ),
//                           ),
//                           SizedBox(height: r.blockH * 3),

//                           Padding(
//                             padding: EdgeInsets.only(
//                               left: 6 * r.blockW,
//                               right: 7 * r.blockW,
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Container(
//                                       height: r.blockH * 4,
//                                       width: r.blockW * 5,
//                                       child: Stack(
//                                         clipBehavior: Clip.none,
//                                         children: [
//                                           PositionedDirectional(
//                                             // top:,
//                                             start: -r.blockW * 0.9,
//                                             top: -r.blockH * 0.1,
//                                             child: CircleAvatar(
//                                               backgroundColor:
//                                                   AppTheme.primaryTextColor,
//                                               radius: r.blockW * 0.6,
//                                             ),
//                                           ),
//                                           Text(
//                                             "٢٦",
//                                             style: TextStyle(
//                                               fontSize: r.blockH * 3.2,
//                                               fontWeight: FontWeight.bold,
//                                               color:
//                                                   AppTheme.secondaryTextColor,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Text(
//                                       "٢٧/١١/٢٠٢٥",
//                                       style: TextStyle(
//                                         fontSize: r.blockH * 3,
//                                         color: AppTheme.primaryTextColor,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     SizedBox(
//                                       height: r.blockH * 3.5,
//                                       width: r.blockW * 10,
//                                       child: Text(
//                                         "٤:٥٤",
//                                         style: TextStyle(
//                                           fontSize: r.blockH * 2.9,
//                                           fontWeight: FontWeight.bold,
//                                           color: AppTheme.secondaryTextColor,
//                                         ),
//                                       ),
//                                     ),
//                                     Text(
//                                       LocaleKeys.time_left_for_fajr.tr(),
//                                       style: TextStyle(
//                                         fontSize: r.blockH * 3,
//                                         color: AppTheme.primaryTextColor,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: r.blockH * 2),
//                           Text(
//                             '١٢:٠٠' + " " + LocaleKeys.am_label.tr(),
//                             style: TextStyle(
//                               fontSize: r.blockH * 3,
//                               fontWeight: FontWeight.bold,
//                               color: AppTheme.secondaryTextColor,
//                             ),
//                           ),
//                           SizedBox(height: r.blockH * 2),
//                           Text(
//                             '(وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ)',
//                             style: TextStyle(
//                               fontSize: r.blockH * 3,
//                               fontWeight: FontWeight.bold,
//                               color: AppTheme.secondaryTextColor,
//                             ),
//                           ),
//                           SizedBox(height: r.blockH * 3),
//                           Padding(
//                             padding: EdgeInsets.only(
//                               left: 6 * r.blockW,
//                               right: 7 * r.blockW,
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 AzanTitleTile(
//                                   width: r.blockW * 12,
//                                   title: LocaleKeys.prayer.tr(),
//                                   fontSize: r.blockH * 3.6,
//                                 ),
//                                 AzanTitleTile(
//                                   width: r.blockW * 14,
//                                   title: LocaleKeys.adhan.tr(),
//                                   fontSize: r.blockH * 3.6,
//                                 ),
//                                 AzanTitleTile(
//                                   width: r.blockW * 25,
//                                   title: LocaleKeys.iqama_time.tr(),
//                                   fontSize: r.blockH * 3,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: r.blockH * 1.5),
//                           Padding(
//                             padding: EdgeInsetsDirectional.only(
//                               start: 7 * r.blockW,
//                               end: 7 * r.blockW,
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     PrayerText(
//                                       r: r,
//                                       title: LocaleKeys.fajr.tr(),
//                                     ),
//                                     SizedBox(height: r.blockH * 0.5),
//                                     // SizedBox(height: r.blockH * 0.5),
//                                     PrayerText(
//                                       r: r,
//                                       title: LocaleKeys.sunrise.tr(),
//                                     ),
//                                     SizedBox(height: r.blockH * 0.5),

//                                     PrayerText(
//                                       r: r,
//                                       title: LocaleKeys.dhuhr.tr(),
//                                     ),
//                                     SizedBox(height: r.blockH * 0.5),

//                                     PrayerText(
//                                       r: r,
//                                       title: LocaleKeys.asr.tr(),
//                                     ),
//                                     SizedBox(height: r.blockH * 0.5),

//                                     PrayerText(
//                                       r: r,
//                                       title: LocaleKeys.maghrib.tr(),
//                                     ),
//                                     SizedBox(height: r.blockH * 0.5),

//                                     PrayerText(
//                                       r: r,
//                                       title: LocaleKeys.isha.tr(),
//                                     ),
//                                   ],
//                                 ),
//                                 // azan times
//                                 Padding(
//                                   padding: EdgeInsetsDirectional.only(
//                                     end: r.blockW * 6,
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       AzanTimeText(r: r, time: '٤:٤٤'),
//                                       SizedBox(height: r.blockH * 0.5),
//                                       AzanTimeText(r: r, time: '٦:٠٧'),
//                                       SizedBox(height: r.blockH * 0.5),
//                                       AzanTimeText(r: r, time: '١١:٢٧'),
//                                       SizedBox(height: r.blockH * 0.5),
//                                       AzanTimeText(r: r, time: '٢:٢٧'),
//                                       SizedBox(height: r.blockH * 0.5),
//                                       AzanTimeText(r: r, time: '٤:٤٧'),
//                                       SizedBox(height: r.blockH * 0.5),
//                                       AzanTimeText(r: r, time: '٦:١٧'),
//                                     ],
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsetsDirectional.only(
//                                     end: r.blockW * 7,
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       AzanTimeText(r: r, time: '٥:٠٠'),
//                                       SizedBox(height: r.blockH * 0.5),
//                                       AzanTimeText(r: r, time: '٦:٢٠'),
//                                       SizedBox(height: r.blockH * 0.5),
//                                       AzanTimeText(r: r, time: '١١:٤٥'),
//                                       SizedBox(height: r.blockH * 0.5),
//                                       AzanTimeText(r: r, time: '٢:٤٥'),
//                                       SizedBox(height: r.blockH * 0.5),
//                                       AzanTimeText(r: r, time: '٥:٠٠'),
//                                       SizedBox(height: r.blockH * 0.5),
//                                       AzanTimeText(r: r, time: '٦:٣٠'),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: r.blockH * 2),

//                           AzkarSlider(
//                             adhkar: [
//                               '''اللّهمَّ أَنْتَ رَبِّي لا إلهَ إلاّ أَنْتَ ، خَلَقْتَني وَأَنا عَبْدُك ، وَأَنا عَلى عَهْدِكَ وَوَعْدِكَ ما اسْتَطَعْت ، أَعوذُبِكَ مِنْ شَرِّ ما صَنَعْت ، أَبوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبوءُ بِذَنْبي فَاغْفِرْ لي فَإِنَّهُ لا يَغْفِرُ الذُّنوبَ إِلاّ أَنْتَ
// ''',
//                               'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّد',
//                               '''
// اللّهُمَّ ما أَمسى بي مِنْ نِعْمَةٍ أَو بِأَحَدٍ مِنْ خَلْقِك ، فَمِنْكَ وَحْدَكَ لا شريكَ لَك ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْر.''',
//                               // زوّد ما تشاء من الأذكار
//                             ],
//                             height: r.h * 0.13,
//                             maxFontSize: r.blockH * 3,
//                             minFontSize: r.blockH * 1,
//                           ),
//                           // Padding(
//                           //   padding: EdgeInsets.only(
//                           //     left: 6 * r.blockW,
//                           //     right: 7 * r.blockW,
//                           //   ),
//                           //   child: Row(
//                           //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           //     children: [
//                           //       Text(
//                           //         LocaleKeys.fajr.tr(),
//                           //         style: TextStyle(
//                           //           fontSize: r.blockH * 5.3,
//                           //           fontWeight: FontWeight.bold,
//                           //           color: AppTheme.primaryTextColor,
//                           //         ),
//                           //       ),
//                           //       Text(
//                           //         '12:00 AM',
//                           //         style: TextStyle(
//                           //           fontSize: r.blockH * 5.3,
//                           //           fontWeight: FontWeight.bold,
//                           //           color: AppTheme.secondaryTextColor,
//                           //         ),
//                           //       ),
//                           //       Text(
//                           //         '5:08 AM',
//                           //         style: TextStyle(
//                           //           fontSize: r.blockH * 5.3,
//                           //           fontWeight: FontWeight.bold,
//                           //           color: AppTheme.secondaryTextColor,
//                           //         ),
//                           //       ),
//                           //     ],
//                           //   ),
//                           // ),

//                           // Container(
//                           //   width: r.w * 0.8,
//                           //   height: r.h * 0.13,
//                           //   child: Center(
//                           //     child: AutoSizeText(
//                           //       'اللَّهُمَّ إِنِي  إِنِي    إِنِي أَسْأَلُكَ الهُدَى،الهُدَى،الهُدَى،الهُدَى،الهُدَى،الهُدَدَىفَ، والغنَى ',
//                           //       style: TextStyle(
//                           //         fontSize:
//                           //             r.blockH * 4.2, // أكبر حجم تحب تبدأ منه
//                           //         fontWeight: FontWeight.bold,
//                           //         color: AppTheme.primaryTextColor,
//                           //       ),
//                           //       maxLines: 2, // أقصى عدد سطور
//                           //       minFontSize: r.blockH * 2.0, // أقل حجم تسمح بيه
//                           //       // لو حتى بعد التصغير مش مكفي
//                           //       stepGranularity: 0.5, // درجة التصغير (اختياري)
//                           //       textAlign: TextAlign.center,
//                           //     ),
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class AzanTimeText extends StatelessWidget {
//   const AzanTimeText({super.key, required this.r, required this.time});

//   final R r;
//   final String time;
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       time,
//       style: TextStyle(
//         fontSize: r.blockH * 2.9,
//         fontWeight: FontWeight.bold,
//         color: AppTheme.secondaryTextColor,
//       ),
//     );
//   }
// }

// class PrayerText extends StatelessWidget {
//   const PrayerText({super.key, required this.r, required this.title});

//   final R r;
//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       title,
//       style: TextStyle(
//         fontSize: r.blockH * prayerFactor,
//         fontWeight: FontWeight.bold,
//         color: AppTheme.primaryTextColor,
//       ),
//     );
//   }
// }

// class AzanTitleTile extends StatelessWidget {
//   const AzanTitleTile({
//     super.key,
//     required this.width,
//     required this.title,
//     required this.fontSize,
//   });

//   final double width;
//   final String title;
//   final double fontSize;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: width,
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(width: 2, color: AppTheme.primaryTextColor),
//             ),
//           ),
//           child: Center(
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: fontSize,
//                 fontWeight: FontWeight.bold,
//                 color: AppTheme.primaryTextColor,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class AzkarSlider extends StatefulWidget {
//   final List<String> adhkar;
//   final double height;
//   final double maxFontSize;
//   final double minFontSize;

//   const AzkarSlider({
//     super.key,
//     required this.adhkar,
//     required this.height,
//     required this.maxFontSize,
//     required this.minFontSize,
//   });

//   @override
//   State<AzkarSlider> createState() => _AzkarSliderState();
// }

// class _AzkarSliderState extends State<AzkarSlider> {
//   late final PageController _pageController;
//   Timer? _timer;
//   int _currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();

//     // سلايدر يتحرك تلقائيًا كل 5 ثواني
//     _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (!mounted || widget.adhkar.isEmpty) return;

//       _currentPage = (_currentPage + 1) % widget.adhkar.length;

//       _pageController.animateToPage(
//         _currentPage,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.adhkar.isEmpty) {
//       return const SizedBox.shrink();
//     }
//     final maxSize = widget.maxFontSize.floorToDouble();
//     final minSize = widget.minFontSize.floorToDouble();

//     return SizedBox(
//       height: widget.height,
//       child: PageView.builder(
//         controller: _pageController,
//         itemCount: widget.adhkar.length,
//         // reverse: true لو عايز الحركة عكس الاتجاه الافتراضي
//         itemBuilder: (context, index) {
//           final text = widget.adhkar[index];
//           return Center(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.0),
//               child: AutoSizeText(
//                 text,
//                 style: TextStyle(
//                   fontSize: maxSize,
//                   fontWeight: FontWeight.bold,
//                   color: AppTheme.primaryTextColor,

//                   // حط لون النص اللي عندك هنا
//                   // color: AppTheme.primaryTextColor,
//                 ),
//                 maxLines: 2,
//                 minFontSize: minSize,
//                 // stepGranularity:,
//                 textAlign: TextAlign.center,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
