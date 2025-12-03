import 'package:azan/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
