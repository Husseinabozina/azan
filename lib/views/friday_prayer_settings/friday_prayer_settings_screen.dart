import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FridayPrayerSettingsScreen extends StatefulWidget {
  const FridayPrayerSettingsScreen({super.key});

  @override
  State<FridayPrayerSettingsScreen> createState() =>
      _FridayPrayerSettingsScreenState();
}

class _FridayPrayerSettingsScreenState
    extends State<FridayPrayerSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {},
        builder: (context, state) {
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
                  padding: EdgeInsets.only(top: 20.r, left: 5.w, right: 5.w),
                  child: Column(
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
                          HorizontalSpace(width: 5),
                          Text(
                            LocaleKeys.friday_prayer_settings.tr(),
                            style: TextStyle(
                              color: AppTheme.primaryTextColor,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          HorizontalSpace(width: 5),

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

                      VerticalSpace(height: 10),
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
