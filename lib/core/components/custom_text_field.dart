import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,

    this.hintText,
    this.validator,
    this.suffixIcon,
    this.readOnly,
    this.onSubmitted,
    this.onTap,
    this.controller,
  });
  final String? hintText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool? readOnly;
  final void Function(String? value)? onSubmitted;
  final void Function()? onTap;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly ?? false,
      onTap: onTap,
      controller: controller,

      decoration: InputDecoration(
        filled: true,

        hintText: hintText,
        fillColor: Colors.white,

        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        hintStyle: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey.shade700,
          fontFamily: CacheHelper.getTimesFontFamily(),
        ),
        labelStyle: TextStyle(
          fontSize: 12.sp,
          color: Colors.white.withOpacity(0.75),
          fontFamily: CacheHelper.getTimesFontFamily(),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppTheme.primaryTextColor.withOpacity(0.5),
            width: 1.w,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppTheme.primaryTextColor,

            width: 1.2.w,
          ),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
