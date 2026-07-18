import 'package:azan/core/models/city_option.dart';
import 'package:azan/core/models/country_option.dart';
import 'package:azan/core/utils/dialoge_helper.dart';
import 'package:azan/data/data/city_country_data.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/utils/mqscale.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);
    final filtered = widget.items.where((item) {
      if (_query.trim().isEmpty) return true;
      final q = _query.trim().toLowerCase();
      if (item is CityOption) {
        final haystack = <String>[
          item.nameAr,
          item.nameEn,
          ...item.nameAliases,
        ].map((value) => value.toLowerCase()).join(' ');
        return haystack.contains(q);
      }
      final label = widget.labelBuilder(item).toLowerCase();
      return label.contains(q);
    }).toList();

    final listView = DialogContentCard(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final item = filtered[index];
          final label = widget.labelBuilder(item);
          return DialogSelectableTile(
            key: ValueKey('selection-tile-$label'),
            title: label,
            onTap: () {
              Navigator.of(context).pop(item);
              widget.onSelected(item);
            },
          );
        },
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemCount: filtered.length,
      ),
    );

    return UniversalDialogShell(
      forceMaxHeight: true,
      customMaxWidth: sizing.isLandscape
          ? sizing.screenWidth
          : sizing.dialogWidth,
      customMaxHeight: sizing.isLandscape
          ? sizing.screenHeight
          : sizing.dialogMaxHeight,
      customInsetPadding: sizing.isLandscape
          ? EdgeInsets.symmetric(
              horizontal: sizing.screenWidth * 0.02,
              vertical: sizing.screenHeight * 0.035,
            )
          : null,
      child: sizing.isLandscape
          ? LayoutBuilder(
              builder: (context, constraints) {
                // كل القياسات مشتقّة من sizing — مفيش أرقام ثابتة.
                // العنوان worst-case سطرين، والـ field بارتفاعه الفعلي.
                final titleH = sizing.titleFontSize * 1.3 * 2;
                final fieldH = sizing.textFieldHeight;
                final gap = sizing.verticalGap * 0.7;
                final kbPad = sizing.verticalGap * 0.55;
                final maxKbH =
                    constraints.maxHeight - titleH - gap - fieldH - kbPad;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(child: DialogTitle(widget.title)),
                              DialogCloseButton(
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          SizedBox(height: gap),
                          DialogSearchField(
                            key: const ValueKey('selection-dialog-search'),
                            controller: _searchController,
                            hint: widget.searchHint,
                            onChanged: (value) =>
                                setState(() => _query = value),
                            // الـ field بيعمل clamp(120, default) داخلياً
                            maxKeyboardHeight: maxKbH,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: sizing.verticalGap),
                    Expanded(flex: 6, child: listView),
                  ],
                );
              },
            )
          : Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Expanded(child: DialogTitle(widget.title)),
                    DialogCloseButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: sizing.verticalGap * 0.7),
                DialogSearchField(
                  key: const ValueKey('selection-dialog-search'),
                  controller: _searchController,
                  hint: widget.searchHint,
                  onChanged: (value) => setState(() => _query = value),
                ),
                SizedBox(height: sizing.verticalGap * 0.7),
                Flexible(child: listView),
              ],
            ),
    );
  }
}

Future<CountryOption?> showCountryPickerDialog(
  BuildContext context,
  Function(dynamic item) onSelected,
) {
  return showAppDialog<CountryOption>(
    context: context,
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
  List<CityOption> cities,
  Function(dynamic item) onSelected,
) {
  return showAppDialog<CityOption>(
    context: context,
    builder: (ctx) {
      return _SelectionDialogBody<CityOption>(
        title: LocaleKeys.mosque_city_select_title.tr(),
        items: cities,
        labelBuilder: (c) =>
            context.locale.languageCode == 'en' ? c.nameEn : c.nameAr,
        searchHint: LocaleKeys.city_search_hint.tr(),
        onSelected: onSelected,
      );
    },
  );
}
