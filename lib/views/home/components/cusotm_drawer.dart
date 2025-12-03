import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/alert_dialoges.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/adhkar/adhkar_screen.dart';
import 'package:azan/views/select_location/select_location_screen.dart';
import 'package:azan/views/set_Iqama_azan_sound/set_iqama_azan_sound.dart';
import 'package:azan/views/set_iqama/set_iqama_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
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
                  Assets.images.home.path,
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
