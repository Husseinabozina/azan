import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/components/appbutton.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/azan_adjust_model.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/appbutton.dart';
import 'package:azan/core/components/flash_dialoge.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/helpers/azan_adjust_model.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ✅ عدّل المسار لو مختلف

class AzanAdjustScreen extends StatefulWidget {
  const AzanAdjustScreen({super.key});

  @override
  State<AzanAdjustScreen> createState() => _AzanAdjustScreenState();
}

class _AzanAdjustScreenState extends State<AzanAdjustScreen> {
  late AppCubit appCubit;

  // ===== Iqama local state (نفس منطق SetIqamaScreen) =====
  late List<int> iqamaMinutes;
  late int friDaySermonMinutes;

  @override
  void initState() {
    super.initState();
    appCubit = AppCubit.get(context);

    // default
    friDaySermonMinutes = CacheHelper.getFridayTime();
    iqamaMinutes = List<int>.filled(6, 10);

    _loadIqamaOnce();
  }

  Future<void> _loadIqamaOnce() async {
    await appCubit.getIqamaTime();
    if (!mounted) return;

    setState(() {
      if (appCubit.iqamaMinutes != null && appCubit.iqamaMinutes!.isNotEmpty) {
        iqamaMinutes = List<int>.from(appCubit.iqamaMinutes!);
      }
      // لو جمعة: cubit بيحط الجمعة في index=2 (الظهر) بالفعل
      friDaySermonMinutes = CacheHelper.getFridayTime();
    });
  }

