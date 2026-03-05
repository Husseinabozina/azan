import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:flutter/material.dart';

/// ============================================================================
/// 🎨 NEW RESPONSIVE DIALOG SYSTEM
/// نظام Dialogs جديد متجاوب تماماً مع landscape و portrait
/// ============================================================================

/// 📐 Dialog Configuration
class NewDialogConfig {
  /// الحصول على الـ sizing المناسب
  static NewDialogSizing getSizing(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final isLandscape = size.width > size.height;

    return NewDialogSizing(
      isLandscape: isLandscape,
      screenWidth: size.width,
      screenHeight: size.height,
    );
  }
}

/// 📏 Dialog Sizing
class NewDialogSizing {
  final bool isLandscape;
  final double screenWidth;
  final double screenHeight;

  NewDialogSizing({
    required this.isLandscape,
    required this.screenWidth,
    required this.screenHeight,
  });

  // ════════════════════════════════════════════════════════════════════════════
  // 📐 Dimensions
  // ════════════════════════════════════════════════════════════════════════════

  /// عرض الـ dialog
  double get dialogWidth {
    if (isLandscape) {
      return screenWidth * 0.55; // 55% في landscape
    } else {
      return screenWidth * 0.85; // 85% في portrait
    }
  }

  /// أقصى ارتفاع للـ dialog
  double get dialogMaxHeight {
    if (isLandscape) {
      return screenHeight * 0.80;
    } else {
      return screenHeight * 0.65;
    }
  }

  /// padding الداخلي
  EdgeInsets get dialogPadding {
    return EdgeInsets.symmetric(
      horizontal: isLandscape ? screenWidth * 0.03 : screenWidth * 0.05,
      vertical: screenHeight * 0.02,
    );
  }

  /// inset من حواف الشاشة
  EdgeInsets get dialogInset {
    return EdgeInsets.symmetric(
      horizontal: isLandscape ? screenWidth * 0.10 : screenWidth * 0.08,
      vertical: isLandscape ? screenHeight * 0.08 : screenHeight * 0.10,
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 📝 Font Sizes
  // ════════════════════════════════════════════════════════════════════════════

  double get titleFontSize => isLandscape ? 22.sp : 18.sp;
  double get subtitleFontSize => isLandscape ? 18.sp : 15.sp;
  double get bodyFontSize => isLandscape ? 16.sp : 14.sp;
  double get captionFontSize => isLandscape ? 13.sp : 12.sp;

  // ════════════════════════════════════════════════════════════════════════════
  // 🔘 Button Sizes
  // ════════════════════════════════════════════════════════════════════════════

  Size get buttonSize {
    if (isLandscape) {
      return Size(screenWidth * 0.12, screenHeight * 0.08);
    } else {
      return Size(screenWidth * 0.20, screenHeight * 0.055);
    }
  }

  double get buttonRadius => isLandscape ? 14.r : 12.r;

  // ════════════════════════════════════════════════════════════════════════════
  // 📏 Spacing
  // ════════════════════════════════════════════════════════════════════════════

  double get verticalGap => isLandscape ? screenHeight * 0.025 : screenHeight * 0.03;
  double get horizontalGap => isLandscape ? screenWidth * 0.02 : screenWidth * 0.03;

  // ════════════════════════════════════════════════════════════════════════════
  // 🎨 Border Radius
  // ════════════════════════════════════════════════════════════════════════════

  double get borderRadius => isLandscape ? 20.r : 18.r;
  double get cardBorderRadius => isLandscape ? 16.r : 14.r;
}

/// ============================================================================
/// 🎪 UNIVERSAL DIALOG SHELL - Shell موحد
/// ============================================================================

class NewUniversalDialogShell extends StatelessWidget {
  final Widget child;
  final bool scrollable;
  final double? maxWidth;
  final double? maxHeight;

  const NewUniversalDialogShell({
    super.key,
    required this.child,
    this.scrollable = false,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final sizing = NewDialogConfig.getSizing(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: sizing.dialogInset,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final effectiveMaxWidth = maxWidth ?? sizing.dialogWidth;
          final effectiveMaxHeight = maxHeight ?? sizing.dialogMaxHeight;

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: effectiveMaxWidth,
              maxHeight: effectiveMaxHeight,
            ),
            child: Container(
              padding: sizing.dialogPadding,
              decoration: BoxDecoration(
                color: AppTheme.dialogBackgroundColor,
                borderRadius: BorderRadius.circular(sizing.borderRadius),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: scrollable
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: child,
                    )
                  : child,
            ),
          );
        },
      ),
    );
  }
}

/// ============================================================================
/// 📋 DIALOG COMPONENTS - مكونات جاهزة
/// ============================================================================

