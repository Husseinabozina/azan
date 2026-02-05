import 'dart:ui';

import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/alert_dialoges.dart';
import 'package:azan/core/utils/azkar_scheduling_enums.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';
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

  static final Map<int, String> _weekdayLabels = {
    DateTime.saturday: LocaleKeys.day_saturday.tr(),
    DateTime.sunday: LocaleKeys.day_sunday.tr(),
    DateTime.monday: LocaleKeys.day_monday.tr(),
    DateTime.tuesday: LocaleKeys.day_tuesday.tr(),
    DateTime.wednesday: LocaleKeys.day_wednesday.tr(),
    DateTime.thursday: LocaleKeys.day_thursday.tr(),
    DateTime.friday: LocaleKeys.day_friday.tr(),
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

    // دالة مساعدة لحساب الحجم responsive

    final picked = await showCustomDatePicker(now, context);

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.dhikr_add_new_title.tr(),
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
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
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
                      child: Text(LocaleKeys.schedule_type_specific_date.tr()),
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
                      labelStyle: TextStyle(
                        fontSize: 10.sp,
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

              /// لو تاريخ محدد -> زر يختار التاريخ
              if (_selectedType == DhikrScheduleType.specificDate) ...[
                const VerticalSpace(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickDate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryButtonBackground,

                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                      ),
                      child: Text(
                        LocaleKeys.schedule_select_date_label.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
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
                      backgroundColor: AppTheme.primaryButtonBackground,

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
    );
  }
}
