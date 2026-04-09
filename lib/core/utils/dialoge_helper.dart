import 'dart:math' as math;

import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:flutter/material.dart';

ThemeData buildAppDialogTheme(BuildContext context) {
  final baseTheme = Theme.of(context);
  final fontFamily = CacheHelper.getTextsFontFamily();

  return baseTheme.copyWith(
    textTheme: baseTheme.textTheme.apply(
      fontFamily: fontFamily,
      bodyColor: DialogPalette.bodyTextColor,
      displayColor: DialogPalette.titleTextColor,
    ),
    primaryTextTheme: baseTheme.primaryTextTheme.apply(
      fontFamily: fontFamily,
      bodyColor: DialogPalette.bodyTextColor,
      displayColor: DialogPalette.titleTextColor,
    ),
    colorScheme: baseTheme.colorScheme.copyWith(
      primary: DialogPalette.primaryButtonBackground,
      onPrimary: DialogPalette.primaryButtonText,
      secondary: DialogPalette.iconColor,
      onSecondary: DialogPalette.surfaceColor,
      surface: DialogPalette.surfaceColor,
      onSurface: DialogPalette.bodyTextColor,
      outline: DialogPalette.borderColor,
      error: DialogPalette.destructiveButtonBackground,
      onError: DialogPalette.destructiveButtonText,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: Colors.transparent),
    scaffoldBackgroundColor: Colors.transparent,
    iconTheme: IconThemeData(color: DialogPalette.iconColor),
    dividerTheme: DividerThemeData(color: DialogPalette.dividerColor),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DialogPalette.inputFillColor,
      hintStyle: TextStyle(
        color: DialogPalette.inputHintColor,
        fontFamily: fontFamily,
      ),
      labelStyle: TextStyle(
        color: DialogPalette.inputHintColor,
        fontFamily: fontFamily,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: DialogPalette.inputBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: DialogPalette.inputBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: DialogPalette.inputFocusedBorderColor,
          width: 2,
        ),
      ),
    ),
  );
}

/// ============================================================================
/// Responsive dialog system shared across old and new dialog APIs.
/// ============================================================================

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  RouteSettings? routeSettings,
  bool useSafeArea = true,
  bool useRootNavigator = true,
}) {
  return showDialog<T>(
    context: context,
    builder: (dialogContext) {
      return Theme(
        data: buildAppDialogTheme(dialogContext),
        child: builder(dialogContext),
      );
    },
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? DialogPalette.barrierColor,
    routeSettings: routeSettings,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
  );
}

class DialogConfig {
  static DialogSizing getSizing(BuildContext context) {
    final isLandscape = UiRotationCubit().isLandscape();
    final screenSize = MediaQuery.of(context).size;

    return DialogSizing(
      isLandscape: isLandscape,
      screenWidth: screenSize.width,
      screenHeight: screenSize.height,
    );
  }
}

class DialogSizing {
  DialogSizing({
    required this.isLandscape,
    required this.screenWidth,
    required this.screenHeight,
  });

  final bool isLandscape;
  final double screenWidth;
  final double screenHeight;

  double get dialogWidth {
    const maxDialogWidth = 640.0;
    final calculatedWidth = isLandscape
        ? screenWidth * 0.55
        : screenWidth * 0.88;
    return calculatedWidth.clamp(320.0, maxDialogWidth);
  }

  double get dialogMaxHeight {
    const maxDialogHeight = 650.0;
    final calculatedHeight = isLandscape
        ? screenHeight * 0.80
        : screenHeight * 0.70;
    return calculatedHeight.clamp(350.0, maxDialogHeight);
  }

  EdgeInsets get dialogPadding {
    return EdgeInsets.symmetric(
      horizontal: isLandscape ? screenWidth * 0.025 : screenWidth * 0.04,
      vertical: screenHeight * 0.025,
    );
  }

  EdgeInsets get dialogInset {
    if (isLandscape) {
      return EdgeInsets.symmetric(
        horizontal: screenWidth * 0.10,
        vertical: screenHeight * 0.08,
      );
    }

    return EdgeInsets.symmetric(
      horizontal: screenWidth * 0.06,
      vertical: screenHeight * 0.08,
    );
  }

