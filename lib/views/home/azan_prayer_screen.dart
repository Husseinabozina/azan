import 'dart:async';

import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/models/prayer.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AzanPrayerScreen extends StatefulWidget {
  const AzanPrayerScreen({super.key, required this.nextPrayer});
  final Prayer nextPrayer;
  @override
  State<AzanPrayerScreen> createState() => _AzanPrayerScreenState();
}

class _AzanPrayerScreenState extends State<AzanPrayerScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(context: context),

      body: SizedBox(
        width: 1.sw,
        child: Stack(
          children: [
            Image.asset(
              CacheHelper.getSelectedBackground(),

              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fill,
            ),

            SizedBox(
              width: 1.sw,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.adhan_.tr(),
                    style: TextStyle(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  VerticalSpace(height: 30.h),
                  Text(
                    widget.nextPrayer.title,
                    style: TextStyle(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  VerticalSpace(height: 30.h),
                  Text(
                    widget.nextPrayer.time ?? '',
                    style: TextStyle(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              left: 20.r,
              child: IconButton(
                onPressed: () {
                  scaffoldKey.currentState?.openDrawer();
                },
                icon: Icon(Icons.menu, color: AppTheme.accentColor, size: 30.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
