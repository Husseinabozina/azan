import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/helpers/display_board_schedule_helper.dart';
import 'package:azan/core/models/home_display_mode.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/views/home/display_board_landscape.dart';
import 'package:azan/views/home/display_board_portrait.dart';
import 'package:azan/views/home/home_screen_landscape_2.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppCubit.get(context).assignDisplayAnnouncements();
    });
  }

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

    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        final items = cubit.displayAnnouncementList ?? const [];
        final mode = DisplayBoardScheduleResolver.effectiveDisplayMode(
          manualMode: CacheHelper.getHomeDisplayMode(),
          items: items,
        );
        final isLand = context.watch<UiRotationCubit>().state;
        if (mode == HomeDisplayMode.displayBoard) {
          return isLand
              ? const DisplayBoardLandscapeScreen()
              : const DisplayBoardPortraitScreen();
        }
        return isLand ? HomeScreenLandscape2() : HomeScreenMobile();
      },
    );
  }
}
