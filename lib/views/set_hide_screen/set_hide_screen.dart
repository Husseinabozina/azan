import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/additional_settings/additional_settings_screen.dart';
import 'package:azan/views/adhkar/components/custom_check_box.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:azan/views/home/home_screen_landscape.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';

class SetHideScreen extends StatefulWidget {
  const SetHideScreen({super.key});

  @override
  State<SetHideScreen> createState() => _SetHideScreenState();
}

class _SetHideScreenState extends State<SetHideScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late AppCubit appCubit;

  // ===== cache-backed UI state =====
  late bool enableHideDuringPrayer;
  late bool showTimeOnBlack;
  late bool showDateOnBlack;

  late bool hideAfterSunrise;
  late int hideAfterSunriseMinutes;

  late bool hideAfterIshaa;
  late int hideAfterIshaaMinutes;
  late int azanDuration;
  void _setAzanDuration(int v) {
    setState(() => azanDuration = v);
    CacheHelper.setAzanDuration(v);
  }

  @override
  void initState() {
    super.initState();
    appCubit = AppCubit.get(context);

    enableHideDuringPrayer = CacheHelper.getEnableHidingScreenDuringPrayer();
    showTimeOnBlack = CacheHelper.getShowTimeOnBlackScreen();
    showDateOnBlack = CacheHelper.getShowDateOnBlackScreen();

    hideAfterSunrise = CacheHelper.getHideScreenAfterSunriseEnabled();
    hideAfterSunriseMinutes = CacheHelper.getHideScreenAfterSunriseMinutes();

    hideAfterIshaa = CacheHelper.getHideScreenAfterIshaaEnabled();
    hideAfterIshaaMinutes = CacheHelper.getHideScreenAfterIshaaMinutes();

    azanDuration = CacheHelper.getAzanDuration();

    appCubit.getPrayerDurations();
  }

  @override
  Widget build(BuildContext context) {
    final prayerTitles = <String>[
      LocaleKeys.fajr.tr(),
      LocaleKeys.dhuhr.tr(),
      LocaleKeys.asr.tr(),
      LocaleKeys.maghrib.tr(),
      LocaleKeys.isha.tr(),
    ];

    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(context: context),
      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {
          // لو محتاج تعمل حاجة بعد الحفظ
          if (state is savePrayerDurationSuccess) {
            // no-op
          }
        },
        builder: (context, state) {
          final durations =
              appCubit.prayersDuration ??
              List<int>.filled(prayerTitles.length, 7);

          return SizedBox(
            width: 1.sw,
            child: Stack(
              children: [
                Image.asset(
                  CacheHelper.getSelectedBackground(),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                ),
                SafeArea(
                  child: Column(
                    children: [
                      _TopBar(
                        onMenu: () => scaffoldKey.currentState?.openDrawer(),
                        onClose: () {
                          AppNavigator.pushAndRemoveUntil(
                            context,
                            HomeScreen(),
                          );
                        },
                      ),
                      Expanded(
                        child: (!UiRotationCubit().isLandscape())
                            ? _PortraitBody(
                                azanDuration: azanDuration,
                                onSetAzanDuration: _setAzanDuration,
                                prayerTitles: prayerTitles,
                                durations: durations,
                                enableHideDuringPrayer: enableHideDuringPrayer,
                                showTimeOnBlack: showTimeOnBlack,
                                showDateOnBlack: showDateOnBlack,
                                hideAfterSunrise: hideAfterSunrise,
                                hideAfterSunriseMinutes:
                                    hideAfterSunriseMinutes,
                                hideAfterIshaa: hideAfterIshaa,
                                hideAfterIshaaMinutes: hideAfterIshaaMinutes,
                                onToggleEnableHideDuringPrayer: (v) async {
                                  setState(() => enableHideDuringPrayer = v);
                                  await CacheHelper.setEnableHidingScreenDuringPrayer(
                                    v,
                                  );
                                },
                                onToggleShowTime: (v) async {
                                  setState(() => showTimeOnBlack = v);
                                  await CacheHelper.setShowTimeOnBlackScreen(v);
                                },
                                onToggleShowDate: (v) async {
                                  setState(() => showDateOnBlack = v);
                                  await CacheHelper.setShowDateOnBlackScreen(v);
                                },
                                onToggleSunrise: (v) async {
                                  setState(() => hideAfterSunrise = v);
                                  await CacheHelper.setHideScreenAfterSunriseEnabled(
                                    v,
                                  );
                                },
                                onSunriseMinutesChanged: (m) async {
                                  setState(() => hideAfterSunriseMinutes = m);
                                  await CacheHelper.setHideScreenAfterSunriseMinutes(
                                    m,
                                  );
                                },
                                onToggleIshaa: (v) async {
                                  setState(() => hideAfterIshaa = v);
                                  await CacheHelper.setHideScreenAfterIshaaEnabled(
                                    v,
                                  );
                                },
                                onIshaaMinutesChanged: (m) async {
                                  setState(() => hideAfterIshaaMinutes = m);
                                  await CacheHelper.setHideScreenAfterIshaaMinutes(
                                    m,
                                  );
                                },
                                onPlus: (i) {
                                  final list = List<int>.from(durations);
                                  list[i] = (list[i] + 1).clamp(0, 999);
                                  appCubit.prayersDuration = list;
                                  appCubit.savePrayerDurations(list);

                                  setState(() {});
                                },
                                onMinus: (i) {
                                  final list = List<int>.from(durations);
                                  list[i] = (list[i] - 1).clamp(0, 999);
                                  appCubit.prayersDuration = list;
                                  appCubit.savePrayerDurations(list);
                                  setState(() {});
                                },
                              )
                            // ✅ Landscape: Row -> Left Column settings + Right Column durations (NO SCROLL)
                            : _LandscapeRowBody(
                                azanDuration: azanDuration,
                                onSetAzanDuration: _setAzanDuration,
                                prayerTitles: prayerTitles,
                                durations: durations,
                                enableHideDuringPrayer: enableHideDuringPrayer,
                                showTimeOnBlack: showTimeOnBlack,
                                showDateOnBlack: showDateOnBlack,
                                hideAfterSunrise: hideAfterSunrise,
                                hideAfterSunriseMinutes:
                                    hideAfterSunriseMinutes,
                                hideAfterIshaa: hideAfterIshaa,
                                hideAfterIshaaMinutes: hideAfterIshaaMinutes,
                                onToggleEnableHideDuringPrayer: (v) async {
                                  setState(() => enableHideDuringPrayer = v);
                                  await CacheHelper.setEnableHidingScreenDuringPrayer(
                                    v,
                                  );
                                },
                                onToggleShowTime: (v) async {
                                  setState(() => showTimeOnBlack = v);
                                  await CacheHelper.setShowTimeOnBlackScreen(v);
                                },
                                onToggleShowDate: (v) async {
                                  setState(() => showDateOnBlack = v);
                                  await CacheHelper.setShowDateOnBlackScreen(v);
                                },
                                onToggleSunrise: (v) async {
                                  setState(() => hideAfterSunrise = v);
                                  await CacheHelper.setHideScreenAfterSunriseEnabled(
                                    v,
                                  );
                                },
                                onSunriseMinutesChanged: (m) async {
                                  setState(() => hideAfterSunriseMinutes = m);
                                  await CacheHelper.setHideScreenAfterSunriseMinutes(
                                    m,
                                  );
                                },
                                onToggleIshaa: (v) async {
                                  setState(() => hideAfterIshaa = v);
                                  await CacheHelper.setHideScreenAfterIshaaEnabled(
                                    v,
                                  );
                                },
                                onIshaaMinutesChanged: (m) async {
                                  setState(() => hideAfterIshaaMinutes = m);
                                  await CacheHelper.setHideScreenAfterIshaaMinutes(
                                    m,
                                  );
                                },
                                onPlus: (i) {
                                  final list = List<int>.from(durations);
                                  list[i] = (list[i] + 1).clamp(0, 999);
                                  appCubit.prayersDuration = list;
                                  appCubit.savePrayerDurations(list);
                                  setState(() {});
                                },
                                onMinus: (i) {
                                  final list = List<int>.from(durations);
                                  list[i] = (list[i] - 1).clamp(0, 999);
                                  appCubit.prayersDuration = list;
                                  appCubit.savePrayerDurations(list);
                                  setState(() {});
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ===================== TOP BAR =====================

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMenu, required this.onClose});

  final VoidCallback onMenu;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onMenu,
            icon: Icon(
              Icons.menu,
              color: AppTheme.primaryTextColor,
              size: 26.r,
            ),
          ),
          Text(
            LocaleKeys.set_screen_hide.tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: AppTheme.accentColor, size: 26.r),
          ),
        ],
      ),
    );
  }
}

// ===================== PORTRAIT BODY (SCROLL OK) =====================

class _PortraitBody extends StatelessWidget {
  const _PortraitBody({
    required this.prayerTitles,
    required this.durations,
    required this.enableHideDuringPrayer,
    required this.showTimeOnBlack,
    required this.showDateOnBlack,
    required this.hideAfterSunrise,
    required this.hideAfterSunriseMinutes,
    required this.hideAfterIshaa,
    required this.hideAfterIshaaMinutes,
    required this.onToggleEnableHideDuringPrayer,
    required this.onToggleShowTime,
    required this.onToggleShowDate,
    required this.onToggleSunrise,
    required this.onSunriseMinutesChanged,
    required this.onToggleIshaa,
    required this.onIshaaMinutesChanged,
    required this.onPlus,
    required this.onMinus,
    required this.onSetAzanDuration,
    required this.azanDuration,
  });

  final List<String> prayerTitles;
  final List<int> durations;

  final bool enableHideDuringPrayer;
  final bool showTimeOnBlack;
  final bool showDateOnBlack;

  final bool hideAfterSunrise;
  final int hideAfterSunriseMinutes;

  final bool hideAfterIshaa;
  final int hideAfterIshaaMinutes;
  final int azanDuration;

  final ValueChanged<bool> onToggleEnableHideDuringPrayer;
  final ValueChanged<bool> onToggleShowTime;
  final ValueChanged<bool> onToggleShowDate;

  final ValueChanged<bool> onToggleSunrise;
  final ValueChanged<int> onSunriseMinutesChanged;

  final ValueChanged<bool> onToggleIshaa;
  final ValueChanged<int> onIshaaMinutesChanged;

  final void Function(int index) onPlus;
  final void Function(int index) onMinus;
  final void Function(int index) onSetAzanDuration;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        children: [
          _SectionDivider(),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: SettingTile(
              title: LocaleKeys.enable_hiding_screen_during_prayer.tr(),
              value: enableHideDuringPrayer,
              onChanged: onToggleEnableHideDuringPrayer,
            ),
          ),

          _SectionDivider(),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              children: [
                SettingTile(
                  title: LocaleKeys.show_time_on_black_screen.tr(),
                  value: showTimeOnBlack,
                  onChanged: onToggleShowTime,
                ),
                SizedBox(height: 10.h),
                SettingTile(
                  title: LocaleKeys.show_date_on_black_screen.tr(),
                  value: showDateOnBlack,
                  onChanged: onToggleShowDate,
                ),
              ],
            ),
          ),

          _SectionDivider(),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              children: [
                _TwoLineCheckbox(
                  value: hideAfterSunrise,
                  title: LocaleKeys.hide_screen_after_sunrise_by.tr(),
                  minutes: hideAfterSunriseMinutes,
                  onChanged: onToggleSunrise,
                  onMinutesChanged: onSunriseMinutesChanged,
                ),
                SizedBox(height: 10.h),
                _TwoLineCheckbox(
                  value: hideAfterIshaa,
                  title: LocaleKeys.hide_screen_after_Ishaa_by.tr(),
                  minutes: hideAfterIshaaMinutes,
                  onChanged: onToggleIshaa,
                  onMinutesChanged: onIshaaMinutesChanged,
                ),
              ],
            ),
          ),

          _SectionDivider(),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    LocaleKeys.prayer_duration_for_hiding_screen.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              ...List.generate(prayerTitles.length, (i) {
                return _StepperRow(
                  title: prayerTitles[i],
                  value: durations.length > i ? durations[i] : 10,
                  onMinus: () => onMinus(i),
                  onPlus: () => onPlus(i),
                );
              }),

              _SectionDivider(),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 18.w),
                child: PlusAndMinusWidget(
                  duration: LocaleKeys.min.tr(),
                  onChange: onSetAzanDuration,
                  value: azanDuration,
                  title: LocaleKeys.azan_duration.tr(),
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ],
      ),
    );
  }
}

