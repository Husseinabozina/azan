import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
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
import 'package:azan/views/home/components/cusotm_drawer.dart';
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
  late bool morningAzkarEnabled;
  late bool eveningAzkarEnabled;
  late int morningWindowMinutes;
  late int eveningWindowMinutes;
  late bool afterPrayerAzkarEnabled;
  late int afterPrayerWindowMinutes;
  late bool showSecondsInNextPrayer;

  void _setShowSecondsInNextPrayer(bool v) {
    setState(() => showSecondsInNextPrayer = v);
    CacheHelper.setShowSecondsInNextPrayer(v);
  }

  void _setMorningAzkarEnabled(bool v) {
    setState(() => morningAzkarEnabled = v);
    CacheHelper.setMorningAzkarEnabled(v);
  }

  void _setEveningAzkarEnabled(bool v) {
    setState(() => eveningAzkarEnabled = v);
    CacheHelper.setEveningAzkarEnabled(v);
  }

  void _setMorningWindowMinutes(int v) {
    final clamped = v.clamp(1, 600); // 1..600 دقيقة
    setState(() => morningWindowMinutes = clamped);
    CacheHelper.setMorningAzkarWindowMinutes(clamped);
  }

  void _setEveningWindowMinutes(int v) {
    final clamped = v.clamp(1, 600);
    setState(() => eveningWindowMinutes = clamped);
    CacheHelper.setEveningAzkarWindowMinutes(clamped);
  }

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
    morningAzkarEnabled = CacheHelper.getMorningAzkarEnabled();
    eveningAzkarEnabled = CacheHelper.getEveningAzkarEnabled();
    morningWindowMinutes = CacheHelper.getMorningAzkarWindowMinutes();
    eveningWindowMinutes = CacheHelper.getEveningAzkarWindowMinutes();
    afterPrayerAzkarEnabled = CacheHelper.getAfterPrayerAzkarEnabled();
    afterPrayerWindowMinutes = CacheHelper.getAfterPrayerAzkarWindowMinutes();
    showSecondsInNextPrayer = CacheHelper.getShowSecondsInNextPrayer();
  }

  void _setAfterPrayerAzkarEnabled(bool v) {
    setState(() => afterPrayerAzkarEnabled = v);
    CacheHelper.setAfterPrayerAzkarEnabled(v);
  }

  void _setAfterPrayerWindowMinutes(int v) {
    final clamped = v;
    setState(() => afterPrayerWindowMinutes = clamped);
    CacheHelper.setAfterPrayerAzkarWindowMinutes(clamped);
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
                SafeArea(
                  child: SingleChildScrollView(
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
                              showSecondsInNextPrayer: showSecondsInNextPrayer,
                              onShowSecondsInNextPrayer:
                                  _setShowSecondsInNextPrayer,
                              afterPrayerAzkarEnabled: afterPrayerAzkarEnabled,
                              afterPrayerWindowMinutes:
                                  afterPrayerWindowMinutes,
                              onAfterPrayerAzkarEnabled:
                                  _setAfterPrayerAzkarEnabled,
                              onAfterPrayerWindowMinutes:
                                  _setAfterPrayerWindowMinutes,
                              morningAzkarEnabled: morningAzkarEnabled,
                              eveningAzkarEnabled: eveningAzkarEnabled,
                              morningWindowMinutes: morningWindowMinutes,
                              eveningWindowMinutes: eveningWindowMinutes,
                              onMorningAzkarEnabled: _setMorningAzkarEnabled,
                              onEveningAzkarEnabled: _setEveningAzkarEnabled,
                              onMorningWindowMinutes: _setMorningWindowMinutes,
                              onEveningWindowMinutes: _setEveningWindowMinutes,
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
                  ),
                )
              :
                // ✅ Landscape: عمودين - كل عمود سكرول لوحده
                SafeArea(
                  child: SingleChildScrollView(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 52,
                                  child: _PanelScroll(
                                    child: _LandscapeLeftPanel(
                                      showSecondsInNextPrayer:
                                          showSecondsInNextPrayer,
                                      onShowSecondsInNextPrayer:
                                          _setShowSecondsInNextPrayer,
                                      afterPrayerAzkarEnabled:
                                          afterPrayerAzkarEnabled,
                                      afterPrayerWindowMinutes:
                                          afterPrayerWindowMinutes,
                                      onAfterPrayerAzkarEnabled:
                                          _setAfterPrayerAzkarEnabled,
                                      onAfterPrayerWindowMinutes:
                                          _setAfterPrayerWindowMinutes,
                                      morningAzkarEnabled: morningAzkarEnabled,
                                      eveningAzkarEnabled: eveningAzkarEnabled,
                                      morningWindowMinutes:
                                          morningWindowMinutes,
                                      eveningWindowMinutes:
                                          eveningWindowMinutes,
                                      onMorningAzkarEnabled:
                                          _setMorningAzkarEnabled,
                                      onEveningAzkarEnabled:
                                          _setEveningAzkarEnabled,
                                      onMorningWindowMinutes:
                                          _setMorningWindowMinutes,
                                      onEveningWindowMinutes:
                                          _setEveningWindowMinutes,
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
    required this.morningAzkarEnabled,
    required this.eveningAzkarEnabled,
    required this.morningWindowMinutes,
    required this.eveningWindowMinutes,
    required this.onMorningAzkarEnabled,
    required this.onEveningAzkarEnabled,
    required this.onMorningWindowMinutes,
    required this.onEveningWindowMinutes,
    required this.afterPrayerAzkarEnabled,
    required this.afterPrayerWindowMinutes,
    required this.onAfterPrayerAzkarEnabled,
    required this.onAfterPrayerWindowMinutes,
    required this.showSecondsInNextPrayer,
    required this.onShowSecondsInNextPrayer,
  });
  final bool morningAzkarEnabled;
  final bool eveningAzkarEnabled;
  final int morningWindowMinutes;
  final int eveningWindowMinutes;

  final void Function(bool) onMorningAzkarEnabled;
  final void Function(bool) onEveningAzkarEnabled;
  final void Function(int) onMorningWindowMinutes;
  final void Function(int) onEveningWindowMinutes;
  final bool afterPrayerAzkarEnabled;
  final int afterPrayerWindowMinutes;

  final void Function(bool) onAfterPrayerAzkarEnabled;
  final void Function(int) onAfterPrayerWindowMinutes;
  final void Function(bool) onShowSecondsInNextPrayer;

  final bool showSecondsInNextPrayer;

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
        VerticalSpace(height: 10),

        CustomCheckTile(
          onChanged: onFullTime,
          title: "${LocaleKeys.enable_full_time.tr()} 00:00:00",
          value: fullTime,
        ),
        VerticalSpace(height: 10),

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
        VerticalSpace(height: 10),

        CustomCheckTile(
          onChanged: onArabicNumbers,
          title: LocaleKeys.enable_arabic_numbers.tr(),
          value: arabicNumbers,
        ),
        VerticalSpace(height: 10),

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
        CustomCheckTile(
          onChanged: onShowSecondsInNextPrayer,
          title: LocaleKeys.show_seconds_in_next_prayer.tr(),
          value: showSecondsInNextPrayer,
        ),
        VerticalSpace(height: 12),

        PlusAndMinusWidget(
          duration: LocaleKeys.second.tr(),
          title: LocaleKeys.zekr_appear_duration.tr(),
          onChange: onSliderTime,
          value: sliderTime,
          layout: PlusMinusLayout.wrap,
        ),
        VerticalSpace(height: 12),

        const _DividerLine(),
        VerticalSpace(height: 12),

        // ===== Azkar Timing Settings =====
        Text(
          LocaleKeys.azkar_timing_settings.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
        VerticalSpace(height: 10),

        CustomCheckTile(
          onChanged: onMorningAzkarEnabled,
          title: LocaleKeys.enable_morning_azkar.tr(),
          value: morningAzkarEnabled,
        ),

        VerticalSpace(height: 10),

        PlusAndMinusWidget(
          duration: LocaleKeys.minute.tr(),
          title: LocaleKeys.morning_azkar_window_minutes.tr(),
          onChange: onMorningWindowMinutes,
          value: morningWindowMinutes,
          step: 1,
          min: 1,
          max: 600,
          layout: PlusMinusLayout.wrap,
        ),
        VerticalSpace(height: 12.h),

        CustomCheckTile(
          onChanged: onEveningAzkarEnabled,
          title: LocaleKeys.enable_evening_azkar.tr(),
          value: eveningAzkarEnabled,
        ),
        VerticalSpace(height: 10),

        PlusAndMinusWidget(
          duration: LocaleKeys.minute.tr(),
          title: LocaleKeys.evening_azkar_window_minutes.tr(),
          onChange: onEveningWindowMinutes,
          value: eveningWindowMinutes,
          step: 1,
          min: 1,
          max: 600,
          layout: PlusMinusLayout.wrap,
        ),

        VerticalSpace(height: 10),

        CustomCheckTile(
          onChanged: onAfterPrayerAzkarEnabled,
          title: LocaleKeys.enable_after_prayer_azkar.tr(),
          value: afterPrayerAzkarEnabled,
        ),
        VerticalSpace(height: 10),

        PlusAndMinusWidget(
          duration: LocaleKeys.minute.tr(),
          title: LocaleKeys.after_prayer_azkar_window_minutes.tr(),
          onChange: onAfterPrayerWindowMinutes,
          value: afterPrayerWindowMinutes,
          step: 1,
          min: 1,
          max: 600,
          layout: PlusMinusLayout.wrap,
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
    required this.morningAzkarEnabled,
    required this.eveningAzkarEnabled,
    required this.morningWindowMinutes,
    required this.eveningWindowMinutes,
    required this.onMorningAzkarEnabled,
    required this.onEveningAzkarEnabled,
    required this.onMorningWindowMinutes,
    required this.onEveningWindowMinutes,

    required this.afterPrayerAzkarEnabled,
    required this.afterPrayerWindowMinutes,
    required this.onAfterPrayerAzkarEnabled,
    required this.onAfterPrayerWindowMinutes,
    required this.showSecondsInNextPrayer,

    required this.onShowSecondsInNextPrayer,
  });

  final bool use24h;
  final bool fullTime;
  final bool dimPrev;
  final bool changeCounter;
  final bool arabicNumbers;
  final bool checkInternet;
  final int sliderTime;
  final bool enableShadow;
  final bool showSecondsInNextPrayer;

  final void Function(bool) onShowSecondsInNextPrayer;
  final void Function(int) onSliderTime;
  final void Function(bool) onEnableShadow;

  final Future<void> Function(bool) onUse24h;
  final void Function(bool) onFullTime;
  final void Function(bool) onDimPrev;
  final void Function(bool) onChangeCounter;
  final void Function(bool) onArabicNumbers;
  final void Function(bool) onCheckInternet;
  final bool morningAzkarEnabled;
  final bool eveningAzkarEnabled;
  final int morningWindowMinutes;
  final int eveningWindowMinutes;

  final void Function(bool) onMorningAzkarEnabled;
  final void Function(bool) onEveningAzkarEnabled;
  final void Function(int) onMorningWindowMinutes;
  final void Function(int) onEveningWindowMinutes;

  final bool afterPrayerAzkarEnabled;
  final int afterPrayerWindowMinutes;
  final void Function(bool) onAfterPrayerAzkarEnabled;
  final void Function(int) onAfterPrayerWindowMinutes;

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
        VerticalSpace(height: 10),

        CustomCheckTile(
          onChanged: onFullTime,
          title: "${LocaleKeys.enable_full_time.tr()} 00:00:00",
          value: fullTime,
        ),
        VerticalSpace(height: 10),

        CustomCheckTile(
          onChanged: onDimPrev,
          title: LocaleKeys.dim_previous_prayers.tr(),
          value: dimPrev,
        ),
        VerticalSpace(height: 10),

        CustomCheckTile(
          onChanged: onChangeCounter,
          title: LocaleKeys.change_counter_color.tr(),
          value: changeCounter,
        ),
        VerticalSpace(height: 10),

        CustomCheckTile(
          onChanged: onArabicNumbers,
          title: LocaleKeys.enable_arabic_numbers.tr(),
          value: arabicNumbers,
        ),
        VerticalSpace(height: 10),

        CustomCheckTile(
          onChanged: onCheckInternet,
          title: LocaleKeys.check_your_internet_connection_the_star.tr(),
          value: checkInternet,
        ),
        VerticalSpace(height: 10),
        CustomCheckTile(
          onChanged: onEnableShadow,
          title: LocaleKeys.enable_shadow_around_prayers.tr(),
          value: enableShadow,
        ),
        VerticalSpace(height: 10),

        CustomCheckTile(
          onChanged: onShowSecondsInNextPrayer,
          title: LocaleKeys.show_seconds_in_next_prayer.tr(),
          value: showSecondsInNextPrayer,
        ),

        PlusAndMinusWidget(
          duration: LocaleKeys.second.tr(),
          title: LocaleKeys.zekr_appear_duration.tr(),
          onChange: onSliderTime,
          value: sliderTime,
        ),
        VerticalSpace(height: 8),
        const _DividerLine(),
        VerticalSpace(height: 10),

        Text(
          LocaleKeys.azkar_timing_settings.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
        VerticalSpace(height: 10),

        CustomCheckTile(
          onChanged: onMorningAzkarEnabled,
          title: LocaleKeys.enable_morning_azkar.tr(),
          value: morningAzkarEnabled,
        ),

        VerticalSpace(height: 10),

        PlusAndMinusWidget(
          duration: LocaleKeys.minute.tr(),
          title: LocaleKeys.morning_azkar_window_minutes.tr(),
          onChange: onMorningWindowMinutes,
          value: morningWindowMinutes,
          step: 1,
          min: 1,
          max: 600,
        ),
        VerticalSpace(height: 12.h),

        CustomCheckTile(
          onChanged: onEveningAzkarEnabled,
          title: LocaleKeys.enable_evening_azkar.tr(),
          value: eveningAzkarEnabled,
        ),
        VerticalSpace(height: 10),

        PlusAndMinusWidget(
          duration: LocaleKeys.minute.tr(),
          title: LocaleKeys.evening_azkar_window_minutes.tr(),
          onChange: onEveningWindowMinutes,
          value: eveningWindowMinutes,
          step: 1,
          min: 1,
          max: 600,
        ),

        VerticalSpace(height: 12.h),

        CustomCheckTile(
          onChanged: onAfterPrayerAzkarEnabled,
          title: LocaleKeys.enable_after_prayer_azkar.tr(),
          value: afterPrayerAzkarEnabled,
        ),
        VerticalSpace(height: 10),

        PlusAndMinusWidget(
          duration: LocaleKeys.minute.tr(),
          title: LocaleKeys.after_prayer_azkar_window_minutes.tr(),
          onChange: onAfterPrayerWindowMinutes,
          value: afterPrayerWindowMinutes,
          step: 1,
          min: 1,
          max: 600,
        ),

        VerticalSpace(height: 12),

        VerticalSpace(height: 8),
        const _DividerLine(),
        VerticalSpace(height: 10),

        _EidSection(onChanged: onRefresh),
      ],
    );
  }
}

