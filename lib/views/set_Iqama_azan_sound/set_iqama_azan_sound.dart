import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/simple_sound_player.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SetIqamaAzanSoundScreen extends StatefulWidget {
  const SetIqamaAzanSoundScreen({super.key});

  @override
  State<SetIqamaAzanSoundScreen> createState() =>
      _SetIqamaAzanSoundScreenState();
}

class _SetIqamaAzanSoundScreenState extends State<SetIqamaAzanSoundScreen> {
  late AppCubit cubit;
  final _soundPlayer = SimpleSoundPlayer();

  /// true  => صوت الـ App Theme (alarm مثلاً)
  /// false => الصوت القصير (short azan / iqama)
  late bool _isAdhanAppTheme;
  late bool _isIqamaAppTheme;

  @override
  void initState() {
    super.initState();
    cubit = AppCubit.get(context);

    // نقرا القيمة المحفوظة من الـ Cache
    _isAdhanAppTheme = CacheHelper.getIsAzanAppTheme();
    _isIqamaAppTheme = CacheHelper.getIsIqamaAppTheme();
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
                        // ====== App Bar Row ======
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                AppNavigator.pushAndRemoveUntil(
                                  context,
                                  const HomeScreenMobile(),
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

                        // ====== Title ======
                        Text(
                          LocaleKeys.set_iqama_azan_sound.tr(),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        VerticalSpace(height: 20),

                        // ================== أذان ==================
                        Text(
                          LocaleKeys.set_adhan_sound.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),

                        VerticalSpace(height: 10),

                        // App Theme (أذان)
                        CustomRadioTile(
                          value: true,
                          groupValue: _isAdhanAppTheme,
                          title: LocaleKeys.app_theme.tr(),
                          onChanged: (value) async {
                            if (value == null) return;

                            setState(() {
                              _isAdhanAppTheme = value;
                            });

                            // خزّن في الكاش
                            CacheHelper.setIsAzanAppTheme(value);

                            // جرّب الصوت الجديد
                            await _soundPlayer.playAdhanPing(
                              cubit.getAzanSoundSource,
                            );
                          },
                        ),

                        VerticalSpace(height: 10),

                        // Short Azan
                        CustomRadioTile(
                          value: false,
                          groupValue: _isAdhanAppTheme,
                          title: LocaleKeys.short_azan_sound.tr(),
                          onChanged: (value) async {
                            if (value == null) return;

                            setState(() {
                              _isAdhanAppTheme = value;
                            });

                            CacheHelper.setIsAzanAppTheme(value);

                            await _soundPlayer.playAdhanPing(
                              cubit.getAzanSoundSource,
                            );
                          },
                        ),

                        VerticalSpace(height: 20),

                        // ================== إقامة ==================
                        Text(
                          LocaleKeys.set_iqama_sound.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),

                        VerticalSpace(height: 10),

                        // App Theme (إقامة)
                        CustomRadioTile(
                          value: true,
                          groupValue: _isIqamaAppTheme,
                          title: LocaleKeys.app_theme.tr(),
                          onChanged: (value) async {
                            if (value == null) return;

                            setState(() {
                              _isIqamaAppTheme = value;
                            });

                            CacheHelper.setIsIqamaAppTheme(value);

                            await _soundPlayer.playIqamaPing(
                              cubit.getIqamaSoundSource,
                            );
                          },
                        ),

                        VerticalSpace(height: 10),

                        // Short Iqama
                        CustomRadioTile(
                          value: false,
                          groupValue: _isIqamaAppTheme,
                          title: LocaleKeys.short_iqama_sound.tr(),
                          onChanged: (value) async {
                            if (value == null) return;

                            setState(() {
                              _isIqamaAppTheme = value;
                            });

                            CacheHelper.setIsIqamaAppTheme(value);

                            await _soundPlayer.playIqamaPing(
                              cubit.getIqamaSoundSource,
                            );
                          },
                        ),
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

class CustomRadioTile extends StatelessWidget {
  const CustomRadioTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    required this.onChanged,
    this.radioSize = 20, // 👈 هنا تتحكم في حجم الدايرة
  });

  final bool value;
  final bool groupValue;
  final String title;
  final Function(bool?)? onChanged;
  final double radioSize;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;

    return InkWell(
      onTap: () {
        onChanged?.call(value);
      },
      borderRadius: BorderRadius.circular(50),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔵 الدايرة نفسها (الراديو)
          Container(
            width: radioSize.w,
            height: radioSize.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTheme.accentColor : Colors.white70,
                width: 2,
              ),
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: isSelected ? 1 : 0,
              child: Center(
                child: Container(
                  width: radioSize.w * 0.5,
                  height: radioSize.h * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