// ===================== LANDSCAPE BODY (NO SCROLL) =====================
class _LandscapeRowBody extends StatelessWidget {
  const _LandscapeRowBody({
    required this.prayerTitles,
    required this.durations,
    required this.enableHideDuringPrayer,
    required this.showTimeOnBlack,
    required this.showDateOnBlack,
    required this.hideAfterSunrise,
    required this.hideAfterSunriseMinutes,
    required this.hideAfterIshaa,
    required this.hideAfterIshaaMinutes,
    required this.onToggleEnableHideDuringPrayer,
    required this.onToggleShowTime,
    required this.onToggleShowDate,
    required this.onToggleSunrise,
    required this.onSunriseMinutesChanged,
    required this.onToggleIshaa,
    required this.onIshaaMinutesChanged,
    required this.onPlus,
    required this.onMinus,
    required this.onSetAzanDuration,
    required this.azanDuration,
  });

  final List<String> prayerTitles;
  final List<int> durations;

  final bool enableHideDuringPrayer;
  final bool showTimeOnBlack;
  final bool showDateOnBlack;

  final bool hideAfterSunrise;
  final int hideAfterSunriseMinutes;

  final bool hideAfterIshaa;
  final int hideAfterIshaaMinutes;

  final int azanDuration;

  final ValueChanged<bool> onToggleEnableHideDuringPrayer;
  final ValueChanged<bool> onToggleShowTime;
  final ValueChanged<bool> onToggleShowDate;