  double get titleFontSize {
    if (isLandscape) {
      return 20.0 * (screenWidth / 960.0);
    }
    return 18.0 * (screenWidth / 393.0);
  }

  double get bodyFontSize {
    if (isLandscape) {
      return 16.0 * (screenWidth / 960.0);
    }
    return 15.0 * (screenWidth / 393.0);
  }

  Size get buttonSize {
    if (isLandscape) {
      return Size(screenWidth * 0.08, screenHeight * 0.06);
    }
    return Size(screenWidth * 0.22, screenHeight * 0.055);
  }

  double get verticalGap {
    return isLandscape ? screenHeight * 0.03 : screenHeight * 0.035;
  }

  double get borderRadius {
    final baseRadius = isLandscape ? 18.0 : 20.0;
    final scale =
        math.min(screenWidth, screenHeight) / (isLandscape ? 960.0 : 393.0);
    return baseRadius * scale;
  }

  double get textFieldHeight => isLandscape ? 48.0 : 52.0;

  double get timePickerWidth => dialogWidth;
  double get timePickerHeight => dialogMaxHeight;
  EdgeInsets get timePickerInset => dialogInset;
}

class DialogPalette {
  static const Color barrierColor = Color(0xB3000000);
  static const Color surfaceColor = Color(0xFF101923);
  static const Color surfaceRaisedColor = Color(0xFF172230);
  static const Color titleTextColor = Color(0xFFF4E2B0);
  static const Color titleColor = titleTextColor;
  static const Color bodyTextColor = Color(0xFFF6F8FB);
  static const Color mutedTextColor = Color(0xFFB8C5D5);
  static const Color iconColor = Color(0xFFE5BF72);
  static const Color borderColor = Color(0x4DF4E2B0);
  static const Color dividerColor = Color(0x336E8095);
  static const Color cardBackground = Color(0xFF172230);
  static const Color selectedTileBackground = Color(0x1AD4A64A);
  static const Color selectionBorder = Color(0x66D4A64A);
  static const Color inputFillColor = Color(0xFFF7F8FA);
  static const Color inputTextColor = Color(0xFF18202A);
  static const Color inputHintColor = Color(0xFF748193);
  static const Color inputBorderColor = Color(0xFFD7DEE6);
  static const Color inputFocusedBorderColor = Color(0xFFD4A64A);
  static const Color secondaryButtonBackground = Color(0xFF243243);
  static const Color secondaryButtonText = Color(0xFFF5F7FA);
  static const Color destructiveButtonBackground = Color(0xFFC65151);
  static const Color destructiveButtonText = Color(0xFFFFFFFF);
  static const Color primaryButtonBackground = Color(0xFFD4A64A);
  static const Color primaryButtonText = Color(0xFF1C150A);
  static const Color backgroundColor = surfaceColor;
}

class UniversalDialogShell extends StatelessWidget {
  const UniversalDialogShell({
    super.key,
    required this.child,
    this.forceMaxHeight = false,
    this.customMaxWidth,
    this.customMaxHeight,
  });

  final Widget child;
  final bool forceMaxHeight;
  final double? customMaxWidth;
  final double? customMaxHeight;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: sizing.dialogInset,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final desiredMaxHeight =
              customMaxHeight ??
              (forceMaxHeight ? sizing.dialogMaxHeight : constraints.maxHeight);
          final maxHeight = math.min(desiredMaxHeight, constraints.maxHeight);
          final maxWidth = math.min(
            customMaxWidth ?? sizing.dialogWidth,
            constraints.maxWidth,
          );

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: Container(
              padding: sizing.dialogPadding,
              decoration: BoxDecoration(
                color: DialogPalette.backgroundColor,
                borderRadius: BorderRadius.circular(sizing.borderRadius),
                border: Border.all(
                  color: DialogPalette.borderColor,
                  width: sizing.screenWidth * 0.008,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class DialogTitle extends StatelessWidget {
  const DialogTitle(this.text, {super.key, this.icon, this.iconColor});

  final String text;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);
    final title = Text(
      text,
      style: TextStyle(
        fontSize: sizing.titleFontSize,
        fontWeight: FontWeight.bold,
        color: DialogPalette.titleColor,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );

    if (icon == null) {
      return title;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: iconColor ?? DialogPalette.iconColor,
          size: sizing.titleFontSize * 1.6,
        ),
        SizedBox(height: sizing.verticalGap * 0.35),
        title,
      ],
    );
  }
}

class DialogBodyText extends StatelessWidget {
  const DialogBodyText(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.maxLines,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: TextStyle(
        color: color ?? DialogPalette.bodyTextColor,
        fontSize: sizing.bodyFontSize,
        fontWeight: fontWeight ?? FontWeight.w500,
        height: 1.5,
      ),
    );
  }
}

