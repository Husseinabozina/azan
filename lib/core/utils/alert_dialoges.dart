import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/dhikr_hive_helper.dart';
import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/models/diker.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/azkar_scheduling_enums.dart';
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
                      // labelStyle: TextStyle(
                      //   fontSize: sizing.bodyFontSize * 0.9,
                      // ),
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

Future<void> showEditDhikrDialog2(
  BuildContext context, {
  required Dhikr dhikr,
}) async {
  final sizing = DialogConfig.getSizing(context);

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return UniversalDialogShell(
        forceMaxHeight: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogTitle(LocaleKeys.dhikr_edit_title.tr()),
            SizedBox(height: sizing.verticalGap * 0.6),

            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                child: ImprovedDhikrEditFormWidget(
                  initialText: dhikr.text,
                  initialSchedule: dhikr.schedule,
                  onSubmit: (newText, newSchedule) async {
                    final updatedDhikr = dhikr.copyWith(
                      text: newText,
                      schedule: newSchedule,
                    );

                    await DhikrHiveHelper.updateDhikr(updatedDhikr);

                    // ✅ refresh list
                    AppCubit().assignAdhkar();

                    Navigator.of(ctx).pop();
                  },
                ),
              ),
            ),

            SizedBox(height: sizing.verticalGap * 0.4),

            // ✅ نفس تجربة الديالوج عندك: Cancel / Save (اختياري هنا لأن الفورم فيه زرار Save)
            // تقدر تشيل الجزء ده لو انت مكتفي بزرار Save داخل الفورم
          ],
        ),
      );
    },
  );
}

class ImprovedDhikrEditFormWidget extends StatefulWidget {
  final String initialText;
  final DhikrSchedule? initialSchedule;
  final void Function(String text, DhikrSchedule? schedule) onSubmit;

  const ImprovedDhikrEditFormWidget({
    super.key,
    required this.initialText,
    required this.initialSchedule,
    required this.onSubmit,
  });

  @override
  State<ImprovedDhikrEditFormWidget> createState() =>
      _ImprovedDhikrEditFormWidgetState();
}