class PlusAndMinusWidget extends StatelessWidget {
  const PlusAndMinusWidget({
    super.key,
    required this.onChange,
    required this.value,
    required this.title,
    required this.duration,
    this.mainAxisAlignment,
    this.step = 1,
    this.min,
    this.max,

    // ✅ NEW (اختياري)
    this.layout = PlusMinusLayout.row, // الافتراضي زي القديم
    this.compact = false, // اختياري لتصغير شوية
    this.titleMaxLines = 2,
  });

  final void Function(int) onChange;
  final int value;
  final String title;
  final String duration;
  final MainAxisAlignment? mainAxisAlignment;

  final int step;
  final int? min;
  final int? max;

  // ✅ NEW
  final PlusMinusLayout layout;
  final bool compact;
  final int titleMaxLines;

  int _clamp(int v) {
    if (min != null && v < min!) return min!;
    if (max != null && v > max!) return max!;
    return v;
  }

  Widget _buildTitle() {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: title,
            style: TextStyle(
              fontSize: compact ? 18.sp : 20.sp,
              color: AppTheme.primaryTextColor,
            ),
          ),
          TextSpan(
            text: "  ($duration)",
            style: TextStyle(
              fontSize: compact ? 14.sp : 16.sp,
              color: AppTheme.primaryTextColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
      maxLines: titleMaxLines,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    );
  }