  final ValueChanged<bool> onToggleSunrise;
  final ValueChanged<int> onSunriseMinutesChanged;

  final ValueChanged<bool> onToggleIshaa;
  final ValueChanged<int> onIshaaMinutesChanged;

  final void Function(int index) onPlus;
  final void Function(int index) onMinus;
  final void Function(int index) onSetAzanDuration;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isRtl = CacheHelper.getLang() == 'ar' ? true : false;

        // group width centered (من غير clamp)
        final contentMaxW = constraints.maxWidth * 0.92;
        final gap = constraints.maxWidth * 0.03; // مسافة نسبية
        final dividerW = 1.w;

        // لو ارتفاع الشاشة صغير (موبايل لاندسكيب) نسمح بسكرول خفيف للـbody كله
        final needsScroll = constraints.maxHeight < 420.h;

        Widget panelHeader(String title, IconData icon) {
          final txt = Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: isRtl ? TextAlign.end : TextAlign.start,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryTextColor,
              ),
            ),
          );

          final ic = Icon(icon, size: 18.r, color: AppTheme.accentColor);

          return Row(
            children: isRtl
                ? [txt, SizedBox(width: 10.w), ic]
                : [ic, SizedBox(width: 10.w), txt],
          );
        }

        Widget glassPanel({required Widget child, required Widget header}) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.22),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.14),
                width: 1.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                SizedBox(height: 10.h),
                Divider(color: Colors.white.withOpacity(0.12), height: 1),
                SizedBox(height: 10.h),
                child,
              ],
            ),
          );
        }

        final leftSettings = glassPanel(
          header: panelHeader(
            LocaleKeys.set_screen_hide.tr(),
            Icons.tune_rounded,
          ),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SettingTileDense(
                title: LocaleKeys.enable_hiding_screen_during_prayer.tr(),
                value: enableHideDuringPrayer,
                onChanged: onToggleEnableHideDuringPrayer,
              ),
              SizedBox(height: 10.h),
              SettingTileDense(
                title: LocaleKeys.show_time_on_black_screen.tr(),
                value: showTimeOnBlack,
                onChanged: onToggleShowTime,
              ),
              SizedBox(height: 10.h),
              SettingTileDense(
                title: LocaleKeys.show_date_on_black_screen.tr(),
                value: showDateOnBlack,
                onChanged: onToggleShowDate,
              ),
              SizedBox(height: 12.h),
              Container(
                // width: 20.sw,
                // color: Colors.red,
                child: _TwoLineCheckboxDense(
                  value: hideAfterSunrise,
                  title: LocaleKeys.hide_screen_after_sunrise_by.tr(),
                  minutes: hideAfterSunriseMinutes,
                  onChanged: onToggleSunrise,
                  onMinutesChanged: onSunriseMinutesChanged,
                ),
              ),
              SizedBox(height: 12.h),
              _TwoLineCheckboxDense(
                value: hideAfterIshaa,
                title: LocaleKeys.hide_screen_after_Ishaa_by.tr(),
                minutes: hideAfterIshaaMinutes,
                onChanged: onToggleIshaa,
                onMinutesChanged: onIshaaMinutesChanged,
              ),
            ],
          ),
        );

        final rightDurations = glassPanel(
          header: panelHeader(
            LocaleKeys.prayer_duration_for_hiding_screen.tr(),
            Icons.timer_outlined,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...List.generate(prayerTitles.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _PrayerDurationRow(
                    title: prayerTitles[i],
                    value: durations.length > i ? durations[i] : 10,
                    onPlus: () => onPlus(i),
                    onMinus: () => onMinus(i),
                  ),
                );
              }),
              SizedBox(height: 6.h),
              PlusAndMinusWidget(
                duration: LocaleKeys.min.tr(),
                onChange: onSetAzanDuration,
                value: azanDuration,
                title: LocaleKeys.azan_duration.tr(),
                mainAxisAlignment: MainAxisAlignment.end,
              ),
            ],
          ),
        );

        final body = Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxW),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: isRtl ? rightDurations : leftSettings),
                    SizedBox(width: gap),
                    Container(
                      width: dividerW,
                      color: Colors.white.withOpacity(0.10),
                    ),
                    SizedBox(width: gap),
                    Expanded(child: isRtl ? leftSettings : rightDurations),
                  ],
                ),
              ),
            ),
          ),
        );

        return needsScroll ? SingleChildScrollView(child: body) : body;
      },
    );
  }
}

