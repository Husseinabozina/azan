import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/helpers/location_helper.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/alert_dialoges.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/additional_settings/additional_settings_screen.dart';
import 'package:azan/views/adhkar/adhkar_screen.dart';
import 'package:azan/views/friday_prayer_settings/friday_prayer_settings_screen.dart';
import 'package:azan/views/select_location/select_location_screen.dart';
import 'package:azan/views/set_Iqama_azan_sound/set_iqama_azan_sound.dart';
import 'package:azan/views/set_iqama/set_iqama_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key, required this.context});
  final BuildContext context;

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Locale _nextLocale(String locale) =>
      locale == 'ar' ? const Locale('en') : const Locale('ar');
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(),
      width: 1.sw,
      backgroundColor: Colors.white,

      child: SizedBox(
        width: 1.sw,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final w = constraints.maxWidth;
            final R r = R(constraints);
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
                      // top: 32.h,
                      // left: 32.w,
                      // right: 32.w,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: 20.w,
                            top: 20.h,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: AppTheme.accentColor,
                                  size: 30.r,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(height: h * 0.0009),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(start: 20.w),
                            child: ListView(
                              children: [
                                DrawerListTile(
                                  r: r,
                                  title: LocaleKeys.select_mosque_location.tr(),
                                  onTap: () {
                                    // AppCubit.get(
                                    //   context,
                                    // ).getTodayHijriDate(context);
                                    AppNavigator.push(
                                      context,
                                      SelectLocationScreen(),
                                    );
                                  },
                                ),
                                DrawerListTile(
                                  r: r,
                                  title: LocaleKeys.edit_mosque_name.tr(),
                                  onTap: () {
                                    showEditMosqueNameDialog(
                                      context,
                                      initialName: CacheHelper.getMosqueName(),
                                      onConfirm: (name) {
                                        CacheHelper.removeMosqueName();
                                        CacheHelper.setMosqueName(name);
                                      },
                                      r: r,
                                    );
                                  },
                                ),
                                DrawerListTile(
                                  r: r,
                                  title: LocaleKeys.edit_mosque_azkar.tr(),
                                  onTap: () {
                                    AppNavigator.push(context, AdhkarScreen());
                                  },
                                ),
                                DrawerListTile(
                                  r: r,
                                  title: LocaleKeys.change_fixed_zekr.tr(),
                                  onTap: () {
                                    showEditDhikrDialog(
                                      context,
                                      initialText: CacheHelper.getFixedDhikr(),
                                      onConfirm: (text) {
                                        CacheHelper.setFixedDhikr(text);
                                      },
                                    );
                                  },
                                ),
                                DrawerListTile(
                                  r: r,
                                  title: LocaleKeys.set_iqama_time.tr(),
                                  onTap: () {
                                    AppNavigator.push(
                                      context,
                                      SetIqamaScreen(),
                                    );
                                  },
                                ),
                                // DrawerListTile(
                                //   r: r,
                                //   title: LocaleKeys.friday_prayer_settings.tr(),
                                //   onTap: () {
                                //     AppNavigator.push(
                                //       context,
                                //       FridayPrayerSettingsScreen(),
                                //     );
                                //   },
                                // ),
                                DrawerListTile(
                                  r: r,
                                  title: LocaleKeys.set_iqama_azan_sound.tr(),
                                  onTap: () {
                                    AppNavigator.push(
                                      context,
                                      SetIqamaAzanSoundScreen(),
                                    );
                                  },
                                ),
                                DrawerListTile(
                                  r: r,
                                  title: LocaleKeys.additional_settings.tr(),
                                  onTap: () {
                                    AppNavigator.push(
                                      context,
                                      AdditionalSettingsScreen(),
                                    );
                                  },
                                ),
                                DrawerListTile(
                                  r: r,
                                  title: LocaleKeys.change_screen_background
                                      .tr(),
                                  onTap: () async {
                                    await showChangeBackgroundDialog(
                                      context,
                                      backgrounds: [
                                        // ====== القديم ======
                                        Assets.images.home.path,
                                        Assets
                                            .images
                                            .backgroundBroundWithMosBird
                                            .path,
                                        Assets.images.backgroundLight2.path,
                                        Assets
                                            .images
                                            .backgroundOliveGreenWithMosq
                                            .path,
                                        Assets.images.backgroundGreenWith.path,

                                        // ====== الجديد (اللي كنت ضايفه قبل كدا) ======
                                        Assets.images.awesomeBackground.path,
                                        Assets.images.awesome2.path,
                                        Assets.images.darkBrownBackground.path,
                                        Assets.images.lightBackground1.path,
                                        Assets.images.lightBrownBackground.path,
                                        Assets.images.brownBackground.path,
                                        Assets.images.background2.path,
                                        Assets
                                            .images
                                            .whiteBackgroundWithNaqsh
                                            .path,

                                        // ====== الجديد (اللي بعتهم دلوقتي) ======
                                        Assets
                                            .images
                                            .elegantTealArabesqueBackground
                                            .path,
                                        Assets
                                            .images
                                            .elegantBurgundyArabesqueBackground
                                            .path,
                                        Assets
                                            .images
                                            .convinentOliveGreenBackground
                                            .path,
                                        Assets
                                            .images
                                            .convinentBeigeBackground
                                            .path,
                                        Assets.images.tealBlueBackground.path,
                                      ],
                                      currentBackground:
                                          CacheHelper.getSelectedBackground(),
                                      onConfirm: (selectedPath) {
                                        setState(() {
                                          CacheHelper.setSelectedBackground(
                                            selectedPath,
                                          );
                                        });

                                        // لو حابب تحدث Cubit كمان:
                                        // context.read<AppCubit>().changeBackground(selectedPath);
                                      },
                                    );
                                  },
                                ),

                                LanguageDrawerTile(
                                  r: r,
                                  currentLanguage:
                                      LocalizationHelper.isArabic(context)
                                      ? LocaleKeys.arabic.tr()
                                      : LocaleKeys.english.tr(),
                                  onTap: () {
                                    showChangeLanguageDialog(
                                      context,
                                      currentLanguageCode:
                                          LocalizationHelper.localCode(
                                            widget.context,
                                          ),
                                      onConfirm: (String code) async {
                                        await widget.context.setLocale(
                                          Locale(code),
                                        );
                                        setState(() {
                                          CacheHelper.setLang(code);
                                        });

                                        AppCubit.get(
                                          widget.context,
                                        ).homeScreenMobile?.homeScreenWork();
                                      },
                                    );
                                    // افتح BottomSheet / Dialog لاختيار اللغة
                                  },
                                ),

                                // DrawerListTile(
                                //   r: r,
                                //   title:
                                //       "${LocaleKeys.language.tr()} " +
                                //       "(${(LocalizationHelper.isArabic(context) ? LocaleKeys.english.tr() : LocaleKeys.arabic.tr())})",
                                // ),
                              ],
                            ),
                          ),
                        ),

                        // SizedBox(
                        //   width: 200.w,
                        //   child: Row(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //       SvgPicture.asset(
                        //         Assets.svg.lang,
                        //         height: 24.h,
                        //         width: 24.w,
                        //       ),
                        //       SizedBox(width: 7.w),
                        //       Text(
                        //         LocaleKeys.language.tr(),
                        //         style: Theme.of(context).textTheme.bodyMedium!
                        //             .copyWith(color: Colors.white),
                        //       ),
                        //       const Spacer(),
                        //       Text(
                        //         LocalizationHelper.isArabic(context)
                        //             ? LocaleKeys.english.tr()
                        //             : LocaleKeys.arabic.tr(),
                        //         style: Theme.of(context).textTheme.bodyMedium!
                        //             .copyWith(color: AppTheme.primaryTextColor),
                        //       ),
                        //       HorizontalSpace(width: 5.w),

                        //       // CustomToggle(
                        //       //   value: isArabic,
                        //       //   onChanged: (value) async {
                        //       //     await context.setLocale(_nextLocale(value));
                        //       //     setState(() {
                        //       //       CacheHelper.setLang(
                        //       //         _nextLocale(value).languageCode,
                        //       //       );
                        //       //     });
                        //       //   },
                        //       // ),
                        //       Transform.scale(
                        //         scale: 0.8,
                        //         child: Switch(
                        //           // dragStartBehavior: DragStartBehavior.start,
                        //           inactiveThumbColor: AppTheme.primaryTextColor,
                        //           activeThumbColor: Colors.white,
                        //           activeColor: Colors.white,
                        //           // materialTapTargetSize:
                        //           //     MaterialTapTargetSize.shrinkWrap,
                        //           trackOutlineColor: WidgetStateProperty.all(
                        //             Colors.transparent,
                        //           ),
                        //           padding: EdgeInsets.zero,
                        //           // thumbColor: WidgetStateProperty.all(
                        //           //   context.theme.colorScheme.primary,
                        //           // ),
                        //           activeTrackColor: AppTheme.primaryTextColor,
                        //           value: !LocalizationHelper.isArabic(context),
                        //           onChanged: (toEnglish) async {
                        //             await context.setLocale(
                        //               _nextLocale(toEnglish),
                        //             );
                        //             setState(() {
                        //               CacheHelper.setLang(
                        //                 _nextLocale(toEnglish).languageCode,
                        //               );
                        //             });
                        //           },
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // Spacer(),
                        Text(
                          LocaleKeys.developed_by_ifadh.tr(),
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppTheme.primaryTextColor,
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
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.r,
    required this.title,
    this.onTap,
  });

  final R r;
  final String title;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // عشان تأثير الـ ripple يبان
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        splashColor: AppTheme.primaryTextColor.withOpacity(0.2),
        highlightColor: AppTheme.primaryTextColor.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
          // سيبها شفافة عادي
          child: Center(
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 10.h,
                  width: 10.w,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2.w,
                      color: AppTheme.primaryTextColor,
                    ),
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LanguageDrawerTile extends StatelessWidget {
  const LanguageDrawerTile({
    super.key,
    required this.r,
    required this.currentLanguage, // مثال: "العربية" أو "English"
    this.onTap,
  });

  final R r;
  final String currentLanguage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        splashColor: AppTheme.primaryTextColor.withOpacity(0.2),
        highlightColor: AppTheme.primaryTextColor.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            children: [
              Container(
                height: 10.h,
                width: 10.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2.w,
                    color: AppTheme.primaryTextColor,
                  ),
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10.w),

              /// "اللغة: العربية" مع ألوان مختلفة
              Text.rich(
                TextSpan(
                  text: LocaleKeys.language.tr(), // مثال: "اللغة"
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTextColor.withOpacity(0.8),
                  ),
                  children: [
                    TextSpan(
                      text: " : ",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryTextColor.withOpacity(0.6),
                      ),
                    ),
                    TextSpan(
                      text: currentLanguage, // "العربية" أو "English"
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme
                            .secondaryTextColor, // أو AppTheme.primaryColor لو حابب تميّزها
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