class _ImprovedDhikrEditFormWidgetState
    extends State<ImprovedDhikrEditFormWidget> {
  late final TextEditingController _textController;

  DhikrScheduleType _selectedType = DhikrScheduleType.none;
  final Set<int> _selectedWeekdays = {};
  DateTime? _selectedDate;

  final _formKey = GlobalKey<FormState>();

  static final Map<int, String> _weekdayLabels = {
    DateTime.saturday: LocaleKeys.day_saturday.tr(),
    DateTime.sunday: LocaleKeys.day_sunday.tr(),
    DateTime.monday: LocaleKeys.day_monday.tr(),
    DateTime.tuesday: LocaleKeys.day_tuesday.tr(),
    DateTime.wednesday: LocaleKeys.day_wednesday.tr(),
    DateTime.thursday: LocaleKeys.day_thursday.tr(),
    DateTime.friday: LocaleKeys.day_friday.tr(),
  };

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.initialText);

    // ✅ Prefill schedule → type + values
    final init = _ScheduleInit.fromSchedule(widget.initialSchedule);

    _selectedType = init.type;
    _selectedDate = init.date;
    _selectedWeekdays
      ..clear()
      ..addAll(init.weekdays);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  DhikrSchedule? _buildSchedule() {
    switch (_selectedType) {
      case DhikrScheduleType.none:
        // نفس منطقك الحالي: none => daily
        return DhikrSchedule.daily();

      case DhikrScheduleType.daily:
        return DhikrSchedule.daily();

      case DhikrScheduleType.weekly:
        if (_selectedWeekdays.isEmpty) return null;
        return DhikrSchedule.weekly(
          weekdays: _selectedWeekdays.toList()..sort(),
        );

      case DhikrScheduleType.specificDate:
        if (_selectedDate == null) return DhikrSchedule.daily();
        return DhikrSchedule.specificDate(_selectedDate!);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showUniversalDatePicker(
      context,
      initialDate: _selectedDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);

    return Padding(
      padding: EdgeInsets.zero,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.dhikr_edit_title.tr(),
              style: TextStyle(
                fontSize: sizing.bodyFontSize * 1.2,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryTextColor,
              ),
            ),

            SizedBox(height: sizing.verticalGap * 0.8),

            // ✅ TextField للنص (prefilled)
            TextFormField(
              controller: _textController,
              maxLines: sizing.isLandscape ? 3 : 4,
              // textDirection: widgets.TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.black87,
                fontSize: sizing.bodyFontSize,
              ),
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                alignLabelWithHint: true,
                // labelText: LocaleKeys.dhikr_text_label.tr(),
                hintText: LocaleKeys.dhikr_text_label.tr(),
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sizing.borderRadius),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sizing.borderRadius),
                  borderSide: const BorderSide(
                    color: Color(0xFFF4C66A),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sizing.borderRadius),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sizing.borderRadius),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: sizing.screenWidth * 0.015,
                  vertical: sizing.screenHeight * 0.015,
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return LocaleKeys.dhikr_text_required_error.tr();
                }
                return null;
              },
            ),

            SizedBox(height: sizing.verticalGap * 0.8),

            Text(
              LocaleKeys.schedule_type_label.tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryTextColor,
                fontSize: sizing.bodyFontSize * 1.05,
              ),
            ),

            // ✅ Dropdown للنوع (prefilled)
            DropdownButtonFormField<DhikrScheduleType>(
              iconSize: sizing.bodyFontSize * 2,
              value: _selectedType,
              isExpanded: true,
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: sizing.screenWidth * 0.04,
                  vertical: sizing.screenHeight * 0.01,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sizing.borderRadius),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sizing.borderRadius),
                  borderSide: const BorderSide(
                    color: Color(0xFFF4C66A),
                    width: 2,
                  ),
                ),
              ),
              borderRadius: BorderRadius.circular(sizing.borderRadius),
              dropdownColor: Colors.white,
              style: TextStyle(
                color: Colors.black87,
                fontSize: sizing.bodyFontSize,
                height: 1.3,
              ),
              items: [
                DropdownMenuItem(
                  value: DhikrScheduleType.none,
                  child: Text(LocaleKeys.schedule_type_none.tr()),
                ),
                DropdownMenuItem(
                  value: DhikrScheduleType.daily,
                  child: Text(LocaleKeys.daily.tr()),
                ),
                DropdownMenuItem(
                  value: DhikrScheduleType.weekly,
                  child: Text(LocaleKeys.schedule_type_weekly_days.tr()),
                ),
                DropdownMenuItem(
                  value: DhikrScheduleType.specificDate,
                  child: Text(LocaleKeys.schedule_type_specific_date.tr()),
                ),
              ],
              onChanged: (val) {
                if (val == null) return;
                setState(() {
                  _selectedType = val;
                  // تنظيف القيم حسب النوع لتفادي “بيانات قديمة”
                  if (_selectedType != DhikrScheduleType.weekly) {
                    _selectedWeekdays.clear();
                  }
                  if (_selectedType != DhikrScheduleType.specificDate) {
                    _selectedDate = null;
                  }
                });
              },
            ),

            SizedBox(height: sizing.verticalGap * 0.6),

            // ✅ Weekly chips (prefilled)
            if (_selectedType == DhikrScheduleType.weekly) ...[
              Text(
                LocaleKeys.schedule_select_days_label.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryTextColor,
                  fontSize: sizing.bodyFontSize,
                ),
              ),
              SizedBox(height: sizing.verticalGap * 0.4),
              Wrap(
                spacing: sizing.screenWidth * 0.02,
                runSpacing: sizing.screenHeight * 0.008,
                children: _weekdayLabels.entries.map((entry) {
                  final day = entry.key;
                  final label = entry.value;
                  final isSelected = _selectedWeekdays.contains(day);

                  return FilterChip(
                    labelStyle: TextStyle(
                      fontSize: sizing.bodyFontSize * 0.85,
                      fontWeight: FontWeight.bold,
                    ),
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedWeekdays.add(day);
                        } else {
                          _selectedWeekdays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],

            // ✅ Specific Date (prefilled)
            if (_selectedType == DhikrScheduleType.specificDate) ...[
              SizedBox(height: sizing.verticalGap * 0.6),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickDate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryButtonBackground,
                      padding: EdgeInsets.symmetric(
                        horizontal: sizing.screenWidth * 0.03,
                        vertical: sizing.screenHeight * 0.01,
                      ),
                    ),
                    child: Text(
                      LocaleKeys.schedule_select_date_label.tr(),
                      style: TextStyle(
                        fontSize: sizing.bodyFontSize,
                        color: AppTheme.primaryButtonTextColor,
                      ),
                    ),
                  ),
                  const HorizontalSpace(width: 8),
                  if (_selectedDate != null)
                    Text(
                      '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor,
                        fontSize: sizing.bodyFontSize,
                      ),
                    ),
                ],
              ),
            ],

            SizedBox(height: sizing.verticalGap),

            // ✅ Cancel / Save
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: sizing.buttonSize.width,
                  height: sizing.buttonSize.height,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFE8EEF7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          sizing.borderRadius * 0.8,
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      LocaleKeys.common_cancel.tr(),
                      style: TextStyle(
                        fontSize: sizing.bodyFontSize * 1.05,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: sizing.buttonSize.width,
                  height: sizing.buttonSize.height,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppTheme.primaryButtonBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          sizing.borderRadius * 0.8,
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;

                      final text = _textController.text.trim();
                      final schedule = _buildSchedule();

                      widget.onSubmit(text, schedule);
                    },
                    child: Text(
                      LocaleKeys.common_save.tr(),
                      style: TextStyle(
                        fontSize: sizing.bodyFontSize * 1,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// ✅ Schedule init helper (دي أهم 3 دوال لو DhikrSchedule عندك مختلف)
/// ============================================================================
class _ScheduleInit {
  final DhikrScheduleType type;
  final Set<int> weekdays;
  final DateTime? date;

  const _ScheduleInit({
    required this.type,
    required this.weekdays,
    required this.date,
  });

  factory _ScheduleInit.fromSchedule(DhikrSchedule? schedule) {
    // Default: daily (نفس فلسفتك الحالية)
    if (schedule == null) {
      return const _ScheduleInit(
        type: DhikrScheduleType.daily,
        weekdays: {},
        date: null,
      );
    }

    // ✅ عدّل هنا حسب موديل DhikrSchedule بتاعك
    // 1) weekly
    final w = _tryGetWeekdays(schedule);
    if (w != null && w.isNotEmpty) {
      return _ScheduleInit(
        type: DhikrScheduleType.weekly,
        weekdays: w.toSet(),
        date: null,
      );
    }

    // 2) specificDate
    final d = _tryGetSpecificDate(schedule);
    if (d != null) {
      return _ScheduleInit(
        type: DhikrScheduleType.specificDate,
        weekdays: const {},
        date: d,
      );
    }

    // 3) daily fallback
    return const _ScheduleInit(
      type: DhikrScheduleType.daily,
      weekdays: {},
      date: null,
    );
  }

  /// ✅ TODO: عدّلها حسب موديلك
  static List<int>? _tryGetWeekdays(DhikrSchedule schedule) {
    // لو عندك: schedule.weekdays
    try {
      final dynamic s = schedule;
      final List<dynamic>? raw = s.weekdays as List<dynamic>?;
      if (raw == null) return null;
      return raw.map((e) => e as int).toList();
    } catch (_) {
      return null;
    }
  }

  /// ✅ TODO: عدّلها حسب موديلك
  static DateTime? _tryGetSpecificDate(DhikrSchedule schedule) {
    // لو عندك: schedule.date
    try {
      final dynamic s = schedule;
      final DateTime? d = s.date as DateTime?;
      return d;
    } catch (_) {
      return null;
    }
  }
}
