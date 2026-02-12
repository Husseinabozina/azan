import 'dart:ui';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/azkar_scheduling_enums.dart';
import 'package:azan/core/utils/dialoge_helper.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;

class ImprovedDhikrFormWidget extends StatefulWidget {
  final void Function(String text, DhikrSchedule? schedule) onSubmit;

  const ImprovedDhikrFormWidget({Key? key, required this.onSubmit})
    : super(key: key);

  @override
  State<ImprovedDhikrFormWidget> createState() =>
      _ImprovedDhikrFormWidgetState();
}

class _ImprovedDhikrFormWidgetState extends State<ImprovedDhikrFormWidget> {
  final _textController = TextEditingController();
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
    final picked = await showUniversalDatePicker(
      context,
      initialDate: DateTime.now(),
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
    final sizing = DialogConfig.getSizing(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        // horizontal: sizing.screenWidth * 0.04,
        // vertical: sizing.screenHeight * 0.02,
      ),
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
                  fontSize: sizing.bodyFontSize * 1.2,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryTextColor,
                ),
              ),

              SizedBox(height: sizing.verticalGap * 0.8),

              // TextField للنص
              TextFormField(
                controller: _textController,
                maxLines: 3,
                textDirection: widgets.TextDirection.rtl,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: sizing.bodyFontSize,
                ),
                selectionWidthStyle: BoxWidthStyle.max,
                selectionHeightStyle: BoxHeightStyle.max,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  alignLabelWithHint: true,
                  hintText: LocaleKeys.dhikr_add_new_title.tr(),
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
                    horizontal: sizing.screenWidth * 0.04,
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

              // Dropdown للنوع
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
                  });
                },
              ),

              SizedBox(height: sizing.verticalGap * 0.6),

              // اختيارات الأيام (Weekly)
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

              // اختيار تاريخ محدد
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

              // أزرار الحفظ والإلغاء
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
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
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
                        LocaleKeys.dhikr_save_button.tr(),
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
      ),
    );
  }
}
