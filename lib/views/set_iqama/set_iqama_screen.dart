import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/appbutton.dart';
import 'package:azan/core/components/flash_dialoge.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/iqama_hive_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/azan_time_tile.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:azan/views/select_location/select_location_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

    appCubit.getIqamaTime().then((_) {
      setState(() {
        if (appCubit.iqamaMinutes != null &&
            appCubit.iqamaMinutes!.isNotEmpty) {
          iqamaMinutes = appCubit.iqamaMinutes!;
        }
      });
    });

    // ع${LocaleKeys.min.tr()}${LocaleKeys.min.tr()} العناصر = ع${LocaleKeys.min.tr()}${LocaleKeys.min.tr()} الصلوات
    // مب${LocaleKeys.min.tr()}ئياً 10 ${LocaleKeys.min.tr()}قايق لكل صلاة (ع${LocaleKeys.min.tr()}ّل براحتك أو حمّلها من cubit بع${LocaleKeys.min.tr()}ين)
  }

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
            '${LocaleKeys.set_iqama_time.tr()} ${prayers[index]}',
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
                      // زرار -
                      IconButton(
                        onPressed: () {
                          if (localValue > 0) {
                            setStateDialog(() {
                              localValue -= 1;
                            });
                          }
                        },
                        icon: Icon(Icons.remove, color: AppTheme.accentColor),
                      ),

                      // القيمة الحالية
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
                          '${LocalizationHelper.isArAndArNumberEnable(context) ? DateHelper.toArabicDigits('$localValue') : localValue} ${LocaleKeys.min.tr()}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                      ),

                      // زرار +
                      IconButton(
                        onPressed: () {
                          setStateDialog(() {
                            localValue += 1;
                          });
                        },
                        icon: Icon(Icons.add, color: AppTheme.accentColor),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // اختيارات سريعة زي 5، 10، 15... الخ
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
                              '${LocalizationHelper.isArAndArNumberEnable(context) ? DateHelper.toArabicDigits('$v') : v} ${LocaleKeys.min.tr()}',
                              style: TextStyle(
                                color: AppTheme.primaryButtonTextColor,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: localValue == v,
                            onSelected: (_) {
                              setStateDialog(() {
                                localValue = v;
                              });
                            },
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
              onPressed: () {
                Navigator.of(context).pop(localValue);
              },
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
      setState(() {
        iqamaMinutes[index] = result;
      });

      // ولو حابب تحفظ في الكيوبِت:
      // appCubit.setIqamaMinutesForPrayer(index, result);
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
                      // زرار -
                      IconButton(
                        onPressed: () {
                          if (localValue > 0) {
                            setStateDialog(() {
                              localValue -= 1;
                            });
                          }
                        },
                        icon: Icon(Icons.remove, color: AppTheme.accentColor),
                      ),

                      // القيمة الحالية
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
                          '${LocalizationHelper.isArAndArNumberEnable(context) ? DateHelper.toArabicDigits('$localValue') : localValue} ${LocaleKeys.min.tr()}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                      ),

                      // زرار +
                      IconButton(
                        onPressed: () {
                          setStateDialog(() {
                            localValue += 1;
                          });
                        },
                        icon: Icon(Icons.add, color: AppTheme.accentColor),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // اختيارات سريعة زي 5، 10، 15... الخ
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
                              '${LocalizationHelper.isArAndArNumberEnable(context) ? DateHelper.toArabicDigits('$v') : v} ${LocaleKeys.min.tr()}',
                              style: TextStyle(
                                color: AppTheme.primaryButtonTextColor,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: localValue == v,
                            onSelected: (_) {
                              setStateDialog(() {
                                localValue = v;
                              });
                            },
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
              onPressed: () {
                Navigator.of(context).pop(localValue);
              },
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
      setState(() {
        friDaySermonMinutes = result;

        // iqamaMinutes[index] = result;
      });

      // ولو حابب تحفظ في الكيوبِت:
      // appCubit.setIqamaMinutesForPrayer(index, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayersData = appCubit.prayers(context);
    return Scaffold(
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

              if (appCubit.prayers(context)[0].time == null)
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
                            HomeScreenMobile(),
                          );
                        },
                        icon: Icon(
                          Icons.close,
                          color: AppTheme.accentColor,
                          size: 35.r,
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.menu,
                          color: AppTheme.primaryTextColor,
                          size: 35.r,
                        ),
                      ),
                    ],
                  ),
                ),

              if (appCubit.prayers(context)[0].time == null)
                Positioned(
                  top: .4.sh,
                  // bottom: 50.h,
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

              if (appCubit.prayers(context)[0].time != null)
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 20.r,
                      left: 15.w,
                      right: 15.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,

                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                AppNavigator.pushAndRemoveUntil(
                                  context,
                                  HomeScreenMobile(),
                                );
                              },
                              icon: Icon(
                                Icons.close,
                                color: AppTheme.accentColor,
                                size: 35.r,
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.menu,
                                color: AppTheme.primaryTextColor,
                                size: 35.r,
                              ),
                            ),
                          ],
                        ),
                        VerticalSpace(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 100.w,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    LocaleKeys.prayer.tr(),
                                    maxLines: 1,
                                    textHeightBehavior:
                                        const TextHeightBehavior(
                                          applyHeightToFirstAscent: false,
                                          applyHeightToLastDescent: false,
                                        ),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      height: 1, // ✅ يثبت ارتفاع السطر
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryTextColor,
                                      fontFamily:
                                          CacheHelper.getTimesFontFamily(),
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
                            ),

                            SizedBox(
                              width: 100.w,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    LocaleKeys.adhan_time_label
                                        .tr(), // غيّرها حسب مشروعك
                                    maxLines: 1,
                                    textHeightBehavior:
                                        const TextHeightBehavior(
                                          applyHeightToFirstAscent: false,
                                          applyHeightToLastDescent: false,
                                        ),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      height: 1,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryTextColor,
                                      fontFamily:
                                          CacheHelper.getTimesFontFamily(),
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
                            ),

                            SizedBox(
                              width: 100.w,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    LocaleKeys.iqama_time_minutes_label
                                        .tr(), // غيّرها حسب مشروعك
                                    maxLines: 1,
                                    textHeightBehavior:
                                        const TextHeightBehavior(
                                          applyHeightToFirstAscent: false,
                                          applyHeightToLastDescent: false,
                                        ),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      height: 1,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryTextColor,
                                      fontFamily:
                                          CacheHelper.getTimesFontFamily(),
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
                            ),
                          ],
                        ),
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
                            // Header
                            // TableRow(
                            //   children: [
                            //     Padding(
                            //       padding: EdgeInsets.only(
                            //         right: 10.w,
                            //         left: 10.w,
                            //       ),
                            //       child: Align(
                            //         alignment: Alignment
                            //             .center, // يخلي العنوان في النص
                            //         child: AzanTitleTile(
                            //           width: 30.w,
                            //           title: LocaleKeys.prayer.tr(),
                            //           fontSize: 14.sp,
                            //         ),
                            //       ),
                            //     ),
                            //     const SizedBox(), // spacer col

                            //     Padding(
                            //       padding: EdgeInsets.only(
                            //         right: 10.w,
                            //         left: 10.w,
                            //       ),
                            //       child: Align(
                            //         alignment: Alignment.center,
                            //         child: AzanTitleTile(
                            //           width: 30.w,
                            //           title: LocaleKeys.adhan_time_label.tr(),
                            //           fontSize: 14.sp,
                            //         ),
                            //       ),
                            //     ),
                            //     const SizedBox(), // spacer col
                            //     Padding(
                            //       padding: EdgeInsets.only(
                            //         right: 10.w,
                            //         left: 10.w,
                            //       ),
                            //       child: Align(
                            //         alignment: Alignment.center,
                            //         child: SizedBox(
                            //           width: 120.w,
                            //           height: 50.h,

                            //           child: FittedBox(
                            //             fit: BoxFit.fitWidth,
                            //             child: AzanTitleTile(
                            //               width: 30.w,
                            //               title: LocaleKeys
                            //                   .iqama_time_minutes_label
                            //                   .tr(),
                            //               fontSize: 14.sp,
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //     ),

                            //   ],
                            // ),

                            // Rows
                            ...List.generate(prayers.length, (index) {
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      top: 10.h,
                                      bottom: 10.h,
                                      end: 30.w,
                                      // right: 10.w,
                                    ),
                                    child: Align(
                                      alignment: Alignment
                                          .center, // أو AlignmentDirectional.centerStart لو عايزها تبدأ من البداية
                                      child: PrayerText(title: prayers[index]),
                                    ),
                                  ),
                                  const SizedBox(),

                                  Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      top: 10.h,
                                      bottom: 10.h,
                                      end: 30.w,
                                      // right: 10.w,
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: PrayerText(
                                        title:
                                            prayersData[index].time ?? '--:--',
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
                                        onTap: () => _editIqamaMinutes(index),
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
                                                '${LocalizationHelper.isArAndArNumberEnable(context) ? DateHelper.toArabicDigits(iqamaMinutes[index].toString()) : iqamaMinutes[index]} ${LocaleKeys.min.tr()}',
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
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),

                        VerticalSpace(height: 20.h),
                        Padding(
                          padding: EdgeInsets.only(left: 8.w, right: 8.w),
                          child: Row(
                            children: [
                              Text(
                                LocaleKeys.friday_sermon_time.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                  color: AppTheme.primaryTextColor,
                                ),
                              ),
                              HorizontalSpace(width: 10.w),
                              Align(
                                alignment: Alignment.center,
                                child: InkWell(
                                  onTap: () {
                                    _editFridaySermonMinutes();
                                  },
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: 90.w),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        border: Border.all(
                                          color: AppTheme.primaryTextColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${LocalizationHelper.isArAndArNumberEnable(context) ? DateHelper.toArabicDigits(friDaySermonMinutes.toString()) : friDaySermonMinutes} ${LocaleKeys.min.tr()}',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryTextColor,
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

                        Padding(
                          padding: EdgeInsets.only(left: 8.w, right: 8.w),
                          child: AppButton(
                            color: AppTheme.primaryButtonBackground,
                            onPressed: () {
                              appCubit.saveIqamaTimes();
                              CacheHelper.setFridayTime(friDaySermonMinutes);
                            },
                            child: state is saveIqamaTimesLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    LocaleKeys.common_save.tr(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                      color: AppTheme.primaryButtonTextColor,
                                    ),
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
}
