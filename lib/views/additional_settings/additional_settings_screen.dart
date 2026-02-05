import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/alert_dialoges.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/additional_settings/components/azan_iqam_sound.dart';
import 'package:azan/views/adhkar/components/custom_check_box.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:azan/views/home/home_screen_landscape.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';

class AdditionalSettingsScreen extends StatefulWidget {
  const AdditionalSettingsScreen({super.key});

  @override
  State<AdditionalSettingsScreen> createState() =>
      _AdditionalSettingsScreenState();
}

class _AdditionalSettingsScreenState extends State<AdditionalSettingsScreen> {
  // ✅ UI state (علشان اللون يتغير فورًا)
  late bool use24h;
  late bool fullTime;
  late bool dimPrev;
  late bool changeCounter;
  late bool arabicNumbers;
  late bool checkInternet;
  late int sliderTime;
  @override
  void initState() {
    super.initState();
    use24h = CacheHelper.getUse24HoursFormat();
    fullTime = CacheHelper.getIsFullTimeEnabled();
    dimPrev = CacheHelper.getIsPreviousPrayersDimmed();
    changeCounter = CacheHelper.getIsChangeCounterEnabled();
    arabicNumbers = CacheHelper.getIsArabicNumbersEnabled();
    checkInternet = CacheHelper.getEnableCheckInternetConnection();
    sliderTime = CacheHelper.getSliderTime();
  }

  Future<void> _setUse24h(bool v) async {
    setState(() => use24h = v);
    await CacheHelper.setUse24HoursFormat(v);
  }

  void _setFullTime(bool v) {
    setState(() => fullTime = v);
    CacheHelper.setIsFullTimeEnabled(v);
  }

  void _setDimPrev(bool v) {
    setState(() => dimPrev = v);
    CacheHelper.setIsPreviousPrayersDimmed(v);
  }

  void _setChangeCounter(bool v) {
    setState(() => changeCounter = v);
    CacheHelper.setIsChangeCounterEnabled(v);
  }

  void _setArabicNumbers(bool v) {
    setState(() => arabicNumbers = v);
    CacheHelper.setIsArabicNumbersEnabled(v);
  }

  void _setCheckInternet(bool v) {
    setState(() => checkInternet = v);
    CacheHelper.setEnableCheckInternetConnection(v);
  }

  void _setSliderTime(int v) {
    setState(() => sliderTime = v);
    CacheHelper.setSliderTime(v);
  }

  @override
  Widget build(BuildContext context) {
    'widthoooo ${1.sw} && heightoooooo ${1.sh}'.log();

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            CacheHelper.getSelectedBackground(),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fill,
          ),

