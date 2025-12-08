import 'dart:ui';

import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/azkar_scheduling_enums.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/widgets.dart' as widgets;

class DhikrFormWidget extends StatefulWidget {
  final void Function(String text, DhikrSchedule? schedule) onSubmit;

  const DhikrFormWidget({super.key, required this.onSubmit});

  @override
  State<DhikrFormWidget> createState() => _DhikrFormWidgetState();
}

class _DhikrFormWidgetState extends State<DhikrFormWidget> {
  final _textController = TextEditingController();
  DhikrScheduleType _selectedType = DhikrScheduleType.none;
  final Set<int> _selectedWeekdays = {}; // DateTime.weekday values (1..7)
  DateTime? _selectedDate;

  final _formKey = GlobalKey<FormState>();

  static const Map<int, String> _weekdayLabels = {
    DateTime.saturday: 'السبت',
    DateTime.sunday: 'الأحد',
    DateTime.monday: 'الإثنين',
    DateTime.tuesday: 'الثلاثاء',
    DateTime.wednesday: 'الأربعاء',
    DateTime.thursday: 'الخميس',
    DateTime.friday: 'الجمعة',
  };

  DhikrSchedule? _buildSchedule() {
    switch (_selectedType) {
      case DhikrScheduleType.none:
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
    final now = DateTime.now();
    final size = MediaQuery.of(context).size;

    // حساب الـ scale factor بناءً على عرض الشاشة
    final scaleFactor = (size.width / 390).clamp(0.9, 1.8);

    // دالة مساعدة لحساب الحجم responsive
    double responsiveFontSize(double baseSize) {
      return (baseSize * scaleFactor).clamp(baseSize * 0.8, baseSize * 1.5);
    }

    const darkBlue = Color(0xFF0C355C);
    const gold = Color(0xFFF4C66A);

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: _selectedDate ?? now,
      locale: const Locale('ar'),
      builder: (context, child) {
        final baseTheme = Theme.of(context);

        final datePickerTheme = DatePickerThemeData(
          backgroundColor: darkBlue,
          headerBackgroundColor: darkBlue,
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

          dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.white;
          }),

          dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return gold;
            }
            return Colors.transparent;
          }),

          todayBackgroundColor: WidgetStateProperty.all(gold.withOpacity(0.2)),
          todayBorder: const BorderSide(color: gold, width: 1),

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
              primary: gold,
              onPrimary: Colors.white,
              surface: darkBlue,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: darkBlue,
            datePickerTheme: datePickerTheme,

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: gold,
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: responsiveFontSize(14),
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

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widgets.TextDirection.rtl, // عشان العربي
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إضافة ذكر جديد',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                VerticalSpace(height: 16),
                TextFormField(
                  controller: _textController,
                  maxLines: 3,
                  textDirection: widgets.TextDirection.rtl,
                  style: TextStyle(color: Colors.black87, fontSize: 12.sp),
                  selectionWidthStyle: BoxWidthStyle.max,
                  selectionHeightStyle: BoxHeightStyle.max,

                  decoration: InputDecoration(
                    // labelText: 'نص الذكر',
                    // نخلي الليبل دايمًا فوق
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    // مهم عشان multiline
                    alignLabelWithHint: true,

                    // شكل الليبل
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),

                    // لو حابب تضيف هينت جوا
                    hintText: LocaleKeys.dhikr_add_new_title.tr(),
                    hintStyle: TextStyle(color: Colors.grey.shade500),

                    // نخليها بوكس أبيض جوه الديالوج الأزرق
                    filled: true,
                    fillColor: Colors.white,

                    // البوردر العادي
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1.5.w,
                      ),
                    ),

                    // البوردر وقت الـ focus
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: Color(0xFFF4C66A), // نفس الذهبي بتاع الحوار
                        width: 2.w,
                      ),
                    ),

                    // بوردر الـ error
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),

                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return LocaleKeys.dhikr_text_required_error.tr();
                    }
                    return null;
                  },
                ),
                VerticalSpace(height: 16),

                Text(
                  LocaleKeys.schedule_type_label.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryTextColor,
                    fontSize: 14.sp,
                  ),
                ),

                // VerticalSpace(height: 8),
                SizedBox(
                  // height: 52, // عشا
                  //ن يبقى نفس ارتفاع التكست فيلد تقريبًا
                  child: DropdownButtonFormField<DhikrScheduleType>(
                    iconSize: 25.r,
                    value: _selectedType,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.black87,
                    ),

                    // دي أهم حاجة عشان الشكل يبقى زي التكست فيلد
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none, // مفيش خط زيادة
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Color(0xFFF4C66A), // نفس الدهبى بتاعك
                          width: 2.w,
                        ),
                      ),
                    ),

                    borderRadius: BorderRadius.circular(16),
                    dropdownColor: Colors.white,

                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16.sp,
                      height: 1.3, // يفتح الكلام شوية بدل ما يبقى لازق في بعضه
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
                        child: Text(
                          LocaleKeys.schedule_type_specific_date.tr(),
                        ),
                      ),
                    ],

                    onChanged: (val) {
                      if (val == null) return;
                      setState(() {
                        _selectedType = val;
                      });
                    },
                  ),
                ),

                const VerticalSpace(height: 12),

                /// لو Weekly -> نعرض اختيارات الأيام
                if (_selectedType == DhikrScheduleType.weekly) ...[
                  Text(
                    LocaleKeys.schedule_select_days_label.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  VerticalSpace(height: 8),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 5.h,
                    children: _weekdayLabels.entries.map((entry) {
                      final day = entry.key;
                      final label = entry.value;
                      final isSelected = _selectedWeekdays.contains(day);
                      return FilterChip(
                        labelStyle: TextStyle(fontSize: 10.sp),
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

                /// لو تاريخ محدد -> زر يختار التاريخ
                if (_selectedType == DhikrScheduleType.specificDate) ...[
                  const VerticalSpace(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _pickDate,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                        ),
                        child: Text(
                          LocaleKeys.schedule_select_date_label.tr(),
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                      const HorizontalSpace(width: 8),
                      if (_selectedDate != null)
                        Text(
                          '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}',

                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                    ],
                  ),
                ],

                const VerticalSpace(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 100.w,
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
                          child: Text(
                            LocaleKeys.common_cancel.tr(),

                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTextColor,

                        padding: EdgeInsets.zero,
                        minimumSize: Size(100.w, 40.h),
                        maximumSize: Size(100.w, 40.h),
                      ),

                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;

                        final text = _textController.text.trim();
                        final schedule = _buildSchedule();

                        widget.onSubmit(text, schedule);
                      },
                      child: Text(
                        LocaleKeys.dhikr_save_button.tr(),

                        style: TextStyle(
                          fontSize: 14.sp,

                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
  }
}
