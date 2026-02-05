import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/components/appbutton.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/dhikr_hive_helper.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/alert_dialoges.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/adhkar/components/custom_check_box.dart';
import 'package:azan/views/adhkar/components/dhikr_tile.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:azan/views/home/home_screen_landscape.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  late AppCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = AppCubit.get(context);
    cubit.assignAdhkar();
  }

  bool _isLandscape(BuildContext context) => UiRotationCubit().isLandscape();

  void _goHome(BuildContext context) {
    // يرجّع للشاشة الصح حسب الاتجاه الحالي
    final Widget home = HomeScreen();

    AppNavigator.pushAndRemoveUntil(context, home);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = _isLandscape(context);

    return Scaffold(
      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {},
        builder: (context, state) {
          final adhkar = cubit.adhkarList ?? [];

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
                  padding: EdgeInsets.symmetric(
                    horizontal: isLandscape ? 24.w : 20.w,
                    vertical: 10.h,
                  ),
                  child: Column(
                    children: [
                      // =========================
                      // Header
                      // =========================
                      _Header(
                        onClose: () => _goHome(context),
                        onMenu: () => Navigator.pop(context),
                      ),
                      SizedBox(height: isLandscape ? 10.h : 16.h),

                      // =========================
                      // Body
                      // =========================
                      Expanded(
                        child: isLandscape
                            ? Row(
                                children: [
                                  // LEFT PANEL: Settings + Add button
                                  Expanded(
                                    flex: 4,
                                    child: _GlassPanel(
                                      padding: EdgeInsets.all(16.r),
                                      child: _SettingsPanel(
                                        onAdd: () {
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
                                        sliderValue:
                                            CacheHelper.getSliderOpened(),
                                        onSliderToggle: (value) {
                                          cubit.toggleSlider();
                                        },
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 14.w),

                                  // RIGHT PANEL: List
                                  Expanded(
                                    flex: 8,
                                    child: _GlassPanel(
                                      padding: EdgeInsets.all(16.r),
                                      child: _AdhkarList(adhkar: adhkar),
                                    ),
                                  ),
                                ],
                              )
                            : _PortraitLayout(
                                adhkar: adhkar,
                                onAdd: () {
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
                                sliderValue: CacheHelper.getSliderOpened(),
                                onSliderToggle: (value) {
                                  cubit.toggleSlider();
                                },
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

/// =========================
/// Header row
/// =========================
class _Header extends StatelessWidget {
  const _Header({required this.onClose, required this.onMenu});

  final VoidCallback onClose;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onClose,
          icon: Icon(Icons.close, color: AppTheme.accentColor, size: 34.r),
        ),
        IconButton(
          onPressed: onMenu,
          icon: Icon(Icons.menu, color: AppTheme.primaryTextColor, size: 34.r),
        ),
      ],
    );
  }
}

/// =========================
/// Portrait layout (بدون overflow)
/// بدل SingleChildScrollView نخليها ListView داخل Expanded
/// =========================
class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({
    required this.adhkar,
    required this.onAdd,
    required this.sliderValue,
    required this.onSliderToggle,
  });

  final List<dynamic> adhkar;
  final VoidCallback onAdd;
  final bool sliderValue;
  final ValueChanged<bool> onSliderToggle;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsPanel(
            onAdd: onAdd,
            sliderValue: sliderValue,
            onSliderToggle: onSliderToggle,
          ),
          SizedBox(height: 14.h),

          // ✅ هنا بقى الليست هي اللي تعمل Scroll
          Expanded(child: _AdhkarList(adhkar: adhkar)),
        ],
      ),
    );
  }
}

/// =========================
/// Settings panel (title + note + toggle + add button)
/// =========================
class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.onAdd,
    required this.sliderValue,
    required this.onSliderToggle,
  });

  final VoidCallback onAdd;
  final bool sliderValue;
  final ValueChanged<bool> onSliderToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.mosque_azkar.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.h),
        Text(
          LocaleKeys.azkar_note.tr(),
          style: TextStyle(fontSize: 14.sp, color: AppTheme.secondaryTextColor),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 12.h),

        // Toggle
        Row(
          children: [
            CustomCheckbox(
              size: 24.r,
              activeColor: AppTheme.accentColor,
              value: sliderValue,
              onChanged: (value) => onSliderToggle(value),
            ),
            HorizontalSpace(width: 8.w),
            Expanded(
              child: Text(
                LocaleKeys.enable_slider.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // Add button
        AppButton(
          width: 160.w,
          color: AppTheme.primaryButtonBackground,
          height: 44.h,
          radius: 22.r,
          onPressed: onAdd,
          child: Text(
            LocaleKeys.add_message.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// =========================
/// Adhkar list: لازم تكون scroll داخل panel
/// =========================
class _AdhkarList extends StatelessWidget {
  const _AdhkarList({required this.adhkar});

  final List<dynamic> adhkar;

  @override
  Widget build(BuildContext context) {
    if (adhkar.isEmpty) {
      return Center(
        child: Text(
          '--',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: adhkar.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final dhikr = adhkar[index];
        return DhikrTile(dhikr: dhikr);
      },
    );
  }
}

/// =========================
/// Glass panel بسيط (نفس ستايل الشاشات الكبيرة)
/// =========================
class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.22),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.w),
      ),
      child: child,
    );
  }
}
