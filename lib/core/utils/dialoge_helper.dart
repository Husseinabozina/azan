import 'dart:math' as math;

import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:flutter/material.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

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

class _VirtualKeyboardCoordinator extends ChangeNotifier {
  String? _activeFieldId;

  bool isActive(String fieldId) => _activeFieldId == fieldId;

  void activate(String fieldId) {
    if (_activeFieldId == fieldId) {
      return;
    }
    _activeFieldId = fieldId;
    notifyListeners();
  }

  void deactivate(String fieldId) {
    if (_activeFieldId != fieldId) {
      return;
    }
    _activeFieldId = null;
    notifyListeners();
  }

  void hideAll() {
    if (_activeFieldId == null) {
      return;
    }
    _activeFieldId = null;
    notifyListeners();
  }
}

final _virtualKeyboardCoordinator = _VirtualKeyboardCoordinator();

enum _VirtualKeyboardFieldKind { text, numeric }

class VirtualKeyboardFieldTheme {
  const VirtualKeyboardFieldTheme({
    required this.fillColor,
    required this.borderColor,
    required this.activeBorderColor,
    required this.errorBorderColor,
    required this.textColor,
    required this.hintColor,
    required this.labelColor,
    required this.keyboardTextColor,
    required this.keyboardBackgroundColor,
    required this.keyboardBorderColor,
    required this.keyboardShadow,
  });

  final Color fillColor;
  final Color borderColor;
  final Color activeBorderColor;
  final Color errorBorderColor;
  final Color textColor;
  final Color hintColor;
  final Color labelColor;
  final Color keyboardTextColor;
  final Color keyboardBackgroundColor;
  final Color keyboardBorderColor;
  final List<BoxShadow> keyboardShadow;
}

class VirtualTextField extends StatelessWidget {
  const VirtualTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.textAlign = TextAlign.right,
    this.textDirection = TextDirection.rtl,
    this.prefix,
    this.suffix,
    this.contentPadding,
    this.minFieldHeight,
    this.borderRadius,
    this.textStyle,
    this.labelStyle,
    this.errorStyle,
    this.theme = const VirtualKeyboardFieldTheme(
      fillColor: DialogPalette.inputFillColor,
      borderColor: DialogPalette.inputBorderColor,
      activeBorderColor: DialogPalette.inputFocusedBorderColor,
      errorBorderColor: Colors.red,
      textColor: DialogPalette.inputTextColor,
      hintColor: DialogPalette.inputHintColor,
      labelColor: DialogPalette.inputHintColor,
      keyboardTextColor: DialogPalette.inputTextColor,
      keyboardBackgroundColor: Colors.white,
      keyboardBorderColor: Color(0x66D4A64A),
      keyboardShadow: [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    ),
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Widget? prefix;
  final Widget? suffix;
  final EdgeInsetsGeometry? contentPadding;
  final double? minFieldHeight;
  final double? borderRadius;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final VirtualKeyboardFieldTheme theme;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return _VirtualKeyboardEditableField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      textAlign: textAlign,
      textDirection: textDirection,
      prefix: prefix,
      suffix: suffix,
      contentPadding: contentPadding,
      minFieldHeight: minFieldHeight,
      borderRadius: borderRadius,
      textStyle: textStyle,
      labelStyle: labelStyle,
      errorStyle: errorStyle,
      theme: theme,
      kind: _VirtualKeyboardFieldKind.text,
      obscureText: obscureText,
    );
  }
}

class VirtualSearchField extends StatelessWidget {
  const VirtualSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.textAlign = TextAlign.right,
    this.contentPadding,
    this.borderRadius,
    this.textStyle,
    this.theme = const VirtualKeyboardFieldTheme(
      fillColor: DialogPalette.inputFillColor,
      borderColor: DialogPalette.inputBorderColor,
      activeBorderColor: DialogPalette.inputFocusedBorderColor,
      errorBorderColor: Colors.red,
      textColor: DialogPalette.inputTextColor,
      hintColor: DialogPalette.inputHintColor,
      labelColor: DialogPalette.inputHintColor,
      keyboardTextColor: DialogPalette.inputTextColor,
      keyboardBackgroundColor: Colors.white,
      keyboardBorderColor: Color(0x66D4A64A),
      keyboardShadow: [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    ),
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? contentPadding;
  final double? borderRadius;
  final TextStyle? textStyle;
  final VirtualKeyboardFieldTheme theme;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);
    return _VirtualKeyboardEditableField(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      textAlign: textAlign,
      textDirection: TextDirection.rtl,
      prefix: const Icon(Icons.search_rounded),
      contentPadding:
          contentPadding ??
          EdgeInsets.symmetric(
            horizontal: sizing.screenWidth * 0.03,
            vertical: sizing.screenHeight * 0.014,
          ),
      minFieldHeight: sizing.textFieldHeight,
      borderRadius: borderRadius,
      textStyle: textStyle,
      theme: theme,
      kind: _VirtualKeyboardFieldKind.text,
    );
  }
}

