import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomStarHint extends StatefulWidget {
  const BottomStarHint({super.key, required this.text, this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  State<BottomStarHint> createState() => _BottomStarHintState();
}

class _BottomStarHintState extends State<BottomStarHint> {
  late AppCubit cubit;
  @override
  void initState() {
    cubit = AppCubit.get(context);
    cubit.checkConnectivity();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 14.h, left: 5.w, right: 5.w),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: AppTheme.dialogBackgroundColor.withOpacity(0.85),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppTheme.primaryTextColor.withOpacity(0.35),
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cubit.connectivity == true
                      ? Icons.star_rounded
                      : Icons.star_border,
                  size: 18.sp,
                  color: AppTheme.primaryTextColor,
                ),
                SizedBox(width: 4.w),

                Text(
                  cubit.connectivity == true
                      ? LocaleKeys.connected.tr()
                      : LocaleKeys.disconnected.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.dialogBodyTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
