import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/flash_dialoge.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/location_helper.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:azan/views/home/components/live_clock_row.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreenMobile extends StatefulWidget {
  const HomeScreenMobile({super.key});

  @override
  State<HomeScreenMobile> createState() => _HomeScreenMobileState();
}

class _HomeScreenMobileState extends State<HomeScreenMobile> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late AppCubit cubit;

  String? hijriDate;
  late DateTime _lastDate;
  assingHijriDate() async {
    hijriDate = await cubit.getTodayHijriDate();
  }

  late Timer _timer;

  @override
  void initState() {
    super.initState();

    cubit = AppCubit.get(context);
    _lastDate = DateTime.now();

    _initDayData(); // أول لود لبيانات اليوم

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();

      // لو عندك تايمر عدّ تنازلي أو ساعة... خليه يتحدّث عادي
      setState(() {});

      // هنا بنشوف هل اليوم اتغيّر ولا لأ
      if (!_isSameDay(now, _lastDate)) {
        _lastDate = now;
        _onNewDay();
      }
    });
  }

  void _initDayData() {
    assingHijriDate();

    final city = cubit.getCity()?.nameEn ?? '';

    cubit.initializePrayerTimes(city);

    cubit.loadTodayMaxTemp(country: 'Saudi Arabia', city: city);

    cubit.getIqamaTime();
    cubit.assignAdhkar();
  }

  void _onNewDay() {
    // لما اليوم يتغيّر وإنت لسه على نفس الشاشة
    _initDayData();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(),

      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {
          if (state is FetchPrayerTimesFailure) {
            showFlashMessage(
              message: state.message,
              type: FlashMessageType.error,
              context: context,
            );
          }
        },
        builder: (context, state) {
          return SizedBox(
            // width:
            //     1.sw -
            //     MediaQuery.of(context).padding.left -
            //     MediaQuery.of(context).padding.right,
            // child:

            // Column(
            //   children: [
            //     Container(
            //       height: (852 / 4).h,
            //       width: double.infinity,
            //       color: Colors.red,
            //     ),
            //     Container(
            //       height: (852 / 4).h,
            //       width: double.infinity,
            //       color: Colors.red,
            //     ),
            //     Container(
            //       height: (852 / 4).h,
            //       width: double.infinity,
            //       color: Colors.red,
            //     ),
            //     Container(
            //       height: (852 / 4).h,
            //       width: double.infinity,
            //       color: Colors.red,
            //       child: Stack(
            //         children: [
            //           PositionedDirectional(
            //             bottom: 0,
            //             child: Text('ljdf', style: TextStyle(fontSize: 20.sp)),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
            child: Stack(
              children: [
                Image.asset(
                  Assets.images.home.path,

                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                ),

                LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      height: constraints.maxHeight,
                      width: constraints.maxWidth,
                      child: FittedBox(
                        fit: BoxFit.contain,

                        child: SizedBox(
                          height: constraints.maxHeight,
                          width: constraints.maxWidth,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).padding.top,
                                ),
                                child: HomeAppBar(
                                  onDrawerTap: () {
                                    scaffoldKey.currentState?.openDrawer();
                                  },
                                  r: R(BoxConstraints()),
                                ),
                              ),
                              Spacer(flex: 1),

                              Text(
                                DateTime.now().weekdayNameAr,
                                style: TextStyle(
                                  fontSize: 20.sp, // from height h
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTextColor,
                                ),
                              ),
                              // VerticalSpace(height: 10.h),
                              // Spacer(),
                              Spacer(flex: 1),
                              Text(
                                hijriDate == null ? "--:--" : hijriDate!,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                              Spacer(flex: 2),

                              Padding(
                                padding: EdgeInsets.only(
                                  left: 24.w,
                                  right: 24.w,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 37.17.h,
                                          width: cubit.maxTemp != null
                                              ? cubit.maxTemp!
                                                            .toInt()
                                                            .toString()
                                                            .length ==
                                                        2
                                                    ? 32.w
                                                    : 25.w
                                              : 32.w,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              PositionedDirectional(
                                                // top:,
                                                start: 0,
                                                top: 0,
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      AppTheme.primaryTextColor,
                                                  radius: 5.r,
                                                ),
                                              ),
                                              PositionedDirectional(
                                                end: 0,
                                                bottom: 0,
                                                child: Text(
                                                  cubit.maxTemp == null
                                                      ? "--"
                                                      : cubit.maxTemp!
                                                            .toInt()
                                                            .toString(),
                                                  style: TextStyle(
                                                    fontSize: 24.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme
                                                        .secondaryTextColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          DateHelper.toArabicDigits(
                                            DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(DateTime.now()),
                                          ),
                                          style: TextStyle(
                                            fontSize: 24.sp,
                                            color: AppTheme.primaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    FutureBuilder(
                                      future: cubit.nextPrayer,
                                      builder: (context, asyncSnapshot) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              asyncSnapshot.data?.dateTime ==
                                                      null
                                                  ? "--:--"
                                                  : asyncSnapshot
                                                        .data!
                                                        .dateTime!
                                                        .difference(
                                                          DateTime.now(),
                                                        )
                                                        .formatDuration(),
                                              style: TextStyle(
                                                fontSize: 24.sp,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    AppTheme.secondaryTextColor,
                                              ),
                                            ),
                                            Text(
                                              LocaleKeys.left_for.tr() +
                                                  (asyncSnapshot.data?.title
                                                          .substring(1) ??
                                                      ""),
                                              style: TextStyle(
                                                fontSize: 24.sp,
                                                color:
                                                    AppTheme.primaryTextColor,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              Spacer(flex: 1),

                              LiveClockRow(
                                timeFontSize: 64.sp,
                                periodFontSize: 24.sp,
                              ),

                              Padding(
                                padding: EdgeInsets.only(
                                  right: 20.w,
                                  left: 20.w,
                                ),
                                child: Container(
                                  height: 70.h,

                                  // color: Colors.redAccent,
                                  child: Text(
                                    CacheHelper.getFixedDhikr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.secondaryTextColor,
                                    ),
                                  ),
                                ),
                              ),
                              // Spacer(),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 24.w,
                                  right: 24.w,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        AzanTitleTile(
                                          width: 30.w,
                                          title: LocaleKeys.prayer.tr(),
                                          fontSize: 14.sp,
                                        ),
                                        VerticalSpace(height: 10),

                                        ...prayers.map(
                                          (e) => Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 10.h,
                                            ),
                                            child: PrayerText(title: e),
                                          ),
                                        ),
                                      ],
                                    ),

                                    Column(
                                      children: [
                                        AzanTitleTile(
                                          width: 30.w,
                                          title: LocaleKeys.adhan.tr(),
                                          fontSize: 14.sp,
                                        ),

                                        VerticalSpace(height: 10),

                                        ...cubit.prayers.map(
                                          (e) => Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 10.h,
                                            ),
                                            child: AzanTimeText(
                                              time: e.time ?? '--:--',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    Column(
                                      children: [
                                        AzanTitleTile(
                                          width: 30.w,
                                          title: LocaleKeys.iqama_time.tr(),
                                          fontSize: 14.sp,
                                        ),
                                        VerticalSpace(height: 10),

                                        ...cubit.prayers.map(
                                          (e) => Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 10.h,
                                            ),
                                            child: AzanTimeText(
                                              time:
                                                  (e.time != null &&
                                                      cubit.iqamaMinutes !=
                                                          null)
                                                  ? DateHelper.addMinutesToTimeString(
                                                      e.time!,
                                                      cubit.iqamaMinutes![e.id -
                                                          1],
                                                    )
                                                  : '--:--',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (CacheHelper.getSliderOpened())
                                // VerticalSpace(height: 10),
                                AzkarSlider(
                                  adhkar: cubit.todaysAdkar != null
                                      ? cubit.todaysAdkar!
                                            .map((e) => e.text)
                                            .toList()
                                      : [],
                                  height: 120.h,
                                  maxFontSize: 20.sp,
                                  minFontSize: 10.sp,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PrayerText extends StatelessWidget {
  const PrayerText({super.key, required this.title});

  // final R r;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 23.sp,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryTextColor,
      ),
    );
  }
}

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, this.onDrawerTap, required this.r});
  final Function()? onDrawerTap;
  final R r;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 32.w, right: 32.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SvgPicture.asset(Assets.svg.logosvg, height: 31.71.h, width: 30.22.w),
          Text(
            CacheHelper.getMosqueName() ?? 'اسم المسجد',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 40.w,
            height: 40.h,
            child: IconButton(
              onPressed: () {
                onDrawerTap!();
              },
              icon: Icon(Icons.menu, color: AppTheme.accentColor, size: 35.r),
            ),
          ),
        ],
      ),
    );
  }
}

class AzanTitleTile extends StatelessWidget {
  const AzanTitleTile({
    super.key,
    required this.width,
    required this.title,
    required this.fontSize,
  });

  final double width;
  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // width: width,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 2.w, color: AppTheme.primaryTextColor),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AzanTimeText extends StatelessWidget {
  const AzanTimeText({super.key, required this.time});

  final String time;
  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      style: TextStyle(
        fontSize: 23.sp,
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryTextColor,
      ),
    );
  }
}

class AzkarSlider extends StatefulWidget {
  final List<String> adhkar;
  final double height;
  final double maxFontSize;
  final double minFontSize;

  const AzkarSlider({
    super.key,
    required this.adhkar,
    required this.height,
    required this.maxFontSize,
    required this.minFontSize,
  });

  @override
  State<AzkarSlider> createState() => _AzkarSliderState();
}

class _AzkarSliderState extends State<AzkarSlider> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (!mounted || widget.adhkar.isEmpty) return;

      _currentPage = (_currentPage + 1) % widget.adhkar.length;

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.adhkar.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.adhkar.length,
        itemBuilder: (context, index) {
          final text = widget.adhkar[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _AdaptiveTextWidget(
              text: text,
              maxFontSize: widget.maxFontSize,
              minFontSize: widget.minFontSize,
              availableHeight: widget.height,
            ),
          );
        },
      ),
    );
  }
}

