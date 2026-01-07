import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AzanTitleTile extends StatelessWidget {
  const AzanTitleTile({
    super.key,
    required this.width,
    required this.title,
    required this.fontSize,
    this.withNoAscentAndDescent,
  });

  final double width;
  final String title;
  final double fontSize;
  final bool? withNoAscentAndDescent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // width: double.infinity,
          // width: 80.w,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 2.w, color: AppTheme.primaryTextColor),
            ),
          ),

          child: FittedBox(
            child: Center(
              child: Text(
                title,
                textHeightBehavior: withNoAscentAndDescent == true
                    ? TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      )
                    : null,
                style: TextStyle(
                  fontFamily: CacheHelper.getTimesFontFamily(),
                  height: withNoAscentAndDescent == true ? 1 : null,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTextColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AzanTimeText extends StatelessWidget {
  const AzanTimeText({super.key, required this.time, this.dimmed = false});

  final String time;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      style: TextStyle(
        fontFamily: CacheHelper.getTimesFontFamily(),
        fontSize: 23.sp,
        fontWeight: FontWeight.bold,
        color: CacheHelper.getIsPreviousPrayersDimmed()
            ? (dimmed
                  ? AppTheme.primaryTextColor.withOpacity(0.4)
                  : AppTheme.primaryTextColor)
            : AppTheme.primaryTextColor, // عادي
      ),
    );
  }
}
