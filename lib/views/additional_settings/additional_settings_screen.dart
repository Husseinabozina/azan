import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/alert_dialoges.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/adhkar/components/custom_check_box.dart';
import 'package:azan/views/home/home_screen_landscape.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdditionalSettingsScreen extends StatefulWidget {
  const AdditionalSettingsScreen({super.key});

  @override
  State<AdditionalSettingsScreen> createState() =>
      _AdditionalSettingsScreenState();
}

class _AdditionalSettingsScreenState extends State<AdditionalSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            CacheHelper.getSelectedBackground(),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fill,
          ),
          SafeArea(
            child: OrientationBuilder(
              builder: (context, o) {
                final isLandscape = o == Orientation.landscape;

                if (!isLandscape) {
                  // ✅ Portrait: scroll طبيعي
                  return SingleChildScrollView(
                    child: SizedBox(
                      width: 1.sw,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TopBar(),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 10.h,
                              left: 10.w,
                              right: 10.w,
                              bottom: 14.h,
                            ),
                            child: _PortraitContent(),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ✅ Landscape: Row من عمودين (وكل عمود سكرول رأسي لوحده)
                return SizedBox(
                  width: 1.sw,
                  child: Column(
                    children: [
                      _TopBar(),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 10.h,
                            left: 10.w,
                            right: 10.w,
                            bottom: 10.h,
                          ),
                          child: Row(
                            children: [
                              // LEFT PANEL
                              Expanded(
                                flex: 52,
                                child: _PanelScroll(
                                  child: _LandscapeLeftPanel(),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              // RIGHT PANEL
                              Expanded(
                                flex: 48,
                                child: _PanelScroll(
                                  child: _LandscapeRightPanel(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===================== TOP BAR =====================
  Widget _TopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            AppNavigator.pushAndRemoveUntil(
              context,
              MediaQuery.of(context).orientation == Orientation.landscape
                  ? const HomeScreenLandscape()
                  : const HomeScreenMobile(),
            );
          },
          icon: Icon(Icons.close, color: AppTheme.accentColor, size: 35.r),
        ),
        Text(
          LocaleKeys.additional_settings.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.menu, color: AppTheme.primaryTextColor, size: 35.r),
        ),
      ],
    );
  }
}

// ===================== PANELS HELPERS =====================

class _PanelScroll extends StatelessWidget {
  const _PanelScroll({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(child: SingleChildScrollView(child: child));
  }
}

// ===================== PORTRAIT CONTENT (زي بتاعك لكن مرتب) =====================

class _PortraitContent extends StatefulWidget {
  @override
  State<_PortraitContent> createState() => _PortraitContentState();
}

class _PortraitContentState extends State<_PortraitContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCheckTile(
          onChanged: (value) {
            setState(() => CacheHelper.setUse24HoursFormat(value));
          },
          title: LocaleKeys.enable_24_hours.tr(),
          value: CacheHelper.getUse24HoursFormat(),
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: (value) {
            setState(() => CacheHelper.setIsFullTimeEnabled(value));
          },
          title: "${LocaleKeys.enable_full_time.tr()} 00:00:00",
          value: CacheHelper.getIsFullTimeEnabled(),
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: (value) {
            setState(() => CacheHelper.setIsPreviousPrayersDimmed(value));
          },
          title: LocaleKeys.dim_previous_prayers.tr(),
          value: CacheHelper.getIsPreviousPrayersDimmed(),
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: (value) {
            setState(() => CacheHelper.setIsChangeCounterEnabled(value));
          },
          title: LocaleKeys.change_counter_color.tr(),
          value: CacheHelper.getIsChangeCounterEnabled(),
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: (value) {
            setState(() => CacheHelper.setIsArabicNumbersEnabled(value));
          },
          title: LocaleKeys.enable_arabic_numbers.tr(),
          value: CacheHelper.getIsArabicNumbersEnabled(),
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: (value) {
            setState(() {
              CacheHelper.setEnableCheckInternetConnection(value);
            });
          },
          title: LocaleKeys.check_your_internet_connection_the_star.tr(),
          value: CacheHelper.getEnableCheckInternetConnection(),
        ),

        VerticalSpace(height: 14.h),
        _DividerLine(),
        VerticalSpace(height: 14.h),

        _EidSection(onChanged: () => setState(() {})),

        VerticalSpace(height: 14.h),
        _DividerLine(),
        VerticalSpace(height: 14.h),

        _FontsSection(onChanged: () => setState(() {})),
      ],
    );
  }
}

// ===================== LANDSCAPE LEFT PANEL =====================

class _LandscapeLeftPanel extends StatefulWidget {
  @override
  State<_LandscapeLeftPanel> createState() => _LandscapeLeftPanelState();
}

class _LandscapeLeftPanelState extends State<_LandscapeLeftPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // toggles
        CustomCheckTile(
          onChanged: (value) =>
              setState(() => CacheHelper.setUse24HoursFormat(value)),
          title: LocaleKeys.enable_24_hours.tr(),
          value: CacheHelper.getUse24HoursFormat(),
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: (value) =>
              setState(() => CacheHelper.setIsFullTimeEnabled(value)),
          title: "${LocaleKeys.enable_full_time.tr()} 00:00:00",
          value: CacheHelper.getIsFullTimeEnabled(),
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: (value) =>
              setState(() => CacheHelper.setIsPreviousPrayersDimmed(value)),
          title: LocaleKeys.dim_previous_prayers.tr(),
          value: CacheHelper.getIsPreviousPrayersDimmed(),
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: (value) =>
              setState(() => CacheHelper.setIsChangeCounterEnabled(value)),
          title: LocaleKeys.change_counter_color.tr(),
          value: CacheHelper.getIsChangeCounterEnabled(),
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: (value) =>
              setState(() => CacheHelper.setIsArabicNumbersEnabled(value)),
          title: LocaleKeys.enable_arabic_numbers.tr(),
          value: CacheHelper.getIsArabicNumbersEnabled(),
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: (value) => setState(() {
            CacheHelper.setEnableCheckInternetConnection(value);
          }),
          title: LocaleKeys.check_your_internet_connection_the_star.tr(),
          value: CacheHelper.getEnableCheckInternetConnection(),
        ),

        VerticalSpace(height: 14.h),
        _DividerLine(),
        VerticalSpace(height: 14.h),

        _EidSection(onChanged: () => setState(() {})),
      ],
    );
  }
}

