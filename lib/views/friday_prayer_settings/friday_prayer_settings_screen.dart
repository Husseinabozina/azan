import 'dart:async';

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/components/flash_dialoge.dart';
import 'package:azan/core/components/global_copyright_footer.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FridayPrayerSettingsScreen extends StatefulWidget {
  const FridayPrayerSettingsScreen({super.key});

  @override
  State<FridayPrayerSettingsScreen> createState() =>
      _FridayPrayerSettingsScreenState();
}

class _FridayPrayerSettingsScreenState
    extends State<FridayPrayerSettingsScreen> {
  static const int _minMinutes = 0;
  static const int _maxMinutes = 180;

  late final AppCubit _appCubit;
  late int _fridayMinutes;
  List<int> _baseIqamaMinutes = List<int>.filled(6, 10);

  @override
  void initState() {
    super.initState();
    _appCubit = AppCubit.get(context);
    _fridayMinutes = CacheHelper.getFridayTime();
    unawaited(_loadBaseIqama());
  }

  Future<void> _loadBaseIqama() async {
    final stored = await _appCubit.getStoredIqamaMinutes();
    if (!mounted || stored.isEmpty) return;
    setState(() => _baseIqamaMinutes = List<int>.from(stored));
  }

  void _stepMinutes(int delta) {
    setState(() {
      _fridayMinutes = (_fridayMinutes + delta).clamp(_minMinutes, _maxMinutes);
    });
  }

  Future<void> _save() async {
    await _appCubit.saveBaseIqamaTimes(
      List<int>.from(_baseIqamaMinutes),
      fridayMinutes: _fridayMinutes,
    );
  }

  void _goHome() {
    AppNavigator.pushAndRemoveUntil(context, const HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = UiRotationCubit().isLandscape();

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const GlobalCopyrightFooter(),
      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {
          if (state is saveIqamaTimesSuccess) {
            showFlashMessage(
              message: LocaleKeys.saved_successfully.tr(),
              type: FlashMessageType.success,
              context: context,
            );
          } else if (state is saveIqamaTimesFailure) {
            showFlashMessage(
              message: LocaleKeys.something_went_wrong_please_try_again.tr(),
              type: FlashMessageType.error,
              context: context,
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  CacheHelper.getSelectedBackground(),
                  fit: BoxFit.fill,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLandscape ? 28.w : 18.w,
                    vertical: isLandscape ? 14.h : 18.h,
                  ),
                  child: Column(
                    children: [
                      _TopBar(
                        onClose: _goHome,
                        onBack: () => Navigator.pop(context),
                      ),
                      SizedBox(height: isLandscape ? 18.h : 24.h),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isLandscape ? 560.w : double.infinity,
                            ),
                            child: _FridaySettingsCard(
                              minutes: _fridayMinutes,
                              isSaving: state is saveIqamaTimesLoading,
                              onMinus5: () => _stepMinutes(-5),
                              onMinus: () => _stepMinutes(-1),
                              onPlus: () => _stepMinutes(1),
                              onPlus5: () => _stepMinutes(5),
                              onReset: () => setState(
                                () => _fridayMinutes =
                                    CacheHelper.getFridayTime(),
                              ),
                              onSave: _save,
                            ),
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
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose, required this.onBack});

  final VoidCallback onClose;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onClose,
          icon: Icon(Icons.close, color: AppTheme.accentColor, size: 34.r),
        ),
        Expanded(
          child: Text(
            LocaleKeys.friday_prayer_settings.tr(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        IconButton(
          onPressed: onBack,
          icon: Icon(
            Icons.arrow_forward_rounded,
            color: AppTheme.primaryTextColor,
            size: 32.r,
          ),
        ),
      ],
    );
  }
}

class _FridaySettingsCard extends StatelessWidget {
  const _FridaySettingsCard({
    required this.minutes,
    required this.isSaving,
    required this.onMinus5,
    required this.onMinus,
    required this.onPlus,
    required this.onPlus5,
    required this.onReset,
    required this.onSave,
  });

  final int minutes;
  final bool isSaving;
  final VoidCallback onMinus5;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onPlus5;
  final VoidCallback onReset;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1.w,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.friday_sermon_time.tr(),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'اضبط مدة الانتظار بعد أذان الظهر يوم الجمعة قبل الخطبة أو الإقامة. هذه القيمة تُستخدم في حساب صلاة الجمعة والأذكار المرتبطة بها.',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              children: [
                Text(
                  '$minutes ${LocaleKeys.min.tr()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    _StepButton(label: '-5', onTap: onMinus5),
                    SizedBox(width: 8.w),
                    _StepButton(icon: Icons.remove_rounded, onTap: onMinus),
                    SizedBox(width: 8.w),
                    _StepButton(icon: Icons.add_rounded, onTap: onPlus),
                    SizedBox(width: 8.w),
                    _StepButton(label: '+5', onTap: onPlus5),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  title: 'إعادة ضبط',
                  backgroundColor: Colors.black.withValues(alpha: 0.20),
                  textColor: AppTheme.primaryTextColor,
                  onTap: onReset,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                flex: 2,
                child: _ActionButton(
                  title: isSaving ? '...' : LocaleKeys.common_save.tr(),
                  backgroundColor: AppTheme.primaryButtonBackground,
                  textColor: AppTheme.primaryButtonTextColor,
                  onTap: isSaving ? null : onSave,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          height: 42.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppTheme.accentColor.withValues(alpha: 0.35),
            ),
          ),
          child: icon == null
              ? Text(
                  label ?? '',
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : Icon(icon, color: AppTheme.primaryTextColor, size: 22.r),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.title,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  final String title;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onTap == null
              ? backgroundColor.withValues(alpha: 0.50)
              : backgroundColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