class _AdaptiveTextWidget extends StatelessWidget {
  final String text;
  final double maxFontSize;
  final double minFontSize;
  final double availableHeight;

  const _AdaptiveTextWidget({
    required this.text,
    required this.maxFontSize,
    required this.minFontSize,
    required this.availableHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double currentFontSize = maxFontSize;
        int lines = 1;

        // نجرب نحسب عدد الأسطر عند الحجم الأقصى
        final textPainter = TextPainter(
          textDirection: material.TextDirection.rtl,
          textAlign: TextAlign.center,
        );

        // نبدأ بالحجم الأقصى ونشوف كام سطر هيطلع
        while (currentFontSize >= minFontSize) {
          textPainter.text = TextSpan(
            text: text,
            style: TextStyle(
              fontSize: currentFontSize,
              fontWeight: FontWeight.bold,
              height: 1.5, // line height
            ),
          );
          textPainter.layout(maxWidth: width);

          lines = textPainter.computeLineMetrics().length;
          final textHeight = textPainter.height;

          // لو السطور 2 أو أقل والنص داخل في المساحة المتاحة، خلاص كده تمام
          if (lines <= 2 && textHeight <= availableHeight) {
            break;
          }

          // لو السطور أكتر من 2، نصغر الخط شوية
          if (lines > 2) {
            currentFontSize -= 1;
          } else if (textHeight > availableHeight) {
            // لو الارتفاع أكبر من المتاح، نصغر الخط
            currentFontSize -= 0.5;
          } else {
            break;
          }

          // نتأكد إننا ما نزلناش عن الحد الأدنى
          if (currentFontSize < minFontSize) {
            currentFontSize = minFontSize;
            break;
          }
        }

        // نرسم النص النهائي
        return Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: currentFontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            textDirection: material.TextDirection.rtl,
            maxLines: lines > 2 ? null : 2,
            overflow: lines > 2 ? TextOverflow.visible : null,
          ),
        );
      },
    );
  }
}