// ===================== LANDSCAPE RIGHT PANEL =====================

class _LandscapeRightPanel extends StatefulWidget {
  @override
  State<_LandscapeRightPanel> createState() => _LandscapeRightPanelState();
}

class _LandscapeRightPanelState extends State<_LandscapeRightPanel> {
  @override
  Widget build(BuildContext context) {
    return _FontsSection(onChanged: () => setState(() {}));
  }
}

// ===================== SECTIONS =====================

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2.h,
      width: double.infinity,
      color: AppTheme.secondaryTextColor,
    );
  }
}

class _EidSection extends StatelessWidget {
  const _EidSection({required this.onChanged});
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final lang = LocalizationHelper.isArAndArNumberEnable(context)
        ? CacheHelper.getLang()
        : 'en';

    return Column(
      children: [
        Row(
          // crossAxisAlignment:  ,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  showAddEidDialog(
                    LocaleKeys.eid_al_fitr.tr(),
                    context,
                    onConfirm: (date, time) {
                      CacheHelper.setFitrEid(
                        DateFormat('yyyy-MM-dd', lang).format(date),
                        DateHelper.formatTimeWithSettings(time, context),
                      );
                      onChanged();
                    },
                    onCancel: () {},
                  );
                },
                child: Text(
                  LocaleKeys.set_fetr_eid_prayer.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              ),
            ),

            Expanded(
              child: CustomTimeCheckTile(
                titleValue: CacheHelper.getFitrEid() != null
                    ? "${CacheHelper.getFitrEid()![0]} ${CacheHelper.getFitrEid()![1]}"
                    : null,
                title: LocaleKeys.show_fetr_eid_prayer.tr(),
                value: CacheHelper.getShowFitrEid(),
                onChanged: (value) {
                  CacheHelper.setShowFitrEid(value);
                  onChanged();
                },
              ),
            ),

            // VerticalSpace(height: 6.h),
          ],
        ),
        VerticalSpace(height: 10.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  showAddEidDialog(
                    LocaleKeys.eid_al_adha.tr(),
                    context,
                    onConfirm: (date, time) {
                      CacheHelper.setAdhaEid(
                        DateFormat('yyyy-MM-dd', lang).format(date),
                        DateHelper.formatTimeWithSettings(time, context),
                      );
                      onChanged();
                    },
                    onCancel: () {},
                  );
                },
                child: Text(
                  LocaleKeys.set_adha_eid_prayer.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              ),
            ),
            // Spacer(),
            Expanded(
              child: CustomTimeCheckTile(
                titleValue: CacheHelper.getAdhaEid() != null
                    ? "${CacheHelper.getAdhaEid()![0]} ${CacheHelper.getAdhaEid()![1]}"
                    : null,
                title: LocaleKeys.show_adha_eid_prayer.tr(),
                value: CacheHelper.getShowAdhaEid(),
                onChanged: (value) {
                  CacheHelper.setShowAdhaEid(value);
                  onChanged();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FontsSection extends StatelessWidget {
  const _FontsSection({required this.onChanged});
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // عدد الأعمدة حسب العرض المتاح (بدون overflow)
        int cols = 4;
        if (c.maxWidth < 520)
          cols = 2;
        else if (c.maxWidth < 760)
          cols = 3;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                LocaleKeys.set_app_fonts.tr(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTextColor,
                ),
              ),
            ),
            VerticalSpace(height: 10.h),

            _FontsGrid(columns: cols, onChanged: onChanged),
          ],
        );
      },
    );
  }
}