class DialogContentCard extends StatelessWidget {
  const DialogContentCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);
    return Container(
      width: double.infinity,
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: sizing.screenWidth * 0.03,
            vertical: sizing.verticalGap * 0.55,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? DialogPalette.cardBackground,
        borderRadius: BorderRadius.circular(sizing.borderRadius * 0.8),
        border: Border.all(color: DialogPalette.dividerColor, width: 1),
      ),
      child: child,
    );
  }
}

class DialogTextField extends StatelessWidget {
  const DialogTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.maxLines = 1,
    this.textAlign = TextAlign.right,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final int maxLines;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);
    final fixedHeight = maxLines == 1 ? sizing.textFieldHeight : null;

    return SizedBox(
      height: fixedHeight,
      child: TextField(
        controller: controller,
        textAlign: textAlign,
        maxLines: maxLines,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(
          color: DialogPalette.inputTextColor,
          fontSize: sizing.bodyFontSize,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: DialogPalette.inputFillColor,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: sizing.screenWidth * 0.035,
            vertical: maxLines == 1
                ? sizing.textFieldHeight * 0.3
                : sizing.screenHeight * 0.016,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizing.borderRadius * 0.7),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizing.borderRadius * 0.7),
            borderSide: const BorderSide(
              color: DialogPalette.inputBorderColor,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizing.borderRadius * 0.7),
            borderSide: const BorderSide(
              color: DialogPalette.inputFocusedBorderColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class DialogSearchField extends StatelessWidget {
  const DialogSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: DialogPalette.inputTextColor,
        fontSize: sizing.bodyFontSize,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: DialogPalette.inputFillColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: sizing.screenWidth * 0.03,
          vertical: sizing.screenHeight * 0.014,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sizing.borderRadius * 0.9),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sizing.borderRadius * 0.9),
          borderSide: const BorderSide(
            color: DialogPalette.inputBorderColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sizing.borderRadius * 0.9),
          borderSide: const BorderSide(
            color: DialogPalette.inputFocusedBorderColor,
            width: 2,
          ),
        ),
      ),
    );
  }
}

enum DialogButtonVariant { primary, secondary, destructive }

class DialogButton extends StatelessWidget {
  const DialogButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.fontWeight = FontWeight.w600,
    this.icon,
    this.variant = DialogButtonVariant.primary,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final FontWeight fontWeight;
  final IconData? icon;
  final DialogButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);
    final resolvedBackground = backgroundColor ?? _variantBackground();
    final resolvedTextColor = textColor ?? _variantTextColor();

    return SizedBox(
      width: sizing.buttonSize.width,
      height: sizing.buttonSize.height,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: resolvedBackground,
          foregroundColor: resolvedTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sizing.borderRadius * 0.8),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: sizing.bodyFontSize * 1.1),
              SizedBox(width: sizing.screenWidth * 0.01),
            ],
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: resolvedTextColor,
                  fontWeight: fontWeight,
                  fontSize: sizing.bodyFontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _variantBackground() {
    switch (variant) {
      case DialogButtonVariant.secondary:
        return DialogPalette.secondaryButtonBackground;
      case DialogButtonVariant.destructive:
        return DialogPalette.destructiveButtonBackground;
      case DialogButtonVariant.primary:
        return DialogPalette.primaryButtonBackground;
    }
  }

  Color _variantTextColor() {
    switch (variant) {
      case DialogButtonVariant.secondary:
        return DialogPalette.secondaryButtonText;
      case DialogButtonVariant.destructive:
        return DialogPalette.destructiveButtonText;
      case DialogButtonVariant.primary:
        return DialogPalette.primaryButtonText;
    }
  }
}

