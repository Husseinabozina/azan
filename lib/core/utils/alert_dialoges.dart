import 'package:azan/core/components/appbutton.dart';
import 'package:azan/core/components/custom_text_field.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/adhkar/components/dhikr_from_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// widgets
import 'package:flutter/widgets.dart' as widgets;

Future<void> showEditMosqueNameDialog(
  BuildContext context, {
  String? initialName,
  required ValueChanged<String> onConfirm,
  required R r,
}) async {
  final controller = TextEditingController(text: initialName ?? '');

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final size = MediaQuery.of(context).size;
      return Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            width: 1.sw - 70.w,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
            decoration: BoxDecoration(
              color: AppTheme.dialogBackgroundColor, // الأزرق الغامق
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 4.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // العنوان
                Text(
                  LocaleKeys.edit_mosque_name.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.dialogTitleColor, // أصفر/ذهبي
                  ),
                ),
                SizedBox(height: 20.h),

                // حقل اسم المسجد
                TextField(
                  controller: controller,
                  // textDirection: widgets.TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.black, fontSize: 12.sp),
                  decoration: InputDecoration(
                    hintText: LocaleKeys.mosque_name_label.tr(),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 15.h,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // الأزرار
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 74.w,
                      height: 40.h,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.cancelButtonBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          LocaleKeys.common_cancel.tr(),
                          style: TextStyle(
                            color: AppTheme.cancelButtonTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),

                    // زر موافق
                    SizedBox(
                      width: 74.w,
                      height: 40.h,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.primaryButtonBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        onPressed: () {
                          final text = controller.text.trim();

                          if (text.isNotEmpty) {
                            onConfirm(text);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          LocaleKeys.common_ok.tr(),
                          style: TextStyle(
                            color: AppTheme.primaryButtonTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),

                    // زر إلغاء
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showEditNotificationMessageDialog(
  BuildContext context, {
  String? initialText,
  required ValueChanged<String> onConfirm,
}) async {
  final controller = TextEditingController(text: initialText ?? '');

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final size = MediaQuery.of(context).size;
      return Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            width: 1.sw - 70.w,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
            decoration: BoxDecoration(
              color: AppTheme.dialogBackgroundColor, // الأزرق الغامق
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 4.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // العنوان
                Text(
                  LocaleKeys.edit_nofication_message.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.dialogTitleColor, // أصفر/ذهبي
                  ),
                ),
                SizedBox(height: 20.h),

                // حقل اسم المسجد
                TextField(
                  controller: controller,
                  // textDirection: widgets.TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.black, fontSize: 12.sp),
                  decoration: InputDecoration(
                    hintText: LocaleKeys.notification_message.tr(),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 15.h,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // الأزرار
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 74.w,
                      height: 40.h,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.cancelButtonBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          LocaleKeys.common_cancel.tr(),
                          style: TextStyle(
                            color: AppTheme.cancelButtonTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),

                    // زر موافق
                    SizedBox(
                      width: 74.w,
                      height: 40.h,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.primaryButtonBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        onPressed: () {
                          final text = controller.text.trim();

                          if (text.isNotEmpty) {
                            onConfirm(text);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          LocaleKeys.common_ok.tr(),
                          style: TextStyle(
                            color: AppTheme.primaryButtonTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),

                    // زر إلغاء
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showAddDhikrDialog(
  BuildContext context, {
  required void Function(String text, DhikrSchedule? schedule) onConfirm,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      final size = MediaQuery.of(context).size;

      return Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // العرض يكون شبه اللي عندك
              maxWidth: 1.sw - 70.w,
              // علشان لو الفورم كبرت يبقى فيه scroll وما يطلعش برا الشاشة
              maxHeight: size.height * 0.75,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
              decoration: BoxDecoration(
                color: AppTheme.dialogBackgroundColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 4.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // العنوان
                  Text(
                    LocaleKeys.dhikr_add_to_mosque.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.dialogTitleColor,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  /// الفورم نفسها
                  Flexible(
                    child: SingleChildScrollView(
                      // padding بسيط لو حابب
                      child: DhikrFormWidget(
                        onSubmit: (text, schedule) {
                          onConfirm(text, schedule);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // زر إلغاء
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<bool?> showDeleteDhikrDialog(
  BuildContext context, {
  String? dhikrText,
  required void Function() onConfirm,
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            width: 1.sw - 70.w,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
            decoration: BoxDecoration(
              color: AppTheme.dialogBackgroundColor, // الأزرق الغامق
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 4.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // العنوان
                Text(
                  LocaleKeys.dhikr_delete_title.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.dialogTitleColor, // أصفر/ذهبي
                  ),
                ),
                SizedBox(height: 16.h),

                // النص
                Text(
                  dhikrText == null || dhikrText.isEmpty
                      ? LocaleKeys.dhikr_delete_confirm_message.tr()
                      : '${LocaleKeys.dhikr_delete_confirm_message.tr()}\n\n"$dhikrText"',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                ),

                SizedBox(height: 20.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 90.w,
                      height: 40.h,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.cancelButtonBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text(
                          LocaleKeys.common_cancel.tr(),
                          style: TextStyle(
                            color: AppTheme.cancelButtonTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // زر حذف
                    SizedBox(
                      width: 90.w,
                      height: 40.h,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFE57373), // أحمر فاتح
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        onPressed: () {
                          onConfirm();

                          Navigator.of(context).pop(true); // موافق على الحذف
                        },
                        child: Text(
                          LocaleKeys.delete.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // زر إلغاء
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showEditDhikrDialog(
  BuildContext context, {
  required String initialText,
  required ValueChanged<String> onConfirm,
}) async {
  final controller = TextEditingController(text: initialText);

  await showDialog(
    context: context,
    barrierDismissible: false, // ميقفلش بالضغط برة بالغلط
    builder: (context) {
      return Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            width: 1.sw - 70.w,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
            decoration: BoxDecoration(
              color: AppTheme.dialogBackgroundColor, // الأزرق الغامق
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 4.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // العنوان
                Text(
                  LocaleKeys.dhikr_edit_title.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.dialogTitleColor, // أصفر/ذهبي
                  ),
                ),
                SizedBox(height: 20.h),

                // حقل نص الذكر
                TextField(
                  controller: controller,
                  // textDirection: widgets.TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: LocaleKeys.dhikr_text_label.tr(), //'نص الذكر',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 15.h,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Color(0xFFF4C66A),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // الأزرار
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 90.w,
                      height: 40.h,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.cancelButtonBackgroundColor,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          LocaleKeys.common_cancel.tr(),
                          style: TextStyle(
                            color: AppTheme.cancelButtonTextColor,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // زر موافق
                    SizedBox(
                      width: 90.w,
                      height: 40.h,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.primaryButtonBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isNotEmpty) {
                            onConfirm(text);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          LocaleKeys.common_ok.tr(),
                          style: TextStyle(
                            color: AppTheme.primaryButtonTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // زر إلغاء
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showChangeLanguageDialog(
  BuildContext context, {
  required String currentLanguageCode, // "ar" أو "en"
  required ValueChanged<String> onConfirm,
}) async {
  String selectedLang = currentLanguageCode;

  await showDialog(
    context: context,
    barrierDismissible: false, // زي باقي الـ dialogs المهمة
    builder: (context) {
      return Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            width: 1.sw - 70.w,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
            decoration: BoxDecoration(
              color: AppTheme.dialogBackgroundColor, // الأزرق الغامق
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 4.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // العنوان
                    Text(
                      LocaleKeys.language.tr(), // "تغيير اللغة"
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.dialogTitleColor, // أصفر/ذهبي
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // اختيار اللغة - عربي
                    InkWell(
                      borderRadius: BorderRadius.circular(14.r),
                      onTap: () {
                        setState(() {
                          selectedLang = 'ar';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: selectedLang == 'ar'
                              ? Colors.white.withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedLang == 'ar'
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: AppTheme.dialogTitleColor,
                              size: 20.sp,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              LocaleKeys.arabic.tr(), // "العربية"
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // اختيار اللغة - إنجليزي
                    InkWell(
                      borderRadius: BorderRadius.circular(14.r),
                      onTap: () {
                        setState(() {
                          selectedLang = 'en';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: selectedLang == 'en'
                              ? Colors.white.withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedLang == 'en'
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: AppTheme.dialogTitleColor,
                              size: 20.sp,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              LocaleKeys.english.tr(), // "English"
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // الأزرار
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 90.w,
                          height: 40.h,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  AppTheme.cancelButtonBackgroundColor,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              LocaleKeys.common_cancel.tr(),
                              style: TextStyle(
                                color: AppTheme.cancelButtonTextColor,

                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),

                        // زر موافق
                        SizedBox(
                          width: 90.w,
                          height: 40.h,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: AppTheme.primaryButtonBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                            onPressed: () {
                              onConfirm(selectedLang);
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              LocaleKeys.common_ok.tr(),
                              style: TextStyle(
                                color: AppTheme.primaryButtonTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // زر إلغاء
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showChangeBackgroundDialog(
  BuildContext context, {
  required List<String> backgrounds, // paths للصور
  required String currentBackground, // الخلفية الحالية
  required ValueChanged<String> onConfirm, // يرجعلك الـ path المختار
}) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            width: 1.sw - 70.w,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
            decoration: BoxDecoration(
              color: AppTheme.dialogBackgroundColor,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 4.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _BackgroundPickerContent(
              backgrounds: backgrounds,
              initialBackground: currentBackground,
              onConfirm: onConfirm,
            ),
          ),
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
    Key? key,
    required this.backgrounds,
    required this.initialBackground,
    required this.onConfirm,
  }) : super(key: key);

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          LocaleKeys.choose_app_wallpaper.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.dialogTitleColor,
          ),
        ),
        SizedBox(height: 16.h),

        // ***** خلفيات بشكل أفقي *****
        SizedBox(
          height: 180.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.backgrounds.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final path = widget.backgrounds[index];
              final isSelected = path == _selectedBackground;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBackground = path;
                  });
                },
                child: Container(
                  width: 110.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.dialogTitleColor
                          : Colors.white.withOpacity(0.3),
                      width: isSelected ? 3.w : 1.w,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: Image.asset(path, fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 16.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 90.w,
              height: 40.h,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.cancelButtonBackgroundColor,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  LocaleKeys.common_cancel.tr(),
                  style: TextStyle(
                    color: AppTheme.cancelButtonTextColor,

                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            SizedBox(
              width: 90.w,
              height: 40.h,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.primaryButtonBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                onPressed: () {
                  widget.onConfirm(_selectedBackground);
                  Navigator.of(context).pop();
                },

                child: Text(
                  LocaleKeys.common_save.tr(),
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<TimeOfDay?> pickTime(BuildContext context) async {
  return await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (context, child) {
      final baseTheme = Theme.of(context);

      // ScreenUtil helpers
      double fs(double v) => v.sp;
      EdgeInsets btnPad() =>
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h);

      final dialogBg = AppTheme.dialogBackgroundColor;

      // ========= Contrast helpers (WCAG-ish) =========
      double _lin(Color c) {
        double ch(int v) {
          final s = v / 255.0;
          return (s <= 0.03928)
              ? (s / 12.92)
              : MathPow.pow((s + 0.055) / 1.055, 2.4).toDouble();
        }

        // ignore: deprecated_member_use
        return 0.2126 * ch(c.red) + 0.7152 * ch(c.green) + 0.0722 * ch(c.blue);
      }

      double _contrast(Color a, Color b) {
        final l1 = _lin(a);
        final l2 = _lin(b);
        final bright = l1 > l2 ? l1 : l2;
        final dark = l1 > l2 ? l2 : l1;
        return (bright + 0.05) / (dark + 0.05);
      }

      Color _onFor(Color bg) {
        final br = ThemeData.estimateBrightnessForColor(bg);
        // dark bg -> near-white, light bg -> near-black
        return br == Brightness.dark
            ? const Color(0xFFF5F7FA)
            : const Color(0xFF121212);
      }

      Color _mix(Color fg, Color bg, double t) {
        // t: 0..1 (0 = fg, 1 = bg)
        return Color.lerp(fg, bg, t)!;
      }

      Color _ensureContrast(Color fg, Color bg, {double min = 4.5}) {
        if (_contrast(fg, bg) >= min) return fg;

        final prefer = _onFor(bg);
        // جرّب الأول أبيض/أسود حسب الخلفية
        if (_contrast(prefer, bg) >= min) return prefer;

        // لو لسه (نادر جدًا)، نقرب تدريجيًا من prefer
        Color cur = fg;
        for (int i = 0; i < 12; i++) {
          cur = _mix(cur, prefer, 0.25);
          if (_contrast(cur, bg) >= min) return cur;
        }
        return prefer;
      }

      Color _tuneAccent(Color accent, Color bg) {
        // عايزين accent واضح فوق bg (min 3.0 كفاية للأيقونات/الحواف)
        const min = 3.0;
        if (_contrast(accent, bg) >= min) return accent;

        final br = ThemeData.estimateBrightnessForColor(bg);
        var hsl = HSLColor.fromColor(accent);

        // لو الخلفية غامقة -> زوّد lightness شوية، لو فاتحة -> قلله
        for (int i = 0; i < 10; i++) {
          final delta = br == Brightness.dark ? 0.06 : -0.06;
          hsl = hsl.withLightness((hsl.lightness + delta).clamp(0.10, 0.90));
          final tuned = hsl.toColor();
          if (_contrast(tuned, bg) >= min) return tuned;
        }

        // fallback واضح
        return br == Brightness.dark
            ? const Color(0xFF66C6FF)
            : const Color(0xFF0A66C2);
      }

      // ====== derive safe colors ======
      final onDialog = _ensureContrast(_onFor(dialogBg), dialogBg, min: 7.0);
      final onDialogMuted = _ensureContrast(
        onDialog.withOpacity(0.78),
        dialogBg,
        min: 4.5,
      );

      final rawAccent = AppTheme.primaryButtonBackground;
      final accent = _tuneAccent(rawAccent, dialogBg);

      // لون النص فوق accent (للـ selected / hand)
      final onAccent = _ensureContrast(_onFor(accent), accent, min: 4.5);

      Color _surfaceTint(double opacity) =>
          Color.alphaBlend(onDialog.withOpacity(opacity), dialogBg);

      final timePickerTheme = TimePickerThemeData(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(12.w),

        helpTextStyle: TextStyle(
          fontSize: fs(12),
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: onDialogMuted,
          fontFamily: CacheHelper.getTimesFontFamily(),
        ),

        timeSelectorSeparatorTextStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: fs(12),
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: onDialogMuted,
            fontFamily: CacheHelper.getTimesFontFamily(),
          ),
        ),

        hourMinuteTextStyle: TextStyle(
          fontSize: fs(26),
          fontWeight: FontWeight.bold,
          height: 1.1,
          color: onDialog,
          fontFamily: CacheHelper.getTimesFontFamily(),
        ),

        hourMinuteColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Color.alphaBlend(accent.withOpacity(0.22), dialogBg);
          }
          return _surfaceTint(0.06);
        }),
        hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
          // نص الساعة داخل الـ pill
          if (states.contains(WidgetState.selected)) return onDialog;
          return onDialog;
        }),

        dayPeriodTextStyle: TextStyle(
          fontSize: fs(12),
          fontWeight: FontWeight.w800,
          height: 1.1,
          color: onDialog,
          fontFamily: CacheHelper.getTimesFontFamily(),
        ),
        dayPeriodColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Color.alphaBlend(accent.withOpacity(0.22), dialogBg);
          }
          return _surfaceTint(0.06);
        }),
        dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return onDialog;
          return onDialogMuted;
        }),
        dayPeriodShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),

        dialBackgroundColor: _surfaceTint(0.08),
        dialHandColor: accent,

        dialTextStyle: TextStyle(
          fontSize: fs(12),
          fontWeight: FontWeight.w700,
          fontFamily: CacheHelper.getTimesFontFamily(),
        ),
        dialTextColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return onAccent;
          return _ensureContrast(
            onDialog.withOpacity(0.80),
            _surfaceTint(0.08),
            min: 4.5,
          );
        }),

        entryModeIconColor: accent,

        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
          hintStyle: TextStyle(
            fontSize: fs(12),
            color: onDialogMuted.withOpacity(0.90),
            fontFamily: CacheHelper.getTimesFontFamily(),
          ),
          labelStyle: TextStyle(
            fontSize: fs(12),
            color: onDialogMuted,
            fontFamily: CacheHelper.getTimesFontFamily(),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: _ensureContrast(
                onDialog.withOpacity(0.20),
                dialogBg,
                min: 2.0,
              ),
              width: 1.w,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: accent, width: 1.2.w),
          ),
        ),

        cancelButtonStyle: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontSize: fs(14),
              fontWeight: FontWeight.bold,
              fontFamily: CacheHelper.getTimesFontFamily(),
            ),
          ),
          padding: WidgetStatePropertyAll(btnPad()),
          foregroundColor: WidgetStatePropertyAll(
            _ensureContrast(accent, dialogBg, min: 3.0),
          ),
          overlayColor: WidgetStatePropertyAll(
            Color.alphaBlend(accent.withOpacity(0.12), dialogBg),
          ),
        ),
        confirmButtonStyle: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontSize: fs(14),
              fontWeight: FontWeight.bold,
              fontFamily: CacheHelper.getTimesFontFamily(),
            ),
          ),
          padding: WidgetStatePropertyAll(btnPad()),
          foregroundColor: WidgetStatePropertyAll(
            _ensureContrast(accent, dialogBg, min: 3.0),
          ),
          overlayColor: WidgetStatePropertyAll(
            Color.alphaBlend(accent.withOpacity(0.12), dialogBg),
          ),
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
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: _ensureContrast(accent, dialogBg, min: 3.0),
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fs(14),
                fontFamily: CacheHelper.getTimesFontFamily(),
              ),
              padding: btnPad(),
            ),
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 0.9.sw.clamp(280.w, 520.w),
              maxHeight: 0.75.sh.clamp(360.h, 680.h),
            ),
            child: child!,
          ),
        ),
      );
    },
  );
}

/// tiny helper to avoid importing dart:math everywhere in your file
class MathPow {
  static num pow(num x, num exponent) =>
      x == 0 ? 0 : (x.toDouble()).pow(exponent);
}

extension _PowExt on double {
  double pow(num e) => double.parse((toStringAsFixed(12))) == 0.0
      ? 0.0
      : (num.parse(toString()) as num).toDouble()._pow(e);

  double _pow(num e) {
    // fallback using dart:math is better, but this keeps snippet standalone.
    // If you prefer: just import 'dart:math' and replace with math.pow(this, e).toDouble()
    double r = 1.0;
    for (int i = 0; i < (e as double).round(); i++) {
      r *= this;
    }
    return r;
  }
}

// date and time TextFields Dialogs for eid
Future<void> showAddEidDialog(
  String title,
  BuildContext context, {
  required void Function(DateTime date, TimeOfDay time) onConfirm,
  required void Function() onCancel,

  // required Widget child,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AddEidDialog(
      // child: child,
      onConfirm: onConfirm,
      title: title,
    ),
  );
}

class AddEidDialog extends StatefulWidget {
  const AddEidDialog({super.key, required this.onConfirm, required this.title});
  final void Function(DateTime date, TimeOfDay time) onConfirm;
  final String title;

  @override
  State<AddEidDialog> createState() => _AddEidDialogState();
}

class _AddEidDialogState extends State<AddEidDialog> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  DateTime? date;
  TimeOfDay? time;
  String? title;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        backgroundColor: AppTheme.dialogBackgroundColor,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Container(
            width: 1.sw - 70.w,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
            decoration: BoxDecoration(
              color: AppTheme.dialogBackgroundColor, // الأزرق الغامق
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 4.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: CacheHelper.getTimesFontFamily(),
                    color: AppTheme.accentColor,
                  ),
                ),
                VerticalSpace(height: 20),
                // date textfield
                CustomTextField(
                  controller: dateController,
                  readOnly: true,
                  suffixIcon: Icon(
                    Icons.calendar_month,
                    color: AppTheme.primaryTextColor,
                  ),
                  hintText: LocaleKeys.date.tr(),

                  onTap: () async {
                    " date  : ${dateController!.text}".log();
                    date = await showCustomDatePicker(DateTime.now(), context);
                    if (date != null) {
                      setState(() {
                        dateController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(date!);
                        " date  : ${dateController!.text}".log();
                      });
                    }
                  },
                ),
                VerticalSpace(height: 10),
                CustomTextField(
                  controller: timeController,
                  readOnly: true,
                  suffixIcon: Icon(
                    Icons.access_time,
                    color: AppTheme.primaryTextColor,
                  ),
                  hintText: LocaleKeys.time.tr(),
                  onTap: () async {
                    time = await pickTime(context);
                    if (time != null) {
                      setState(() {
                        timeController.text = time!.format(context);
                      });
                    }
                  },
                ),
                VerticalSpace(height: 10),

                AppButton(
                  color: AppTheme.accentColor,

                  onPressed: () {
                    if (date != null && time != null) {
                      widget.onConfirm(date!, time!);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    LocaleKeys.common_save.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<DateTime?> showCustomDatePicker(
  DateTime now,
  // double Function(double baseSize) responsiveFontSize,
  //  Color AppTheme.primaryTextColor,
  //   Color AppTheme.darkBlue,
  BuildContext context,
) {
  final size = MediaQuery.of(context).size;

  // حساب الـ scale factor بناءً على عرض الشاشة
  final scaleFactor = (size.width / 390).clamp(0.9, 1.8);
  double responsiveFontSize(double baseSize) {
    return (baseSize * scaleFactor).clamp(baseSize * 0.8, baseSize * 1.5);
  }

  return showDatePicker(
    context: context,
    firstDate: DateTime(now.year - 1),
    lastDate: DateTime(now.year + 5),
    initialDate: now,
    locale: Locale(context.locale.languageCode),
    builder: (context, child) {
      final baseTheme = Theme.of(context);

      final datePickerTheme = DatePickerThemeData(
        backgroundColor: AppTheme.dialogBackgroundColor,
        headerBackgroundColor: AppTheme.dialogBackgroundColor,
        headerForegroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),

        headerHeadlineStyle: TextStyle(
          fontSize: responsiveFontSize(20),
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.2,
        ),

        headerHelpStyle: TextStyle(
          fontSize: responsiveFontSize(12),
          fontWeight: FontWeight.w600,
          color: Colors.white70,
          height: 1.2,
        ),

        weekdayStyle: TextStyle(
          fontSize: responsiveFontSize(12),
          fontWeight: FontWeight.w600,
          color: Colors.white70,
          height: 1.2,
        ),

        dayStyle: TextStyle(
          fontSize: responsiveFontSize(14),
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1.2,
        ),

        yearStyle: TextStyle(
          fontSize: responsiveFontSize(16),
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.2,
        ),
        yearForegroundColor: WidgetStateProperty.all(AppTheme.accentColor),

        dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),

        dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTheme.primaryTextColor;
          }
          return Colors.transparent;
        }),

        todayBackgroundColor: WidgetStateProperty.all(
          AppTheme.primaryTextColor.withOpacity(0.2),
        ),
        todayBorder: BorderSide(color: AppTheme.primaryTextColor, width: 1),

        dividerColor: Colors.white24,

        cancelButtonStyle: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontSize: responsiveFontSize(14),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        confirmButtonStyle: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontSize: responsiveFontSize(14),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
                fontSize: responsiveFontSize(14),
                color: AppTheme.accentColor,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scaleFactor,
                vertical: 8 * scaleFactor,
              ),
            ),
          ),
        ),
        // ✅ الحل: استخدم Column عشان الـ constraints تشتغل صح
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: (size.width * 0.9).clamp(280.w, 600.w),
                maxHeight: (size.height * 0.75).clamp(400.h, 700.h),
                minWidth: 280.w,
                minHeight: 400.h,
              ),
              child: child!,
            ),
          ],
        ),
      );
    },
  );
}
