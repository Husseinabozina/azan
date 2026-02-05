// selection_dialog.dart
import 'package:azan/core/models/city_option.dart';
import 'package:azan/core/models/country_option.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/data/data/city_country_data.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';

typedef ItemLabel<T> = String Function(T item);

class _SelectionDialogBody<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final ItemLabel<T> labelBuilder;
  final String searchHint;
  final Function(T item) onSelected;
  const _SelectionDialogBody({
    required this.title,
    required this.items,
    required this.labelBuilder,
    required this.searchHint,
    required this.onSelected,
  });

  @override
  State<_SelectionDialogBody<T>> createState() =>
      _SelectionDialogBodyState<T>();
}

class _SelectionDialogBodyState<T> extends State<_SelectionDialogBody<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((item) {
      if (_query.trim().isEmpty) return true;
      final label = widget.labelBuilder(item);
      final q = _query.trim();
      return label.contains(q);
    }).toList();

    return Dialog(
      backgroundColor: AppTheme.dialogBackgroundColor,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width:
            // MediaQuery.of(context).size.width * 0.8,
            1.sw - 70.w,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppTheme.dialogBackgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 4.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // العنوان + زر إغلاق
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // حقل البحث
              TextField(
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                textAlign: TextAlign.right,
                onChanged: (val) {
                  setState(() => _query = val);
                },
              ),
              SizedBox(height: 16.h),

              // ليست العناصر
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final label = widget.labelBuilder(item);

                    return InkWell(
                      onTap: () {
                        widget.onSelected(item);
                        // AppNavigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemCount: filtered.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<CountryOption?> showCountryPickerDialog(
  BuildContext context,
  Function(dynamic item) onSelected,
) {
  return showDialog<CountryOption>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return _SelectionDialogBody<CountryOption>(
        title: 'اختر بلد المسجد',
        items: kCountries,
        labelBuilder: (c) => c.nameAr,
        searchHint: 'ابحث عن الدولة',
        onSelected: onSelected,
      );
    },
  );
}

Future<CityOption?> showSaudiCityPickerDialog(
  BuildContext context,
  Function(dynamic item) onSelected,
) {
  return showDialog<CityOption>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return _SelectionDialogBody<CityOption>(
        title: LocaleKeys.mosque_city_select_title.tr(),
        items: kSaudiCities,
        labelBuilder: (c) =>
            context.locale.languageCode == 'en' ? c.nameEn : c.nameAr,
        searchHint: LocaleKeys.city_search_hint.tr(),
        onSelected: onSelected,
      );
    },
  );
}
