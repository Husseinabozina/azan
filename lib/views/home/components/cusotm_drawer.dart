import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/helpers/display_board_schedule_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/alert_dialoges.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/dialoge_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/additional_settings/additional_settings_screen.dart';
import 'package:azan/views/adhkar/adhkar_screen.dart';
import 'package:azan/views/about_app/about_app_screen.dart';
import 'package:azan/views/change_%20background_settings/change_background_settings_screen.dart';
import 'package:azan/views/display_board/display_board_settings_screen.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:azan/views/managed_azkar/managed_azkar_screen.dart';
import 'package:azan/views/prayer_calendar/hijri_prayer_calendar_screen.dart';
import 'package:azan/views/select_location/select_location_screen.dart';
import 'package:azan/views/set_azan_iqama/set_azan_iqama_screen.dart';
import 'package:azan/views/set_hide_screen/set_hide_screen.dart';
import 'package:azan/views/slides/slides_screen.dart';
import 'package:azan/views/weather_status/weather_status_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'dart:io';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

const String _hijriPrayerCalendarTitle =
    'إدارة مواقيت الصلاة حسب توقيت أم القري';

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
  Future<void> _reopenHome() async {
    final cubit = AppCubit();
    await DisplayBoardScheduleResolver.switchBackToHomeMode(
      items: cubit.displayAnnouncementList ?? const [],
      now: DateTime.now(),
      dismissCurrentScheduled: true,
    );
    await cubit.assignDisplayAnnouncements();
    if (!mounted) return;
    await AppNavigator.pushAndRemoveUntil(widget.context, const HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = UiRotationCubit().isLandscape();

    final String targetLabel = isLandscape
        ? LocaleKeys.portrait.tr()
        : LocaleKeys.landscape.tr();

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
              title: LocaleKeys.morning_evening_adhkar.tr(),
              onTap: () {
                AppNavigator.push(context, const ManagedAzkarScreen());
              },
            ),
            _DrawerEntry(
              title: LocaleKeys.view_slides.tr(),
              onTap: () {
                AppNavigator.push(context, SlidesScreen());
              },
            ),
            _DrawerEntry(
              title: LocaleKeys.display_board_management.tr(),
              onTap: () {
                AppNavigator.push(context, const DisplayBoardSettingsScreen());
              },
            ),
            _DrawerEntry(
              title: LocaleKeys.change_app_logo.tr(),
              onTap: () {
                showAppDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return Center(
                      child: UniversalDialogShell(
                        customMaxHeight: 140.h,
                        child: Center(
                          child: MosqueLogoRadioPicker(
                            mainAxisSize: MainAxisSize.min,
                            defaultAssetPath: Assets.svg.logosvg,
                            onChanged: (path) {
                              if (path != null) {
                                CacheHelper.setMosqueLogoPath(path);
                              } else {
                                CacheHelper.clearMosqueLogoPath();
                              }

                              Navigator.pop(context); // اقفل الديالوج
                              _reopenHome();
                            },
                          ),
                        ),
                      ),
                    );
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
              title: LocaleKeys.additional_settings.tr(),
              onTap: () {
                AppNavigator.push(context, AdditionalSettingsScreen());
              },
            ),
            _DrawerEntry(
              title: LocaleKeys.iqama_azan_settings.tr(),
              onTap: () {
                AppNavigator.push(context, AzanAdjustScreen());
              },
            ),
            _DrawerEntry(
              title: _hijriPrayerCalendarTitle,
              onTap: () {
                AppNavigator.push(context, const HijriPrayerCalendarScreen());
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
              title: LocaleKeys.about_app.tr(),
              onTap: () {
                AppNavigator.push(context, AboutAppScreen());
              },
            ),
            _DrawerEntry(
              title: LocaleKeys.weather_status.tr(),
              onTap: () {
                AppNavigator.push(context, WeatherStatusScreen());
              },
            ),
            // if (isLargeScreen(kind))
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
            //                          if (isLandscape) {
            //   SystemChrome.setPreferredOrientations([
            //     DeviceOrientation.landscapeLeft,
            //     DeviceOrientation.landscapeRight,
            //   ]);
            // } else {
            //   SystemChrome.setPreferredOrientations([
            //     DeviceOrientation.portraitUp,
            //     // DeviceOrientation.portraitDown,  // لو عاوز upside-down كمان
            //   ]);
            // }
          ];

          // Entry إضافي للغة (شكل خاص)
          final languageTile = LanguageDrawerTile(
            r: r,
            currentLanguage: LocalizationHelper.localCode() == 'ar'
                ? LocaleKeys.arabic.tr()
                : (LocalizationHelper.localCode() == 'bn'
                      ? 'বাংলা'
                      : LocaleKeys.english.tr()),
            onTap: () {
              showChangeLanguageDialog(
                context,
                currentLanguageCode: LocalizationHelper.localCode(),
                onConfirm: (String code) async {
                  await widget.context.setLocale(Locale(code));
                  setState(() {
                    CacheHelper.setLang(code);
                  });
                  await _reopenHome();
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
                                size: 35.r,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
                child: _DrawerTitleText(
                  title: title,
                  denseLandscape: denseLandscape,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerTitleText extends StatelessWidget {
  const _DrawerTitleText({required this.title, this.denseLandscape = false});

  final String title;
  final bool denseLandscape;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return Text(
          title,
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: (denseLandscape ? 20 : 24).sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
            height: 1.2,
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
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryTextColor.withOpacity(0.85),
                    ),
                    children: [
                      TextSpan(
                        text: " : ",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTextColor.withOpacity(0.6),
                        ),
                      ),
                      TextSpan(
                        text: currentLanguage,
                        style: TextStyle(
                          fontSize: 20.sp,
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

enum MosqueLogoSource { defaultAsset, device }

class MosqueLogoRadioPicker extends StatefulWidget {
  const MosqueLogoRadioPicker({
    super.key,
    required this.defaultAssetPath,
    this.previewSize = 36,
    this.onChanged,
    this.mainAxisSize,
  });

  final String defaultAssetPath; // مثال: 'assets/images/mosque_logo.png'
  final double previewSize;
  final ValueChanged<String?>?
  onChanged; // null = default, otherwise custom path

  final MainAxisSize? mainAxisSize;
  @override
  State<MosqueLogoRadioPicker> createState() => _MosqueLogoRadioPickerState();
}

class _MosqueLogoRadioPickerState extends State<MosqueLogoRadioPicker> {
  MosqueLogoSource _source = MosqueLogoSource.defaultAsset;
  String? _customPath;

  @override
  void initState() {
    super.initState();
    _customPath = CacheHelper.getMosqueLogoPath();
    final hasCustom = _customPath != null && File(_customPath!).existsSync();
    _source = hasCustom
        ? MosqueLogoSource.device
        : MosqueLogoSource.defaultAsset;
  }

  Future<void> _pickFromGallery() async {
    final prevSource = _source;
    final prevPath = _customPath;

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1024,
    );

    if (!mounted) return;

    // ✅ المستخدم رجع بدون اختيار (Cancel/Back)
    if (picked == null) {
      setState(() {
        _source = prevSource;
        _customPath = prevPath;
      });
      return;
    }

    // ✅ خزّن نسخة داخل app storage عشان تفضل موجودة
    final dir = await getApplicationDocumentsDirectory();
    final ext = p.extension(picked.path).toLowerCase();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final savedPath = p.join(dir.path, 'mosque_logo_$ts$ext');

    await File(picked.path).copy(savedPath);

    await CacheHelper.setMosqueLogoPath(savedPath);

    setState(() {
      _source = MosqueLogoSource.device;
      _customPath = savedPath;
    });

    widget.onChanged?.call(savedPath);
  }

  Future<void> _useDefault() async {
    // اختياري: لو عايز تمسح الملف القديم
    final path = _customPath;
    if (path != null) {
      final f = File(path);
      if (await f.exists()) {
        await f.delete();
      }
    }
    await CacheHelper.clearMosqueLogoPath();

    setState(() {
      _source = MosqueLogoSource.defaultAsset;
      _customPath = null;
    });

    widget.onChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final hasCustom = _customPath != null && File(_customPath!).existsSync();

    return Column(
      mainAxisSize: widget.mainAxisSize ?? MainAxisSize.max,
      children: [
        CustomRadioTile<MosqueLogoSource>(
          padding: EdgeInsetsDirectional.zero,
          value: MosqueLogoSource.defaultAsset,
          groupValue: _source,
          radioSize: 22, // 👈 حجم الدايرة
          onTap: _useDefault,
          title: Text(
            LocaleKeys.default_app_logo.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryTextColor,
            ),
          ),
          trailing: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SvgPicture.asset(
              widget.defaultAssetPath,
              width: widget.previewSize.r,
              height: widget.previewSize.r,
              fit: BoxFit.contain,
            ),
          ),
        ),

        const VerticalSpace(height: 15),
        CustomRadioTile<MosqueLogoSource>(
          padding: EdgeInsetsDirectional.zero,

          value: MosqueLogoSource.device,
          groupValue: _source,
          radioSize: 22, // 👈 حجم الدايرة
          onTap: () async {
            // نفس سلوكك: أول ما تختارها يفتح الجاليري
            setState(() => _source = MosqueLogoSource.device);
            await _pickFromGallery();
          },
          title: Text(
            LocaleKeys.select_from_device.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryTextColor,
            ),
          ),
          trailing: hasCustom
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_customPath!),
                    width: widget.previewSize.r,
                    height: widget.previewSize.r,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  Icons.image,
                  size: widget.previewSize.r,
                  color: AppTheme.primaryTextColor,
                ),
        ),
      ],
    );
  }
}

class CustomRadioTile<T> extends StatelessWidget {
  const CustomRadioTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onTap,
    required this.title,
    this.subtitle,
    this.trailing,
    this.radioSize = 22,
    this.strokeWidth = 2,
    this.dotScale = 0.55,
    this.gap = 12,
    this.padding = const EdgeInsetsDirectional.symmetric(
      horizontal: 12,
      vertical: 10,
    ),
    this.radius = 14,
    this.selectedColor,
    this.unselectedColor,
    this.backgroundColor,
  });

  final T value;
  final T groupValue;
  final VoidCallback onTap;

  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;

  final double radioSize;
  final double strokeWidth;
  final double dotScale;
  final double gap;
  final EdgeInsetsDirectional padding;
  final double radius;

  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? backgroundColor;

  bool get _selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final sel = selectedColor ?? AppTheme.accentColor;
    final unsel =
        unselectedColor ?? AppTheme.primaryTextColor.withOpacity(0.35);

    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Padding(
          padding: padding.copyWith(
            start: padding.start.w,
            end: padding.end.w,
            top: padding.top.h,
            bottom: padding.bottom.h,
          ),
          child: Row(
            children: [
              RadioDot(
                selected: _selected,
                size: radioSize.r,
                strokeWidth: strokeWidth.w,
                dotScale: dotScale,
                selectedColor: sel,
                unselectedColor: unsel,
              ),
              HorizontalSpace(width: gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle.merge(
                      style: TextStyle(color: AppTheme.primaryTextColor),
                      child: title,
                    ),
                    if (subtitle != null) ...[
                      const VerticalSpace(height: 4),
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          color: AppTheme.primaryTextColor.withOpacity(0.7),
                          fontSize: 12.sp,
                        ),
                        child: subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[SizedBox(width: 10.h), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

class RadioDot extends StatelessWidget {
  const RadioDot({
    required this.selected,
    required this.size,
    required this.strokeWidth,
    required this.dotScale,
    required this.selectedColor,
    required this.unselectedColor,
  });

  final bool selected;
  final double size;
  final double strokeWidth;
  final double dotScale;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    final c = selected ? selectedColor : unselectedColor;

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c, width: strokeWidth),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: selected ? size * dotScale : 0,
            height: selected ? size * dotScale : 0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selectedColor,
            ),
          ),
        ),
      ),
    );
  }
}