class VirtualNumericField extends StatelessWidget {
  const VirtualNumericField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.textAlign = TextAlign.left,
    this.textDirection = TextDirection.ltr,
    this.prefix,
    this.suffix,
    this.contentPadding,
    this.minFieldHeight,
    this.borderRadius,
    this.textStyle,
    this.labelStyle,
    this.errorStyle,
    this.allowNegative = false,
    this.theme = const VirtualKeyboardFieldTheme(
      fillColor: DialogPalette.inputFillColor,
      borderColor: DialogPalette.inputBorderColor,
      activeBorderColor: DialogPalette.inputFocusedBorderColor,
      errorBorderColor: Colors.red,
      textColor: DialogPalette.inputTextColor,
      hintColor: DialogPalette.inputHintColor,
      labelColor: DialogPalette.inputHintColor,
      keyboardTextColor: DialogPalette.inputTextColor,
      keyboardBackgroundColor: Colors.white,
      keyboardBorderColor: Color(0x66D4A64A),
      keyboardShadow: [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    ),
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Widget? prefix;
  final Widget? suffix;
  final EdgeInsetsGeometry? contentPadding;
  final double? minFieldHeight;
  final double? borderRadius;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final bool allowNegative;
  final VirtualKeyboardFieldTheme theme;

  @override
  Widget build(BuildContext context) {
    return _VirtualKeyboardEditableField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      validator: validator,
      onChanged: onChanged,
      maxLines: 1,
      textAlign: textAlign,
      textDirection: textDirection,
      prefix: prefix,
      suffix: suffix,
      contentPadding: contentPadding,
      minFieldHeight: minFieldHeight,
      borderRadius: borderRadius,
      textStyle: textStyle,
      labelStyle: labelStyle,
      errorStyle: errorStyle,
      theme: theme,
      kind: _VirtualKeyboardFieldKind.numeric,
      allowNegative: allowNegative,
    );
  }
}

