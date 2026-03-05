import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/components/appbutton.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/helpers/slide_hive_helper.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/alert_dialoges.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/views/adhkar/components/custom_check_box.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:azan/views/slides/components/slide_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azan/core/components/global_copyright_footer.dart';

class SlidesScreen extends StatefulWidget {
  const SlidesScreen({super.key});

  @override
  State<SlidesScreen> createState() => _SlidesScreenState();
}

class _SlidesScreenState extends State<SlidesScreen> {
  late AppCubit cubit;
  late bool _slidesEnabled;
  late bool _randomOrder;
  late int _slideDuration;

  @override
  void initState() {
    super.initState();
    cubit = AppCubit.get(context);
    cubit.assignSlides();
    _slidesEnabled = CacheHelper.getSlidesEnabled();
    _randomOrder = CacheHelper.getSlidesRandomOrder();
    _slideDuration = CacheHelper.getSlidesDisplaySeconds();
  }

  bool _isLandscape(BuildContext context) => UiRotationCubit().isLandscape();

  void _goHome(BuildContext context) {
    AppNavigator.pushAndRemoveUntil(context, HomeScreen());
  }

  void _setSlidesEnabled(bool enabled) {
    setState(() => _slidesEnabled = enabled);
    CacheHelper.setSlidesEnabled(enabled);
  }

  void _setRandomOrder(bool enabled) {
    setState(() => _randomOrder = enabled);
    CacheHelper.setSlidesRandomOrder(enabled);
  }

  void _setSlideDuration(int seconds) {
    final clamped = seconds.clamp(1, 120);
    setState(() => _slideDuration = clamped);
    CacheHelper.setSlidesDisplaySeconds(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = _isLandscape(context);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const GlobalCopyrightFooter(),
      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {},
        builder: (context, state) {
          final slides = cubit.slideList ?? [];

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
                    vertical: 5.h,
                  ),
                  child: Column(
                    children: [
                      _Header(
                        onClose: () => _goHome(context),
                        onMenu: () => Navigator.pop(context),
                      ),
                      SizedBox(height: isLandscape ? 10.h : 16.h),
                      Expanded(
                        child: isLandscape
                            ? Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: _GlassPanel(
                                      padding: EdgeInsets.all(16.r),
                                      child: SingleChildScrollView(
                                        child: _SlidesSettingsPanel(
                                          slidesEnabled: _slidesEnabled,
                                          onSlidesEnabled: _setSlidesEnabled,
                                          randomOrder: _randomOrder,
                                          onRandomOrder: _setRandomOrder,
                                          slideDuration: _slideDuration,
                                          onSlideDuration: _setSlideDuration,
                                          onAdd: () {
                                            showAddDhikrDialog(
                                              context,
                                              onConfirm: (text, schedule) {
                                                SlideHiveHelper.addSlide(
                                                  text,
                                                  schedule: schedule,
                                                );
                                                cubit.assignSlides();
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    flex: 8,
                                    child: _GlassPanel(
                                      padding: EdgeInsets.all(16.r),
                                      child: _SlidesList(slides: slides),
                                    ),
                                  ),
                                ],
                              )
                            : _SlidesPortraitLayout(
                                slides: slides,
                                slidesEnabled: _slidesEnabled,
                                onSlidesEnabled: _setSlidesEnabled,
                                randomOrder: _randomOrder,
                                onRandomOrder: _setRandomOrder,
                                slideDuration: _slideDuration,
                                onSlideDuration: _setSlideDuration,
                                onAdd: () {
                                  showAddDhikrDialog(
                                    context,
                                    onConfirm: (text, schedule) {
                                      SlideHiveHelper.addSlide(
                                        text,
                                        schedule: schedule,
                                      );
                                      cubit.assignSlides();
                                    },
                                  );
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

class _SlidesPortraitLayout extends StatelessWidget {
  const _SlidesPortraitLayout({
    required this.slides,
    required this.slidesEnabled,
    required this.onSlidesEnabled,
    required this.randomOrder,
    required this.onRandomOrder,
    required this.slideDuration,
    required this.onSlideDuration,
    required this.onAdd,
  });

  final List<dynamic> slides;
  final bool slidesEnabled;
  final ValueChanged<bool> onSlidesEnabled;
  final bool randomOrder;
  final ValueChanged<bool> onRandomOrder;
  final int slideDuration;
  final ValueChanged<int> onSlideDuration;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SlidesSettingsPanel(
            slidesEnabled: slidesEnabled,
            onSlidesEnabled: onSlidesEnabled,
            randomOrder: randomOrder,
            onRandomOrder: onRandomOrder,
            slideDuration: slideDuration,
            onSlideDuration: onSlideDuration,
            onAdd: onAdd,
          ),
          SizedBox(height: 14.h),
          Expanded(child: _SlidesList(slides: slides)),
        ],
      ),
    );
  }
}

class _SlidesSettingsPanel extends StatelessWidget {
  const _SlidesSettingsPanel({
    required this.slidesEnabled,
    required this.onSlidesEnabled,
    required this.randomOrder,
    required this.onRandomOrder,
    required this.slideDuration,
    required this.onSlideDuration,
    required this.onAdd,
  });

  final bool slidesEnabled;
  final ValueChanged<bool> onSlidesEnabled;
  final bool randomOrder;
  final ValueChanged<bool> onRandomOrder;
  final int slideDuration;
  final ValueChanged<int> onSlideDuration;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'slides_center_title'.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'slides_center_note'.tr(),
          style: TextStyle(fontSize: 14.sp, color: AppTheme.secondaryTextColor),
          maxLines: 5,
          overflow: TextOverflow.fade,
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            CustomCheckbox(
              size: 24.r,
              activeColor: AppTheme.accentColor,
              value: slidesEnabled,
              onChanged: onSlidesEnabled,
            ),
            HorizontalSpace(width: 8.w),
            Expanded(
              child: Text(
                'enable_slides'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            CustomCheckbox(
              size: 24.r,
              activeColor: AppTheme.accentColor,
              value: randomOrder,
              onChanged: onRandomOrder,
            ),
            HorizontalSpace(width: 8.w),
            Expanded(
              child: Text(
                'display_slides_randomly'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        _DurationPicker(
          value: slideDuration,
          onChanged: onSlideDuration,
          title: 'slide_display_duration'.tr(),
          unit: 'second'.tr(),
        ),
        SizedBox(height: 14.h),
        AppButton(
          width: 170.w,
          color: AppTheme.primaryButtonBackground,
          height: 44.h,
          radius: 22.r,
          onPressed: onAdd,
          child: Text(
            'add_slide'.tr(),
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

class _DurationPicker extends StatelessWidget {
  const _DurationPicker({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.unit,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String title;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryTextColor,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 8.h,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StepperButton(
              icon: Icons.remove,
              onTap: () => onChanged(value - 1),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.22),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.18),
                  width: 1.w,
                ),
              ),
              child: Text(
                '$value $unit',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryTextColor,
                ),
              ),
            ),
            _StepperButton(icon: Icons.add, onTap: () => onChanged(value + 1)),
          ],
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: AppTheme.primaryButtonBackground,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(icon, size: 20.r, color: AppTheme.primaryButtonTextColor),
      ),
    );
  }
}

class _SlidesList extends StatelessWidget {
  const _SlidesList({required this.slides});

  final List<dynamic> slides;

  @override
  Widget build(BuildContext context) {
    if (slides.isEmpty) {
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
      itemCount: slides.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final slide = slides[index];
        return SlideTile(slide: slide);
      },
    );
  }
}

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
