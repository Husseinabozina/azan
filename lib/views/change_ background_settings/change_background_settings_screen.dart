import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/native_orientation.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ===============================
/// BackgroundThemes: List of all backgrounds (same list you already use)
/// ===============================
class BackgroundThemes {
  static List<String> all = [
    Assets.images.home.path,
    Assets.images.backgroundBroundWithMosBird.path,
    Assets.images.backgroundLight2.path,
    Assets.images.backgroundOliveGreenWithMosq.path,
    Assets.images.backgroundGreenWith.path,

    Assets.images.awesomeBackground.path,
    Assets.images.awesome2.path,
    Assets.images.darkBrownBackground.path,
    Assets.images.lightBackground1.path,
    Assets.images.lightBrownBackground.path,
    Assets.images.brownBackground.path,
    Assets.images.background2.path,
    Assets.images.whiteBackgroundWithNaqsh.path,
    Assets.images.elegantTealArabesqueBackground.path,
    Assets.images.elegantBurgundyArabesqueBackground.path,
    Assets.images.convinentOliveGreenBackground.path,
    Assets.images.convinentBeigeBackground.path,
    Assets.images.tealBlueBackground.path,

    Assets.images.hr0.path,
    Assets.images.hr1.path,
    Assets.images.hr2.path,
    Assets.images.hr3.path,
    Assets.images.hr4.path,
    Assets.images.hr5.path,
    Assets.images.hr6.path,
    Assets.images.hr7.path,
    Assets.images.hr8.path,
    Assets.images.hr9.path,
    Assets.images.hr10.path,
    Assets.images.hr11.path,
    Assets.images.hr12.path,
    Assets.images.hr13.path,
    Assets.images.hr14.path,
    Assets.images.hr15.path,
    Assets.images.hr16.path,
    Assets.images.hr17.path,
    Assets.images.hr18.path,
    Assets.images.hr19.path,
    Assets.images.hr20.path,
    Assets.images.hr21.path,
    Assets.images.hr22.path,
    Assets.images.hr23.path,
    Assets.images.hr24.path,
    Assets.images.hr25.path,
    Assets.images.hr26.path,
    Assets.images.hr27.path,
    Assets.images.hr28.path,
    Assets.images.hr29.path,
    Assets.images.hr30.path,
    Assets.images.hr31.path,
    Assets.images.hr32.path,
    Assets.images.hr33.path,
    Assets.images.hr34.path,
    Assets.images.hr35.path,
    Assets.images.hr36.path,
    Assets.images.hr37.path,
    Assets.images.hr38.path,

    Assets.images.vr20.path,
    Assets.images.vr21.path,
    Assets.images.vr22.path,
    Assets.images.vr23.path,
    Assets.images.vr24.path,
    Assets.images.vr25.path,
    Assets.images.vr26.path,
    Assets.images.vr27.path,
  ];

  static int clampIndex(int i) {
    if (all.isEmpty) return 0;
    if (i < 0) return 0;
    if (i >= all.length) return all.length - 1;
    return i;
  }
}

/// ===============================
/// Screen
/// ===============================
class ChangeBackgroundSettingsScreen extends StatefulWidget {
  const ChangeBackgroundSettingsScreen({super.key});

  @override
  State<ChangeBackgroundSettingsScreen> createState() =>
      _ChangeBackgroundSettingsScreenState();
}

