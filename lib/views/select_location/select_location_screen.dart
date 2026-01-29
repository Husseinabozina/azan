import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/alert_dialoge.dart';
import 'package:azan/core/components/appbutton.dart';
import 'package:azan/core/components/flash_dialoge.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/models/city_option.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/core/utils/selection_dialoge.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  late AppCubit appCubit;

  @override
  void initState() {
    appCubit = AppCubit.get(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {
          if (state is FetchPrayerTimesFailure) {
            showFlashMessage(
              message: state.message,
              type: FlashMessageType.error,
              context: context,
            );
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
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
                        top: 20.r,
                        left: 15.w,
                        right: 15.w,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          (CacheHelper.getCity() != null)
                              ? Row(
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
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      Assets.svg.logosvg,
                                      height: 50.h,
                                      width: 42.w,
                                    ),
                                  ],
                                ),
                          VerticalSpace(height: 30),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              AppButton(
                                onPressed: null,
                                color: AppTheme.primaryButtonBackground,
                                width: 160.w,
                                height: 40.h,
                                child: Text(
                                  LocaleKeys.country_saudi_arabia.tr(),
                                  style: TextStyle(
                                    color: AppTheme.primaryButtonTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                              // HorizontalSpace(width: 10),
                              AppButton(
                                color: AppTheme.primaryButtonBackground,

                                onPressed: () {
                                  showSaudiCityPickerDialog(context, (
                                    item,
                                  ) async {
                                    final city = item as CityOption;
                                    appCubit.setCity(city);
                                    appCubit.assignCityChanged(true);

                                    if (!CacheHelper.getFirstAppOpen()) {
                                      CacheHelper.setFirstAppOpen(true);
                                      AppNavigator.pop(context);
                                      AppNavigator.pushAndRemoveUntil(
                                        context,
                                        HomeScreen(),
                                      );
                                    } else {
                                      AppNavigator.pop(context);
                                      AppNavigator.push(context, HomeScreen());
                                    }
                                  });
                                },
                                width: 160.w,
                                height: 40.h,
                                child: Row(
                                  children: [
                                    Text(
                                      (LocalizationHelper.isArabic(context)
                                              ? appCubit.getCity()?.nameAr
                                              : appCubit.getCity()?.nameEn) ??
                                          LocaleKeys.mosque_city_select_title
                                              .tr(),
                                      style: TextStyle(
                                        color: AppTheme.primaryButtonTextColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    HorizontalSpace(width: 10),
                                    SvgPicture.asset(
                                      Assets.svg.arrowBottom,
                                      height: 8.h,
                                      width: 8.w,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (state is FetchPrayerTimesLoading)
                    Container(
                      height: h,
                      width: w,
                      color: Colors.black54,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryTextColor,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
