import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, this.onDrawerTap});
  final Function()? onDrawerTap;

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
