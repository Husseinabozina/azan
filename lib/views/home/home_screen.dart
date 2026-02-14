import 'dart:async';

import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_state.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/views/home/home_screen_landscape.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:azan/views/select_location/select_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // لو أول مرة يفتح التطبيق، روح لاختيار الموقع (ثابت)
    if (!CacheHelper.getFirstAppOpen()) return SelectLocationScreen();

    // مصدر الحقيقة الوحيد: qt (0 أو 1)
    // final int qt = context.select((UiRotationCubit c) => c.state);

    // ✅ القاعدة الصح:
    // qt=1 => Portrait UI => Mobile screen
    // qt=0 => Landscape UI => Landscape screen
    // final bool isPortraitUi = (qt == 1);

    // debugPrint('HomeScreen qt=$qt -> ${isPortraitUi ? "Mobile" : "Landscape"}');
    // return BlocConsumer<UiRotationCubit, bool>(
    //   listener: (context, state) {
    //     // TODO: implement listener
    //   },
    //   builder: (context, state) {
    //     final cubit = UiRotationCubit();

    //     if (cubit.isLandscape()) {
    //       return HomeScreenLandscape();
    //     }
    //     return HomeScreenMobile();
    //   },
    // );

    return BlocBuilder<UiRotationCubit, bool>(
      builder: (context, isLand) {
        return isLand ? HomeScreenLandscape() : HomeScreenMobile();
      },
    );
  }
}