class _ChangeBackgroundSettingsScreenState
    extends State<ChangeBackgroundSettingsScreen> {
  late BackgroundChangeMode mode;
  late int themeIndex;

  late Map<String, int> perPrayer;
  late Map<String, int> perDay;
  late List<int> randomPool;

  late int _savedIndex; // الخلفية الفعلية الحالية (ثابتة)
  @override
  void initState() {
    super.initState();

    mode = CacheHelper.getBackgroundChangeMode();

    _savedIndex = BackgroundThemes.clampIndex(
      CacheHelper.getBackgroundThemeIndex(),
    );

    themeIndex = _savedIndex; // ✅ الـ preview يبدأ من المحفوظ

    perPrayer = CacheHelper.getBackgroundPerPrayerMap(
      fallback: {
        "isha": 4,
        "maghrib": 33,
        "asr": 16,
        "dhuhr": 0,
        "sunrise": 13,
        "fajr": 7,
      },
    );

    perDay = CacheHelper.getBackgroundPerDayMap(
      fallback: {
        "sun": 5,
        "mon": 8,
        "tue": 31,
        "wed": 16,
        "thu": 7,
        "fri": 3,
        "sat": 27,
      },
    );

    randomPool = CacheHelper.getBackgroundRandomPool(
      fallback: [4, 6, 8, 9, 18],
    );
  }

  void _persistAll() {
    CacheHelper.setBackgroundChangeMode(mode);
    CacheHelper.setBackgroundThemeIndex(themeIndex);
    CacheHelper.setBackgroundPerPrayerMap(perPrayer);
    CacheHelper.setBackgroundPerDayMap(perDay);
    CacheHelper.setBackgroundRandomPool(randomPool);
  }

  void _saveAndExit() {
    _savedIndex = themeIndex; // ✅ خلّي الفعلي يساوي الـ preview
    _persistAll();
    Navigator.pop(context);
  }

  void _cancelAndExit() {
    setState(() => themeIndex = _savedIndex); // ✅ رجّع preview
    Navigator.pop(context);
  }

  void _setMode(BackgroundChangeMode m) {
    setState(() => mode = m);
  }

  void _changeThemeIndex(int next) {
    setState(() => themeIndex = BackgroundThemes.clampIndex(next));
  }

  Future<void> _pickSingleTheme({
    required int current,
    required ValueChanged<int> onPick,
  }) async {
    final picked = await showDialog<int>(
      context: context,
      builder: (_) => ThemePickerDialog(
        current: current,
        count: BackgroundThemes.all.length,
      ),
    );
    if (picked != null) onPick(BackgroundThemes.clampIndex(picked));
  }

  Future<void> _pickMultiThemes({
    required List<int> current,
    required ValueChanged<List<int>> onPick,
  }) async {
    final picked = await showDialog<List<int>>(
      context: context,
      builder: (_) => ThemeMultiPickerDialog(
        current: current,
        count: BackgroundThemes.all.length,
      ),
    );
    if (picked != null) {
      final cleaned = picked.map(BackgroundThemes.clampIndex).toSet().toList()
        ..sort();
      onPick(cleaned);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = UiRotationCubit().isLandscape();

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            CacheHelper.getSelectedBackground(),
            fit: BoxFit.fill,
            height: 1.sh,
            width: 1.sw,
          ),
          // ✅ محتوى الصفحة
          isLandscape
              ? SingleChildScrollView(
                  child: SizedBox(
                    width: 1.sw,
                    child: Column(
                      children: [
                        TopBar(
                          title: "تغيير خلفية الشاشة",
                          onClose: () => Navigator.pop(context),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 10.h,
                            left: 10.w,
                            right: 10.w,
                            bottom: 10.h,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 52,
                                child: PanelScroll(
                                  child: LandscapeLeftPanel(
                                    mode: mode,
                                    onModeChanged: _setMode,
                                    themeIndex: themeIndex,
                                    onPrev: () =>
                                        _changeThemeIndex(themeIndex - 1),
                                    onNext: () =>
                                        _changeThemeIndex(themeIndex + 1),
                                    onPickTheme: () => _pickSingleTheme(
                                      current: themeIndex,
                                      onPick: (v) => _changeThemeIndex(v),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                flex: 48,
                                child: PanelScroll(
                                  child: LandscapeRightPanel(
                                    mode: mode,
                                    perPrayer: perPrayer,
                                    perDay: perDay,
                                    randomPool: randomPool,
                                    onPickPrayerTheme: (key, current) {
                                      _pickSingleTheme(
                                        current: current,
                                        onPick: (v) {
                                          setState(() {
                                            perPrayer[key] = v;
                                            // _persistAll();
                                          });
                                        },
                                      );
                                    },
                                    onPickDayTheme: (key, current) {
                                      _pickSingleTheme(
                                        current: current,
                                        onPick: (v) {
                                          setState(() {
                                            perDay[key] = v;
                                            // _persistAll();
                                          });
                                        },
                                      );
                                    },
                                    onPickRandomPool: () {
                                      _pickMultiThemes(
                                        current: randomPool,
                                        onPick: (list) {
                                          setState(() {
                                            randomPool = list;
                                            // _persistAll();
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: SaveCancelBar(
                            onSave: _saveAndExit,
                            onCancel: _cancelAndExit,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: SizedBox(
                    width: 1.sw,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TopBar(
                          title: "تغيير خلفية الشاشة",
                          onClose: () => Navigator.pop(context),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 10.h,
                            left: 10.w,
                            right: 10.w,
                            bottom: 14.h,
                          ),
                          child: PortraitContent(
                            onSave: _saveAndExit, // ✅
                            onCancel: _cancelAndExit,
                            mode: mode,
                            onModeChanged: _setMode,
                            themeIndex: themeIndex,
                            onPrev: () => _changeThemeIndex(themeIndex - 1),
                            onNext: () => _changeThemeIndex(themeIndex + 1),
                            onPickTheme: () => _pickSingleTheme(
                              current: themeIndex,
                              onPick: (v) => _changeThemeIndex(v),
                            ),
                            perPrayer: perPrayer,
                            perDay: perDay,
                            randomPool: randomPool,
                            onPickPrayerTheme: (key, current) {
                              _pickSingleTheme(
                                current: current,
                                onPick: (v) {
                                  setState(() {
                                    perPrayer[key] = v;
                                    // _persistAll();
                                  });
                                },
                              );
                            },
                            onPickDayTheme: (key, current) {
                              _pickSingleTheme(
                                current: current,
                                onPick: (v) {
                                  setState(() {
                                    perDay[key] = v;
                                    // _persistAll();
                                  });
                                },
                              );
                            },
                            onPickRandomPool: () {
                              _pickMultiThemes(
                                current: randomPool,
                                onPick: (list) {
                                  setState(() {
                                    randomPool = list;
                                    // _persistAll();
                                  });
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
      ),
    );
  }
}

/// ===============================
/// TopBar (uses your CustomAppbar style)
/// ===============================
class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    // ✅ هنا عدّل حسب CustomAppbar الحقيقي عندك
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 6.h),
        child: Row(
          children: [
            SizedBox(width: 10.w),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.menu, color: Colors.white, size: 26.r),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close, color: Colors.white, size: 26.r),
            ),
            SizedBox(width: 10.w),
          ],
        ),
      ),
    );
  }
}

class SaveCancelBar extends StatelessWidget {
  const SaveCancelBar({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = UiRotationCubit().isLandscape();

    final double h = isLandscape ? 50.h : 44.h;
    final double radius = isLandscape ? 14.r : 12.r;
    final double gap = isLandscape ? 14.w : 10.w;

    final TextStyle t = TextStyle(
      fontSize: isLandscape ? 16.sp : 14.sp,
      fontWeight: FontWeight.w800,
    );

    return Padding(
      padding: EdgeInsets.only(top: isLandscape ? 12.h : 8.h),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cancelButtonBackgroundColor,
                  foregroundColor: AppTheme.cancelButtonTextColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: isLandscape ? 10.h : 8.h,
                  ),
                  elevation: isLandscape ? 2 : 1,
                ),
                onPressed: onCancel,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("إلغاء", style: t),
                ),
              ),
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: SizedBox(
              height: h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryButtonBackground,
                  foregroundColor: AppTheme.primaryButtonTextColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: isLandscape ? 10.h : 8.h,
                  ),
                  elevation: isLandscape ? 2 : 1,
                ),
                onPressed: onSave,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("حفظ", style: t),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// Portrait Content (non-private)
/// ===============================
///

class PortraitContent extends StatelessWidget {
  const PortraitContent({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.themeIndex,
    required this.onPrev,
    required this.onNext,
    required this.onPickTheme,
    required this.perPrayer,
    required this.perDay,
    required this.randomPool,
    required this.onPickPrayerTheme,
    required this.onPickDayTheme,
    required this.onPickRandomPool,
    required this.onSave, // ✅
    required this.onCancel,
  });
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final BackgroundChangeMode mode;
  final ValueChanged<BackgroundChangeMode> onModeChanged;

  final int themeIndex;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPickTheme;

  final Map<String, int> perPrayer;
  final Map<String, int> perDay;
  final List<int> randomPool;

  final void Function(String key, int current) onPickPrayerTheme;
  final void Function(String key, int current) onPickDayTheme;
  final VoidCallback onPickRandomPool;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackgroundPreviewSelector(
          themeIndex: themeIndex,
          onPrev: onPrev,
          onNext: onNext,
          onTapPreview: onPickTheme,
        ),
        SizedBox(height: 10.h),

        BackgroundModeSection(mode: mode, onChanged: onModeChanged),
        SizedBox(height: 10.h),

        if (mode == BackgroundChangeMode.perPrayer)
          PrayerThemesRow(values: perPrayer, onTapItem: onPickPrayerTheme),

        if (mode == BackgroundChangeMode.perDay)
          DayThemesRow(values: perDay, onTapItem: onPickDayTheme),

        if (mode == BackgroundChangeMode.randomPool)
          RandomPoolSection(pool: randomPool, onTapPool: onPickRandomPool),

        VerticalSpace(height: 10.h),

        SaveCancelBar(onSave: onSave, onCancel: onCancel),
      ],
    );
  }
}

/// ===============================
/// Landscape panels (non-private)
/// ===============================
class LandscapeLeftPanel extends StatelessWidget {
  const LandscapeLeftPanel({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.themeIndex,
    required this.onPrev,
    required this.onNext,
    required this.onPickTheme,
  });

  final BackgroundChangeMode mode;
  final ValueChanged<BackgroundChangeMode> onModeChanged;

  final int themeIndex;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPickTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackgroundPreviewSelector(
          themeIndex: themeIndex,
          onPrev: onPrev,
          onNext: onNext,
          onTapPreview: onPickTheme,
        ),
        SizedBox(height: 12.h),
        BackgroundModeSection(mode: mode, onChanged: onModeChanged),
      ],
    );
  }
}

class LandscapeRightPanel extends StatelessWidget {
  const LandscapeRightPanel({
    super.key,
    required this.mode,
    required this.perPrayer,
    required this.perDay,
    required this.randomPool,
    required this.onPickPrayerTheme,
    required this.onPickDayTheme,
    required this.onPickRandomPool,
  });

  final BackgroundChangeMode mode;
  final Map<String, int> perPrayer;
  final Map<String, int> perDay;
  final List<int> randomPool;

  final void Function(String key, int current) onPickPrayerTheme;
  final void Function(String key, int current) onPickDayTheme;
  final VoidCallback onPickRandomPool;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (mode == BackgroundChangeMode.perPrayer)
          PrayerThemesRow(values: perPrayer, onTapItem: onPickPrayerTheme),
        if (mode == BackgroundChangeMode.perDay)
          DayThemesRow(values: perDay, onTapItem: onPickDayTheme),
        if (mode == BackgroundChangeMode.randomPool)
          RandomPoolSection(pool: randomPool, onTapPool: onPickRandomPool),
      ],
    );
  }
}

class PanelScroll extends StatelessWidget {
  const PanelScroll({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: child,
    );
  }
}

/// ===============================
/// Preview selector (square + number + 2 arrows)
/// ===============================
class BackgroundPreviewSelector extends StatelessWidget {
  const BackgroundPreviewSelector({
    super.key,
    required this.themeIndex,
    required this.onPrev,
    required this.onNext,
    required this.onTapPreview,
  });

  final int themeIndex;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onTapPreview;

  @override
  Widget build(BuildContext context) {
    final r = 12.r;

    return Row(
      children: [
        // small square preview
        InkWell(
          onTap: onTapPreview,
          borderRadius: BorderRadius.circular(r),
          child: SizedBox(
            width: 50.r,
            height: 70.r,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ✅ Shadow + Clip للصورة
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(r),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                        color: Colors.black.withOpacity(0.25),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(r),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          BackgroundThemes.all[themeIndex],
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ Border فوق الكل (Overlay)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.28),
                          width: 1.5.w,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: 10.w),

        Text(
          "$themeIndex",
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),

        const Spacer(),

        IconButton(
          onPressed: onPrev,
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18.r),
        ),
        IconButton(
          onPressed: onNext,
          icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18.r),
        ),
      ],
    );
  }
}

