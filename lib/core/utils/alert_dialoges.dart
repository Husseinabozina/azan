import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/views/adhkar/components/dhikr_from_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        child: Directionality(
          // عشان RTL
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              width: 1.sw - 70.w,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
              decoration: BoxDecoration(
                color: const Color(0xFF163A63), // الأزرق الغامق
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
                    'تحرير اسم المسجد',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF4C66A), // أصفر/ذهبي
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // حقل اسم المسجد
                  TextField(
                    controller: controller,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'اسم المسجد',
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
                      // زر موافق
                      SizedBox(
                        width: 74.w,
                        height: 40.h,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFFE8EEF7),
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
                          child: const Text(
                            'موافق',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: r.blockW * 1),

                      // زر إلغاء
                      SizedBox(
                        width: 74.w,
                        height: 40.h,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFFE8EEF7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
                              color: Colors.black87,
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
        child: Directionality(
          textDirection: TextDirection.rtl,
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
                  color: const Color(0xFF163A63),
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
                      'إضافة ذكر للمسجد',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF4C66A),
                      ),
                    ),
                    SizedBox(height: 16.h),

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
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              width: 1.sw - 70.w,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
              decoration: BoxDecoration(
                color: const Color(0xFF163A63), // الأزرق الغامق
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
                    'حذف الذكر',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF4C66A), // أصفر/ذهبي
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // النص
                  Text(
                    dhikrText == null || dhikrText.isEmpty
                        ? 'هل أنت متأكد من حذف هذا الذكر؟'
                        : 'هل أنت متأكد من حذف هذا الذكر؟\n\n"$dhikrText"',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                  ),

                  SizedBox(height: 20.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // زر حذف
                      SizedBox(
                        width: 90.w,
                        height: 40.h,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFE57373,
                            ), // أحمر فاتح
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          onPressed: () {
                            onConfirm();

                            Navigator.of(context).pop(true); // موافق على الحذف
                          },
                          child: const Text(
                            'حذف',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // زر إلغاء
                      SizedBox(
                        width: 90.w,
                        height: 40.h,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFE8EEF7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
                              color: Colors.black87,
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
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              width: 1.sw - 70.w,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
              decoration: BoxDecoration(
                color: const Color(0xFF163A63), // الأزرق الغامق
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
                    'تعديل الذكر',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF4C66A), // أصفر/ذهبي
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // حقل نص الذكر
                  TextField(
                    controller: controller,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'نص الذكر',
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
                      // زر موافق
                      SizedBox(
                        width: 90.w,
                        height: 40.h,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFE8EEF7),
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
                          child: const Text(
                            'موافق',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // زر إلغاء
                      SizedBox(
                        width: 90.w,
                        height: 40.h,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFE8EEF7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
                              color: Colors.black87,
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
          ),
        ),
      );
    },
  );
}
