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
import 'package:azan/views/home/components/home_star_hint.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';

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
            child: SingleChildScrollView(
              child: SizedBox(
                width: 1.sw,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

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
                          icon: Icon(
                            Icons.menu,
                            color: AppTheme.primaryTextColor,
                            size: 35.r,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10.h,
                        left: 10.w,
                        right: 10.w,
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CustomCheckTile(
                          //   title: LocaleKeys.palestine_flag.tr(),
                          //   value: CacheHelper.getpalestinianFlag(),
                          //   onChanged: (value) {
                          //     setState(() {
                          //       CacheHelper.setpalestinianFlag(value);
                          //     });
                          //   },
                          // ),
                          // VerticalSpace(height: 10),
                          CustomCheckTile(
                            onChanged: (value) {
                              setState(() {
                                CacheHelper.setUse24HoursFormat(value);
                              });
                            },
                            title: LocaleKeys.enable_24_hours.tr(),
                            value: CacheHelper.getUse24HoursFormat(),
                          ),

                          VerticalSpace(height: 10),

                          CustomCheckTile(
                            onChanged: (value) {
                              setState(() {
                                CacheHelper.setIsFullTimeEnabled(value);
                              });
                            },
                            title:
                                LocaleKeys.enable_full_time.tr() + " 00:00:00",
                            value: CacheHelper.getIsFullTimeEnabled(),
                          ),
                          VerticalSpace(height: 10),

                          CustomCheckTile(
                            onChanged: (value) {
                              setState(() {
                                CacheHelper.setIsPreviousPrayersDimmed(value);
                              });
                            },
                            title: LocaleKeys.dim_previous_prayers.tr(),
                            value: CacheHelper.getIsPreviousPrayersDimmed(),
                          ),
                          VerticalSpace(height: 10),

                          CustomCheckTile(
                            onChanged: (value) {
                              setState(() {
                                CacheHelper.setIsChangeCounterEnabled(value);
                              });
                            },
                            title: LocaleKeys.change_counter_color.tr(),
                            value: CacheHelper.getIsChangeCounterEnabled(),
                          ),
                          VerticalSpace(height: 10),

                          CustomCheckTile(
                            onChanged: (value) {
                              setState(() {
                                CacheHelper.setIsArabicNumbersEnabled(value);
                              });
                            },
                            title: LocaleKeys.enable_arabic_numbers.tr(),
                            value: CacheHelper.getIsArabicNumbersEnabled(),
                          ),
                          VerticalSpace(height: 10),

                          CustomCheckTile(
                            onChanged: (value) {
                              setState(() {
                                CacheHelper.setEnableCheckInternetConnection(
                                  value,
                                );
                              });
                            },
                            title: LocaleKeys
                                .check_your_internet_connection_the_star
                                .tr(),
                            value:
                                CacheHelper.getEnableCheckInternetConnection(),
                          ),

                          VerticalSpace(height: 10),

                          // VerticalSpace(height: 10),
                          // Container(
                          //   height: 2.h,
                          //   width: double.infinity,
                          //   color: AppTheme.secondaryTextColor,
                          // ),
                          // VerticalSpace(height: 10),
                          // Row(
                          //   children: [
                          //     Container(
                          //       height: 10.h,
                          //       width: 10.w,
                          //       decoration: BoxDecoration(
                          //         border: Border.all(
                          //           width: 2.w,
                          //           color: AppTheme.primaryTextColor,
                          //         ),
                          //         color: Colors.transparent,
                          //         shape: BoxShape.circle,
                          //       ),
                          //     ),
                          //     SizedBox(width: 10.w),

                          //     Expanded(
                          //       child: Text(
                          //         LocaleKeys.notification_message_before_iqama
                          //             .tr(),
                          //         style: TextStyle(
                          //           fontSize: 12.sp,
                          //           color: AppTheme.primaryTextColor,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // VerticalSpace(height: 1),

                          // textspan
                          // Align(
                          //   alignment: AlignmentDirectional.centerStart,
                          //   child: InkWell(
                          //     onTap: () {
                          //       showEditNotificationMessageDialog(
                          //         context,
                          //         initialText:
                          //             CacheHelper.getNotificationMessageBeforeIqama(),
                          //         onConfirm: (value) {
                          //           setState(() {
                          //             CacheHelper.setNotificationMessageBeforeIqama(
                          //               value,
                          //             );
                          //           });
                          //         },
                          //       );
                          //     },
                          //     child: Text.rich(
                          //       textAlign: TextAlign.start,

                          //       TextSpan(
                          //         children: [
                          //           TextSpan(
                          //             text: LocaleKeys.the_message.tr() + ":",
                          //             style: TextStyle(
                          //               fontSize: 12.sp,
                          //               fontWeight: FontWeight.w600,
                          //               color: AppTheme.primaryTextColor,
                          //             ),
                          //           ),
                          //           TextSpan(
                          //             text:
                          //                 CacheHelper.getNotificationMessageBeforeIqama(),
                          //             style: TextStyle(
                          //               fontSize: 12.sp,
                          //               fontWeight: FontWeight.bold,
                          //               color: AppTheme.secondaryTextColor,
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          VerticalSpace(height: 10),
                          Container(
                            height: 2.h,
                            width: double.infinity,
                            color: AppTheme.secondaryTextColor,
                          ),
                          VerticalSpace(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  showAddEidDialog(
                                    LocaleKeys.eid_al_fitr.tr(),
                                    context,
                                    onConfirm: (date, time) {
                                      setState(() {
                                        CacheHelper.setFitrEid(
                                          DateFormat(
                                            'yyyy-MM-dd',
                                            LocalizationHelper.isArAndArNumberEnable(
                                                  context,
                                                )
                                                ? CacheHelper.getLang()
                                                : 'en',
                                          ).format(date),
                                          DateHelper.formatTimeWithSettings(
                                            time,
                                            context,
                                          ),
                                        );
                                        // CacheHelper.setFitrEid(time);
                                      });
                                    },

                                    onCancel: () {},
                                  );

                                  // pickTime(context).then((value) {
                                  //   setState(() {
                                  //     if (value != null) {
                                  //       CacheHelper.setFitrEid(
                                  //         DateHelper.formatTimeWithSettings(
                                  //           value,
                                  //           context,
                                  //         ),
                                  //       );
                                  //     }
                                  //   });
                                  // });
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
                              VerticalSpace(height: 5),

                              InkWell(
                                onTap: () {
                                  // final TextEditingController timeController = TextEditingController();
                                  showAddEidDialog(
                                    LocaleKeys.eid_al_adha.tr(),
                                    context,

                                    onConfirm: (date, time) {
                                      setState(() {
                                        CacheHelper.setAdhaEid(
                                          DateFormat(
                                            'yyyy-MM-dd',
                                            LocalizationHelper.isArAndArNumberEnable(
                                                  context,
                                                )
                                                ? CacheHelper.getLang()
                                                : 'en',
                                          ).format(date),
                                          DateHelper.formatTimeWithSettings(
                                            time,
                                            context,
                                          ),
                                        );
                                        // CacheHelper.setAdhaEid(time);
                                      });
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
                              VerticalSpace(height: 5),

                              CustomTimeCheckTile(
                                titleValue: CacheHelper.getFitrEid() != null
                                    ? (CacheHelper.getFitrEid()![0] +
                                          ' ' +
                                          CacheHelper.getFitrEid()![1])
                                    : null,
                                title: LocaleKeys.show_fetr_eid_prayer.tr(),
                                value: CacheHelper.getShowFitrEid(),
                                onChanged: (value) {
                                  setState(() {
                                    CacheHelper.setShowFitrEid(value);
                                  });
                                },
                              ),
                              VerticalSpace(height: 4),
                              CustomTimeCheckTile(
                                titleValue: CacheHelper.getAdhaEid() != null
                                    ? (CacheHelper.getAdhaEid()![0] +
                                          ' ' +
                                          CacheHelper.getAdhaEid()![1])
                                    : null,
                                title: LocaleKeys.show_adha_eid_prayer.tr(),
                                value: CacheHelper.getShowAdhaEid(),
                                onChanged: (value) {
                                  setState(() {
                                    CacheHelper.setShowAdhaEid(value);
                                  });
                                },
                              ),

                              // Text.rich(
                              //   TextSpan(
                              //     children: [
                              //       TextSpan(
                              //         text: LocaleKeys.show_adha_eid_prayer.tr() + ": ",
                              //         style: TextStyle(
                              //           fontSize: 12.sp,
                              //           fontWeight: FontWeight.w600,
                              //           color: AppTheme.primaryTextColor,
                              //         ),
                              //       ),
                              //       TextSpan(
                              //         text: CacheHelper.getAdhaEid(),
                              //         style: TextStyle(
                              //           fontSize: 12.sp,
                              //           fontWeight: FontWeight.bold,
                              //           color: AppTheme.secondaryTextColor,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),

                          VerticalSpace(height: 10),
                          Container(
                            height: 2.h,
                            width: double.infinity,
                            color: AppTheme.secondaryTextColor,
                          ),
                          VerticalSpace(height: 10),

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

                          // Text(
                          //   LocaleKeys.the_message.tr() + ":"
                          //   ,style: TextStyle(
                          //     fontSize: 15.sp,
                          //   ) ,
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Text(
                                        LocaleKeys.the_adhkar.tr(),
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryTextColor,
                                        ),
                                      ),
                                    ),
                                    VerticalSpace(height: 10),

                                    ...List.generate(azkarFonts.length, (
                                      index,
                                    ) {
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 5.h),
                                        child: CustomCheckTile(
                                          checkBoxSize: 18.r,
                                          fontSize: 12.sp,
                                          title: azkarFonts[index],
                                          value:
                                              CacheHelper.getAzkarFontFamily() ==
                                              azkarFonts[index],
                                          onChanged: (value) {
                                            setState(() {
                                              CacheHelper.setAzkarFontFamily(
                                                azkarFonts[index],
                                              );
                                            });
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Text(
                                        LocaleKeys.time.tr(),
                                        style: TextStyle(
                                          fontFamily:
                                              CacheHelper.getTimeFontFamily(),
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryTextColor,
                                        ),
                                      ),
                                    ),
                                    VerticalSpace(height: 10),

                                    ...List.generate(timeFonts.length, (index) {
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 5.h),

                                        child: CustomCheckTile(
                                          checkBoxSize: 18.r,
                                          fontSize: 12.sp,
                                          title: timeFonts[index],
                                          value:
                                              CacheHelper.getTimeFontFamily() ==
                                              timeFonts[index],
                                          onChanged: (value) {
                                            setState(() {
                                              CacheHelper.setTimeFontFamily(
                                                timeFonts[index],
                                              );
                                            });
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Text(
                                        LocaleKeys.prayers.tr(),
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryTextColor,
                                        ),
                                      ),
                                    ),
                                    VerticalSpace(height: 10),

                                    ...List.generate(timesFonts.length, (
                                      index,
                                    ) {
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 5.h),

                                        child: CustomCheckTile(
                                          checkBoxSize: 18.r,
                                          fontSize: 12.sp,
                                          title: timesFonts[index],
                                          value:
                                              CacheHelper.getTimesFontFamily() ==
                                              timesFonts[index],
                                          onChanged: (value) {
                                            setState(() {
                                              CacheHelper.setTimesFontFamily(
                                                timesFonts[index],
                                              );
                                            });
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Text(
                                        LocaleKeys.texts.tr(),
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryTextColor,
                                        ),
                                      ),
                                    ),
                                    VerticalSpace(height: 10),

                                    ...List.generate(textsFonts.length, (
                                      index,
                                    ) {
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 5.h),

                                        child: CustomCheckTile(
                                          checkBoxSize: 18.r,
                                          fontSize: 12.sp,
                                          title: textsFonts[index],
                                          value:
                                              CacheHelper.getTextsFontFamily() ==
                                              textsFonts[index],
                                          onChanged: (value) {
                                            setState(() {
                                              CacheHelper.setTextsFontFamily(
                                                textsFonts[index],
                                              );
                                            });
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // VerticalSpace(height: 10),
                    // Text(
                    //   LocaleKeys.Palestinian_flag.tr(),
                    //   style: TextStyle(
                    //     fontSize: 20.sp,
                    //     fontWeight: FontWeight.bold,
                    //     color: AppTheme.primaryTextColor,
                    //   ),
                    //   // LocaleKeys.
                    // ),

                    // CustomCheckTile(
                    //   title: LocaleKeys.Palestinian_flag.tr(),
                    //   value: CacheHelper.getpalestinianFlag(),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       CacheHelper.setpalestinianFlag(value);
                    //     });
                    //   },
                    // ),
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

class CustomCheckTile extends StatelessWidget {
  CustomCheckTile({
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
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCheckbox(
          size: checkBoxSize ?? 20.r,
          activeColor: AppTheme.accentColor,
          value: value,
          onChanged: onChanged,
        ),
        HorizontalSpace(width: 5),

        Expanded(
          child: Text(
            title,
            maxLines: 2,
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
  CustomTimeCheckTile({
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

        HorizontalSpace(width: 5),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: title + ": ",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTextColor,
                ),
              ),
              TextSpan(
                text: titleValue ?? '--:--',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
