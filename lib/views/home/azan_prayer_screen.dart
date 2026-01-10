import 'dart:async';

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/models/prayer.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:azan/views/home/components/live_clock_row.dart';
import 'package:azan/views/home/components/random_duaa_ticker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AzanPrayerScreen extends StatefulWidget {
  const AzanPrayerScreen({super.key, required this.currentPrayer});
  final Prayer currentPrayer;
  @override
  State<AzanPrayerScreen> createState() => _AzanPrayerScreenState();
}

class _AzanPrayerScreenState extends State<AzanPrayerScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _azanTerminat = false;
  bool _doaaTerminat = false;
  late AppCubit appCubit;

  @override
  void initState() {
    appCubit = AppCubit.get(context);
    Timer(Duration(minutes: 2), () {
      setState(() {
        _azanTerminat = true;
      });
      Timer(Duration(minutes: 2), () {
        setState(() {
          _doaaTerminat = true;
        });
        // Timer(Duration(minutes: appCubit.prayertime), () {

        // })
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _azanTerminat ? Colors.black : Colors.transparent;

    Color textColor = _azanTerminat ? Colors.white : AppTheme.primaryTextColor;

    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(context: context),

      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          return SizedBox(
            width: 1.sw,
            child: Stack(
              children: [
                Image.asset(
                  CacheHelper.getSelectedBackground(),

                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                  // color: backgroundColor,
                ),
                // AnimatedContainer(
                //   duration: const Duration(milliseconds: 800),
                //   curve: Curves.easeInOut,
                //   color: backgroundColor,
                //   width: 1.sw,
                //   height: 1.sh,
                //   child: Image.asset(
                //     CacheHelper.getSelectedBackground(),

                //     width: double.infinity,
                //     height: double.infinity,
                //     fit: BoxFit.fill,
                //     // color: backgroundColor,
                //   ),
                // ),
                // AnimatedContainer(
                //   duration: const Duration(milliseconds: 1500),
                //   curve: Curves.easeInOut,
                //   color: backgroundColor,
                //   width: 1.sw,
                //   height: 1.sh,
                // ),
                if (!_azanTerminat)
                  SizedBox(
                    width: 1.sw,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeInOut,
                      style: TextStyle(color: textColor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            LocaleKeys.adhan_.tr(),
                            style: TextStyle(
                              fontSize: 35.sp,
                              fontWeight: FontWeight.bold,
                              // color: AppTheme.primaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          VerticalSpace(height: 30.h),
                          Text(
                            widget.currentPrayer.title,
                            style: TextStyle(
                              fontSize: 35.sp,
                              fontWeight: FontWeight.bold,
                              // color: AppTheme.primaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          VerticalSpace(height: 30.h),
                          Text(
                            widget.currentPrayer.time ?? '',
                            style: TextStyle(
                              fontSize: 35.sp,
                              fontWeight: FontWeight.bold,
                              // color: AppTheme.primaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_azanTerminat && !_doaaTerminat)
                  Opacity(
                    opacity: _azanTerminat && !_doaaTerminat ? 1 : 0,

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          duaaAfterAzan,
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                if (_doaaTerminat)
                  Opacity(
                    opacity: _doaaTerminat ? 1 : 0,
                    child: SizedBox(
                      width: 1.sw,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Text(
                            appCubit.hijriDate ?? "",
                            style: TextStyle(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                              // color: Colors.white,
                              // color: AppTheme.primaryTextColor,
                              color: AppTheme.primaryButtonTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          LiveClockRow(
                            timeFontSize: 25.sp,
                            periodFontSize: 25.sp,
                          ),

                          Text(
                            LocaleKeys.please_turn_off_the_phone.tr(),
                            style: TextStyle(fontSize: 36.sp),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_azanTerminat)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10.h,
                    left: 20.r,
                    child: IconButton(
                      onPressed: () {
                        scaffoldKey.currentState?.openDrawer();
                      },
                      icon: Icon(
                        Icons.menu,
                        color: AppTheme.accentColor,
                        size: 30.r,
                      ),
                    ),
                  ),

                // RandomDuaaTicker(
                //   items: const [
                //     "سبحان الله",
                //     "الحمد لله",
                //     "لا إله إلا الله",
                //     "الله أكبر",
                //     "اللهم صلِّ على محمد",
                //   ],
                //   interval: const Duration(seconds: 8),
                // ),
                Positioned(
                  bottom: 80.h,
                  left: 20.w,
                  right: 20.w,
                  child: Column(
                    children: [
                      Image.asset(
                        Assets.images.closePhone.path,
                        height: 130.h,
                        width: 130.w,
                      ),
                      Text(
                        LocaleKeys.please_turn_off_the_phone.tr(),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
