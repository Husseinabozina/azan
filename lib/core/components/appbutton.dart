import 'package:azan/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  final void Function()? onPressed;
  final Widget? iconComponent;
  final Widget? textComponent;
  final Color? color;
  final double? height;
  final double? top;
  final double? bottom;
  final double? start;
  final double? end;
  final double? radius;
  final double? width;
  final List<Color>? colors;
  final Widget child;
  final Color? borderColor;
  final bool autoResize;

  // New parameters for max constraints
  final double? maxWidth;
  final double? maxHeight;
  final double? minWidth;
  final double? minHeight;

  const AppButton({
    super.key,
    this.onPressed,
    required this.child,
    this.color,
    this.height,
    this.radius,
    this.width,
    this.top,
    this.bottom,
    this.start,
    this.end,
    this.iconComponent,
    this.textComponent,
    this.colors,
    this.borderColor,
    this.autoResize = false,

    // New constraint parameters
    this.maxWidth,
    this.maxHeight,
    this.minWidth,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate effective constraints
    final double effectiveMinWidth = _getEffectiveMinWidth();
    final double effectiveMaxWidth = _getEffectiveMaxWidth();
    final double effectiveMinHeight = _getEffectiveMinHeight();
    final double effectiveMaxHeight = _getEffectiveMaxHeight();

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: top ?? 0,
        start: start ?? 0,
        bottom: bottom ?? 0,
        end: end ?? 0,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: effectiveMinWidth,
          maxWidth: effectiveMaxWidth,
          minHeight: effectiveMinHeight,
          maxHeight: effectiveMaxHeight,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            elevation: WidgetStateProperty.all(0),
            padding: const WidgetStatePropertyAll(EdgeInsets.all(0)),
            maximumSize: WidgetStateProperty.all(
              Size(effectiveMaxWidth, effectiveMaxHeight),
            ),
            minimumSize: WidgetStateProperty.all(
              Size(effectiveMinWidth, effectiveMinHeight),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              color: color ?? AppTheme.accentColor,
              borderRadius: BorderRadius.circular(radius ?? 13.r),
              border: Border.all(
                color: borderColor ?? color ?? AppTheme.accentColor,
              ),
            ),
            child: Container(
              constraints: BoxConstraints(
                minWidth: effectiveMinWidth,
                minHeight: effectiveMinHeight,
                maxWidth: effectiveMaxWidth,
                maxHeight: effectiveMaxHeight,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: autoResize ? 12.w : 8.w,
                vertical: 4.h,
              ),
              alignment: Alignment.center,
              child: autoResize
                  ? IntrinsicWidth(
                      child: IntrinsicHeight(child: _buildResponsiveChild()),
                    )
                  : _buildResponsiveChild(),
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods to calculate effective constraints
  double _getEffectiveMinWidth() {
    if (autoResize) {
      return minWidth ?? 0;
    }
    return minWidth ?? width ?? 0.w;
  }

  double _getEffectiveMaxWidth() {
    if (autoResize) {
      return maxWidth ?? double.infinity;
    }
    if (maxWidth != null && width != null) {
      return maxWidth! < width! ? width! : maxWidth!;
    }
    return maxWidth ?? width ?? double.infinity;
  }

  double _getEffectiveMinHeight() {
    return minHeight ?? height ?? 48.h;
  }

  double _getEffectiveMaxHeight() {
    if (maxHeight != null && height != null) {
      return maxHeight! < height! ? height! : maxHeight!;
    }
    return maxHeight ?? height ?? double.infinity;
  }

  Widget _buildResponsiveChild() {
    // If the child is a Text widget, wrap it with proper overflow handling
    if (child is Text) {
      final textChild = child as Text;
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          textChild.data ?? '',
          style: textChild.style,
          textAlign: TextAlign.center,
          maxLines: _calculateMaxLines(),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    // For other widgets, use FittedBox to scale them down if needed
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: child,
    );
  }

  // Calculate max lines based on height constraints
  int _calculateMaxLines() {
    if (maxHeight != null && height != null) {
      // If we have height constraints, allow multiple lines
      return maxHeight! > (height! * 1.5) ? 2 : 1;
    }
    return 1;
  }
}
