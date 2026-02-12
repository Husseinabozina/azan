import 'dart:math' as math;
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// ============================================================================
/// 🎯 RESPONSIVE DIALOG SYSTEM - بدون clamp، بدعم كامل للorientation
/// ============================================================================

class DialogConfig {
  /// احصل على الconfiguration الصحيحة بناءً على الorientation والشاشة
  static DialogSizing getSizing(BuildContext context) {
    final isLandscape = UiRotationCubit().isLandscape();
    final screenSize = MediaQuery.of(context).size;

    // احسب العرض الفعلي للشاشة
    final effectiveWidth = isLandscape ? screenSize.width : screenSize.width;
    final effectiveHeight = isLandscape ? screenSize.height : screenSize.height;

    return DialogSizing(
      isLandscape: isLandscape,
      screenWidth: effectiveWidth,
      screenHeight: effectiveHeight,
    );
  }
}

class DialogSizing {
  final bool isLandscape;
  final double screenWidth;
  final double screenHeight;

  DialogSizing({
    required this.isLandscape,
    required this.screenWidth,
    required this.screenHeight,
  });

  /// احسب العرض المناسب للdialog (نسبة من الشاشة)
  double get dialogWidth {
    if (isLandscape) {
      // في الlandscape: 60-70% من العرض
      return screenWidth * 0.65;
    } else {
      // في الportrait: 85-90% من العرض
      return screenWidth * 0.88;
    }
  }

  /// احسب الارتفاع الأقصى للdialog
  double get dialogMaxHeight {
    if (isLandscape) {
      // في الlandscape: 85% من الارتفاع (عشان الكيبورد)
      return screenHeight * 0.85;
    } else {
      // في الportrait: 70% من الارتفاع
      return screenHeight * 0.70;
    }
  }

  /// padding داخلي للdialog
  EdgeInsets get dialogPadding {
    if (isLandscape) {
      return EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025, // ~2.5%
        vertical: screenHeight * 0.015, // ~1.5%
      );
    } else {
      return EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04, // ~4%
        vertical: screenHeight * 0.015, // ~1.5%
      );
    }
  }

  /// inset للdialog من حواف الشاشة
  EdgeInsets get dialogInset {
    if (isLandscape) {
      return EdgeInsets.symmetric(
        horizontal: screenWidth * 0.08,
        vertical: screenHeight * 0.05,
      );
    } else {
      return EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: screenHeight * 0.08,
      );
    }
  }

  /// حجم الخط للعناوين
  double get titleFontSize {
    if (isLandscape) {
      // في landscape: نستخدم العرض عشان الشاشة أوسع
      final scale = screenWidth / 960.0;
      return 18.0 * scale; // ✅ أكبر من portrait
    } else {
      // في portrait: نستخدم العرض
      final scale = screenWidth / 393.0;
      return 16.0 * scale;
    }
  }

  /// حجم الخط للنصوص العادية
  double get bodyFontSize {
    if (isLandscape) {
      // في landscape: نستخدم العرض
      final scale = screenWidth / 960.0;
      return 14.0 * scale; // ✅ أكبر من portrait
    } else {
      // في portrait: نستخدم العرض
      final scale = screenWidth / 393.0;
      return 13.0 * scale;
    }
  }

  /// حجم الأزرار
  Size get buttonSize {
    if (isLandscape) {
      // في landscape: أزرار أكبر عشان الشاشة واسعة
      return Size(screenWidth * 0.14, screenHeight * 0.10);
    } else {
      // في portrait: أزرار عادية
      return Size(screenWidth * 0.22, screenHeight * 0.048);
    }
  }

  /// المسافات الرأسية
  double get verticalGap {
    return isLandscape ? screenHeight * 0.02 : screenHeight * 0.025;
  }

  /// border radius
  double get borderRadius {
    final baseRadius = isLandscape ? 16.0 : 18.0;
    final scale =
        math.min(screenWidth, screenHeight) / (isLandscape ? 960 : 393);
    return baseRadius * scale;
  }
}

/// ============================================================================
/// 🎨 UNIVERSAL DIALOG SHELL - Shell موحد لكل الdialogs
/// ============================================================================

class UniversalDialogShell extends StatelessWidget {
  final Widget child;
  final bool forceMaxHeight;
  final double? customMaxHeight;

  const UniversalDialogShell({
    super.key,
    required this.child,
    this.forceMaxHeight = false,
    this.customMaxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: sizing.dialogInset,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // constraints هنا بالفعل "بعد الكيبورد" لأن Dialog بيعالج viewInsets تلقائيًا
          final desiredMax =
              customMaxHeight ??
              (forceMaxHeight ? sizing.dialogMaxHeight : constraints.maxHeight);

          final maxHeight = math.min(desiredMax, constraints.maxHeight);

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: sizing.dialogWidth,
              maxHeight: maxHeight,
            ),
            child: Container(
              padding: sizing.dialogPadding,
              decoration: BoxDecoration(
                color: AppTheme.dialogBackgroundColor,
                borderRadius: BorderRadius.circular(sizing.borderRadius),
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: sizing.screenWidth * 0.008,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
              //  GestureDetector(
              //   // behavior: HitTestBehavior.translucent,
              //   // onTap: () => FocusScope.of(
              //   //   context,
              //   // ).unfocus(), // يقفل الكيبورد من غير ما يقفل الديالوج
              //   child: child,
              // ),
            ),
          );
        },
      ),
    );
  }
}

/// 🛠️ DIALOG COMPONENTS - مكونات جاهزة للاستخدام
/// ============================================================================

class DialogTitle extends StatelessWidget {
  final String text;