class DialogButtonRow extends StatelessWidget {
  const DialogButtonRow({
    super.key,
    this.leftButton,
    this.rightButton,
    this.children,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  final Widget? leftButton;
  final Widget? rightButton;
  final List<Widget>? children;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);
    final items =
        children ??
        <Widget>[
          if (leftButton != null) leftButton!,
          if (rightButton != null) rightButton!,
        ];

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: sizing.screenWidth * 0.03,
      runSpacing: sizing.verticalGap * 0.3,
      children: items,
    );
  }
}

class DialogSelectableTile extends StatelessWidget {
  const DialogSelectableTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.isSelected = false,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isSelected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(sizing.borderRadius * 0.75),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: sizing.screenWidth * 0.03,
            vertical: sizing.verticalGap * 0.35,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? DialogPalette.selectedTileBackground
                : Colors.transparent,
            borderRadius: BorderRadius.circular(sizing.borderRadius * 0.75),
            border: Border.all(
              color: isSelected
                  ? DialogPalette.selectionBorder
                  : DialogPalette.dividerColor,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isSelected
                      ? DialogPalette.primaryButtonBackground
                      : DialogPalette.iconColor,
                ),
                SizedBox(width: sizing.screenWidth * 0.025),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: DialogPalette.bodyTextColor,
                        fontSize: sizing.bodyFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      SizedBox(height: sizing.verticalGap * 0.15),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: DialogPalette.mutedTextColor,
                          fontSize: sizing.bodyFontSize * 0.9,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (trailing == null && isSelected)
                const Icon(
                  Icons.check_circle,
                  color: DialogPalette.primaryButtonBackground,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DialogCloseButton extends StatelessWidget {
  const DialogCloseButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);

    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashRadius: sizing.bodyFontSize * 1.6,
      onPressed: onPressed,
      icon: Icon(
        Icons.close_rounded,
        color: DialogPalette.iconColor,
        size: sizing.titleFontSize * 1.25,
      ),
    );
  }
}

Future<TimeOfDay?> showUniversalTimePicker(
  BuildContext context, {
  TimeOfDay? initialTime,
  TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
}) async {
  final sizing = DialogConfig.getSizing(context);

  return showTimePicker(
    context: context,
    initialTime: initialTime ?? TimeOfDay.now(),
    initialEntryMode: initialEntryMode,
    builder: (context, child) {
      final baseTheme = Theme.of(context);
      final dialogBg = DialogPalette.surfaceColor;
      final accent = DialogPalette.primaryButtonBackground;
      final onDialog = _ensureContrast(Colors.white, dialogBg);
      final onAccent = _ensureContrast(Colors.white, accent);

      return Theme(
        data: baseTheme.copyWith(
          dialogTheme: DialogThemeData(backgroundColor: dialogBg),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: dialogBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(sizing.borderRadius),
            ),
            padding: EdgeInsets.all(sizing.screenWidth * 0.025),
            helpTextStyle: TextStyle(
              fontSize: sizing.bodyFontSize * 0.95,
              fontWeight: FontWeight.w600,
              color: DialogPalette.mutedTextColor,
              fontFamily: CacheHelper.getTimesFontFamily(),
            ),
            hourMinuteTextStyle: TextStyle(
              fontSize: sizing.titleFontSize * 1.6,
              fontWeight: FontWeight.bold,
              color: onDialog,
              fontFamily: CacheHelper.getTimesFontFamily(),
            ),
            dayPeriodTextStyle: TextStyle(
              fontSize: sizing.bodyFontSize,
              fontWeight: FontWeight.w800,
              color: onDialog,
              fontFamily: CacheHelper.getTimesFontFamily(),
            ),
            dialTextStyle: TextStyle(
              fontSize: sizing.bodyFontSize,
              fontWeight: FontWeight.w700,
              color: DialogPalette.bodyTextColor,
              fontFamily: CacheHelper.getTimesFontFamily(),
            ),
            dialHandColor: accent,
            dialBackgroundColor: DialogPalette.surfaceRaisedColor,
            cancelButtonStyle: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(accent),
              textStyle: WidgetStatePropertyAll(
                TextStyle(
                  fontSize: sizing.bodyFontSize * 1.1,
                  fontWeight: FontWeight.bold,
                  fontFamily: CacheHelper.getTimesFontFamily(),
                ),
              ),
            ),
            confirmButtonStyle: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(accent),
              textStyle: WidgetStatePropertyAll(
                TextStyle(
                  fontSize: sizing.bodyFontSize * 1.1,
                  fontWeight: FontWeight.bold,
                  fontFamily: CacheHelper.getTimesFontFamily(),
                ),
              ),
            ),
          ),
          colorScheme: baseTheme.colorScheme.copyWith(
            primary: accent,
            onPrimary: onAccent,
            surface: dialogBg,
            onSurface: onDialog,
          ),
        ),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: sizing.timePickerWidth,
              maxHeight: sizing.timePickerHeight,
            ),
            child: child!,
          ),
        ),
      );
    },
  );
}

