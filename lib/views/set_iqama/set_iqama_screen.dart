import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/components/appbutton.dart';
import 'package:azan/core/components/flash_dialoge.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/dialoge_helper.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:azan/views/select_location/select_location_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/core/components/global_copyright_footer.dart';

class SetIqamaScreen extends StatefulWidget {
  const SetIqamaScreen({super.key});

  @override
  State<SetIqamaScreen> createState() => _SetIqamaScreenState();
}

class _SetIqamaScreenState extends State<SetIqamaScreen> {
  late AppCubit appCubit;
  late List<int> iqamaMinutes; // لكل صلاة
  late int friDaySermonMinutes;

  @override
  void initState() {
    super.initState();
    appCubit = AppCubit.get(context);
    friDaySermonMinutes = CacheHelper.getFridayTime();
    iqamaMinutes = List<int>.filled(prayers.length, 10);

    appCubit.getStoredIqamaMinutes().then((storedIqama) {
      if (!mounted) return;
      setState(() {
        if (storedIqama.isNotEmpty) {
          iqamaMinutes = storedIqama;
        }
      });
    });
  }

  Future<void> _editIqamaMinutes(int index) async {
    final result = await _showMinutesEditorDialog(
      title: '${LocaleKeys.set_iqama_time.tr()} ${prayers[index]}',
      current: iqamaMinutes[index],
    );

    if (result != null && mounted) {
      setState(() => iqamaMinutes[index] = result);
    }
  }

  Future<void> _editFridaySermonMinutes() async {
    final result = await _showMinutesEditorDialog(
      title: LocaleKeys.friday_sermon_time.tr(),
      current: friDaySermonMinutes,
    );

    if (result != null && mounted) {
      setState(() => friDaySermonMinutes = result);
    }
  }

  String _formatMinutes(int value) {
    final normalized = LocalizationHelper.isArAndArNumberEnable()
        ? DateHelper.toArabicDigits('$value')
        : '$value';
    return '$normalized ${LocaleKeys.min.tr()}';
  }

