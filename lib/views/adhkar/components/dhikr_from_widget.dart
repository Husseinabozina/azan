import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/azkar_scheduling_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: _selectedDate ?? now,
      locale: const Locale('ar'),
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
      textDirection: TextDirection.rtl, // عشان العربي
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إضافة ذكر جديد',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _textController,
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
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
                    hintText: 'اكتب نص الذكر هنا',
                    hintStyle: TextStyle(color: Colors.grey.shade500),

                    // نخليها بوكس أبيض جوه الديالوج الأزرق
                    filled: true,
                    fillColor: Colors.white,

                    // البوردر العادي
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),

                    // البوردر وقت الـ focus
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFFF4C66A), // نفس الذهبي بتاع الحوار
                        width: 2,
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

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'من فضلك أدخل نص الذكر';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'نوع الجدولة',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<DhikrScheduleType>(
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  value: _selectedType,
                  isExpanded: true,
                  dropdownColor: AppTheme.primaryTextColor,
                  style: const TextStyle(color: AppTheme.secondaryTextColor),
                  items: [
                    DropdownMenuItem(
                      value: DhikrScheduleType.none,
                      child: Text(
                        'بدون جدولة (يظهر دائمًا)',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                    DropdownMenuItem(
                      value: DhikrScheduleType.daily,
                      child: Text('يوميًا', style: TextStyle(fontSize: 16.sp)),
                    ),
                    DropdownMenuItem(
                      value: DhikrScheduleType.weekly,
                      child: Text(
                        'أيام محددة من الأسبوع',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                    DropdownMenuItem(
                      value: DhikrScheduleType.specificDate,
                      child: Text(
                        'تاريخ محدد مرة واحدة',
                        style: TextStyle(fontSize: 16.sp),
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
                const SizedBox(height: 12),

                /// لو Weekly -> نعرض اختيارات الأيام
                if (_selectedType == DhikrScheduleType.weekly) ...[
                  const Text(
                    'اختر اليوم / الأيام:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _weekdayLabels.entries.map((entry) {
                      final day = entry.key;
                      final label = entry.value;
                      final isSelected = _selectedWeekdays.contains(day);
                      return FilterChip(
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _pickDate,
                        child: const Text('اختيار التاريخ'),
                      ),
                      const SizedBox(width: 8),
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

                const SizedBox(height: 24),
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
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
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
                      child: const Text(
                        'حفظ الذكر',
                        style: TextStyle(
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
