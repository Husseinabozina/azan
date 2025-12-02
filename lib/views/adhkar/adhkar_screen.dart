import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/appbutton.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/dhikr_hive_helper.dart';
import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/models/diker.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/alert_dialoges.dart';
import 'package:azan/core/utils/azkar_scheduling_enums.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/adhkar/components/dhikr_from_widget.dart';
import 'package:azan/views/adhkar/components/dhikr_tile.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  late AppCubit cubit;

  @override
  void initState() {
    cubit = AppCubit.get(context);
    cubit.assignAdhkar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {},
        builder: (context, state) {
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
                  padding: EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
                  child: SingleChildScrollView(
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
                        Text(
                          LocaleKeys.mosque_azkar.tr(),
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                        VerticalSpace(height: 10),
                        Text(
                          LocaleKeys.azkar_note.tr(),
                          style: TextStyle(
                            fontSize: 15.sp,
                            // fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),

                        Row(
                          children: [
                            Checkbox(
                              value: CacheHelper.getSliderOpened(),
                              onChanged: (value) {
                                cubit.toggleSlider();
                              },
                            ),
                            // HorizontalSpace(width: 3),
                            Text(
                              LocaleKeys.enable_slider.tr(),
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        VerticalSpace(height: 8),
                        AppButton(
                          width: 115.w,
                          color: Colors.white,
                          radius: 25.r,
                          onPressed: () {
                            showAddDhikrDialog(
                              context,
                              onConfirm: (text, schedule) {
                                DhikrHiveHelper.addDhikr(
                                  text,
                                  schedule: schedule,
                                );
                                cubit.assignAdhkar();
                              },
                            );
                          },
                          child: Text(
                            LocaleKeys.add_message.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B375D),
                            ),
                          ),
                        ),
                        VerticalSpace(height: 10),

                        if (cubit.adhkarList != null)
                          ...cubit.adhkarList!.map((dhikr) {
                            return DhikrTile(dhikr: dhikr);
                          }),

                        // Text(
                        //   // adhkarList != null ? adhkarList![0].text : '',
                        //   cubit.adhkarList != null
                        //       ? cubit.adhkarList![0].text
                        //       : '',
                        //   style: TextStyle(
                        //     fontSize: 20.sp,
                        //     fontWeight: FontWeight.bold,
                        //     color: AppTheme.primaryTextColor,
                        //   ),
                        // ),
                      ],
                    ),
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
