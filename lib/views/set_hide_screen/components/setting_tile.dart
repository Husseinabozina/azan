import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/views/adhkar/components/custom_check_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomCheckbox(
          size: 22.r,
          activeColor: AppTheme.accentColor,
          value: value,
          onChanged: onChanged,
        ),
        HorizontalSpace(width: 10.w),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end, // عندك عربي غالباً
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
