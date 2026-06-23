import 'package:azan/core/utils/dialoge_helper.dart';
import 'package:flutter/material.dart';

class NewDialogConfig {
  static DialogSizing getSizing(BuildContext context) {
    return DialogConfig.getSizing(context);
  }
}

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
    return UniversalDialogShell(
      customMaxWidth: maxWidth,
      customMaxHeight: maxHeight,
      forceMaxHeight: maxHeight != null || scrollable,
      child: scrollable ? SingleChildScrollView(child: child) : child,
    );
  }
}

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
    return DialogTitle(text, icon: icon, iconColor: iconColor);
  }
}

class NewDialogSubtitle extends StatelessWidget {
  final String text;

  const NewDialogSubtitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return DialogBodyText(
      text,
      color: DialogPalette.mutedTextColor,
      fontWeight: FontWeight.w600,
    );
  }
}

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
    return DialogContentCard(
      padding: padding,
      backgroundColor: backgroundColor,
      child: child,
    );
  }
}

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
    return DialogButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
      variant: isDestructive
          ? DialogButtonVariant.destructive
          : DialogButtonVariant.primary,
    );
  }
}

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
    return DialogButtonRow(children: children, mainAxisAlignment: mainAxisAlignment);
  }
}

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
    return DialogTextField(
      controller: controller,
      label: labelText,
      hint: hintText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      prefixIcon: prefixIcon,
      suffixIcon: suffixWidget,
      obscureText: isPassword,
    );
  }
}

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
    return DialogSelectableTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onTap: onTap,
      isSelected: isSelected,
      trailing: trailing,
    );
  }
}

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
    final sizing = DialogConfig.getSizing(context);
    return Divider(
      height: height ?? sizing.verticalGap,
      color: color ?? DialogPalette.dividerColor,
      thickness: thickness ?? 1,
    );
  }
}

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
  final sizing = NewDialogConfig.getSizing(context);

  await showAppDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      return NewUniversalDialogShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NewDialogTitle(text: title, icon: icon),
            SizedBox(height: sizing.verticalGap * 0.8),
            NewDialogContentCard(child: DialogBodyText(message)),
            SizedBox(height: sizing.verticalGap),
            NewDialogButtonRow(
              children: [
                if (cancelText != null && onCancel != null)
                  NewDialogButton(
                    text: cancelText,
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      onCancel();
                    },
                    backgroundColor: DialogPalette.secondaryButtonBackground,
                    textColor: DialogPalette.secondaryButtonText,
                  ),
                NewDialogButton(
                  text: confirmText ?? 'موافق',
                  onPressed: () {
                    Navigator.pop(dialogContext);
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

Future<bool?> showNewConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
  IconData? icon,
  Color? iconColor,
}) {
  final sizing = NewDialogConfig.getSizing(context);

  return showAppDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return NewUniversalDialogShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NewDialogTitle(text: title, icon: icon, iconColor: iconColor),
            SizedBox(height: sizing.verticalGap * 0.8),
            NewDialogContentCard(
              child: DialogBodyText(message, maxLines: 5),
            ),
            SizedBox(height: sizing.verticalGap),
            NewDialogButtonRow(
              children: [
                NewDialogButton(
                  text: cancelText ?? 'إلغاء',
                  onPressed: () => Navigator.pop(dialogContext, false),
                  backgroundColor: DialogPalette.secondaryButtonBackground,
                  textColor: DialogPalette.secondaryButtonText,
                ),
                NewDialogButton(
                  text: confirmText ?? 'تأكيد',
                  onPressed: () => Navigator.pop(dialogContext, true),
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

Future<String?> showNewInputDialog({
  required BuildContext context,
  required String title,
  required String hint,
  String? initialValue,
  int maxLines = 1,
  IconData? icon,
}) {
  final controller = TextEditingController(text: initialValue ?? '');
  final sizing = NewDialogConfig.getSizing(context);

  return showAppDialog<String>(
    context: context,
    builder: (dialogContext) {
      return NewUniversalDialogShell(
        scrollable: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NewDialogTitle(text: title, icon: icon),
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
                  onPressed: () => Navigator.pop(dialogContext),
                  backgroundColor: DialogPalette.secondaryButtonBackground,
                  textColor: DialogPalette.secondaryButtonText,
                ),
                NewDialogButton(
                  text: 'موافق',
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.pop(dialogContext, text);
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

Future<T?> showNewSingleChoiceDialog<T>({
  required BuildContext context,
  required String title,
  required List<DialogChoiceItem<T>> items,
  T? initialValue,
}) {
  final sizing = NewDialogConfig.getSizing(context);
  T? selectedValue = initialValue;

  return showAppDialog<T>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: NewDialogListItem(
                          title: item.title,
                          subtitle: item.subtitle,
                          icon: item.icon,
                          isSelected: selectedValue == item.value,
                          onTap: () => setState(() => selectedValue = item.value),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: sizing.verticalGap),
                NewDialogButtonRow(
                  children: [
                    NewDialogButton(
                      text: 'إلغاء',
                      onPressed: () => Navigator.pop(dialogContext),
                      backgroundColor: DialogPalette.secondaryButtonBackground,
                      textColor: DialogPalette.secondaryButtonText,
                    ),
                    NewDialogButton(
                      text: 'موافق',
                      onPressed: () {
                        if (selectedValue != null) {
                          Navigator.pop(dialogContext, selectedValue);
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