/// 🏷️ Dialog Title
class NewDialogTitle extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? iconColor;

  const NewDialogTitle({
    super.key,
    required this.text,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final sizing = NewDialogConfig.getSizing(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: sizing.titleFontSize * 1.3,
            color: iconColor ?? AppTheme.accentColor,
          ),
          SizedBox(width: sizing.horizontalGap),
        ],
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: TextStyle(
                fontSize: sizing.titleFontSize,
                fontWeight: FontWeight.w700,
                color: AppTheme.dialogTitleColor,
                fontFamily: CacheHelper.getTextsFontFamily(),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

/// 📝 Dialog Subtitle
class NewDialogSubtitle extends StatelessWidget {
  final String text;

  const NewDialogSubtitle({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final sizing = NewDialogConfig.getSizing(context);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: TextStyle(
          fontSize: sizing.subtitleFontSize,
          fontWeight: FontWeight.w500,
          color: AppTheme.secondaryTextColor,
          fontFamily: CacheHelper.getTextsFontFamily(),
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// 📄 Dialog Content Card
class NewDialogContentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const NewDialogContentCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final sizing = NewDialogConfig.getSizing(context);

    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: sizing.screenWidth * 0.02,
            vertical: sizing.verticalGap * 0.8,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(sizing.cardBorderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.w,
        ),
      ),
      child: child,
    );
  }
}

/// 🔘 Dialog Button
class NewDialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isDestructive;

  const NewDialogButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final sizing = NewDialogConfig.getSizing(context);

    final effectiveBgColor = backgroundColor ??
        (isDestructive ? const Color(0xFFE57373) : AppTheme.primaryButtonBackground);
    final effectiveTextColor = textColor ??
        (isDestructive ? Colors.white : AppTheme.primaryButtonTextColor);

    return SizedBox(
      width: sizing.buttonSize.width,
      height: sizing.buttonSize.height,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: effectiveBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sizing.buttonRadius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: sizing.screenWidth * 0.02,
            vertical: sizing.screenHeight * 0.01,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: sizing.bodyFontSize * 1.2,
                color: effectiveTextColor,
              ),
              SizedBox(width: sizing.horizontalGap * 0.5),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: sizing.bodyFontSize,
                    fontFamily: CacheHelper.getTextsFontFamily(),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ↔️ Dialog Button Row
class NewDialogButtonRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;

  const NewDialogButtonRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final sizing = NewDialogConfig.getSizing(context);

    return Wrap(
      spacing: sizing.horizontalGap,
      runSpacing: sizing.verticalGap * 0.5,
      alignment: WrapAlignment.center,
      children: children.map((child) {
        return child;
      }).toList(),
    );
  }
}

/// 📝 Dialog TextField
class NewDialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool isPassword;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixWidget;

  const NewDialogTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.isPassword = false,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
    this.suffixWidget,
  });

  @override
  Widget build(BuildContext context) {
    final sizing = NewDialogConfig.getSizing(context);

    return TextField(
      controller: controller,
      obscureText: isPassword,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        color: Colors.black,
        fontSize: sizing.bodyFontSize,
        fontFamily: CacheHelper.getTextsFontFamily(),
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: sizing.bodyFontSize * 0.9,
        ),
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: sizing.bodyFontSize * 0.9,
        ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: sizing.screenWidth * 0.03,
          vertical: sizing.screenHeight * 0.015,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.grey.shade600)
            : null,
        suffixIcon: suffixWidget,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sizing.borderRadius * 0.7),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sizing.borderRadius * 0.7),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sizing.borderRadius * 0.7),
          borderSide: BorderSide(
            color: AppTheme.accentColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sizing.borderRadius * 0.7),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sizing.borderRadius * 0.7),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// 📋 Dialog List Item
class NewDialogListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isSelected;
  final Widget? trailing;

  const NewDialogListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.isSelected = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final sizing = NewDialogConfig.getSizing(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(sizing.cardBorderRadius * 0.8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sizing.screenWidth * 0.025,
          vertical: sizing.verticalGap * 0.6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(sizing.cardBorderRadius * 0.8),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: sizing.bodyFontSize * 1.3,
                color: isSelected
                    ? AppTheme.accentColor
                    : AppTheme.secondaryTextColor,
              ),
              SizedBox(width: sizing.horizontalGap),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: sizing.bodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.accentColor
                            : AppTheme.primaryTextColor,
                        fontFamily: CacheHelper.getTextsFontFamily(),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: sizing.verticalGap * 0.3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: sizing.captionFontSize,
                          color: AppTheme.secondaryTextColor,
                          fontFamily: CacheHelper.getTextsFontFamily(),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: sizing.horizontalGap),
              trailing!,
            ],
            if (isSelected) ...[
              SizedBox(width: sizing.horizontalGap * 0.5),
              Icon(
                Icons.check_circle,
                size: sizing.bodyFontSize * 1.2,
                color: AppTheme.accentColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 🎯 Dialog Divider
class NewDialogDivider extends StatelessWidget {
  final double? height;
  final Color? color;
  final double? thickness;

  const NewDialogDivider({
    super.key,
    this.height,
    this.color,
    this.thickness,
  });

  @override
  Widget build(BuildContext context) {
    final sizing = NewDialogConfig.getSizing(context);

    return Divider(
      height: height ?? sizing.verticalGap,
      color: color ?? Colors.white.withOpacity(0.15),
      thickness: thickness ?? 1,
    );
  }
}

/// ============================================================================
/// 🎪 PRE-BUILT DIALOGS - Dialogs جاهزة للاستخدام
/// ============================================================================

/// ✅ Simple Alert Dialog
Future<void> showNewAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmText,
  VoidCallback? onConfirm,
  String? cancelText,
  VoidCallback? onCancel,
  IconData? icon,
  bool barrierDismissible = true,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return NewUniversalDialogShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NewDialogTitle(
              text: title,
              icon: icon,
              iconColor: icon != null ? AppTheme.accentColor : null,
            ),
            SizedBox(height: NewDialogConfig.getSizing(context).verticalGap * 0.8),
            NewDialogContentCard(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: NewDialogConfig.getSizing(context).bodyFontSize,
                  color: AppTheme.primaryTextColor,
                  fontFamily: CacheHelper.getTextsFontFamily(),
                  height: 1.6,
                ),
              ),
            ),
            SizedBox(height: NewDialogConfig.getSizing(context).verticalGap),
            NewDialogButtonRow(
              children: [
                if (cancelText != null && onCancel != null)
                  NewDialogButton(
                    text: cancelText,
                    onPressed: () {
                      Navigator.pop(context);
                      onCancel();
                    },
                    backgroundColor: AppTheme.cancelButtonBackgroundColor,
                    textColor: AppTheme.cancelButtonTextColor,
                  ),
                NewDialogButton(
                  text: confirmText ?? 'موافق',
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm?.call();
                  },
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

/// ⚠️ Confirmation Dialog
Future<bool?> showNewConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
  IconData? icon,
  Color? iconColor,
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return NewUniversalDialogShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NewDialogTitle(
              text: title,
              icon: icon,
              iconColor: iconColor ?? AppTheme.accentColor,
            ),
            SizedBox(height: NewDialogConfig.getSizing(context).verticalGap * 0.8),
            NewDialogContentCard(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: NewDialogConfig.getSizing(context).bodyFontSize,
                  color: AppTheme.primaryTextColor,
                  fontFamily: CacheHelper.getTextsFontFamily(),
                  height: 1.6,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: NewDialogConfig.getSizing(context).verticalGap),
            NewDialogButtonRow(
              children: [
                NewDialogButton(
                  text: cancelText ?? 'إلغاء',
                  onPressed: () => Navigator.pop(context, false),
                  backgroundColor: AppTheme.cancelButtonBackgroundColor,
                  textColor: AppTheme.cancelButtonTextColor,
                ),
                NewDialogButton(
                  text: confirmText ?? 'تأكيد',
                  onPressed: () => Navigator.pop(context, true),
                  isDestructive: true,
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

/// 📝 Input Dialog
Future<String?> showNewInputDialog({
  required BuildContext context,
  required String title,
  required String hint,
  String? initialValue,
  int maxLines = 1,
  IconData? icon,
}) async {
  final controller = TextEditingController(text: initialValue ?? '');
  final sizing = NewDialogConfig.getSizing(context);

  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return NewUniversalDialogShell(
        scrollable: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NewDialogTitle(
              text: title,
              icon: icon,
            ),
            SizedBox(height: sizing.verticalGap),
            NewDialogTextField(
              controller: controller,
              hintText: hint,
              maxLines: maxLines,
            ),
            SizedBox(height: sizing.verticalGap),
            NewDialogButtonRow(
              children: [
                NewDialogButton(
                  text: 'إلغاء',
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: AppTheme.cancelButtonBackgroundColor,
                  textColor: AppTheme.cancelButtonTextColor,
                ),
                NewDialogButton(
                  text: 'موافق',
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.pop(context, text);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

/// 📋 Single Choice Dialog
Future<T?> showNewSingleChoiceDialog<T>({
  required BuildContext context,
  required String title,
  required List<DialogChoiceItem<T>> items,
  T? initialValue,
}) async {
  T? selectedValue = initialValue;
  final sizing = NewDialogConfig.getSizing(context);

  return showDialog<T>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return NewUniversalDialogShell(
            scrollable: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NewDialogTitle(text: title),
                SizedBox(height: sizing.verticalGap * 0.8),
                NewDialogContentCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: items.map((item) {
                      final isSelected = selectedValue == item.value;
                      return NewDialogListItem(
                        title: item.title,
                        subtitle: item.subtitle,
                        icon: item.icon,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => selectedValue = item.value);
                        },
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: sizing.verticalGap),
                NewDialogButtonRow(
                  children: [
                    NewDialogButton(
                      text: 'إلغاء',
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: AppTheme.cancelButtonBackgroundColor,
                      textColor: AppTheme.cancelButtonTextColor,
                    ),
                    NewDialogButton(
                      text: 'موافق',
                      onPressed: () {
                        if (selectedValue != null) {
                          Navigator.pop(context, selectedValue);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// 🎁 Dialog Choice Item
class DialogChoiceItem<T> {
  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;

  DialogChoiceItem({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
  });
}
