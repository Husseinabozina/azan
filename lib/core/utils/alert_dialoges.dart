import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/dialoge_helper.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/adhkar/components/dhikr_from_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// ============================================================================
/// ✅ IMPROVED DIALOGS - بدون clamp، responsive تمامًا
/// ============================================================================

/// تعديل اسم المسجد
Future<void> showEditMosqueNameDialog(
  BuildContext context, {
  String? initialName,
  required ValueChanged<String> onConfirm,
}) async {
  final controller = TextEditingController(text: initialName ?? '');
  final sizing = DialogConfig.getSizing(context);

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return UniversalDialogShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogTitle(LocaleKeys.edit_mosque_name.tr()),
            SizedBox(height: sizing.verticalGap),

            DialogTextField(
              controller: controller,
              hint: LocaleKeys.mosque_name_label.tr(),
            ),

            SizedBox(height: sizing.verticalGap),

            DialogButtonRow(
              leftButton: DialogButton(
                text: LocaleKeys.common_cancel.tr(),
                backgroundColor: AppTheme.cancelButtonBackgroundColor,
                textColor: AppTheme.cancelButtonTextColor,
                onPressed: () => Navigator.of(context).pop(),
              ),
              rightButton: DialogButton(
                text: LocaleKeys.common_ok.tr(),
                backgroundColor: AppTheme.primaryButtonBackground,
                textColor: AppTheme.primaryButtonTextColor,
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    onConfirm(text);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// تعديل رسالة الإشعار
Future<void> showEditNotificationMessageDialog(
  BuildContext context, {
  String? initialText,
  required ValueChanged<String> onConfirm,
}) async {
  final controller = TextEditingController(text: initialText ?? '');
  final sizing = DialogConfig.getSizing(context);

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return UniversalDialogShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogTitle(LocaleKeys.edit_nofication_message.tr()),
            SizedBox(height: sizing.verticalGap),

            DialogTextField(
              controller: controller,
              hint: LocaleKeys.notification_message.tr(),
            ),

            SizedBox(height: sizing.verticalGap),

            DialogButtonRow(
              leftButton: DialogButton(
                text: LocaleKeys.common_cancel.tr(),
                backgroundColor: AppTheme.cancelButtonBackgroundColor,
                textColor: AppTheme.cancelButtonTextColor,
                onPressed: () => Navigator.of(context).pop(),
              ),
              rightButton: DialogButton(
                text: LocaleKeys.common_ok.tr(),
                backgroundColor: AppTheme.primaryButtonBackground,
                textColor: AppTheme.primaryButtonTextColor,
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    onConfirm(text);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showAddDhikrDialog2(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        // insetPadding: sizing.dialogInset,
        child: Container(
          padding: EdgeInsets.only(top: 12.h),
          decoration: BoxDecoration(
            color: AppTheme.dialogBackgroundColor,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(),
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
  );
}

/// إضافة ذكر جديد
Future<void> showAddDhikrDialog(
  BuildContext context, {
  required void Function(String text, DhikrSchedule? schedule) onConfirm,
}) async {
  final sizing = DialogConfig.getSizing(context);

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return UniversalDialogShell(
        forceMaxHeight: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogTitle(LocaleKeys.dhikr_add_to_mosque.tr()),
            SizedBox(height: sizing.verticalGap * 0.6),

            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                child: ImprovedDhikrFormWidget(
                  onSubmit: (text, schedule) {
                    onConfirm(text, schedule);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// حذف ذكر
Future<bool?> showDeleteDhikrDialog(
  BuildContext context, {
  String? dhikrText,
  required void Function() onConfirm,
}) async {
  final sizing = DialogConfig.getSizing(context);

  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return UniversalDialogShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogTitle(LocaleKeys.dhikr_delete_title.tr()),
            SizedBox(height: sizing.verticalGap * 0.8),

            Text(
              dhikrText == null || dhikrText.isEmpty
                  ? LocaleKeys.dhikr_delete_confirm_message.tr()
                  : '${LocaleKeys.dhikr_delete_confirm_message.tr()}\n\n"$dhikrText"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sizing.bodyFontSize * 1.05,
                color: Colors.white,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: sizing.verticalGap),

            DialogButtonRow(
              leftButton: DialogButton(
                text: LocaleKeys.common_cancel.tr(),
                backgroundColor: AppTheme.cancelButtonBackgroundColor,
                textColor: AppTheme.cancelButtonTextColor,
                onPressed: () => Navigator.of(context).pop(false),
              ),
              rightButton: DialogButton(
                text: LocaleKeys.delete.tr(),
                backgroundColor: const Color(0xFFE57373),
                textColor: Colors.white,
                fontWeight: FontWeight.w700,
                onPressed: () {
                  onConfirm();
                  Navigator.of(context).pop(true);
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// تعديل ذكر
Future<void> showEditDhikrDialog(
  BuildContext context, {
  required String initialText,
  required ValueChanged<String> onConfirm,
}) async {
  final controller = TextEditingController(text: initialText);
  final sizing = DialogConfig.getSizing(context);

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return UniversalDialogShell(
        forceMaxHeight: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogTitle(LocaleKeys.dhikr_edit_title.tr()),
            SizedBox(height: sizing.verticalGap),

            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.right,
                  maxLines: sizing.isLandscape ? 3 : 4,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: sizing.bodyFontSize * 1.05,
                  ),
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: LocaleKeys.dhikr_text_label.tr(),
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: sizing.screenWidth * 0.035,
                      vertical: sizing.screenHeight * 0.015,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(sizing.borderRadius),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(sizing.borderRadius),
                      borderSide: const BorderSide(
                        color: Color(0xFFF4C66A),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: sizing.verticalGap),

            DialogButtonRow(
              leftButton: DialogButton(
                text: LocaleKeys.common_cancel.tr(),
                backgroundColor: AppTheme.cancelButtonBackgroundColor,
                textColor: AppTheme.cancelButtonTextColor,
                onPressed: () => Navigator.of(context).pop(),
              ),
              rightButton: DialogButton(
                text: LocaleKeys.common_ok.tr(),
                backgroundColor: AppTheme.primaryButtonBackground,
                textColor: AppTheme.primaryButtonTextColor,
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    onConfirm(text);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// تغيير اللغة
Future<void> showChangeLanguageDialog(
  BuildContext context, {
  required String currentLanguageCode,
  required ValueChanged<String> onConfirm,
}) async {
  String selectedLang = currentLanguageCode;
  final sizing = DialogConfig.getSizing(context);

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return UniversalDialogShell(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(LocaleKeys.language.tr()),
                SizedBox(height: sizing.verticalGap),

                InkWell(
                  borderRadius: BorderRadius.circular(
                    sizing.borderRadius * 0.7,
                  ),
                  onTap: () => setState(() => selectedLang = 'ar'),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sizing.screenWidth * 0.03,
                      vertical: sizing.screenHeight * 0.012,
                    ),
                    decoration: BoxDecoration(
                      color: selectedLang == 'ar'
                          ? Colors.white.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        sizing.borderRadius * 0.7,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedLang == 'ar'
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: AppTheme.dialogTitleColor,
                          size: sizing.bodyFontSize * 1.5,
                        ),
                        SizedBox(width: sizing.screenWidth * 0.025),
                        Text(
                          LocaleKeys.arabic.tr(),
                          style: TextStyle(
                            fontSize: sizing.bodyFontSize * 1.05,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: sizing.verticalGap * 0.4),

                InkWell(
                  borderRadius: BorderRadius.circular(
                    sizing.borderRadius * 0.7,
                  ),
                  onTap: () => setState(() => selectedLang = 'en'),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sizing.screenWidth * 0.03,
                      vertical: sizing.screenHeight * 0.012,
                    ),
                    decoration: BoxDecoration(
                      color: selectedLang == 'en'
                          ? Colors.white.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        sizing.borderRadius * 0.7,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedLang == 'en'
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: AppTheme.dialogTitleColor,
                          size: sizing.bodyFontSize * 1.5,
                        ),
                        SizedBox(width: sizing.screenWidth * 0.025),
                        Text(
                          LocaleKeys.english.tr(),
                          style: TextStyle(
                            fontSize: sizing.bodyFontSize * 1.05,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: sizing.verticalGap),

                DialogButtonRow(
                  leftButton: DialogButton(
                    text: LocaleKeys.common_cancel.tr(),
                    backgroundColor: AppTheme.cancelButtonBackgroundColor,
                    textColor: AppTheme.cancelButtonTextColor,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  rightButton: DialogButton(
                    text: LocaleKeys.common_ok.tr(),
                    backgroundColor: AppTheme.primaryButtonBackground,
                    textColor: AppTheme.primaryButtonTextColor,
                    onPressed: () {
                      onConfirm(selectedLang);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

/// تغيير الخلفية
Future<void> showChangeBackgroundDialog(
  BuildContext context, {
  required List<String> backgrounds,
  required String currentBackground,
  required ValueChanged<String> onConfirm,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return UniversalDialogShell(
        forceMaxHeight: true,
        child: _BackgroundPickerContent(
          backgrounds: backgrounds,
          initialBackground: currentBackground,
          onConfirm: onConfirm,
        ),
      );
    },
  );
}

class _BackgroundPickerContent extends StatefulWidget {
  final List<String> backgrounds;
  final String initialBackground;
  final ValueChanged<String> onConfirm;

  const _BackgroundPickerContent({
    required this.backgrounds,
    required this.initialBackground,
    required this.onConfirm,
  });

  @override
  State<_BackgroundPickerContent> createState() =>
      _BackgroundPickerContentState();
}

class _BackgroundPickerContentState extends State<_BackgroundPickerContent> {
  late String _selectedBackground;

  @override
  void initState() {
    super.initState();
    _selectedBackground = widget.initialBackground;
  }

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);
    final thumbH = sizing.isLandscape
        ? sizing.screenHeight * 0.35
        : sizing.screenHeight * 0.25;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DialogTitle(LocaleKeys.choose_app_wallpaper.tr()),
        SizedBox(height: sizing.verticalGap * 0.8),

        SizedBox(
          height: thumbH,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.backgrounds.length,
            separatorBuilder: (_, __) =>
                SizedBox(width: sizing.screenWidth * 0.03),
            itemBuilder: (context, index) {
              final path = widget.backgrounds[index];
              final isSelected = path == _selectedBackground;

              return GestureDetector(
                onTap: () => setState(() => _selectedBackground = path),
                child: Container(
                  width: sizing.isLandscape
                      ? sizing.screenWidth * 0.15
                      : sizing.screenWidth * 0.28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(sizing.borderRadius),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.dialogTitleColor
                          : Colors.white.withOpacity(0.3),
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      sizing.borderRadius * 0.85,
                    ),
                    child: Image.asset(path, fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: sizing.verticalGap * 0.8),

        DialogButtonRow(
          leftButton: DialogButton(
            text: LocaleKeys.common_cancel.tr(),
            backgroundColor: AppTheme.cancelButtonBackgroundColor,
            textColor: AppTheme.cancelButtonTextColor,
            onPressed: () => Navigator.of(context).pop(),
          ),
          rightButton: DialogButton(
            text: LocaleKeys.common_save.tr(),
            backgroundColor: AppTheme.primaryButtonBackground,
            textColor: AppTheme.primaryTextColor,
            onPressed: () {
              widget.onConfirm(_selectedBackground);
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}

/// ============================================================================
/// ✅ EID DIALOGS
/// ============================================================================

Future<void> showAddEidDialog(
  String title,
  BuildContext context, {
  required void Function(DateTime date, TimeOfDay time) onConfirm,
  required void Function() onCancel,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _AddEidDialog(onConfirm: onConfirm, title: title),
  );
}

class _AddEidDialog extends StatefulWidget {
  const _AddEidDialog({required this.onConfirm, required this.title});

  final void Function(DateTime date, TimeOfDay time) onConfirm;
  final String title;

  @override
  State<_AddEidDialog> createState() => _AddEidDialogState();
}

class _AddEidDialogState extends State<_AddEidDialog> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  DateTime? date;
  TimeOfDay? time;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);

    return UniversalDialogShell(
      forceMaxHeight: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: sizing.titleFontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: sizing.verticalGap),

          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Date field
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: sizing.bodyFontSize,
                    ),
                    decoration: InputDecoration(
                      hintText: LocaleKeys.date.tr(),
                      suffixIcon: Icon(
                        Icons.calendar_month,
                        color: AppTheme.primaryTextColor,
                        size: sizing.bodyFontSize * 1.8,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: sizing.screenWidth * 0.035,
                        vertical: sizing.screenHeight * 0.015,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          sizing.borderRadius,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onTap: () async {
                      date = await showUniversalDatePicker(
                        context,
                        initialDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          dateController.text = DateFormat(
                            'yyyy-MM-dd',
                          ).format(date!);
                        });
                      }
                    },
                  ),

                  VerticalSpace(height: sizing.verticalGap * 0.5),

                  // Time field
                  TextField(
                    controller: timeController,
                    readOnly: true,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: sizing.bodyFontSize,
                    ),
                    decoration: InputDecoration(
                      hintText: LocaleKeys.time.tr(),
                      suffixIcon: Icon(
                        Icons.access_time,
                        color: AppTheme.primaryTextColor,
                        size: sizing.bodyFontSize * 1.8,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: sizing.screenWidth * 0.035,
                        vertical: sizing.screenHeight * 0.015,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          sizing.borderRadius,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onTap: () async {
                      time = await showUniversalTimePicker(context);
                      if (time != null) {
                        setState(
                          () => timeController.text = time!.format(context),
                        );
                      }
                    },
                  ),

                  VerticalSpace(height: sizing.verticalGap * 0.6),

                  // Save button
                  SizedBox(
                    width: sizing.buttonSize.width * 1.3,
                    height: sizing.buttonSize.height,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            sizing.borderRadius * 0.8,
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (date != null && time != null) {
                          widget.onConfirm(date!, time!);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        LocaleKeys.common_save.tr(),
                        style: TextStyle(
                          fontSize: sizing.bodyFontSize * 1.2,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