class _FontsGrid extends StatelessWidget {
  const _FontsGrid({required this.columns, required this.onChanged});
  final int columns;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final groups = <_FontGroupData>[
      _FontGroupData(
        header: LocaleKeys.the_adhkar.tr(),
        headerStyle: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryTextColor,
        ),
        items: azkarFonts,
        selected: CacheHelper.getAzkarFontFamily(),
        onSelect: (v) {
          CacheHelper.setAzkarFontFamily(v);
          onChanged();
        },
      ),
      _FontGroupData(
        header: LocaleKeys.time.tr(),
        headerStyle: TextStyle(
          fontFamily: CacheHelper.getTimeFontFamily(),
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryTextColor,
        ),
        items: timeFonts,
        selected: CacheHelper.getTimeFontFamily(),
        onSelect: (v) {
          CacheHelper.setTimeFontFamily(v);
          onChanged();
        },
      ),
      _FontGroupData(
        header: LocaleKeys.prayers.tr(),
        headerStyle: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryTextColor,
        ),
        items: timesFonts,
        selected: CacheHelper.getTimesFontFamily(),
        onSelect: (v) {
          CacheHelper.setTimesFontFamily(v);
          onChanged();
        },
      ),
      _FontGroupData(
        header: LocaleKeys.texts.tr(),
        headerStyle: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryTextColor,
        ),
        items: textsFonts,
        selected: CacheHelper.getTextsFontFamily(),
        onSelect: (v) {
          CacheHelper.setTextsFontFamily(v);
          onChanged();
        },
      ),
    ];

    // لو columns أقل من 4، هنرتبهم في GridView
    return GridView.builder(
      itemCount: groups.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        // ارتفاع مرن حسب المحتوى (نجرب امتداد ثابت مناسب)
        mainAxisExtent: 100.h,
      ),
      itemBuilder: (context, i) => _FontGroupCard(data: groups[i]),
    );
  }
}

class _FontGroupData {
  _FontGroupData({
    required this.header,
    required this.headerStyle,
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  final String header;
  final TextStyle headerStyle;
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelect;
}

class _FontGroupCard extends StatelessWidget {
  const _FontGroupCard({required this.data});
  final _FontGroupData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(data.header, style: data.headerStyle),
        ),
        VerticalSpace(height: 10.h),
        ...List.generate(data.items.length, (index) {
          final name = data.items[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: CustomCheckTile(
              checkBoxSize: 18.r,
              fontSize: 12.sp,
              title: name,
              value: data.selected == name,
              onChanged: (_) => data.onSelect(name),
            ),
          );
        }),
      ],
    );
  }
}

// ===================== TILES =====================

class CustomCheckTile extends StatelessWidget {
  const CustomCheckTile({
    super.key,
    required this.onChanged,
    required this.title,
    required this.value,
    this.fontSize,
    this.checkBoxSize,
  });

  final Function(bool value) onChanged;
  final String title;
  final bool value;
  final double? fontSize;
  final double? checkBoxSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomCheckbox(
          size: checkBoxSize ?? 20.r,
          activeColor: AppTheme.accentColor,
          value: value,
          onChanged: onChanged,
        ),
        HorizontalSpace(width: 6.w),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize ?? 15.sp,
              color: AppTheme.primaryTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTimeCheckTile extends StatelessWidget {
  const CustomTimeCheckTile({
    super.key,
    required this.onChanged,
    required this.title,
    required this.value,
    this.fontSize,
    this.checkBoxSize,
    required this.titleValue,
  });

  final Function(bool value) onChanged;
  final String title;
  final bool value;
  final double? fontSize;
  final double? checkBoxSize;
  final String? titleValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomCheckbox(
          size: checkBoxSize ?? 20.r,
          activeColor: AppTheme.accentColor,
          value: value,
          onChanged: onChanged,
        ),
        HorizontalSpace(width: 6.w),

        // ✅ ده كان سبب overflow عندك: لازم Expanded + RichText بحدود
        Expanded(
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$title: ",
                  style: TextStyle(
                    fontSize: (fontSize ?? 12.sp),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
                TextSpan(
                  text: titleValue ?? '--:--',
                  style: TextStyle(
                    fontSize: (fontSize ?? 12.sp),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