  Widget _buildControls() {
    final iconSize = compact ? 22.r : 26.r;
    final valueSize = compact ? 18.sp : 20.sp;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => onChange(_clamp(value + step)),
          icon: Icon(Icons.add, color: AppTheme.accentColor, size: iconSize),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: valueSize,
            color: AppTheme.secondaryTextColor,
          ),
        ),
        IconButton(
          onPressed: () => onChange(_clamp(value - step)),
          icon: Icon(Icons.remove, color: AppTheme.accentColor, size: iconSize),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 1) نفس القديم تمامًا
    if (layout == PlusMinusLayout.row) {
      return Row(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: compact ? 18.sp : 20.sp,
              color: AppTheme.primaryTextColor,
            ),
          ),
          Text(
            "  ($duration)",
            style: TextStyle(
              fontSize: compact ? 14.sp : 16.sp,
              color: AppTheme.primaryTextColor.withOpacity(0.7),
            ),
          ),
          HorizontalSpace(width: 10),
          _buildControls(),
        ],
      );
    }

    // ✅ 2) Wrap: يمنع overflow ويكسر لسطر تاني تلقائيًا
    if (layout == PlusMinusLayout.wrap) {
      return LayoutBuilder(
        builder: (context, c) {
          return Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10.w,
            runSpacing: 6.h,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: c.maxWidth),
                child: _buildTitle(),
              ),
              _buildControls(),
            ],
          );
        },
      );
    }

    // ✅ 3) Stacked: عنوان فوق + أزرار تحت (أضمن حاجة ضد overflow)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),
        VerticalSpace(height: 6.h),
        _buildControls(),
      ],
    );
  }
}