/// ===============================
/// Radio modes section
/// ===============================
class BackgroundModeSection extends StatelessWidget {
  const BackgroundModeSection({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final BackgroundChangeMode mode;
  final ValueChanged<BackgroundChangeMode> onChanged;

  TextStyle get _t => TextStyle(color: Colors.white, fontSize: 15.sp);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _radio(
          title: "تغيير الخلفية يدوياً",
          value: BackgroundChangeMode.manual,
        ),
        _radio(
          title: "تغيير الخلفية عند كل صلاة",
          subtitle: "(Click on prayer to change)",
          value: BackgroundChangeMode.perPrayer,
        ),
        _radio(
          title: "تغيير الخلفية كل يوم",
          subtitle: "(Click on the day to change)",
          value: BackgroundChangeMode.perDay,
        ),
        _radio(
          title: "تغيير الخلفية كل يوم بشكل عشوائي من هذه القائمة:",
          subtitle: "(Click on themes numbers to change)",
          value: BackgroundChangeMode.randomPool,
        ),
      ],
    );
  }

  Widget _radio({
    required String title,
    String? subtitle,
    required BackgroundChangeMode value,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Radio<BackgroundChangeMode>(
              value: value,
              groupValue: mode,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              activeColor: Colors.white,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _t.copyWith(fontWeight: FontWeight.w700)),
                  if (subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        subtitle,
                        style: _t.copyWith(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// Prayer themes row
/// ===============================
class PrayerThemesRow extends StatelessWidget {
  const PrayerThemesRow({
    super.key,
    required this.values,
    required this.onTapItem,
  });

  final Map<String, int> values;
  final void Function(String key, int current) onTapItem;

  @override
  Widget build(BuildContext context) {
    final items = <_MiniSelectItem>[
      _MiniSelectItem(keyId: "isha", label: "العشاء"),
      _MiniSelectItem(keyId: "maghrib", label: "المغرب"),
      _MiniSelectItem(keyId: "asr", label: "العصر"),
      _MiniSelectItem(keyId: "dhuhr", label: "الظهر"),
      _MiniSelectItem(keyId: "sunrise", label: "الشروق"),
      _MiniSelectItem(keyId: "fajr", label: "الفجر"),
    ];

    return _RowWithDividers(
      title: "",
      items: items.map((e) {
        final v = values[e.keyId] ?? 0;
        return _MiniSelectBox(
          label: e.label,
          value: v,
          onTap: () => onTapItem(e.keyId, v),
        );
      }).toList(),
    );
  }
}

/// ===============================
/// Day themes row
/// ===============================
class DayThemesRow extends StatelessWidget {
  const DayThemesRow({
    super.key,
    required this.values,
    required this.onTapItem,
  });

  final Map<String, int> values;
  final void Function(String key, int current) onTapItem;

  @override
  Widget build(BuildContext context) {
    final items = <_MiniSelectItem>[
      _MiniSelectItem(keyId: "sun", label: "الأحد"),
      _MiniSelectItem(keyId: "mon", label: "الإثنين"),
      _MiniSelectItem(keyId: "tue", label: "الثلاثاء"),
      _MiniSelectItem(keyId: "wed", label: "الأربعاء"),
      _MiniSelectItem(keyId: "thu", label: "الخميس"),
      _MiniSelectItem(keyId: "fri", label: "الجمعة"),
      _MiniSelectItem(keyId: "sat", label: "السبت"),
    ];

    return _RowWithDividers(
      title: "",
      items: items.map((e) {
        final v = values[e.keyId] ?? 0;
        return _MiniSelectBox(
          label: e.label,
          value: v,
          onTap: () => onTapItem(e.keyId, v),
        );
      }).toList(),
    );
  }
}

/// ===============================
/// Random pool section
/// ===============================
class RandomPoolSection extends StatelessWidget {
  const RandomPoolSection({
    super.key,
    required this.pool,
    required this.onTapPool,
  });

  final List<int> pool;
  final VoidCallback onTapPool;

  @override
  Widget build(BuildContext context) {
    final text = pool.isEmpty ? "-" : pool.join(",");

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: InkWell(
        onTap: onTapPool,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.22),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Text(
            text,
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// ===============================
/// Shared: row with vertical dividers
/// ===============================
class _RowWithDividers extends StatelessWidget {
  const _RowWithDividers({required this.title, required this.items});

  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.22),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _withDividers(items),
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> children) {
    final out = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      out.add(Expanded(child: children[i]));
      if (i != children.length - 1) {
        out.add(
          Container(
            width: 1,
            height: 28.h,
            color: Colors.white.withOpacity(0.15),
          ),
        );
      }
    }
    return out;
  }
}

class _MiniSelectItem {
  final String keyId;
  final String label;
  _MiniSelectItem({required this.keyId, required this.label});
}

class _MiniSelectBox extends StatelessWidget {
  const _MiniSelectBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final int value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "$value",
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// Dialog: Single theme picker
/// ===============================
class ThemePickerDialog extends StatelessWidget {
  const ThemePickerDialog({
    super.key,
    required this.current,
    required this.count,
  });

  final int current;
  final int count;

  @override
  Widget build(BuildContext context) {
    final r = 10.r;

    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.9),
      title: Text(
        "اختر رقم الخلفية",
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
      ),
      content: SizedBox(
        width: 0.85.sw,
        height: 0.55.sh,
        child: GridView.builder(
          itemCount: count,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
          ),
          itemBuilder: (context, i) {
            final bool selected = i == current;
            return InkWell(
              onTap: () => Navigator.pop(context, i),
              borderRadius: BorderRadius.circular(r),
              child: SizedBox(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // ✅ الصورة + overlay داخل Clip
                    ClipRRect(
                      borderRadius: BorderRadius.circular(r),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            BackgroundThemes.all[i],
                            fit: BoxFit.cover,
                          ),

                          // overlay لتثبيت القراءة فوق أي خلفية
                          Container(
                            color: Colors.black.withOpacity(
                              selected ? 0.15 : 0.35,
                            ),
                          ),

                          Center(
                            child: Text(
                              "$i",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14.sp,
                                shadows: const [
                                  Shadow(blurRadius: 10, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ✅ بوردر فوق كل حاجة (Overlay)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(r),
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                selected ? 0.9 : 0.16,
                              ),
                              width: selected ? 2.2 : 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ✅ Glow بسيط لو selected (اختياري لكن شكله جامد)
                    if (selected)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(r),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                  color: Colors.white.withOpacity(0.18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "إلغاء",
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
        ),
      ],
    );
  }
}

/// ===============================
/// Dialog: Multi theme picker (random pool)
/// ===============================
class ThemeMultiPickerDialog extends StatefulWidget {
  const ThemeMultiPickerDialog({
    super.key,
    required this.current,
    required this.count,
  });

  final List<int> current;
  final int count;

  @override
  State<ThemeMultiPickerDialog> createState() => _ThemeMultiPickerDialogState();
}

class _ThemeMultiPickerDialogState extends State<ThemeMultiPickerDialog> {
  late Set<int> selected;

  @override
  void initState() {
    super.initState();
    selected = widget.current.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.9),
      title: Text(
        "اختر ثيمات العشوائي",
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
      ),
      content: SizedBox(
        width: 0.85.sw,
        height: 0.55.sh,
        child: GridView.builder(
          itemCount: widget.count,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
          ),
          itemBuilder: (context, i) {
            final bool isOn = selected.contains(i);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isOn) {
                    selected.remove(i);
                  } else {
                    selected.add(i);
                  }
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isOn ? Colors.white : Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(isOn ? 0.8 : 0.15),
                  ),
                ),
                child: Text(
                  "$i",
                  style: TextStyle(
                    color: isOn ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "إلغاء",
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, selected.toList()..sort()),
          child: Text("حفظ", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