Future<DateTime?> showUniversalDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final sizing = DialogConfig.getSizing(context);
  final now = initialDate ?? DateTime.now();

  return showDatePicker(
    context: context,
    initialDate: now,
    firstDate: firstDate ?? DateTime(now.year - 1),
    lastDate: lastDate ?? DateTime(now.year + 5),
    builder: (context, child) {
      final baseTheme = Theme.of(context);

      return Theme(
        data: baseTheme.copyWith(
          colorScheme: baseTheme.colorScheme.copyWith(
            primary: DialogPalette.primaryButtonBackground,
            onPrimary: DialogPalette.primaryButtonText,
            surface: DialogPalette.surfaceColor,
            onSurface: DialogPalette.bodyTextColor,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: DialogPalette.surfaceColor,
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: DialogPalette.surfaceColor,
            headerBackgroundColor: DialogPalette.surfaceRaisedColor,
            headerForegroundColor: DialogPalette.titleTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(sizing.borderRadius),
            ),
            headerHeadlineStyle: TextStyle(
              fontSize: sizing.titleFontSize * 1.25,
              fontWeight: FontWeight.bold,
              color: DialogPalette.titleTextColor,
            ),
            headerHelpStyle: TextStyle(
              fontSize: sizing.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: DialogPalette.mutedTextColor,
            ),
            weekdayStyle: TextStyle(
              fontSize: sizing.bodyFontSize * 0.95,
              fontWeight: FontWeight.w600,
              color: DialogPalette.mutedTextColor,
            ),
            dayStyle: TextStyle(
              fontSize: sizing.bodyFontSize * 1.05,
              fontWeight: FontWeight.w500,
              color: DialogPalette.bodyTextColor,
            ),
            yearStyle: TextStyle(
              fontSize: sizing.bodyFontSize * 1.2,
              fontWeight: FontWeight.w600,
              color: DialogPalette.bodyTextColor,
            ),
            dayForegroundColor: WidgetStateProperty.all(
              DialogPalette.bodyTextColor,
            ),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return DialogPalette.primaryButtonBackground;
              }
              return Colors.transparent;
            }),
            todayBackgroundColor: WidgetStateProperty.all(
              DialogPalette.primaryButtonBackground.withValues(alpha: 0.2),
            ),
            todayBorder: const BorderSide(
              color: DialogPalette.primaryButtonBackground,
              width: 1,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: DialogPalette.primaryButtonBackground,
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: sizing.bodyFontSize * 1.1,
              ),
            ),
          ),
        ),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: sizing.dialogWidth,
              maxHeight: sizing.dialogMaxHeight,
            ),
            child: child!,
          ),
        ),
      );
    },
  );
}

Color _ensureContrast(Color foreground, Color background) {
  final fgLuminance = foreground.computeLuminance();
  final bgLuminance = background.computeLuminance();
  final contrast =
      (math.max(fgLuminance, bgLuminance) + 0.05) /
      (math.min(fgLuminance, bgLuminance) + 0.05);

  if (contrast < 4.5) {
    return bgLuminance > 0.5 ? Colors.black87 : Colors.white;
  }

  return foreground;
}