          !UiRotationCubit().isLandscape()
              ?
                // ✅ Portrait: scroll طبيعي
                SingleChildScrollView(
                  child: SizedBox(
                    width: 1.sw,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(context: context),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 10.h,
                            left: 10.w,
                            right: 10.w,
                            bottom: 14.h,
                          ),
                          child: _PortraitContent(
                            enableShadow: CacheHelper.getEnableGlassEffect(),
                            onEnableShadow: (value) => setState(() {
                              CacheHelper.setEnableGlassEffect(value);
                            }),
                            sliderTime: sliderTime,
                            onSliderTime: _setSliderTime,
                            use24h: use24h,
                            fullTime: fullTime,
                            dimPrev: dimPrev,
                            changeCounter: changeCounter,
                            arabicNumbers: arabicNumbers,
                            checkInternet: checkInternet,
                            onUse24h: _setUse24h,
                            onFullTime: _setFullTime,
                            onDimPrev: _setDimPrev,
                            onChangeCounter: _setChangeCounter,
                            onArabicNumbers: _setArabicNumbers,
                            onCheckInternet: _setCheckInternet,
                            onRefresh: () => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              :
                // ✅ Landscape: عمودين - كل عمود سكرول لوحده
                SingleChildScrollView(
                  child: SizedBox(
                    width: 1.sw,
                    child: Column(
                      children: [
                        _TopBar(context: context),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 10.h,
                            left: 10.w,
                            right: 10.w,
                            bottom: 10.h,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 52,
                                child: _PanelScroll(
                                  child: _LandscapeLeftPanel(
                                    onEnableShadow: (value) => setState(() {
                                      CacheHelper.setEnableGlassEffect(value);
                                    }),
                                    enableShadow:
                                        CacheHelper.getEnableGlassEffect(),
                                    onSliderTime: _setSliderTime,
                                    sliderTime: sliderTime,

                                    use24h: use24h,
                                    fullTime: fullTime,
                                    dimPrev: dimPrev,
                                    changeCounter: changeCounter,
                                    arabicNumbers: arabicNumbers,
                                    checkInternet: checkInternet,
                                    onUse24h: _setUse24h,
                                    onFullTime: _setFullTime,
                                    onDimPrev: _setDimPrev,
                                    onChangeCounter: _setChangeCounter,
                                    onArabicNumbers: _setArabicNumbers,
                                    onCheckInternet: _setCheckInternet,
                                    onRefresh: () => setState(() {}),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                flex: 48,
                                child: _PanelScroll(
                                  child: _LandscapeRightPanel(
                                    onRefresh: () => setState(() {}),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ===================== TOP BAR =====================

class _TopBar extends StatelessWidget {
  const _TopBar({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext context2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            AppNavigator.pushAndRemoveUntil(context, HomeScreen());
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

// ===================== PORTRAIT CONTENT =====================

class _PortraitContent extends StatelessWidget {
  const _PortraitContent({
    required this.use24h,
    required this.fullTime,
    required this.dimPrev,
    required this.changeCounter,
    required this.arabicNumbers,
    required this.checkInternet,
    required this.onUse24h,
    required this.onFullTime,
    required this.onDimPrev,
    required this.onChangeCounter,
    required this.onArabicNumbers,
    required this.onCheckInternet,
    required this.onRefresh,
    required this.sliderTime,
    required this.onSliderTime,
    required this.enableShadow,
    required this.onEnableShadow,
  });

  final bool use24h;
  final bool fullTime;
  final bool dimPrev;
  final bool changeCounter;
  final bool arabicNumbers;
  final bool checkInternet;
  final bool enableShadow;

  final int sliderTime;

  final void Function(int) onSliderTime;

  final Future<void> Function(bool) onUse24h;
  final void Function(bool) onFullTime;
  final void Function(bool) onDimPrev;
  final void Function(bool) onChangeCounter;
  final void Function(bool) onArabicNumbers;
  final void Function(bool) onCheckInternet;
  final void Function(bool) onEnableShadow;

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCheckTile(
          onChanged: (v) => onUse24h(v),
          title: LocaleKeys.enable_24_hours.tr(),
          value: use24h,
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: onFullTime,
          title: "${LocaleKeys.enable_full_time.tr()} 00:00:00",
          value: fullTime,
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: onDimPrev,
          title: LocaleKeys.dim_previous_prayers.tr(),
          value: dimPrev,
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: onChangeCounter,
          title: LocaleKeys.change_counter_color.tr(),
          value: changeCounter,
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: onArabicNumbers,
          title: LocaleKeys.enable_arabic_numbers.tr(),
          value: arabicNumbers,
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: onCheckInternet,
          title: LocaleKeys.check_your_internet_connection_the_star.tr(),
          value: checkInternet,
        ),
        VerticalSpace(height: 12),
        CustomCheckTile(
          onChanged: onEnableShadow,
          title: LocaleKeys.enable_shadow_around_prayers.tr(),
          value: enableShadow,
        ),
        VerticalSpace(height: 12),
        _zekrAppearDurationWidget(
          onSliderTime: onSliderTime,
          sliderTime: sliderTime,
        ),

        VerticalSpace(height: 12),
        const _DividerLine(),
        VerticalSpace(height: 12),

        _EidSection(onChanged: onRefresh),

        VerticalSpace(height: 12),

        const _DividerLine(),
        VerticalSpace(height: 12),
        AzanIqamaSoundOptions(
          initialUseMp3: CacheHelper.getUseMp3Azan(), // انت اعمل getter
          initialShortAzan: CacheHelper.getUseShortAzan(), // انت اعمل getter
          initialShortIqama: CacheHelper.getUseShortIqama(), // انت اعمل getter
          onUseMp3Changed: (v) => CacheHelper.setUseMp3Azan(v),
          onShortAzanChanged: (v) => CacheHelper.setUseShortAzan(v),
          onShortIqamaChanged: (v) => CacheHelper.setUseShortIqama(v),
        ),
        VerticalSpace(height: 12),

        _FontsSection(onChanged: onRefresh),
      ],
    );
  }
}

// ===================== LANDSCAPE LEFT PANEL =====================

class _LandscapeLeftPanel extends StatelessWidget {
  const _LandscapeLeftPanel({
    required this.use24h,
    required this.fullTime,
    required this.dimPrev,
    required this.changeCounter,
    required this.arabicNumbers,
    required this.checkInternet,
    required this.onUse24h,
    required this.onFullTime,
    required this.onDimPrev,
    required this.onChangeCounter,
    required this.onArabicNumbers,
    required this.onCheckInternet,
    required this.onRefresh,

    required this.sliderTime,
    required this.onSliderTime,
    required this.enableShadow,
    required this.onEnableShadow,
  });

  final bool use24h;
  final bool fullTime;
  final bool dimPrev;
  final bool changeCounter;
  final bool arabicNumbers;
  final bool checkInternet;
  final int sliderTime;
  final bool enableShadow;
  final void Function(int) onSliderTime;
  final void Function(bool) onEnableShadow;

  final Future<void> Function(bool) onUse24h;
  final void Function(bool) onFullTime;
  final void Function(bool) onDimPrev;
  final void Function(bool) onChangeCounter;
  final void Function(bool) onArabicNumbers;
  final void Function(bool) onCheckInternet;

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCheckTile(
          onChanged: (v) => onUse24h(v),
          title: LocaleKeys.enable_24_hours.tr(),
          value: use24h,
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: onFullTime,
          title: "${LocaleKeys.enable_full_time.tr()} 00:00:00",
          value: fullTime,
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: onDimPrev,
          title: LocaleKeys.dim_previous_prayers.tr(),
          value: dimPrev,
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: onChangeCounter,
          title: LocaleKeys.change_counter_color.tr(),
          value: changeCounter,
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: onArabicNumbers,
          title: LocaleKeys.enable_arabic_numbers.tr(),
          value: arabicNumbers,
        ),
        VerticalSpace(height: 10.h),

        CustomCheckTile(
          onChanged: onCheckInternet,
          title: LocaleKeys.check_your_internet_connection_the_star.tr(),
          value: checkInternet,
        ),
        VerticalSpace(height: 8),
        VerticalSpace(height: 12),
        CustomCheckTile(
          onChanged: onEnableShadow,
          title: LocaleKeys.enable_shadow_around_prayers.tr(),
          value: enableShadow,
        ),

        _zekrAppearDurationWidget(
          onSliderTime: onSliderTime,
          sliderTime: sliderTime,
        ),
        VerticalSpace(height: 8),
        const _DividerLine(),

        VerticalSpace(height: 8),

        _EidSection(onChanged: onRefresh),
      ],
    );
  }
}

class _zekrAppearDurationWidget extends StatelessWidget {
  const _zekrAppearDurationWidget({
    super.key,
    required this.onSliderTime,
    required this.sliderTime,
  });

  final void Function(int) onSliderTime;
  final int sliderTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          LocaleKeys.zekr_appear_duration.tr(),
          style: TextStyle(fontSize: 20.sp, color: AppTheme.primaryTextColor),
        ),
        Text(
          "  (${LocaleKeys.second.tr()})",
          style: TextStyle(
            fontSize: 16.sp,
            color: AppTheme.primaryTextColor.withOpacity(0.7),
          ),
        ),
        HorizontalSpace(width: 10),
        IconButton(
          onPressed: () {
            onSliderTime(sliderTime + 1);
          },
          icon: Icon(Icons.add, color: AppTheme.accentColor, size: 26.r),
        ),
        Text(
          sliderTime.toString(),
          style: TextStyle(fontSize: 20.sp, color: AppTheme.secondaryTextColor),
        ),
        IconButton(
          onPressed: () {
            onSliderTime(sliderTime - 1);
          },
          icon: Icon(Icons.remove, color: AppTheme.accentColor, size: 26.r),
        ),
      ],
    );
  }
}

// ===================== LANDSCAPE RIGHT PANEL =====================

class _LandscapeRightPanel extends StatelessWidget {
  const _LandscapeRightPanel({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(children: [_FontsSection(onChanged: onRefresh)]);
  }
}

// ===================== SECTIONS =====================

class _DividerLine extends StatelessWidget {
  const _DividerLine();

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
    final lang = LocalizationHelper.isArAndArNumberEnable()
        ? CacheHelper.getLang()
        : 'en';

    return Column(
      children: [
        Row(
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
        int cols = 4;
        if (c.maxWidth < 520) {
          cols = 2;
        } else if (c.maxWidth < 760) {
          cols = 3;
        }

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

    return Wrap(
      // direction: Axis.horizontal,
      // spacing: 5.w,
      // runSpacing: 12.h,
      children: groups
          .map(
            (e) => SizedBox(
              width: UiRotationCubit().isLandscape() ? .14.sw : .23.sw,

              child: _FontGroupCard(data: e),
            ),
          )
          .toList(),
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
              withoutExpand: true,
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
    this.withoutExpand,
  });

  final Function(bool value) onChanged;
  final String title;
  final bool value;
  final double? fontSize;
  final double? checkBoxSize;
  final bool? withoutExpand;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomCheckbox(
          size: checkBoxSize ?? 20.r,
          activeColor: AppTheme.accentColor,
          value: value,
          onChanged: onChanged,
        ),
        HorizontalSpace(width: 6.w),
        (withoutExpand == true)
            ? Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize ?? 15.sp,
                  color: AppTheme.primaryTextColor,
                ),
              )
            : Expanded(
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
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomCheckbox(
          size: checkBoxSize ?? 20.r,
          activeColor: AppTheme.accentColor,
          value: value,
          onChanged: onChanged,
        ),
        HorizontalSpace(width: 6.w),
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