  Future<int?> _showMinutesEditorDialog({
    required String title,
    required int current,
  }) {
    final sizing = DialogConfig.getSizing(context);

    return showAppDialog<int>(
      context: context,
      builder: (dialogContext) {
        int localValue = current;

        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return UniversalDialogShell(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogTitle(title),
                  SizedBox(height: sizing.verticalGap * 0.7),
                  DialogBodyText(
                    LocaleKeys.select_minutes_after_adhan.tr(),
                    color: DialogPalette.mutedTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: sizing.verticalGap * 0.7),
                  DialogContentCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (localValue > 0) {
                              setStateDialog(() => localValue -= 1);
                            }
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline_rounded,
                            color: DialogPalette.primaryButtonBackground,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: DialogPalette.selectionBorder,
                              width: 1.5,
                            ),
                            color: DialogPalette.inputFillColor,
                          ),
                          child: Text(
                            _formatMinutes(localValue),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: DialogPalette.inputTextColor,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              setStateDialog(() => localValue += 1),
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: DialogPalette.primaryButtonBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: sizing.verticalGap * 0.55),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [0, 5, 10, 15, 20, 25, 30].map((value) {
                      final selected = localValue == value;
                      return ChoiceChip(
                        label: Text(
                          _formatMinutes(value),
                          style: TextStyle(
                            color: selected
                                ? DialogPalette.primaryButtonText
                                : DialogPalette.bodyTextColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: selected,
                        selectedColor: DialogPalette.primaryButtonBackground,
                        backgroundColor: DialogPalette.surfaceRaisedColor,
                        side: BorderSide(
                          color: selected
                              ? DialogPalette.primaryButtonBackground
                              : DialogPalette.dividerColor,
                        ),
                        onSelected: (_) =>
                            setStateDialog(() => localValue = value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: sizing.verticalGap),
                  DialogButtonRow(
                    leftButton: DialogButton(
                      text: LocaleKeys.common_cancel.tr(),
                      variant: DialogButtonVariant.secondary,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                    rightButton: DialogButton(
                      text: LocaleKeys.common_ok.tr(),
                      onPressed: () =>
                          Navigator.of(dialogContext).pop(localValue),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prayersData = appCubit.prayers(context);
    final bool hasTimes = prayersData.isNotEmpty && prayersData[0].time != null;

    final isLandscape = UiRotationCubit().isLandscape();
    final screenW = MediaQuery.of(context).size.width;

    // ✅ width responsive بدل 100.w
    final double colW = isLandscape ? (screenW * 0.18) : 100.w;

    // ✅ Header font responsive
    final double headerFont = isLandscape ? 16.sp : 14.sp;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const GlobalCopyrightFooter(),
      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {
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
          return Stack(
            children: [
              Image.asset(
                CacheHelper.getSelectedBackground(),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fill,
              ),

              // =========================
              //  NO TIMES UI (as-is)
              // =========================
              if (!hasTimes)
                PositionedDirectional(
                  top: 40.h,
                  start: 32.w,
                  end: 32.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          AppNavigator.pushAndRemoveUntil(
                            context,
                            HomeScreen(),
                          );
                        },
                        icon: Icon(
                          Icons.close,
                          color: AppTheme.accentColor,
                          size: 35.r,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.menu,
                          color: AppTheme.primaryTextColor,
                          size: 35.r,
                        ),
                      ),
                    ],
                  ),
                ),

              if (!hasTimes)
                Positioned(
                  top: .4.sh,
                  right: .10.sw,
                  left: .10.sw,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          LocaleKeys.no_prayer_times.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                        VerticalSpace(height: 20),
                        AppButton(
                          color: AppTheme.primaryTextColor,
                          child: Text(
                            LocaleKeys.open_prayer_times_button.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => AppNavigator.push(
                            context,
                            SelectLocationScreen(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // =========================
              //  TIMES UI (Responsive + Scroll)
              // =========================
              if (hasTimes)
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: 20.r,
                          left: 15.w,
                          right: 15.w,
                          bottom: 16.h,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Top bar
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      AppNavigator.pushAndRemoveUntil(
                                        context,
                                        HomeScreen(),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: AppTheme.accentColor,
                                      size: 35.r,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(
                                      Icons.menu,
                                      color: AppTheme.primaryTextColor,
                                      size: 35.r,
                                    ),
                                  ),
                                ],
                              ),

                              VerticalSpace(height: 30),

                              // ✅ Header row responsive
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _HeaderBlock(
                                    width: colW,
                                    text: LocaleKeys.prayer.tr(),
                                    fontSize: headerFont,
                                  ),
                                  _HeaderBlock(
                                    width: colW,
                                    text: LocaleKeys.adhan_time_label.tr(),
                                    fontSize: headerFont,
                                  ),
                                  _HeaderBlock(
                                    width: colW,
                                    text: LocaleKeys.iqama_time_minutes_label
                                        .tr(),
                                    fontSize: headerFont,
                                  ),
                                ],
                              ),

                              SizedBox(height: 10.h),

                              // Table (same logic)
                              Table(
                                columnWidths: {
                                  0: const FlexColumnWidth(3), // الصلاة
                                  1: FixedColumnWidth(2.w), // spacer
                                  2: const FlexColumnWidth(3), // الأذان
                                  3: FixedColumnWidth(4.w), // spacer
                                  4: const FlexColumnWidth(2), // الإقامة
                                },
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  ...List.generate(prayers.length, (index) {
                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            top: 10.h,
                                            bottom: 10.h,
                                            end: 30.w,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: PrayerText(
                                              title: prayers[index],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(),

                                        Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            top: 10.h,
                                            bottom: 10.h,
                                            end: 30.w,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: PrayerText(
                                              title:
                                                  prayersData[index].time ??
                                                  '--:--',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(),

                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10.h,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: InkWell(
                                              onTap: () =>
                                                  _editIqamaMinutes(index),
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  minWidth: 90.w,
                                                ),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 6.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16.r,
                                                        ),
                                                    border: Border.all(
                                                      color: AppTheme
                                                          .primaryTextColor,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${LocalizationHelper.isArAndArNumberEnable() ? DateHelper.toArabicDigits(iqamaMinutes[index].toString()) : iqamaMinutes[index]} ${LocaleKeys.min.tr()}',
                                                      style: TextStyle(
                                                        fontSize: 18.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppTheme
                                                            .primaryTextColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),

                              VerticalSpace(height: 20.h),

                              // Friday Sermon
                              Padding(
                                padding: EdgeInsets.only(left: 8.w, right: 8.w),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: AutoSizeText(
                                        LocaleKeys.friday_sermon_time.tr(),
                                        maxLines: 1,
                                        minFontSize: 10,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isLandscape ? 18.sp : 16.sp,
                                          color: AppTheme.primaryTextColor,
                                        ),
                                      ),
                                    ),
                                    HorizontalSpace(width: 10.w),
                                    Align(
                                      alignment: Alignment.center,
                                      child: InkWell(
                                        onTap: _editFridaySermonMinutes,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minWidth: 90.w,
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12.w,
                                              vertical: 6.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                              border: Border.all(
                                                color:
                                                    AppTheme.primaryTextColor,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${LocalizationHelper.isArAndArNumberEnable() ? DateHelper.toArabicDigits(friDaySermonMinutes.toString()) : friDaySermonMinutes} ${LocaleKeys.min.tr()}',
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppTheme.primaryTextColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              VerticalSpace(height: 10.h),

                              // Save Button
                              Padding(
                                padding: EdgeInsets.only(left: 8.w, right: 8.w),
                                child: AppButton(
                                  color: AppTheme.primaryButtonBackground,
                                  onPressed: () {
                                    appCubit.saveIqamaTimes();
                                    CacheHelper.setFridayTime(
                                      friDaySermonMinutes,
                                    );
                                  },
                                  child: state is saveIqamaTimesLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          LocaleKeys.common_save.tr(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.sp,
                                            color:
                                                AppTheme.primaryButtonTextColor,
                                          ),
                                        ),
                                ),
                              ),

                              // ✅ Spacer بسيط علشان الـminHeight ما يعملش تكدس تحت
                              SizedBox(height: 6.h),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// ✅ Header block: AutoSizeText + line
class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock({
    required this.width,
    required this.text,
    required this.fontSize,
  });

  final double width;
  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AutoSizeText(
            text,
            maxLines: 1,
            minFontSize: 10,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
              fontFamily: CacheHelper.getTimesFontFamily(),
              height: 1.1,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 2.h,
            width: double.infinity,
            color: AppTheme.primaryTextColor,
          ),
        ],
      ),
    );
  }
}
