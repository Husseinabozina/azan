import 'package:azan/core/utils/mqscale.dart';
import 'package:flutter/material.dart';

class GlassPill extends StatelessWidget {
  const GlassPill({
    super.key,
    required this.child,
    this.enabled = true,
    this.highlighted = false,
    this.highlightColor,
    this.highlightOpacity = 0.72,
    this.height,
    this.radius = 22,
    this.blurSigma = 14,
    this.padding,
    this.margin,
    this.scaleHeight = true, // ✅ NEW
  });

  final Widget child;
  final bool enabled;
  final bool highlighted;
  final Color? highlightColor;
  final double highlightOpacity;
  final double? height;
  final double radius;
  final double blurSigma;
  final EdgeInsetsDirectional? padding;
  final EdgeInsetsDirectional? margin;
  final bool scaleHeight; // ✅ NEW

  @override
  Widget build(BuildContext context) {
    final resolvedHeight = (height == null)
        ? null
        : (scaleHeight ? height!.h : height);
    final effectiveHighlightColor = highlightColor ?? const Color(0xFF1FC767);
    final effectiveHighlightOpacity = highlightOpacity
        .clamp(0.20, 1.0)
        .toDouble();
    final highlightDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(radius.r),
      gradient: LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [
          effectiveHighlightColor.withValues(alpha: effectiveHighlightOpacity),
          effectiveHighlightColor.withValues(
            alpha: (effectiveHighlightOpacity * 0.82)
                .clamp(0.16, 1.0)
                .toDouble(),
          ),
        ],
      ),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.22),
        width: 0.9.w,
      ),
    );

    if (!enabled) {
      return Container(
        height: resolvedHeight,
        margin: margin,
        decoration: highlighted ? highlightDecoration : null,
        child: child,
      );
    }

    return Container(
      height: resolvedHeight,
      // margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.r),
        child: Container(
          // filter: ImageFilter.blur(sigmaX: blurSigma.w, sigmaY: blurSigma.h),
          child: Container(
            padding: padding,
            decoration: highlighted
                ? highlightDecoration
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(radius.r),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        // Slightly darker than before for clearer row separation.
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.12),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 0.8.w,
                    ),
                  ),
            child: child,
          ),
        ),
      ),
    );
  }
}
