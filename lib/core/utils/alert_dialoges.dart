import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/theme/app_theme.dart';
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