// ===================== COMMON WIDGETS =====================

class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Divider(
        height: 18.h,
        thickness: 1,
        color: Colors.white.withOpacity(0.15),
      ),
    );
  }
}

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.onChanged,
    required this.title,
    required this.value,
  });

  final void Function(bool value) onChanged;
  final String title;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomCheckbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.accentColor,
          size: 22.r,
        ),
        HorizontalSpace(width: 10.w),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

class SettingTileDense extends StatelessWidget {
  const SettingTileDense({
    super.key,
    required this.onChanged,
    required this.title,
    required this.value,
  });

  final void Function(bool value) onChanged;
  final String title;
  final bool value;

  @override
  Widget build(BuildContext context) {
    final isRtl = CacheHelper.getLang() == 'ar' ? true : false;

    final checkbox = CustomCheckbox(
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.accentColor,
      size: 20.r,
    );

    final label = Expanded(
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: isRtl ? TextAlign.end : TextAlign.start,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.secondaryTextColor,
        ),
      ),
    );

    return Row(
      children: isRtl
          ? [label, HorizontalSpace(width: 8.w), checkbox]
          : [checkbox, HorizontalSpace(width: 8.w), label],
    );
  }
}

class _TwoLineCheckbox extends StatelessWidget {
  const _TwoLineCheckbox({
    required this.value,
    required this.title,
    required this.minutes,
    required this.onChanged,
    required this.onMinutesChanged,
  });

