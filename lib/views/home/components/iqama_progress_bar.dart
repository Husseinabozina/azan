import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:flutter/material.dart';

class IqamaProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String label;
  final double? width;
  final double? height;

  const IqamaProgressBar({
    super.key,
    required this.progress,
    required this.label,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveHeight = height ?? 24.h;
    final double effectiveWidth = width ?? 1.sw * 0.8;
    final hasLabel = label.trim().isNotEmpty;

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(effectiveHeight / 2),
        border: Border.all(
          color: AppTheme.primaryTextColor.withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Stack(
        children: [
          // Progress Fill
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.secondaryTextColor.withOpacity(0.8),
                    AppTheme.secondaryTextColor,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(effectiveHeight / 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryTextColor.withOpacity(0.3),
                    blurRadius: 4.r,
                    spreadRadius: 1.r,
                  ),
                ],
              ),
            ),
          ),
          // Label Text centered inside
          if (hasLabel)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: (effectiveHeight * 0.55).sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 1.h),
                          blurRadius: 2.r,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