class VirtualReadOnlyLauncherField extends StatelessWidget {
  const VirtualReadOnlyLauncherField({
    super.key,
    required this.controller,
    required this.onTap,
    this.labelText,
    this.hintText,
    this.textAlign = TextAlign.right,
    this.textDirection = TextDirection.rtl,
    this.prefix,
    this.suffix,
    this.contentPadding,
    this.minFieldHeight,
    this.borderRadius,
    this.textStyle,
    this.labelStyle,
    this.theme = const VirtualKeyboardFieldTheme(
      fillColor: DialogPalette.inputFillColor,
      borderColor: DialogPalette.inputBorderColor,
      activeBorderColor: DialogPalette.inputFocusedBorderColor,
      errorBorderColor: Colors.red,
      textColor: DialogPalette.inputTextColor,
      hintColor: DialogPalette.inputHintColor,
      labelColor: DialogPalette.inputHintColor,
      keyboardTextColor: DialogPalette.inputTextColor,
      keyboardBackgroundColor: Colors.white,
      keyboardBorderColor: Color(0x66D4A64A),
      keyboardShadow: [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    ),
  });

  final TextEditingController controller;
  final VoidCallback onTap;
  final String? labelText;
  final String? hintText;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Widget? prefix;
  final Widget? suffix;
  final EdgeInsetsGeometry? contentPadding;
  final double? minFieldHeight;
  final double? borderRadius;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final VirtualKeyboardFieldTheme theme;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);
    final effectiveBorderRadius = borderRadius ?? sizing.borderRadius * 0.7;
    final effectiveContentPadding =
        contentPadding ??
        EdgeInsets.symmetric(
          horizontal: sizing.screenWidth * 0.035,
          vertical: sizing.screenHeight * 0.016,
        );
    final effectiveTextStyle =
        textStyle ??
        TextStyle(color: theme.textColor, fontSize: sizing.bodyFontSize);
    final effectiveLabelStyle =
        labelStyle ??
        TextStyle(
          color: theme.labelColor,
          fontSize: sizing.bodyFontSize * 0.9,
          fontWeight: FontWeight.w600,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null && labelText!.trim().isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              bottom: sizing.verticalGap * 0.28,
              right: sizing.screenWidth * 0.01,
              left: sizing.screenWidth * 0.01,
            ),
            child: Text(labelText!, style: effectiveLabelStyle),
          ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _virtualKeyboardCoordinator.hideAll();
            onTap();
          },
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: minFieldHeight ?? sizing.textFieldHeight,
            ),
            padding: effectiveContentPadding,
            decoration: BoxDecoration(
              color: theme.fillColor,
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
              border: Border.all(color: theme.borderColor),
            ),
            child: Row(
              children: [
                if (prefix != null) ...[
                  prefix!,
                  SizedBox(width: sizing.screenWidth * 0.02),
                ],
                Expanded(
                  child: Text(
                    controller.text.trim().isEmpty
                        ? (hintText ?? '')
                        : controller.text,
                    textAlign: textAlign,
                    textDirection: textDirection,
                    style: effectiveTextStyle.copyWith(
                      color: controller.text.trim().isEmpty
                          ? theme.hintColor
                          : effectiveTextStyle.color,
                    ),
                  ),
                ),
                if (suffix != null) ...[
                  SizedBox(width: sizing.screenWidth * 0.02),
                  suffix!,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VirtualKeyboardEditableField extends StatefulWidget {
  const _VirtualKeyboardEditableField({
    required this.controller,
    required this.kind,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.textAlign = TextAlign.right,
    this.textDirection = TextDirection.rtl,
    this.prefix,
    this.suffix,
    this.contentPadding,
    this.minFieldHeight,
    this.borderRadius,
    this.textStyle,
    this.labelStyle,
    this.errorStyle,
    required this.theme,
    this.allowNegative = false,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final _VirtualKeyboardFieldKind kind;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Widget? prefix;
  final Widget? suffix;
  final EdgeInsetsGeometry? contentPadding;
  final double? minFieldHeight;
  final double? borderRadius;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final VirtualKeyboardFieldTheme theme;
  final bool allowNegative;
  final bool obscureText;

  @override
  State<_VirtualKeyboardEditableField> createState() =>
      _VirtualKeyboardEditableFieldState();
}

class _VirtualKeyboardEditableFieldState
    extends State<_VirtualKeyboardEditableField> {
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  late final String _fieldId;

  bool get _isKeyboardVisible => _virtualKeyboardCoordinator.isActive(_fieldId);

  @override
  void initState() {
    super.initState();
    _fieldId = '${identityHashCode(this)}';
    widget.controller.addListener(_handleExternalTextChange);
    _virtualKeyboardCoordinator.addListener(_handleCoordinatorChanged);
  }

  @override
  void didUpdateWidget(covariant _VirtualKeyboardEditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_handleExternalTextChange);
    widget.controller.addListener(_handleExternalTextChange);
    _syncFieldValue(triggerChange: false);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleExternalTextChange);
    _virtualKeyboardCoordinator.removeListener(_handleCoordinatorChanged);
    _virtualKeyboardCoordinator.deactivate(_fieldId);
    super.dispose();
  }

  void _handleCoordinatorChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _handleExternalTextChange() {
    _syncFieldValue(triggerChange: false);
  }

  void _showKeyboard() {
    widget.controller.selection = TextSelection.collapsed(
      offset: widget.controller.text.length,
    );
    _syncFieldValue(triggerChange: false);
    _virtualKeyboardCoordinator.activate(_fieldId);
  }

  void _hideKeyboard() {
    _syncFieldValue(triggerChange: false);
    _virtualKeyboardCoordinator.deactivate(_fieldId);
  }

  void _syncFieldValue({required bool triggerChange}) {
    if (widget.kind == _VirtualKeyboardFieldKind.numeric) {
      _normalizeNumericText();
    }
    final value = widget.controller.text;
    _fieldKey.currentState?.didChange(value);
    if (triggerChange) {
      widget.onChanged?.call(value);
    }
  }

  void _normalizeNumericText() {
    final original = widget.controller.text;
    final isNegative = widget.allowNegative && original.startsWith('-');
    var sanitized = original.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    sanitized = sanitized.replaceAll('-', '');

    final firstDotIndex = sanitized.indexOf('.');
    if (firstDotIndex != -1) {
      final beforeDot = sanitized.substring(0, firstDotIndex + 1);
      final afterDot = sanitized
          .substring(firstDotIndex + 1)
          .replaceAll('.', '');
      sanitized = '$beforeDot$afterDot';
    }

    if (widget.allowNegative && isNegative) {
      sanitized = sanitized.isEmpty ? '-' : '-$sanitized';
    }

    if (sanitized == original) {
      return;
    }

    widget.controller.value = widget.controller.value.copyWith(
      text: sanitized,
      selection: TextSelection.collapsed(offset: sanitized.length),
      composing: TextRange.empty,
    );
  }

  void _toggleNegativeSign() {
    if (widget.kind != _VirtualKeyboardFieldKind.numeric ||
        !widget.allowNegative) {
      return;
    }
    final current = widget.controller.text;
    final next = current.startsWith('-')
        ? current.substring(1)
        : (current.isEmpty ? '-' : '-$current');
    widget.controller.value = widget.controller.value.copyWith(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
      composing: TextRange.empty,
    );
    _syncFieldValue(triggerChange: true);
  }

  String _displayValue(String value) {
    if (!widget.obscureText) {
      return value;
    }
    return List.filled(value.length, '•').join();
  }

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);
    final effectiveBorderRadius =
        widget.borderRadius ?? sizing.borderRadius * 0.7;
    final effectiveContentPadding =
        widget.contentPadding ??
        EdgeInsets.symmetric(
          horizontal: sizing.screenWidth * 0.035,
          vertical: widget.maxLines == 1
              ? sizing.textFieldHeight * 0.3
              : sizing.screenHeight * 0.016,
        );
    final effectiveTextStyle =
        widget.textStyle ??
        TextStyle(color: widget.theme.textColor, fontSize: sizing.bodyFontSize);
    final effectiveLabelStyle =
        widget.labelStyle ??
        TextStyle(
          color: widget.theme.labelColor,
          fontSize: sizing.bodyFontSize * 0.9,
          fontWeight: FontWeight.w600,
        );
    final effectiveErrorStyle =
        widget.errorStyle ??
        TextStyle(
          color: Colors.red.shade700,
          fontSize: sizing.bodyFontSize * 0.82,
          fontWeight: FontWeight.w600,
        );
    final keyboardHeight = sizing.isLandscape
        ? (widget.kind == _VirtualKeyboardFieldKind.numeric ? 220.0 : 230.0)
        : (widget.kind == _VirtualKeyboardFieldKind.numeric ? 240.0 : 260.0);

    return FormField<String>(
      key: _fieldKey,
      initialValue: widget.controller.text,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        final showHint = widget.controller.text.trim().isEmpty;
        final borderColor = field.hasError
            ? widget.theme.errorBorderColor
            : (_isKeyboardVisible
                  ? widget.theme.activeBorderColor
                  : widget.theme.borderColor);
        final borderWidth = field.hasError || _isKeyboardVisible ? 2.0 : 1.2;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.labelText != null && widget.labelText!.trim().isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  bottom: sizing.verticalGap * 0.28,
                  right: sizing.screenWidth * 0.01,
                  left: sizing.screenWidth * 0.01,
                ),
                child: Text(widget.labelText!, style: effectiveLabelStyle),
              ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _showKeyboard,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight:
                      widget.minFieldHeight ??
                      math.max(
                        sizing.bodyFontSize * widget.maxLines * 1.2,
                        sizing.textFieldHeight,
                      ),
                ),
                padding: effectiveContentPadding,
                decoration: BoxDecoration(
                  color: widget.theme.fillColor,
                  borderRadius: BorderRadius.circular(effectiveBorderRadius),
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.prefix != null) ...[
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: sizing.screenWidth * 0.02,
                          top: 2,
                        ),
                        child: widget.prefix,
                      ),
                    ],
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                              sizing.bodyFontSize *
                              math.max(widget.maxLines, 1) *
                              1.15,
                        ),
                        child: Text(
                          showHint
                              ? (widget.hintText ?? '')
                              : _displayValue(widget.controller.text),
                          textAlign: widget.textAlign,
                          textDirection: widget.textDirection,
                          maxLines: widget.maxLines,
                          overflow: TextOverflow.ellipsis,
                          style: effectiveTextStyle.copyWith(
                            color: showHint
                                ? widget.theme.hintColor
                                : effectiveTextStyle.color,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: sizing.screenWidth * 0.02),
                    if (widget.suffix != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: widget.suffix,
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          _isKeyboardVisible
                              ? Icons.keyboard_hide_rounded
                              : Icons.keyboard_rounded,
                          color: widget.theme.hintColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: EdgeInsets.only(
                  top: sizing.verticalGap * 0.22,
                  right: sizing.screenWidth * 0.015,
                  left: sizing.screenWidth * 0.015,
                ),
                child: Text(
                  field.errorText!,
                  style: effectiveErrorStyle,
                  textAlign: TextAlign.right,
                ),
              ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _isKeyboardVisible
                  ? Padding(
                      key: ValueKey('virtual-keyboard-$_fieldId'),
                      padding: EdgeInsets.only(top: sizing.verticalGap * 0.55),
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.theme.keyboardBackgroundColor,
                          borderRadius: BorderRadius.circular(
                            effectiveBorderRadius,
                          ),
                          border: Border.all(
                            color: widget.theme.keyboardBorderColor,
                            width: 1.2,
                          ),
                          boxShadow: widget.theme.keyboardShadow,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.only(
                                start: sizing.screenWidth * 0.02,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (widget.kind ==
                                          _VirtualKeyboardFieldKind.numeric &&
                                      widget.allowNegative)
                                    TextButton.icon(
                                      onPressed: _toggleNegativeSign,
                                      icon: const Icon(
                                        Icons.exposure_neg_1_rounded,
                                      ),
                                      label: const Text('-'),
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  IconButton(
                                    onPressed: _hideKeyboard,
                                    icon: Icon(
                                      Icons.keyboard_hide_rounded,
                                      color: widget.theme.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                effectiveBorderRadius,
                              ),
                              child: VirtualKeyboard(
                                height: keyboardHeight,
                                textController: widget.controller,
                                type:
                                    widget.kind ==
                                        _VirtualKeyboardFieldKind.numeric
                                    ? VirtualKeyboardType.Numeric
                                    : VirtualKeyboardType.Alphanumeric,
                                defaultLayouts: const [
                                  VirtualKeyboardDefaultLayouts.Arabic,
                                  VirtualKeyboardDefaultLayouts.English,
                                ],
                                textColor: widget.theme.keyboardTextColor,
                                fontSize: sizing.bodyFontSize * 0.85,
                                postKeyPress: (_) {
                                  _syncFieldValue(triggerChange: true);
                                  if (!mounted) {
                                    return;
                                  }
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
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
    final prefix = prefixIcon == null ? null : Icon(prefixIcon);
    final allowNegative = keyboardType?.signed ?? false;
    final isNumeric = keyboardType?.index == TextInputType.number.index;

    if (isNumeric) {
      return VirtualNumericField(
        controller: controller,
        labelText: label,
        hintText: hint,
        textAlign: textAlign,
        textDirection: TextDirection.ltr,
        prefix: prefix,
        suffix: suffixIcon,
        allowNegative: allowNegative,
        minFieldHeight: fixedHeight,
        borderRadius: sizing.borderRadius * 0.7,
        contentPadding: EdgeInsets.symmetric(
          horizontal: sizing.screenWidth * 0.035,
          vertical: maxLines == 1
              ? sizing.textFieldHeight * 0.3
              : sizing.screenHeight * 0.016,
        ),
        textStyle: TextStyle(
          color: DialogPalette.inputTextColor,
          fontSize: sizing.bodyFontSize,
        ),
      );
    }

    return VirtualTextField(
      controller: controller,
      labelText: label,
      hintText: hint,
      maxLines: maxLines,
      textAlign: textAlign,
      prefix: prefix,
      suffix: suffixIcon,
      minFieldHeight: fixedHeight,
      borderRadius: sizing.borderRadius * 0.7,
      contentPadding: EdgeInsets.symmetric(
        horizontal: sizing.screenWidth * 0.035,
        vertical: maxLines == 1
            ? sizing.textFieldHeight * 0.3
            : sizing.screenHeight * 0.016,
      ),
      textStyle: TextStyle(
        color: DialogPalette.inputTextColor,
        fontSize: sizing.bodyFontSize,
      ),
      obscureText: obscureText,
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

    return VirtualSearchField(
      controller: controller,
      hintText: hint,
      onChanged: onChanged,
      textAlign: TextAlign.right,
      textStyle: TextStyle(
        color: DialogPalette.inputTextColor,
        fontSize: sizing.bodyFontSize,
      ),
      borderRadius: sizing.borderRadius * 0.9,
      contentPadding: EdgeInsets.symmetric(
        horizontal: sizing.screenWidth * 0.03,
        vertical: sizing.screenHeight * 0.014,
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