  // ========= Iqama dialogs (نفس دوالي القديمة) =========
  Future<void> _editIqamaMinutes(int index) async {
    final current = iqamaMinutes[index];

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        int localValue = current;

        return AlertDialog(
          backgroundColor: AppTheme.dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            '${LocaleKeys.set_iqama_time.tr()} ${appCubit.prayers(context)[index].title}',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.select_minutes_after_adhan.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (localValue > 0) {
                            setStateDialog(() => localValue -= 1);
                          }
                        },
                        icon: Icon(Icons.remove, color: AppTheme.accentColor),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppTheme.primaryTextColor,
                            width: 1.5,
                          ),
                          color: Colors.white,
                        ),
                        child: Text(
                          '${LocalizationHelper.isArAndArNumberEnable() ? DateHelper.toArabicDigits('$localValue') : localValue} ${LocaleKeys.min.tr()}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setStateDialog(() => localValue += 1),
                        icon: Icon(Icons.add, color: AppTheme.accentColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [0, 5, 10, 15, 20, 25, 30]
                        .map(
                          (v) => ChoiceChip(
                            color: WidgetStatePropertyAll(
                              AppTheme.primaryButtonBackground,
                            ),
                            label: Text(
                              '${LocalizationHelper.isArAndArNumberEnable() ? DateHelper.toArabicDigits('$v') : v} ${LocaleKeys.min.tr()}',
                              style: TextStyle(
                                color: AppTheme.primaryButtonTextColor,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: localValue == v,
                            onSelected: (_) =>
                                setStateDialog(() => localValue = v),
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                LocaleKeys.common_cancel.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: AppTheme.cancelButtonBackgroundColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(localValue),
              child: Text(
                LocaleKeys.common_ok.tr(),
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null && mounted) {
      setState(() => iqamaMinutes[index] = result);
    }
  }

  Future<void> _editFridaySermonMinutes() async {
    final current = friDaySermonMinutes;

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        int localValue = current;

        return AlertDialog(
          backgroundColor: AppTheme.dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            LocaleKeys.friday_sermon_time.tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.select_minutes_after_adhan.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (localValue > 0) {
                            setStateDialog(() => localValue -= 1);
                          }
                        },
                        icon: Icon(Icons.remove, color: AppTheme.accentColor),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppTheme.primaryTextColor,
                            width: 1.5,
                          ),
                          color: Colors.white,
                        ),
                        child: Text(
                          '${LocalizationHelper.isArAndArNumberEnable() ? DateHelper.toArabicDigits('$localValue') : localValue} ${LocaleKeys.min.tr()}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setStateDialog(() => localValue += 1),
                        icon: Icon(Icons.add, color: AppTheme.accentColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [0, 5, 10, 15, 20, 25, 30]
                        .map(
                          (v) => ChoiceChip(
                            color: WidgetStatePropertyAll(
                              AppTheme.primaryButtonBackground,
                            ),
                            label: Text(
                              '${LocalizationHelper.isArAndArNumberEnable() ? DateHelper.toArabicDigits('$v') : v} ${LocaleKeys.min.tr()}',
                              style: TextStyle(
                                color: AppTheme.primaryButtonTextColor,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: localValue == v,
                            onSelected: (_) =>
                                setStateDialog(() => localValue = v),
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                LocaleKeys.common_cancel.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: AppTheme.cancelButtonBackgroundColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(localValue),
              child: Text(
                LocaleKeys.common_ok.tr(),
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null && mounted) {
      setState(() => friDaySermonMinutes = result);
    }
  }

  Future<void> _saveIqama() async {
    // ✅ اربطها بنفس cubit logic
    appCubit.iqamaMinutes = List<int>.from(iqamaMinutes);

    // الجمعة محفوظة في cache
    CacheHelper.setFridayTime(friDaySermonMinutes);

    await appCubit.saveIqamaTimes();
  }

  // ========= UI helpers =========
  Widget _topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            AppNavigator.pushAndRemoveUntil(context, HomeScreen());
          },
          icon: Icon(Icons.close, color: AppTheme.accentColor, size: 35.r),
        ),
        Flexible(
          child: FittedBox(
            child: Text(
              LocaleKeys.azan_adjust_subtitle.tr(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.menu, color: AppTheme.primaryTextColor, size: 35.r),
        ),
      ],
    );
  }

  Widget _sectionCard({required Widget child}) {
    // ✅ بدل الـGlass الكبير: كل Section لوحده خفيف
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      // textAlign: TextAlign.right,
      style: TextStyle(
        color: AppTheme.primaryTextColor,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _hintText(String text) {
    return Text(
      text,
      // textAlign: TextAlign.right,
      style: TextStyle(
        color: AppTheme.primaryTextColor.withOpacity(0.80),
        fontSize: 12.sp,
      ),
    );
  }

  static const int _minIqama = 0;
  static const int _maxIqama = 180;

  void _stepIqama(int index, int delta) {
    setState(() {
      final next = (iqamaMinutes[index] + delta).clamp(_minIqama, _maxIqama);
      iqamaMinutes[index] = next;
    });
  }

  void _stepFriday(int delta) {
    setState(() {
      final next = (friDaySermonMinutes + delta).clamp(_minIqama, _maxIqama);
      friDaySermonMinutes = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {
          // ✅ رسائل حفظ الإقامة (نفس منطق SetIqamaScreen)
          if (state is saveIqamaTimesSuccess) {
            showFlashMessage(
              message: LocaleKeys.saved_successfully.tr(),
              type: FlashMessageType.success,
              context: context,
            );
          } else if (state is saveIqamaTimesFailure) {
            showFlashMessage(
              message: LocaleKeys.something_went_wrong_please_try_again.tr(),
              type: FlashMessageType.error,
              context: context,
            );
          }
        },
        builder: (context, state) {
          final size = MediaQuery.of(context).size;
          final isLandscape = UiRotationCubit().isLandscape();

          // ✅ designSize

          final cubit = AppCubit.get(context);
          final s = cubit.azanAdjust.normalized();

          void update(AzanAdjustSettings next) {
            cubit.updateAzanAdjustSettings(next.normalized());
          }

          void updateManualShift(int v) {
            update(s.copyWith(manualAllShiftMinutes: v));
          }

          void updatePerPrayer(int index, int minutes) {
            final list = List<int>.from(s.perPrayerMinutes);
            if (index < 0 || index >= list.length) return;
            list[index] = minutes.clamp(-180, 180);
            update(s.copyWith(perPrayerMinutes: list));
          }

          // ✅ checkbox responsive (عشان الكبيرة متبقاش صغيرة)
          final checkboxScale = isLandscape ? 1.25 : 1.0;

          // ✅ prayers for iqama view (to show adhan times)
          final prayersData = cubit.prayers(context);

          // =========================
          // UI
          // =========================
          return Stack(
            children: [
              Image.asset(
                CacheHelper.getSelectedBackground(),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fill,
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 20.r,
                    left: 15.w,
                    right: 15.w,
                    bottom: 14.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _topBar(context),
                      VerticalSpace(height: 12),

                      Expanded(
                        child: SingleChildScrollView(
                          child: isLandscape
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // LEFT: Prayer Adjustments
                                    Expanded(
                                      child: Column(
                                        children: [
                                          _sectionCard(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                _sectionTitle(
                                                  LocaleKeys.azan_adjust_title
                                                      .tr(),
                                                ),
                                                VerticalSpace(height: 6),
                                                _hintText(
                                                  LocaleKeys
                                                      .azan_adjust_subtitle
                                                      .tr(),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Ramadan / Summer toggles
                                          _sectionCard(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _sectionTitle(
                                                  LocaleKeys
                                                      .azan_adjust_section_prayer_times
                                                      .tr(),
                                                ),
                                                VerticalSpace(height: 10),

                                                _CheckRow(
                                                  scale: checkboxScale,
                                                  text: LocaleKeys
                                                      .azan_adjust_ramadan_isha_plus_30
                                                      .tr(),
                                                  value: s.ramadanIshaPlus30,
                                                  onChanged: (v) => update(
                                                    s.copyWith(
                                                      ramadanIshaPlus30: v,
                                                    ),
                                                  ),
                                                ),
                                                _CheckRow(
                                                  scale: checkboxScale,
                                                  text: LocaleKeys
                                                      .azan_adjust_summer_plus_hour
                                                      .tr(),
                                                  value: s.summerPlusHour,
                                                  onChanged: (v) => update(
                                                    s.copyWith(
                                                      summerPlusHour: v,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Global shift buttons with meaning (بدل -60/+60)
                                          _sectionCard(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                _sectionTitle(
                                                  LocaleKeys
                                                      .azan_adjust_global_shift_title
                                                      .tr(),
                                                ),
                                                VerticalSpace(height: 8),
                                                _hintText(
                                                  LocaleKeys
                                                      .azan_adjust_global_shift_hint
                                                      .tr(),
                                                ),
                                                VerticalSpace(height: 12),

                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: _ShiftChoiceButton(
                                                        selected:
                                                            s.manualAllShiftMinutes ==
                                                            -60,
                                                        title: LocaleKeys
                                                            .azan_adjust_global_shift_minus_hour
                                                            .tr(),
                                                        onTap: () =>
                                                            updateManualShift(
                                                              -60,
                                                            ),
                                                      ),
                                                    ),
                                                    HorizontalSpace(width: 10),
                                                    Expanded(
                                                      child: _ShiftChoiceButton(
                                                        selected:
                                                            s.manualAllShiftMinutes ==
                                                            0,
                                                        title: LocaleKeys
                                                            .azan_adjust_global_shift_none
                                                            .tr(),
                                                        onTap: () =>
                                                            updateManualShift(
                                                              0,
                                                            ),
                                                      ),
                                                    ),
                                                    HorizontalSpace(width: 10),
                                                    Expanded(
                                                      child: _ShiftChoiceButton(
                                                        selected:
                                                            s.manualAllShiftMinutes ==
                                                            60,
                                                        title: LocaleKeys
                                                            .azan_adjust_global_shift_plus_hour
                                                            .tr(),
                                                        onTap: () =>
                                                            updateManualShift(
                                                              60,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Per prayer adjustments (landscape grid like screenshot)
                                          _sectionCard(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    AppButton(
                                                      width: 140.w,
                                                      height: 38.h,
                                                      color: Colors.black
                                                          .withOpacity(0.22),
                                                      onPressed: () => update(
                                                        AzanAdjustSettings.defaults(),
                                                      ),
                                                      child: Text(
                                                        LocaleKeys
                                                            .azan_adjust_reset
                                                            .tr(),
                                                        style: TextStyle(
                                                          color: AppTheme
                                                              .primaryTextColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12.sp,
                                                        ),
                                                      ),
                                                    ),
                                                    _sectionTitle(
                                                      LocaleKeys
                                                          .azan_adjust_per_prayer_title
                                                          .tr(),
                                                    ),
                                                  ],
                                                ),
                                                VerticalSpace(height: 6),
                                                _hintText(
                                                  LocaleKeys
                                                      .azan_adjust_per_prayer_hint
                                                      .tr(),
                                                ),
                                                VerticalSpace(height: 14),

                                                Row(
                                                  children: List.generate(6, (
                                                    i,
                                                  ) {
                                                    final title =
                                                        _prayerTitleByIndex(i);
                                                    final v =
                                                        s.perPrayerMinutes[i];

                                                    return Expanded(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 6.w,
                                                            ),
                                                        child: _PrayerAdjustColumn(
                                                          title: title,
                                                          value: v,
                                                          onMinus: () =>
                                                              updatePerPrayer(
                                                                i,
                                                                v - 1,
                                                              ),
                                                          onPlus: () =>
                                                              updatePerPrayer(
                                                                i,
                                                                v + 1,
                                                              ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    HorizontalSpace(width: 12),

                                    // RIGHT: Iqama + Hijri info
                                    Expanded(
                                      child: Column(
                                        children: [
                                          _sectionCard(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                _sectionTitle(
                                                  LocaleKeys
                                                      .azan_adjust_iqama_section_title
                                                      .tr(),
                                                ),
                                                VerticalSpace(height: 6),
                                                _hintText(
                                                  LocaleKeys
                                                      .azan_adjust_iqama_hint
                                                      .tr(),
                                                ),
                                                VerticalSpace(height: 12),

                                                ...List.generate(6, (i) {
                                                  final pr = prayersData[i];
                                                  final timeText =
                                                      pr.time ?? '--:--';
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                      bottom: 10.h,
                                                    ),
                                                    child: _IqamaRowInline(
                                                      prayerTitle: pr.title,
                                                      adhanTime: timeText,
                                                      value: iqamaMinutes[i],
                                                      onMinus: () =>
                                                          _stepIqama(i, -1),
                                                      onPlus: () =>
                                                          _stepIqama(i, 1),
                                                      onMinus5: () =>
                                                          _stepIqama(i, -5),
                                                      onPlus5: () =>
                                                          _stepIqama(i, 5),
                                                    ),
                                                  );
                                                }),

                                                VerticalSpace(height: 10),

                                                _FridayRowInline(
                                                  title: LocaleKeys
                                                      .friday_sermon_time
                                                      .tr(),
                                                  value: friDaySermonMinutes,
                                                  onMinus: () =>
                                                      _stepFriday(-1),
                                                  onPlus: () => _stepFriday(1),
                                                  onMinus5: () =>
                                                      _stepFriday(-5),
                                                  onPlus5: () => _stepFriday(5),
                                                ),

                                                VerticalSpace(height: 12),

                                                AppButton(
                                                  color: AppTheme
                                                      .primaryButtonBackground,
                                                  width: double.infinity,
                                                  height: 44.h,
                                                  onPressed:
                                                      state
                                                          is saveIqamaTimesLoading
                                                      ? null
                                                      : _saveIqama,
                                                  child:
                                                      state
                                                          is saveIqamaTimesLoading
                                                      ? const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                        )
                                                      : Text(
                                                          LocaleKeys.common_save
                                                              .tr(),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14.sp,
                                                            color: AppTheme
                                                                .primaryButtonTextColor,
                                                          ),
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          _sectionCard(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                _sectionTitle(
                                                  LocaleKeys
                                                      .azan_adjust_hijri_section_title
                                                      .tr(),
                                                ),
                                                VerticalSpace(height: 8),
                                                _hintText(
                                                  LocaleKeys
                                                      .azan_adjust_hijri_section_hint
                                                      .tr(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    // ===== PORTRAIT =====
                                    // _sectionCard(
                                    //   child: Column(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.end,
                                    //     children: [
                                    //       _sectionTitle(
                                    //         LocaleKeys.azan_adjust_title.tr(),
                                    //       ),
                                    //       VerticalSpace(height: 6),
                                    //       _hintText(
                                    //         LocaleKeys.azan_adjust_subtitle
                                    //             .tr(),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    _sectionCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _sectionTitle(
                                            LocaleKeys
                                                .azan_adjust_section_prayer_times
                                                .tr(),
                                          ),
                                          VerticalSpace(height: 10),
                                          _CheckRow(
                                            scale: 1.5,
                                            text: LocaleKeys
                                                .azan_adjust_ramadan_isha_plus_30
                                                .tr(),
                                            value: s.ramadanIshaPlus30,
                                            onChanged: (v) => update(
                                              s.copyWith(ramadanIshaPlus30: v),
                                            ),
                                          ),
                                          _CheckRow(
                                            scale: 1.5,
                                            text: LocaleKeys
                                                .azan_adjust_summer_plus_hour
                                                .tr(),
                                            value: s.summerPlusHour,
                                            onChanged: (v) => update(
                                              s.copyWith(summerPlusHour: v),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    _sectionCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _sectionTitle(
                                            LocaleKeys
                                                .azan_adjust_global_shift_title
                                                .tr(),
                                          ),
                                          VerticalSpace(height: 8),
                                          _hintText(
                                            LocaleKeys
                                                .azan_adjust_global_shift_hint
                                                .tr(),
                                          ),
                                          VerticalSpace(height: 12),
                                          Column(
                                            // crossAxisAlignment:
                                            // CrossAxisAlignment.start,
                                            children: [
                                              _ShiftChoiceButton(
                                                selected:
                                                    s.manualAllShiftMinutes ==
                                                    60,
                                                title: LocaleKeys
                                                    .azan_adjust_global_shift_plus_hour
                                                    .tr(),
                                                onTap: () =>
                                                    updateManualShift(60),
                                                fullWidth: true,
                                              ),
                                              VerticalSpace(height: 10),
                                              _ShiftChoiceButton(
                                                selected:
                                                    s.manualAllShiftMinutes ==
                                                    0,
                                                title: LocaleKeys
                                                    .azan_adjust_global_shift_none
                                                    .tr(),
                                                onTap: () =>
                                                    updateManualShift(0),
                                                fullWidth: true,
                                              ),
                                              VerticalSpace(height: 10),
                                              _ShiftChoiceButton(
                                                selected:
                                                    s.manualAllShiftMinutes ==
                                                    -60,
                                                title: LocaleKeys
                                                    .azan_adjust_global_shift_minus_hour
                                                    .tr(),
                                                onTap: () =>
                                                    updateManualShift(-60),
                                                fullWidth: true,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    _sectionCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              AppButton(
                                                width: 140.w,
                                                height: 38.h,
                                                color: Colors.black.withOpacity(
                                                  0.22,
                                                ),
                                                onPressed: () => update(
                                                  AzanAdjustSettings.defaults(),
                                                ),
                                                child: Text(
                                                  LocaleKeys.azan_adjust_reset
                                                      .tr(),
                                                  style: TextStyle(
                                                    color: AppTheme
                                                        .primaryTextColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              ),
                                              _sectionTitle(
                                                LocaleKeys
                                                    .azan_adjust_per_prayer_title
                                                    .tr(),
                                              ),
                                            ],
                                          ),
                                          VerticalSpace(height: 6),
                                          _hintText(
                                            LocaleKeys
                                                .azan_adjust_per_prayer_hint
                                                .tr(),
                                          ),
                                          VerticalSpace(height: 14),

                                          ...List.generate(6, (i) {
                                            final title = _prayerTitleByIndex(
                                              i,
                                            );
                                            final v = s.perPrayerMinutes[i];

                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom: 10.h,
                                              ),
                                              child: _AdjustRowPortrait(
                                                title: title,
                                                value: v,
                                                onMinus: () =>
                                                    updatePerPrayer(i, v - 1),
                                                onPlus: () =>
                                                    updatePerPrayer(i, v + 1),
                                                onMinus5: () =>
                                                    updatePerPrayer(i, v - 5),
                                                onPlus5: () =>
                                                    updatePerPrayer(i, v + 5),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),

                                    // Iqama
                                    _sectionCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          _sectionTitle(
                                            LocaleKeys
                                                .azan_adjust_iqama_section_title
                                                .tr(),
                                          ),
                                          VerticalSpace(height: 6),
                                          _hintText(
                                            LocaleKeys.azan_adjust_iqama_hint
                                                .tr(),
                                          ),
                                          VerticalSpace(height: 12),

                                          ...List.generate(6, (i) {
                                            final pr = prayersData[i];
                                            final timeText = pr.time ?? '--:--';
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom: 10.h,
                                              ),
                                              child: _IqamaRowInline(
                                                prayerTitle: pr.title,
                                                adhanTime: timeText,
                                                value: iqamaMinutes[i],
                                                onMinus: () =>
                                                    _stepIqama(i, -1),
                                                onPlus: () => _stepIqama(i, 1),
                                                onMinus5: () =>
                                                    _stepIqama(i, -5),
                                                onPlus5: () => _stepIqama(i, 5),
                                              ),
                                            );
                                          }),

                                          VerticalSpace(height: 10),

                                          _FridayRowInline(
                                            title: LocaleKeys.friday_sermon_time
                                                .tr(),
                                            value: friDaySermonMinutes,
                                            onMinus: () => _stepFriday(-1),
                                            onPlus: () => _stepFriday(1),
                                            onMinus5: () => _stepFriday(-5),
                                            onPlus5: () => _stepFriday(5),
                                          ),

                                          VerticalSpace(height: 12),

                                          AppButton(
                                            color: AppTheme
                                                .primaryButtonBackground,
                                            width: double.infinity,
                                            height: 44.h,
                                            onPressed:
                                                state is saveIqamaTimesLoading
                                                ? null
                                                : _saveIqama,
                                            child:
                                                state is saveIqamaTimesLoading
                                                ? const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                : Text(
                                                    LocaleKeys.common_save.tr(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14.sp,
                                                      color: AppTheme
                                                          .primaryButtonTextColor,
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Hijri info
                                    _sectionCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _sectionTitle(
                                            LocaleKeys
                                                .azan_adjust_hijri_section_title
                                                .tr(),
                                          ),
                                          VerticalSpace(height: 8),
                                          _hintText(
                                            LocaleKeys
                                                .azan_adjust_hijri_section_hint
                                                .tr(),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _prayerTitleByIndex(int i) {
    switch (i) {
      case 0:
        return LocaleKeys.fajr.tr();
      case 1:
        return LocaleKeys.sunrise.tr();
      case 2:
        return LocaleKeys.dhuhr.tr();
      case 3:
        return LocaleKeys.asr.tr();
      case 4:
        return LocaleKeys.maghrib.tr();
      case 5:
        return LocaleKeys.isha.tr();
      default:
        return '';
    }
  }
}

// =====================
// Widgets
// =====================

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.text,
    required this.value,
    required this.onChanged,
    required this.scale,
  });

  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Transform.scale(
              scale: scale,
              child: SizedBox(
                width: 24.r,
                height: 24.r,
                child: Checkbox(
                  value: value,
                  onChanged: (v) => onChanged(v ?? false),
                  activeColor: AppTheme.accentColor,
                  checkColor: Colors.black,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
            HorizontalSpace(width: 10.w),
            Expanded(
              child: Text(
                text,
                // textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShiftChoiceButton extends StatelessWidget {
  const _ShiftChoiceButton({
    required this.selected,
    required this.title,
    required this.onTap,
    this.fullWidth = false,
  });

  final bool selected;
  final String title;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: onTap,
      width: fullWidth ? double.infinity : null,
      height: 44.h,
      color: selected
          ? AppTheme.primaryButtonBackground
          : Colors.black.withOpacity(0.22),
      child: AutoSizeText(
        title,
        maxLines: 1,
        minFontSize: 9,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: selected
              ? AppTheme.primaryButtonTextColor
              : AppTheme.primaryTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

class _InlineStepper extends StatelessWidget {
  const _InlineStepper({
    required this.valueText,
    required this.showFast,
    required this.onMinus,
    required this.onPlus,
    required this.onMinus5,
    required this.onPlus5,
  });

  final String valueText;
  final bool showFast;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onMinus5;
  final VoidCallback onPlus5;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showFast) ...[
          _MiniSquareBtn(
            icon: Icons.fast_rewind,
            onTap: onMinus5,
            buttonWidth: 34.w,
            buttonHeight: 34.h,
            iconSize: 16.r,
          ),
          HorizontalSpace(width: 6.w),
        ],
        _MiniSquareBtn(
          icon: Icons.remove,
          onTap: onMinus,
          buttonWidth: 34.w,
          buttonHeight: 34.h,
          iconSize: 18.r,
        ),
        HorizontalSpace(width: 8.w),
        Container(
          width: 86.w,
          height: 34.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.22),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valueText,
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
        HorizontalSpace(width: 8.w),
        _MiniSquareBtn(
          icon: Icons.add,
          onTap: onPlus,
          buttonWidth: 34.w,
          buttonHeight: 34.h,
          iconSize: 18.r,
        ),
        if (showFast) ...[
          HorizontalSpace(width: 6.w),
          _MiniSquareBtn(
            icon: Icons.fast_forward,
            onTap: onPlus5,
            buttonWidth: 34.w,
            buttonHeight: 34.h,
            iconSize: 16.r,
          ),
        ],
      ],
    );
  }
}

class _FridayRowInline extends StatelessWidget {
  const _FridayRowInline({
    required this.title,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    required this.onMinus5,
    required this.onPlus5,
  });

  final String title;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onMinus5;
  final VoidCallback onPlus5;

  @override
  Widget build(BuildContext context) {
    final vText = LocalizationHelper.isArAndArNumberEnable()
        ? DateHelper.toArabicDigits('$value')
        : '$value';

    return LayoutBuilder(
      builder: (context, c) {
        final showFast = c.maxWidth >= 320;

        return Row(
          children: [
            _InlineStepper(
              valueText: '$vText ${LocaleKeys.min.tr()}',
              showFast: showFast,
              onMinus: onMinus,
              onPlus: onPlus,
              onMinus5: onMinus5,
              onPlus5: onPlus5,
            ),
            HorizontalSpace(width: 10.w),
            Expanded(
              child: Text(
                title,
                // textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _IqamaRowInline extends StatelessWidget {
  const _IqamaRowInline({
    required this.prayerTitle,
    required this.adhanTime,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    required this.onMinus5,
    required this.onPlus5,
  });

  final String prayerTitle;
  final String adhanTime;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onMinus5;
  final VoidCallback onPlus5;

  @override
  Widget build(BuildContext context) {
    final vText = LocalizationHelper.isArAndArNumberEnable()
        ? DateHelper.toArabicDigits('$value')
        : '$value';

    return LayoutBuilder(
      builder: (context, c) {
        // لو المساحة ضيقة شيل أزرار +/-5 تلقائيًا عشان مفيش overflow
        final showFast = c.maxWidth >= 320;

        return Row(
          children: [
            _InlineStepper(
              valueText: '$vText ${LocaleKeys.min.tr()}',
              showFast: showFast,
              onMinus: onMinus,
              onPlus: onPlus,
              onMinus5: onMinus5,
              onPlus5: onPlus5,
            ),
            HorizontalSpace(width: 10.w),
            Expanded(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayerTitle,
                    // textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${LocaleKeys.adhan_time_label.tr()}: $adhanTime',
                    // textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppTheme.primaryTextColor.withOpacity(0.75),
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PrayerAdjustColumn extends StatelessWidget {
  const _PrayerAdjustColumn({
    required this.title,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String title;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  String _pretty(int v) => (v > 0) ? "+$v" : "$v";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        children: [
          AutoSizeText(
            title,
            maxLines: 1,
            minFontSize: 10,
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
          VerticalSpace(height: 8),
          Container(
            height: 34.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.22),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Text(
              _pretty(value),
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          VerticalSpace(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _MiniSquareBtn(
                  icon: Icons.add,
                  onTap: onPlus,
                  iconSize: 15.r,
                ),
              ),
              HorizontalSpace(width: 5),
              Expanded(
                child: _MiniSquareBtn(
                  icon: Icons.remove,
                  onTap: onMinus,
                  iconSize: 15.r,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniSquareBtn extends StatelessWidget {
  const _MiniSquareBtn({
    required this.icon,
    required this.onTap,
    this.buttonHeight,
    this.buttonWidth,
    this.iconSize,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double? buttonHeight;
  final double? buttonWidth;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: buttonWidth ?? 38.w,
        height: buttonHeight ?? 38.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.22),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Icon(
          icon,
          size: iconSize ?? 20.r,
          color: AppTheme.primaryTextColor,
        ),
      ),
    );
  }
}

class _AdjustRowPortrait extends StatelessWidget {
  const _AdjustRowPortrait({
    required this.title,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    required this.onMinus5,
    required this.onPlus5,
  });

  final String title;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onMinus5;
  final VoidCallback onPlus5;

  String _pretty(int v) => (v > 0) ? "+$v" : "$v";

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            _MiniSquareBtn(icon: Icons.fast_rewind, onTap: onMinus5),
            HorizontalSpace(width: 6.w),
            _MiniSquareBtn(icon: Icons.remove, onTap: onMinus),
            HorizontalSpace(width: 8.w),
            Container(
              width: 70.w,
              height: 38.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.22),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Text(
                _pretty(value),
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ),
            HorizontalSpace(width: 8.w),
            _MiniSquareBtn(icon: Icons.add, onTap: onPlus),
            HorizontalSpace(width: 6.w),
            _MiniSquareBtn(icon: Icons.fast_forward, onTap: onPlus5),
          ],
        ),
        const Spacer(),
        Text(
          title,
          // textAlign: TextAlign.right,
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _IqamaRow extends StatelessWidget {
  const _IqamaRow({
    required this.prayerTitle,
    required this.adhanTime,
    required this.iqamaValue,
    required this.onTap,
  });

  final String prayerTitle;
  final String adhanTime;
  final int iqamaValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final vText = LocalizationHelper.isArAndArNumberEnable()
        ? DateHelper.toArabicDigits('$iqamaValue')
        : '$iqamaValue';

    return Row(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: 120.w,
            height: 40.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.22),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Text(
              '$vText ${LocaleKeys.min.tr()}',
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
        HorizontalSpace(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                prayerTitle,
                // textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '${LocaleKeys.adhan_time_label.tr()}: $adhanTime',
                // textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppTheme.primaryTextColor.withOpacity(0.75),
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FridayRow extends StatelessWidget {
  const _FridayRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final int value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final vText = LocalizationHelper.isArAndArNumberEnable()
        ? DateHelper.toArabicDigits('$value')
        : '$value';

    return Row(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: 120.w,
            height: 40.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.22),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Text(
              '$vText ${LocaleKeys.min.tr()}',
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
        HorizontalSpace(width: 10.w),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
        ),
      ],
    );
  }
}