enum PlusMinusLayout { row, wrap, stacked }

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
        VerticalSpace(height: 10),
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
        int cols = UiRotationCubit().isLandscape() ? 2 : 4;

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
            VerticalSpace(height: 10),
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

  String _pick(String cached, List<String> items) {
    // ✅ حماية من القيم القديمة في الكاش (Tajwal/FreeSpans...)
    if (items.contains(cached)) return cached;
    return items.first;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final spacing = 3.w;
        final runSpacing = 3.w;

        final itemWidth = (c.maxWidth - (runSpacing * (columns - 1))) / columns;

        final groups = <_FontGroupData>[
          _FontGroupData(
            header: LocaleKeys.texts.tr(),
            headerStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryTextColor,
            ),
            items: textsFonts,
            selected: _pick(CacheHelper.getTextsFontFamily(), textsFonts),
            onSelect: (v) {
              CacheHelper.setTextsFontFamily(v);
              onChanged();
            },
          ),
          _FontGroupData(
            header: LocaleKeys.prayers.tr(),
            headerStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryTextColor,
            ),
            items: timesFonts,
            selected: _pick(CacheHelper.getTimesFontFamily(), timesFonts),
            onSelect: (v) {
              CacheHelper.setTimesFontFamily(v);
              onChanged();
            },
          ),
          _FontGroupData(
            header: LocaleKeys.time.tr(),
            headerStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryTextColor,
            ),
            items: timeFonts,
            selected: _pick(CacheHelper.getTimeFontFamily(), timeFonts),
            onSelect: (v) {
              CacheHelper.setTimeFontFamily(v);
              onChanged();
            },
          ),
          _FontGroupData(
            header: LocaleKeys.the_adhkar.tr(),
            headerStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryTextColor,
            ),
            items: azkarFonts,
            selected: _pick(CacheHelper.getAzkarFontFamily(), azkarFonts),
            onSelect: (v) {
              CacheHelper.setAzkarFontFamily(v);
              onChanged();
            },
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,

          children: groups
              .map(
                (e) => SizedBox(
                  width: itemWidth,

                  child: _FontGroupCard(data: e),
                ),
              )
              .toList(),
        );
      },
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
        VerticalSpace(height: 8),
        ...data.items.map((name) {
          return Container(
            child: Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: _FontRadioRow(
                title: name,
                groupValue: data.selected,
                onSelect: data.onSelect,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _FontRadioRow extends StatelessWidget {
  const _FontRadioRow({
    required this.title,
    required this.groupValue,
    required this.onSelect,
  });

  final String title;
  final String groupValue;
  final ValueChanged<String> onSelect;

  double _fontFromWidth(double w) {
    // w = عرض المساحة المتاحة للنص فقط
    // عامل التحويل: كل ما المساحة تكبر يكبر الخط
    final s = isLargeScreen(kind)
        ? w * 0.13
        : w * 0.14; // جرّب 0.16..0.22 حسب ذوقك
    return s; // حدود ثابتة
  }

  @override
  Widget build(BuildContext context) {
    return UiRotationCubit().isLandscape()
        ? InkWell(
            onTap: () => onSelect(title),
            child: Row(
              children: [
                RadioDot(
                  selected: title == groupValue,
                  size: 20.r,

                  strokeWidth: 2.w,
                  dotScale: 0.55,

                  selectedColor: AppTheme.accentColor,
                  unselectedColor: AppTheme.primaryTextColor.withOpacity(0.35),
                ),
                HorizontalSpace(width: 6),

                // ✅ لا Expanded هنا
                Text(
                  title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: title,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              ],
            ),
          )
        : LayoutBuilder(
            builder: (context, c) {
              final rowW = c.maxWidth;

              final radioSize = 20.r; // حجم الراديو
              final gap = 4.w; // مسافة بين الراديو والنص
              final textW = (rowW - radioSize - gap);

              final fontSize = _fontFromWidth(textW);

              return InkWell(
                onTap: () => onSelect(title),
                child: Row(
                  children: [
                    RadioDot(
                      selected: title == groupValue,
                      size: 16.r,

                      strokeWidth: 2.w,
                      dotScale: 0.55,

                      selectedColor: AppTheme.accentColor,
                      unselectedColor: AppTheme.primaryTextColor.withOpacity(
                        0.35,
                      ),
                    ),
                    SizedBox(width: gap),

                    // ✅ لا Expanded هنا
                    SizedBox(
                      width: textW,
                      child: Text(
                        title,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: title,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
