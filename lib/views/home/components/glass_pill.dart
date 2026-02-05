import 'dart:ui';
import 'package:azan/core/utils/screenutil_flip_ext.dart';
import 'package:flutter/material.dart';

class GlassPill extends StatelessWidget {
  GlassPill({
    super.key,
    required this.child,
    this.enabled = true,
    this.height,
    this.radius = 22,
    this.blurSigma = 14,
    this.padding,
    this.margin,
    this.scaleHeight = true, // ✅ NEW
  });

  final Widget child;
  final bool enabled;
  final double? height;
  final double radius;
  final double blurSigma;
  final EdgeInsetsDirectional? padding;
  final EdgeInsets? margin;
  final bool scaleHeight; // ✅ NEW

  @override
  Widget build(BuildContext context) {
    final resolvedHeight = (height == null)
        ? null
        : (scaleHeight ? height!.h : height);

    if (!enabled) {
      return Container(height: resolvedHeight, margin: margin, child: child);
    }

    return Container(
      height: resolvedHeight,
      // margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma.w, sigmaY: blurSigma.h),
          child: Container(
            // padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.14),
                  Colors.white.withOpacity(0.06),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.22),
                width: 1.w,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