  final bool value;
  final String title;
  final int minutes;
  final ValueChanged<bool> onChanged;
  final ValueChanged<int> onMinutesChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomCheckbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.accentColor,
          size: 22.r,
        ),
        HorizontalSpace(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _MiniStepButton(
                    icon: Icons.add,
                    onTap: () => onMinutesChanged((minutes + 1).clamp(0, 999)),
                  ),
                  HorizontalSpace(width: 8.w),
                  _MiniStepButton(
                    icon: Icons.remove,
                    onTap: () => onMinutesChanged((minutes - 1).clamp(0, 999)),
                  ),
                  HorizontalSpace(width: 12.w),
                  Text(
                    minutes.toString(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TwoLineCheckboxDense extends StatelessWidget {
  const _TwoLineCheckboxDense({
    required this.value,
    required this.title,
    required this.minutes,
    required this.onChanged,
    required this.onMinutesChanged,
  });

  final bool value;
  final String title;
  final int minutes;
  final ValueChanged<bool> onChanged;
  final ValueChanged<int> onMinutesChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomCheckbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.accentColor,
          size: 20.r,
        ),
        HorizontalSpace(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryTextColor,
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _MiniStepButtonDense(
                  icon: Icons.add,
                  onTap: () => onMinutesChanged((minutes + 1).clamp(0, 999)),
                ),
                HorizontalSpace(width: 8.w),
                _MiniStepButtonDense(
                  icon: Icons.remove,
                  onTap: () => onMinutesChanged((minutes - 1).clamp(0, 999)),
                ),
                HorizontalSpace(width: 10.w),
                SizedBox(
                  width: 34.w,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        minutes.toString(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStepButton extends StatelessWidget {
  const _MiniStepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32.w,
      height: 26.h,
      child: Material(
        color: AppTheme.accentColor,
        borderRadius: BorderRadius.circular(4.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(4.r),
          onTap: onTap,
          child: Icon(icon, size: 16.r, color: AppTheme.secondaryTextColor),
        ),
      ),
    );
  }
}

class _MiniStepButtonDense extends StatelessWidget {
  const _MiniStepButtonDense({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28.w,
      height: 24.h,
      child: Material(
        color: AppTheme.accentColor,
        borderRadius: BorderRadius.circular(4.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(4.r),
          onTap: onTap,
          child: Icon(icon, size: 16.r, color: AppTheme.secondaryTextColor),
        ),
      ),
    );
  }
}

// Portrait duration row
class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.title,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String title;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTextColor,
                ),
              ),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _SquareButton(icon: Icons.add, onTap: onPlus),

                    HorizontalSpace(width: 8.w),
                    SizedBox(
                      width: 34.w,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            value.toString(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HorizontalSpace(width: 8.w),
                    _SquareButton(icon: Icons.remove, onTap: onMinus),
                  ],
                ),
              ),

              // HorizontalSpace(width: 10.w),
            ],
          ),
          SizedBox(height: 8.h),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withOpacity(0.15),
          ),
        ],
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36.w,
      height: 32.h,
      child: Material(
        color: AppTheme.accentColor,
        borderRadius: BorderRadius.circular(4.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(4.r),
          onTap: onTap,
          child: Icon(icon, size: 18.r, color: AppTheme.primaryTextColor),
        ),
      ),
    );
  }
}

// Landscape durations row (very safe, no overflow)
class _PrayerDurationRow extends StatelessWidget {
  const _PrayerDurationRow({
    required this.title,
    required this.value,
    required this.onPlus,
    required this.onMinus,
  });

  final String title;
  final int value;
  final VoidCallback onPlus;
  final VoidCallback onMinus;

  @override
  Widget build(BuildContext context) {
    return Row(
      // textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        _SmallBtn(icon: Icons.add, onTap: onPlus),
        SizedBox(width: 8.w),
        SizedBox(
          width: 44.w,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTextColor,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        _SmallBtn(icon: Icons.remove, onTap: onMinus),
      ],
    );
  }
}

class _SmallBtn extends StatelessWidget {
  const _SmallBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30.w,
      height: 26.h,
      child: Material(
        color: AppTheme.accentColor,
        borderRadius: BorderRadius.circular(6.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(6.r),
          onTap: onTap,
          child: Icon(icon, size: 16.r, color: AppTheme.primaryTextColor),
        ),
      ),
    );
  }
}
