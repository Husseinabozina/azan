import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/alert_dialoges.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/device_kind_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/core/utils/native_orientation.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/additional_settings/additional_settings_screen.dart';
import 'package:azan/views/adhkar/adhkar_screen.dart';
import 'package:azan/views/change_%20background_settings/change_background_settings_screen.dart';
import 'package:azan/views/select_location/select_location_screen.dart';
import 'package:azan/views/set_Iqama_azan_sound/set_iqama_azan_sound.dart';
import 'package:azan/views/set_hide_screen/set_hide_screen.dart';
import 'package:azan/views/set_iqama/set_iqama_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ===============================
/// CustomDrawer
/// - Portrait: ListView (عادي)
/// - Landscape: 2-column Grid بدون Scroll (كل العناصر بتدخل في الشاشة)
/// ===============================
class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key, required this.context});
  final BuildContext context;

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Locale _nextLocale(String locale) =>
      locale == 'ar' ? const Locale('en') : const Locale('ar');

  @override
  Widget build(BuildContext context) {
    final cubit = AppCubit.get(widget.context);

    // ✅ 1) اقرأ وضع الـ UI مرة واحدة من Rotation Cubit
    final int qt = 1; // 0 or 1

    // ✅ 2) اشتقاق واضح

    bool isLandscape = UiRotationCubit().isLandscape();
    final double vPad = isLandscape ? 6.h : 10.h;

    final String targetLabel = isLandscape
        ? LocaleKeys.landscape.tr()
        : LocaleKeys.portrait.tr();

    return Drawer(
      shape: const RoundedRectangleBorder(),
      // في landscape خليها أضيق شوية عشان تبقى شكلها أحلى على TV
      width: 1.sw,
      backgroundColor: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final R r = R(constraints);

          // ====== Entries list (نفس عناصر الـ drawer بتاعتك) ======
          final entries = <_DrawerEntry>[
            _DrawerEntry(
              title: LocaleKeys.select_mosque_location.tr(),
              onTap: () {
                AppNavigator.push(context, SelectLocationScreen());
              },
            ),
            _DrawerEntry(
              title: LocaleKeys.edit_mosque_name.tr(),
              onTap: () {
                showEditMosqueNameDialog(
                  context,
                  initialName: CacheHelper.getMosqueName(),
                  onConfirm: (name) {
                    CacheHelper.removeMosqueName();
                    CacheHelper.setMosqueName(name);
                  },
                  r: r,
                );
              },
            ),
            _DrawerEntry(
              title: LocaleKeys.edit_mosque_azkar.tr(),
              onTap: () {
                AppNavigator.push(context, AdhkarScreen());
              },
            ),
            _DrawerEntry(
              title: LocaleKeys.change_fixed_zekr.tr(),
              onTap: () {
                showEditDhikrDialog(
                  context,
                  initialText: CacheHelper.getFixedDhikr(),
                  onConfirm: (text) {
                    CacheHelper.setFixedDhikr(text);
                  },
                );
              },
            ),
            _DrawerEntry(
              title: LocaleKeys.set_screen_hide.tr(),
              onTap: () {
                AppNavigator.push(context, SetHideScreen());
              },
            ),
            _DrawerEntry(
              title: LocaleKeys.set_iqama_time.tr(),
              onTap: () {
                AppNavigator.push(context, SetIqamaScreen());
              },
            ),
            _DrawerEntry(
              title: LocaleKeys.set_iqama_azan_sound.tr(),
              onTap: () {
                AppNavigator.push(context, SetIqamaAzanSoundScreen());
              },
            ),
            _DrawerEntry(
              title: LocaleKeys.additional_settings.tr(),
              onTap: () {
                AppNavigator.push(context, AdditionalSettingsScreen());
              },
            ),
            _DrawerEntry(
              title: LocaleKeys.change_screen_background.tr(),
              onTap: () async {
                AppNavigator.push(context, ChangeBackgroundSettingsScreen());

                // await showChangeBackgroundDialog(
                //   context,
                //   backgrounds: [
                //     // ====== القديم ======
                //     Assets.images.home.path,
                //     Assets.images.backgroundBroundWithMosBird.path,
                //     Assets.images.backgroundLight2.path,
                //     Assets.images.backgroundOliveGreenWithMosq.path,
                //     Assets.images.backgroundGreenWith.path,

                //     // ====== الجديد ======
                //     Assets.images.awesomeBackground.path,
                //     Assets.images.awesome2.path,
                //     Assets.images.darkBrownBackground.path,
                //     Assets.images.lightBackground1.path,
                //     Assets.images.lightBrownBackground.path,
                //     Assets.images.brownBackground.path,
                //     Assets.images.background2.path,
                //     Assets.images.whiteBackgroundWithNaqsh.path,
                //     Assets.images.elegantTealArabesqueBackground.path,
                //     Assets.images.elegantBurgundyArabesqueBackground.path,
                //     Assets.images.convinentOliveGreenBackground.path,
                //     Assets.images.convinentBeigeBackground.path,
                //     Assets.images.tealBlueBackground.path,
                //     Assets.images.hr0.path,
                //     Assets.images.hr1.path,
                //     Assets.images.hr2.path,
                //     Assets.images.hr3.path,
                //     Assets.images.hr4.path,
                //     Assets.images.hr5.path,
                //     Assets.images.hr6.path,
                //     Assets.images.hr7.path,
                //     Assets.images.hr8.path,
                //     Assets.images.hr9.path,
                //     Assets.images.hr10.path,
                //     Assets.images.hr11.path,
                //     Assets.images.hr12.path,
                //     Assets.images.hr13.path,
                //     Assets.images.hr14.path,
                //     Assets.images.hr15.path,
                //     Assets.images.hr16.path,
                //     Assets.images.hr17.path,
                //     Assets.images.hr18.path,
                //     Assets.images.hr19.path,
                //     Assets.images.hr20.path,
                //     Assets.images.hr21.path,
                //     Assets.images.hr22.path,
                //     Assets.images.hr23.path,
                //     Assets.images.hr24.path,
                //     Assets.images.hr25.path,
                //     Assets.images.hr26.path,
                //     Assets.images.hr27.path,
                //     Assets.images.hr28.path,
                //     Assets.images.hr29.path,
                //     Assets.images.hr30.path,
                //     Assets.images.hr31.path,
                //     // to hr38
                //     Assets.images.hr32.path,
                //     Assets.images.hr33.path,
                //     Assets.images.hr34.path,
                //     Assets.images.hr35.path,
                //     Assets.images.hr36.path,
                //     Assets.images.hr37.path,
                //     Assets.images.hr38.path,
                //     // vr20 to 27
                //     Assets.images.vr20.path,
                //     Assets.images.vr21.path,
                //     Assets.images.vr22.path,
                //     Assets.images.vr23.path,
                //     Assets.images.vr24.path,
                //     Assets.images.vr25.path,
                //     Assets.images.vr26.path,
                //     Assets.images.vr27.path,
                //   ],
                //   currentBackground: CacheHelper.getSelectedBackground(),
                //   onConfirm: (selectedPath) {
                //     setState(() {
                //       CacheHelper.setSelectedBackground(selectedPath);
                //     });
                //   },
                // );
              },
            ),
            _DrawerEntry(
              title: '${LocaleKeys.change_to.tr()} $targetLabel',
              onTap: () {
                // Navigator.pop(context);

                final cubit = context.read<UiRotationCubit>();
                if (cubit.isLandscape()) {
                  cubit.changeIsLandscape(false);
                } else {
                  cubit.changeIsLandscape(true);
                }
              },
            ),
          ];

          // Entry إضافي للغة (شكل خاص)
          final languageTile = LanguageDrawerTile(
            r: r,
            currentLanguage: LocalizationHelper.isArabic(context)
                ? LocaleKeys.arabic.tr()
                : LocaleKeys.english.tr(),
            onTap: () {
              showChangeLanguageDialog(
                context,
                currentLanguageCode: LocalizationHelper.localCode(
                  widget.context,
                ),
                onConfirm: (String code) async {
                  await widget.context.setLocale(Locale(code));
                  setState(() {
                    CacheHelper.setLang(code);
                  });
                  isLandscape
                      ? AppCubit.get(
                          widget.context,
                        ).homeScreenLandscape?.homeScreenWork()
                      : AppCubit.get(
                          widget.context,
                        ).homeScreenMobile?.homeScreenWork();
                },
              );
            },
          );

          // ====== Layout sizing (مهم جدًا عشان no overflow) ======
          final double headerH = isLandscape ? 54.h : 70.h;
          final double footerH = 34.h;

          // المساحة اللي هنحط فيها عناصر القائمة
          final double bodyH = constraints.maxHeight - headerH - footerH;

          // في landscape: 2 أعمدة -> عدد الصفوف = ceil(count/2)
          // +1 للـ language tile
          final int totalTiles = entries.length + 1;
          final int columns = isLandscape ? 2 : 1;
          final int rows = (totalTiles / columns).ceil();

          // mainAxisExtent = ارتفاع كل Tile (بالظبط) عشان كلهم يدخلوا بدون scroll
          // نخصم شوية spacing بين الصفوف
          final double gridSpacing = 8.h;
          final double totalSpacing = gridSpacing * (rows - 1);
          double tileExtent = (bodyH - totalSpacing) / rows;

          // حماية: لو طلع قليل جدًا، صغّر التايل
          // (مع AutoSizeText هيفضل readable)
          tileExtent = tileExtent.clamp(36.h, 74.h);

          return Stack(
            children: [
              Image.asset(
                CacheHelper.getSelectedBackground(),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fill,
              ),

              SafeArea(
                child: Column(
                  children: [
                    // ===============================
                    // Header (Close button)
                    // ===============================
                    SizedBox(
                      height: headerH,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 16.w,
                          top: 10.h,
                          end: 8.w,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close,
                                color: AppTheme.accentColor,
                                size: 28.r,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),

                    // ===============================
                    // Body
                    // Portrait: ListView (scroll عادي)
                    // Landscape: Grid بدون scroll (كل حاجة تدخل)
                    // ===============================
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 16.w,
                          end: 16.w,
                        ),
                        child: isLandscape
                            ? _LandscapeNoScrollGrid(
                                r: r,
                                entries: entries,
                                languageTile: languageTile,
                                tileExtent: tileExtent,
                                spacing: gridSpacing,
                              )
                            : ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  ...entries.map(
                                    (e) => DrawerListTile(
                                      r: r,
                                      title: e.title,
                                      onTap: e.onTap,
                                    ),
                                  ),
                                  languageTile,
                                ],
                              ),
                      ),
                    ),

                    // ===============================
                    // Footer
                    // ===============================
                    SizedBox(
                      height: footerH,
                      child: Center(
                        child: Text(
                          LocaleKeys.developed_by_ifadh.tr(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppTheme.primaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Landscape grid بدون scroll
class _LandscapeNoScrollGrid extends StatelessWidget {
  const _LandscapeNoScrollGrid({
    required this.r,
    required this.entries,
    required this.languageTile,
    required this.tileExtent,
    required this.spacing,
  });

  final R r;
  final List<_DrawerEntry> entries;
  final Widget languageTile;
  final double tileExtent;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    // نجمع العناصر كلها في List واحدة
    final items = <Widget>[
      ...entries.map(
        (e) => DrawerListTile(
          r: r,
          title: e.title,
          onTap: e.onTap,
          // في landscape صغّر padding جوّه التايل تلقائيًا
          denseLandscape: true,
        ),
      ),
      languageTile,
    ];

    return GridView.builder(
      // مهم: ممنوع scroll هنا — الهدف كل حاجة تدخل في الشاشة
      // physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: tileExtent, // ← ده سر "بدون overflow/scroll"
        crossAxisSpacing: 10.w,
        mainAxisSpacing: spacing,
      ),
      itemBuilder: (context, index) => items[index],
    );
  }
}

/// Model بسيط للتعامل مع العناصر
class _DrawerEntry {
  final String title;
  final VoidCallback onTap;
  _DrawerEntry({required this.title, required this.onTap});
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.r,
    required this.title,
    this.onTap,
    this.denseLandscape = false,
  });

  final R r;
  final String title;
  final Function()? onTap;

  /// لو true: نقلل padding/font عشان يركب على landscape بدون ضغط
  final bool denseLandscape;

  @override
  Widget build(BuildContext context) {
    final double vPad = denseLandscape ? 6.h : 10.h;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        splashColor: AppTheme.primaryTextColor.withOpacity(0.2),
        highlightColor: AppTheme.primaryTextColor.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: vPad),
          child: Row(
            children: [
              Container(
                height: 9.h,
                width: 9.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2.w,
                    color: AppTheme.primaryTextColor,
                  ),
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10.w),

              // AutoSize عشان لو العنوان طويل في landscape ما يعملش overflow
              Expanded(child: _DrawerTitleText(title: title)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerTitleText extends StatelessWidget {
  const _DrawerTitleText({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        );
      },
    );
  }
}

class LanguageDrawerTile extends StatelessWidget {
  const LanguageDrawerTile({
    super.key,
    required this.r,
    required this.currentLanguage,
    this.onTap,
  });

  final R r;
  final String currentLanguage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = UiRotationCubit().isLandscape();

    final double vPad = isLandscape ? 6.h : 10.h;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        splashColor: AppTheme.primaryTextColor.withOpacity(0.2),
        highlightColor: AppTheme.primaryTextColor.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: vPad),
          child: Row(
            children: [
              Container(
                height: 9.h,
                width: 9.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2.w,
                    color: AppTheme.primaryTextColor,
                  ),
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10.w),

              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: LocaleKeys.language.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryTextColor.withOpacity(0.85),
                    ),
                    children: [
                      TextSpan(
                        text: " : ",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTextColor.withOpacity(0.6),
                        ),
                      ),
                      TextSpan(
                        text: currentLanguage,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
