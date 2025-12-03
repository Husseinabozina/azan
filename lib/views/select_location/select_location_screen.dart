import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/appbutton.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
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
      body: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          return LayoutBuilder(
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
                            children: [
                              AppButton(
                                onPressed: null,
                                color: Colors.white,
                                width: 160.w,
                                height: 40.h,
                                child: Text(
                                  'السعودية',
                                  style: TextStyle(
                                    color: AppTheme.darkBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                              HorizontalSpace(width: 10),
                              AppButton(
                                onPressed: () {
                                  showSaudiCityPickerDialog(context, (
                                    item,
                                  ) async {
                                    final city = item as CityOption;
                                    appCubit.setCity(city);
                                    await appCubit.initializePrayerTimes(
                                      city.nameEn,
                                    );
                                    if (!CacheHelper.getFirstAppOpen()) {
                                      CacheHelper.setFirstAppOpen(true);
                                      AppNavigator.pushAndRemoveUntil(
                                        context,
                                        HomeScreenMobile(),
                                      );
                                    }
                                  });
                                },
                                color: Colors.white,
                                width: 160.w,
                                height: 40.h,
                                child: Row(
                                  children: [
                                    Text(
                                      appCubit.getCity()?.nameAr ??
                                          'اختر المدينة',
                                      style: TextStyle(
                                        color: AppTheme.darkBlue,
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
                ],
              );
            },
          );
        },
      ),
    );
  }
}
