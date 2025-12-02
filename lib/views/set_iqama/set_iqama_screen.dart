import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/appbutton.dart';
import 'package:azan/core/components/flash_dialoge.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/iqama_hive_helper.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SetIqamaScreen extends StatefulWidget {
  const SetIqamaScreen({super.key});

  @override
  State<SetIqamaScreen> createState() => _SetIqamaScreenState();
}

class _SetIqamaScreenState extends State<SetIqamaScreen> {
  late AppCubit appCubit;
  late List<int> iqamaMinutes; // لكل صلاة

  @override
  void initState() {
    super.initState();
    appCubit = AppCubit.get(context);
    iqamaMinutes = List<int>.filled(prayers.length, 10);
    appCubit.getIqamaTime().then((_) {
      setState(() {
        if (appCubit.iqamaMinutes != null &&
            appCubit.iqamaMinutes!.isNotEmpty) {
          iqamaMinutes = appCubit.iqamaMinutes!;
        }
      });
    });

    // عدد العناصر = عدد الصلوات
    // مبدئياً 10 دقايق لكل صلاة (عدّل براحتك أو حمّلها من cubit بعدين)
  }

  Future<void> _editIqamaMinutes(int index) async {
    final current = iqamaMinutes[index];

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        int localValue = current;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'ضبط إقامة ${prayers[index]}',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'اختر عدد الدقائق بعد الأذان',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // زرار -
                      IconButton(
                        onPressed: () {
                          if (localValue > 0) {
                            setStateDialog(() {
                              localValue -= 1;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),

                      // القيمة الحالية
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppTheme.primaryTextColor,
                            width: 1.5,
                          ),
                          color: Colors.white,
                        ),
                        child: Text(
                          '$localValue د',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                      ),

                      // زرار +
                      IconButton(
                        onPressed: () {
                          setStateDialog(() {
                            localValue += 1;
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // اختيارات سريعة زي 5، 10، 15... الخ
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [0, 5, 10, 15, 20, 25, 30]
                        .map(
                          (v) => ChoiceChip(
                            color: WidgetStatePropertyAll(
                              AppTheme.primaryTextColor,
                            ),
                            label: Text(
                              '$v د',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: localValue == v,
                            onSelected: (_) {
                              setStateDialog(() {
                                localValue = v;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(localValue);
              },
              child: Text(
                'حفظ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
          ],
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        iqamaMinutes[index] = result;
      });

      // ولو حابب تحفظ في الكيوبِت:
      // appCubit.setIqamaMinutesForPrayer(index, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {
          if (state is saveIqamaTimesSuccess) {
            showFlashMessage(
              message: 'تم الحفظ',
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
              Image.asset(
                Assets.images.home.path,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fill,
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: 20.r, left: 15.w, right: 15.w),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              AzanTitleTile(
                                width: 30.w,
                                title: LocaleKeys.prayer.tr(),
                                fontSize: 14.sp,
                              ),
                              VerticalSpace(height: 10),

                              ...prayers.map(
                                (e) => Padding(
                                  padding: EdgeInsets.only(bottom: 19.h),
                                  child: PrayerText(title: e),
                                ),
                              ),
                            ],
                          ),
                          // HorizontalSpace(width: 10),
                          Column(
                            children: [
                              AzanTitleTile(
                                width: 30.w,
                                title: "وقت الأذان",
                                fontSize: 14.sp,
                              ),
                              VerticalSpace(height: 10),

                              ...appCubit.prayers.map(
                                (e) => Padding(
                                  padding: EdgeInsets.only(bottom: 19.h),
                                  child: PrayerText(title: e.time!),
                                ),
                              ),
                            ],
                          ),

                          Column(
                            children: [
                              AzanTitleTile(
                                width: 120.w,
                                title: 'وقت الإقامة (دقيقة)',
                                fontSize: 12.sp,
                              ),
                              VerticalSpace(height: 10),
                              ...List.generate(prayers.length, (index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: InkWell(
                                    onTap: () => _editIqamaMinutes(index),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        border: Border.all(
                                          color: AppTheme.primaryTextColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        '${iqamaMinutes[index]} د', // د = دقيقة
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),

                      VerticalSpace(height: 20.h),
                      Padding(
                        padding: EdgeInsets.only(left: 8.w, right: 8.w),
                        child: AppButton(
                          color: AppTheme.primaryTextColor,
                          onPressed: () {
                            appCubit.saveIqamaTimes();
                          },
                          child: state is saveIqamaTimesLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'حفظ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: Colors.white,
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