  const DialogTitle(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);

    return Text(
      text,
      style: TextStyle(
        fontSize: sizing.titleFontSize,
        fontWeight: FontWeight.bold,
        color: AppTheme.dialogTitleColor,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}

class DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextAlign textAlign;

  const DialogTextField({
    Key? key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.textAlign = TextAlign.right,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);

    return TextField(
      controller: controller,
      textAlign: textAlign,
      maxLines: maxLines,
      style: TextStyle(color: Colors.black, fontSize: sizing.bodyFontSize),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: sizing.screenWidth * 0.035,
          vertical: sizing.screenHeight * 0.015,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sizing.borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final FontWeight fontWeight;

  const DialogButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.fontWeight = FontWeight.w600,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);

    return SizedBox(
      width: sizing.buttonSize.width,
      height: sizing.buttonSize.height,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sizing.borderRadius * 0.8),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: fontWeight,
            fontSize: sizing.bodyFontSize,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class DialogButtonRow extends StatelessWidget {
  final Widget leftButton;
  final Widget rightButton;

  const DialogButtonRow({
    Key? key,
    required this.leftButton,
    required this.rightButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        leftButton,
        SizedBox(width: sizing.screenWidth * 0.03),
        rightButton,
      ],
    );
  }
}

/// ============================================================================
/// ⏰ ENHANCED TIME PICKER - محسّن للlandscape والportrait
/// ============================================================================

Future<TimeOfDay?> showUniversalTimePicker(BuildContext context) async {
  final sizing = DialogConfig.getSizing(context);

  return await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (context, child) {
      final baseTheme = Theme.of(context);

      // دالة لحساب الcontras للألوان
      Color ensureContrast(Color fg, Color bg) {
        final fgLuminance = fg.computeLuminance();
        final bgLuminance = bg.computeLuminance();
        final contrast =
            (math.max(fgLuminance, bgLuminance) + 0.05) /
            (math.min(fgLuminance, bgLuminance) + 0.05);

        if (contrast < 4.5) {
          return bgLuminance > 0.5 ? Colors.black87 : Colors.white;
        }
        return fg;
      }

      final dialogBg = AppTheme.dialogBackgroundColor;
      final accent = AppTheme.primaryButtonBackground;
      final onDialog = ensureContrast(Colors.white, dialogBg);
      final onAccent = ensureContrast(Colors.white, accent);

      final timePickerTheme = TimePickerThemeData(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sizing.borderRadius),
        ),
        padding: EdgeInsets.all(sizing.screenWidth * 0.025),

        helpTextStyle: TextStyle(
          fontSize: sizing.bodyFontSize * 0.95,
          fontWeight: FontWeight.w600,
          color: onDialog.withOpacity(0.8),
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
          fontFamily: CacheHelper.getTimesFontFamily(),
        ),

        dialHandColor: accent,
        dialBackgroundColor: dialogBg.withOpacity(0.3),

        cancelButtonStyle: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontSize: sizing.bodyFontSize * 1.1,
              fontWeight: FontWeight.bold,
              fontFamily: CacheHelper.getTimesFontFamily(),
            ),
          ),
          foregroundColor: WidgetStatePropertyAll(accent),
        ),

        confirmButtonStyle: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontSize: sizing.bodyFontSize * 1.1,
              fontWeight: FontWeight.bold,
              fontFamily: CacheHelper.getTimesFontFamily(),
            ),
          ),
          foregroundColor: WidgetStatePropertyAll(accent),
        ),
      );

      return Theme(
        data: baseTheme.copyWith(
          dialogBackgroundColor: dialogBg,
          timePickerTheme: timePickerTheme,
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

/// ============================================================================
/// 📅 ENHANCED DATE PICKER - محسّن للlandscape والportrait
/// ============================================================================

Future<DateTime?> showUniversalDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final sizing = DialogConfig.getSizing(context);
  final now = initialDate ?? DateTime.now();

  return await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: firstDate ?? DateTime(now.year - 1),
    lastDate: lastDate ?? DateTime(now.year + 5),
    builder: (context, child) {
      final baseTheme = Theme.of(context);

      final datePickerTheme = DatePickerThemeData(
        backgroundColor: AppTheme.dialogBackgroundColor,
        headerBackgroundColor: AppTheme.dialogBackgroundColor,
        headerForegroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sizing.borderRadius),
        ),

        headerHeadlineStyle: TextStyle(
          fontSize: sizing.titleFontSize * 1.25,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),

        headerHelpStyle: TextStyle(
          fontSize: sizing.bodyFontSize,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),

        weekdayStyle: TextStyle(
          fontSize: sizing.bodyFontSize * 0.95,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),

        dayStyle: TextStyle(
          fontSize: sizing.bodyFontSize * 1.05,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),

        yearStyle: TextStyle(
          fontSize: sizing.bodyFontSize * 1.2,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),

        dayForegroundColor: WidgetStateProperty.all(Colors.white),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTheme.primaryTextColor;
          }
          return Colors.transparent;
        }),

        todayBackgroundColor: WidgetStateProperty.all(
          AppTheme.primaryTextColor.withOpacity(0.2),
        ),

        todayBorder: BorderSide(color: AppTheme.primaryTextColor, width: 1),
      );

      return Theme(
        data: baseTheme.copyWith(
          colorScheme: baseTheme.colorScheme.copyWith(
            primary: AppTheme.accentColor,
            onPrimary: Colors.white,
            surface: AppTheme.darkBlue,
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: AppTheme.darkBlue,
          datePickerTheme: datePickerTheme,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.accentColor,
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
