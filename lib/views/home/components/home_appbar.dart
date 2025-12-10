import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, this.onDrawerTap});
  final Function()? onDrawerTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: 10.w),
            child: SvgPicture.asset(
              Assets.svg.logosvg,
              height: 31.71.h,
              width: 30.22.w,
            ),
          ),
          HorizontalSpace(width: 10),
          Flexible(
            // flex: 18,
            child: Center(
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(top: 5.h),
                  child: AdaptiveTextWidget(
                    availableHeight: 35.h,
                    text:
                        CacheHelper.getMosqueName() ??
                        LocaleKeys.mosque_name_label.tr(),
                    maxFontSize: 20.sp,
                    minFontSize: 16.sp,
                  ),

                  // Text(
                  //   CacheHelper.getMosqueName() ??
                  //       LocaleKeys.mosque_name_label.tr(),
                  //   maxLines: 3,
                  //   style: TextStyle(
                  //     fontSize: 20.sp,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.white,
                  //   ),
                  // ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              onDrawerTap!();
            },
            icon: Icon(Icons.menu, color: AppTheme.accentColor, size: 30.r),
          ),
        ],
      ),
    );
  }
}
