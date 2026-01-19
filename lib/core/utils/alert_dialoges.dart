import 'dart:math' as math;

import 'package:azan/core/components/appbutton.dart';
import 'package:azan/core/components/custom_text_field.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/models/dhikr_schedule.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/adhkar/components/dhikr_from_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ============================================================================
/// ✅ Shared helpers (PRIVATE) — لا تغيّر أي calls في ملفات تانية.
/// ============================================================================

bool _isLandscape(BuildContext context) =>
    MediaQuery.of(context).orientation == Orientation.landscape;

/// عرض الديالوج: cap محترم للشاشات الكبيرة (خصوصًا لاندسكيب)
double _dialogMaxWidth(BuildContext context) {
  // 90% من العرض، بس لا يزيد عن قيمة UX مناسبة للشاشات الكبيرة
  // (لو عندك TV/LED شاشات كبيرة جدًا، الكاب ده مهم جدًا)
  final max = _isLandscape(context) ? 680.0 : 560.0;
  return (0.90.sw).clamp(300.0.w, max.w);
}

/// أقصى ارتفاع: cap فقط (مش fill)
double _dialogMaxHeight(BuildContext context) {
  final max = _isLandscape(context) ? (0.88.sh) : (0.75.sh);
  return max.clamp(320.0.h, 760.0.h);
}

EdgeInsets _shellInset(BuildContext context) {
  return EdgeInsets.symmetric(horizontal: (_isLandscape(context) ? 14 : 20).w);
}

EdgeInsets _shellPadding(BuildContext context) {
  return EdgeInsets.symmetric(
    horizontal: (_isLandscape(context) ? 16 : 20).w,
    vertical: (_isLandscape(context) ? 8 : 10).w,
  );
}

double _gap(
  BuildContext context, {
  double portrait = 20,
  double landscape = 12,
}) {
  return (_isLandscape(context) ? landscape : portrait).h;
}

/// نفس شكل الديالوج عندك (خلفية شفافة + كونتينر بنفس الديكور)
/// ✅ الآن:
/// - Keyboard-aware (AnimatedPadding with viewInsets)
/// - SafeArea-aware (use MediaQuery padding)
/// - Caps max size without forcing full height
class _DialogShell extends StatelessWidget {
  const _DialogShell({
    required this.child,
    this.maxHeight,
    this.forceMaxHeight = false,
  });

  final Widget child;

  /// لو عايز تفرض MaxHeight (مفيد للحاجات اللي ممكن تطوّل)
  /// NOTE: we cap maxHeight only; we never force fill height.
  final double? maxHeight;
  final bool forceMaxHeight;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    // مساحة الشاشة الحقيقية بعد SafeArea
    final safeW = mq.size.width - mq.padding.left - mq.padding.right;
    final safeH = mq.size.height - mq.padding.top - mq.padding.bottom;

    // المساحة المتاحة بعد ظهور الكيبورد
    final availableH = safeH - mq.viewInsets.bottom;

    // Width cap (UX) — لا تملأ الشاشة في اللاندسكيب الكبير
    final w = (safeW * 0.90)
        .clamp(300.0, _isLandscape(context) ? 680.0 : 560.0)
        .w;

    // Height cap — cap فقط
    final hCap =
        (maxHeight ?? (availableH * (_isLandscape(context) ? 0.88 : 0.75)))
            .clamp(320.0, 760.0)
            .h;

    final body = Container(
      width: w,
      padding: _shellPadding(context),
      decoration: BoxDecoration(
        color: AppTheme.dialogBackgroundColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: _shellInset(context),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: w,
            // لو forceMaxHeight true: نحط maxHeight cap فقط
            maxHeight: forceMaxHeight ? hCap : double.infinity,
          ),
          child: body,
        ),
      ),
    );
  }
}

Widget _dialogTitle(String title) {
  return Text(
    title,
    style: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
      color: AppTheme.dialogTitleColor,
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.center,
  );
}

Widget _whiteTextField({
  required TextEditingController controller,
  required String hint,
  int maxLines = 1,
  TextAlign textAlign = TextAlign.right,
  double fontSizeSp = 12,
}) {
  return TextField(
    controller: controller,
    textAlign: textAlign,
    maxLines: maxLines,
    style: TextStyle(color: Colors.black, fontSize: fontSizeSp.sp),
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.r),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.text,
    required this.onPressed,
    required this.bg,
    required this.fg,
    this.widthW = 90,
    this.heightH = 40,
    this.fontSizeSp = 12,
    this.weight = FontWeight.w600,
  });

  final String text;
  final VoidCallback onPressed;
  final Color bg;
  final Color fg;

  final double widthW;
  final double heightH;
  final double fontSizeSp;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widthW.w,
      height: heightH.h,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: fg,
            fontWeight: weight,
            fontSize: fontSizeSp.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

Widget _twoButtonsRow({required Widget left, required Widget right}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      left,
      SizedBox(width: 12.w),
      right,
    ],
  );
}

/// ============================================================================
/// ✅ Dialogs (نفس signatures القديمة تمامًا)
/// ============================================================================

Future<void> showEditMosqueNameDialog(
  BuildContext context, {
  String? initialName,
  required ValueChanged<String> onConfirm,
  required R r,
}) async {
  final controller = TextEditingController(text: initialName ?? '');

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Center(
        child: _DialogShell(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogTitle(LocaleKeys.edit_mosque_name.tr()),
              SizedBox(height: _gap(context)),
              _whiteTextField(
                controller: controller,
                hint: LocaleKeys.mosque_name_label.tr(),
                maxLines: 1,
                fontSizeSp: 12,
              ),
              SizedBox(height: _gap(context)),
              _twoButtonsRow(
                left: _DialogButton(
                  text: LocaleKeys.common_cancel.tr(),
                  bg: AppTheme.cancelButtonBackgroundColor,
                  fg: AppTheme.cancelButtonTextColor,
                  widthW: 90,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                right: _DialogButton(
                  text: LocaleKeys.common_ok.tr(),
                  bg: AppTheme.primaryButtonBackground,
                  fg: AppTheme.primaryButtonTextColor,
                  widthW: 90,
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      onConfirm(text);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showEditNotificationMessageDialog(
  BuildContext context, {
  String? initialText,
  required ValueChanged<String> onConfirm,
}) async {
  final controller = TextEditingController(text: initialText ?? '');

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Center(
        child: _DialogShell(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogTitle(LocaleKeys.edit_nofication_message.tr()),
              SizedBox(height: _gap(context)),
              _whiteTextField(
                controller: controller,
                hint: LocaleKeys.notification_message.tr(),
                maxLines: 1,
                fontSizeSp: 12,
              ),
              SizedBox(height: _gap(context)),
              _twoButtonsRow(
                left: _DialogButton(
                  text: LocaleKeys.common_cancel.tr(),
                  bg: AppTheme.cancelButtonBackgroundColor,
                  fg: AppTheme.cancelButtonTextColor,
                  widthW: 90,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                right: _DialogButton(
                  text: LocaleKeys.common_ok.tr(),
                  bg: AppTheme.primaryButtonBackground,
                  fg: AppTheme.primaryButtonTextColor,
                  widthW: 90,
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      onConfirm(text);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// ✅ AddDhikr
/// - dialog shrinks to content when possible
/// - cap height only
/// - scroll only the form area
Future<void> showAddDhikrDialog(
  BuildContext context, {
  required void Function(String text, DhikrSchedule? schedule) onConfirm,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Center(
        child: _DialogShell(
          forceMaxHeight: true,
          maxHeight: _dialogMaxHeight(context),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ لا تمدد
            children: [
              _dialogTitle(LocaleKeys.dhikr_add_to_mosque.tr()),
              SizedBox(height: _gap(context, portrait: 12, landscape: 8)),

              /// ✅ بدل Expanded (اللي كان بيعمل dialog كبير حتى لو الفورم صغير)
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: DhikrFormWidget(
                    onSubmit: (text, schedule) {
                      onConfirm(text, schedule);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),

              SizedBox(height: _gap(context, portrait: 12, landscape: 8)),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool?> showDeleteDhikrDialog(
  BuildContext context, {
  String? dhikrText,
  required void Function() onConfirm,
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Center(
        child: _DialogShell(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogTitle(LocaleKeys.dhikr_delete_title.tr()),
              SizedBox(height: _gap(context, portrait: 16, landscape: 12)),
              Text(
                dhikrText == null || dhikrText.isEmpty
                    ? LocaleKeys.dhikr_delete_confirm_message.tr()
                    : '${LocaleKeys.dhikr_delete_confirm_message.tr()}\n\n"$dhikrText"',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.white),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: _gap(context, portrait: 18, landscape: 12)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DialogButton(
                    text: LocaleKeys.common_cancel.tr(),
                    bg: AppTheme.cancelButtonBackgroundColor,
                    fg: AppTheme.cancelButtonTextColor,
                    widthW: 100,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  SizedBox(width: 12.w),
                  _DialogButton(
                    text: LocaleKeys.delete.tr(),
                    bg: const Color(0xFFE57373),
                    fg: Colors.white,
                    widthW: 100,
                    weight: FontWeight.w700,
                    onPressed: () {
                      onConfirm();
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// ✅ EditDhikr
/// - لا نمدد الديالوج
/// - cap height فقط
/// - الجزء اللي ممكن يطوّل: Flexible + Scroll
Future<void> showEditDhikrDialog(
  BuildContext context, {
  required String initialText,
  required ValueChanged<String> onConfirm,
}) async {
  final controller = TextEditingController(text: initialText);

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Center(
        child: _DialogShell(
          forceMaxHeight: true,
          maxHeight: _dialogMaxHeight(context),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ بدل max
            children: [
              _dialogTitle(LocaleKeys.dhikr_edit_title.tr()),
              SizedBox(height: _gap(context)),

              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.right,
                    maxLines: _isLandscape(context) ? 3 : 4,
                    style: TextStyle(color: Colors.black, fontSize: 13.sp),
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: LocaleKeys.dhikr_text_label.tr(),
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: const BorderSide(
                          color: Color(0xFFF4C66A),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: _gap(context)),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DialogButton(
                    text: LocaleKeys.common_cancel.tr(),
                    bg: AppTheme.cancelButtonBackgroundColor,
                    fg: AppTheme.cancelButtonTextColor,
                    widthW: 100,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 12.w),
                  _DialogButton(
                    text: LocaleKeys.common_ok.tr(),
                    bg: AppTheme.primaryButtonBackground,
                    fg: AppTheme.primaryButtonTextColor,
                    widthW: 100,
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        onConfirm(text);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showChangeLanguageDialog(
  BuildContext context, {
  required String currentLanguageCode,
  required ValueChanged<String> onConfirm,
}) async {
  String selectedLang = currentLanguageCode;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Center(
        child: _DialogShell(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogTitle(LocaleKeys.language.tr()),
                  SizedBox(height: _gap(context)),

                  InkWell(
                    borderRadius: BorderRadius.circular(14.r),
                    onTap: () => setState(() => selectedLang = 'ar'),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: selectedLang == 'ar'
                            ? Colors.white.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedLang == 'ar'
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: AppTheme.dialogTitleColor,
                            size: 20.sp,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            LocaleKeys.arabic.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  InkWell(
                    borderRadius: BorderRadius.circular(14.r),
                    onTap: () => setState(() => selectedLang = 'en'),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: selectedLang == 'en'
                            ? Colors.white.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedLang == 'en'
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: AppTheme.dialogTitleColor,
                            size: 20.sp,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            LocaleKeys.english.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: _gap(context)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _DialogButton(
                        text: LocaleKeys.common_cancel.tr(),
                        bg: AppTheme.cancelButtonBackgroundColor,
                        fg: AppTheme.cancelButtonTextColor,
                        widthW: 100,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(width: 12.w),
                      _DialogButton(
                        text: LocaleKeys.common_ok.tr(),
                        bg: AppTheme.primaryButtonBackground,
                        fg: AppTheme.primaryButtonTextColor,
                        widthW: 100,
                        onPressed: () {
                          onConfirm(selectedLang);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

Future<void> showChangeBackgroundDialog(
  BuildContext context, {
  required List<String> backgrounds,
  required String currentBackground,
  required ValueChanged<String> onConfirm,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Center(
        child: _DialogShell(
          forceMaxHeight: true,
          maxHeight: _dialogMaxHeight(context),
          child: _BackgroundPickerContent(
            backgrounds: backgrounds,
            initialBackground: currentBackground,
            onConfirm: onConfirm,
          ),
        ),
      );
    },
  );
}

class _BackgroundPickerContent extends StatefulWidget {
  final List<String> backgrounds;
  final String initialBackground;
  final ValueChanged<String> onConfirm;

  const _BackgroundPickerContent({
    Key? key,
    required this.backgrounds,
    required this.initialBackground,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<_BackgroundPickerContent> createState() =>
      _BackgroundPickerContentState();
}

class _BackgroundPickerContentState extends State<_BackgroundPickerContent> {
  late String _selectedBackground;

  @override
  void initState() {
    super.initState();
    _selectedBackground = widget.initialBackground;
  }

  @override
  Widget build(BuildContext context) {
    final thumbH = _isLandscape(context) ? 150.h : 180.h;

    return Column(
      mainAxisSize: MainAxisSize.min, // ✅ بدل max عشان مايمدش الديالوج
      children: [
        _dialogTitle(LocaleKeys.choose_app_wallpaper.tr()),
        SizedBox(height: _gap(context, portrait: 16, landscape: 10)),

        SizedBox(
          height: thumbH,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.backgrounds.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final path = widget.backgrounds[index];
              final isSelected = path == _selectedBackground;

              return GestureDetector(
                onTap: () => setState(() => _selectedBackground = path),
                child: Container(
                  width: _isLandscape(context) ? 120.w : 110.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.dialogTitleColor
                          : Colors.white.withOpacity(0.3),
                      width: isSelected ? 3.w : 1.w,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: Image.asset(path, fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: _gap(context, portrait: 16, landscape: 10)),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _DialogButton(
              text: LocaleKeys.common_cancel.tr(),
              bg: AppTheme.cancelButtonBackgroundColor,
              fg: AppTheme.cancelButtonTextColor,
              widthW: 100,
              onPressed: () => Navigator.of(context).pop(),
            ),
            SizedBox(width: 12.w),
            _DialogButton(
              text: LocaleKeys.common_save.tr(),
              bg: AppTheme.primaryButtonBackground,
              fg: AppTheme.primaryTextColor,
              widthW: 100,
              onPressed: () {
                widget.onConfirm(_selectedBackground);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// ============================================================================
/// ✅ pickTime() — ثابت + بدون hacks.
/// ============================================================================

Future<TimeOfDay?> pickTime(BuildContext context) async {
  return await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (context, child) {
      final baseTheme = Theme.of(context);

      double fs(double v) => v.sp;
      EdgeInsets btnPad() =>
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h);

      final dialogBg = AppTheme.dialogBackgroundColor;

      double _lin(Color c) {
        double ch(int v) {
          final s = v / 255.0;
          return (s <= 0.03928)
              ? (s / 12.92)
              : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
        }

        return 0.2126 * ch(c.red) + 0.7152 * ch(c.green) + 0.0722 * ch(c.blue);
      }

      double _contrast(Color a, Color b) {
        final l1 = _lin(a);
        final l2 = _lin(b);
        final bright = l1 > l2 ? l1 : l2;
        final dark = l1 > l2 ? l2 : l1;
        return (bright + 0.05) / (dark + 0.05);
      }

      Color _onFor(Color bg) {
        final br = ThemeData.estimateBrightnessForColor(bg);
        return br == Brightness.dark
            ? const Color(0xFFF5F7FA)
            : const Color(0xFF121212);
      }

      Color _ensureContrast(Color fg, Color bg, {double min = 4.5}) {
        if (_contrast(fg, bg) >= min) return fg;
        return _onFor(bg);
      }

      final onDialog = _ensureContrast(_onFor(dialogBg), dialogBg, min: 7.0);
      final onDialogMuted = _ensureContrast(
        onDialog.withOpacity(0.78),
        dialogBg,
        min: 4.5,
      );

      final accent = AppTheme.primaryButtonBackground;
      final onAccent = _ensureContrast(_onFor(accent), accent, min: 4.5);

      Color _surfaceTint(double opacity) =>
          Color.alphaBlend(onDialog.withOpacity(opacity), dialogBg);

      final timePickerTheme = TimePickerThemeData(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(12.w),
        helpTextStyle: TextStyle(
          fontSize: fs(12),
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: onDialogMuted,
          fontFamily: CacheHelper.getTimesFontFamily(),
        ),
        timeSelectorSeparatorTextStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: fs(12),
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: onDialogMuted,
            fontFamily: CacheHelper.getTimesFontFamily(),
          ),
        ),
        hourMinuteTextStyle: TextStyle(
          fontSize: fs(26),
          fontWeight: FontWeight.bold,
          height: 1.1,
          color: onDialog,
          fontFamily: CacheHelper.getTimesFontFamily(),
        ),
        hourMinuteColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Color.alphaBlend(accent.withOpacity(0.22), dialogBg);
          }
          return _surfaceTint(0.06);
        }),
        dayPeriodTextStyle: TextStyle(
          fontSize: fs(12),
          fontWeight: FontWeight.w800,
          height: 1.1,
          color: onDialog,
          fontFamily: CacheHelper.getTimesFontFamily(),
        ),
        dayPeriodColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Color.alphaBlend(accent.withOpacity(0.22), dialogBg);
          }
          return _surfaceTint(0.06);
        }),
        dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return onDialog;
          return onDialogMuted;
        }),
        dayPeriodShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        dialBackgroundColor: _surfaceTint(0.08),
        dialHandColor: accent,
        dialTextStyle: TextStyle(
          fontSize: fs(12),
          fontWeight: FontWeight.w700,
          fontFamily: CacheHelper.getTimesFontFamily(),
        ),
        dialTextColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return onAccent;
          return _ensureContrast(
            onDialog.withOpacity(0.80),
            _surfaceTint(0.08),
            min: 4.5,
          );
        }),
        entryModeIconColor: accent,
        cancelButtonStyle: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontSize: fs(14),
              fontWeight: FontWeight.bold,
              fontFamily: CacheHelper.getTimesFontFamily(),
            ),
          ),
          padding: WidgetStatePropertyAll(btnPad()),
          foregroundColor: WidgetStatePropertyAll(
            _ensureContrast(accent, dialogBg, min: 3.0),
          ),
        ),
        confirmButtonStyle: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontSize: fs(14),
              fontWeight: FontWeight.bold,
              fontFamily: CacheHelper.getTimesFontFamily(),
            ),
          ),
          padding: WidgetStatePropertyAll(btnPad()),
          foregroundColor: WidgetStatePropertyAll(
            _ensureContrast(accent, dialogBg, min: 3.0),
          ),
        ),
      );

      return Theme(
        data: baseTheme.copyWith(
          dialogBackgroundColor: dialogBg,
          timePickerTheme: timePickerTheme,
          colorScheme: baseTheme.colorScheme.copyWith(
            primary: accent,
            onPrimary: onAccent,
            surface: dialogBg,
            onSurface: onDialog,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: (0.9.sw).clamp(280.0.w, 520.0.w),
              maxHeight: (_isLandscape(context) ? 0.88.sh : 0.75.sh).clamp(
                360.0.h,
                680.0.h,
              ),
            ),
            child: child!,
          ),
        ),
      );
    },
  );
}

/// ============================================================================
/// ✅ Eid Dialogs — نفس signatures.
/// ============================================================================

Future<void> showAddEidDialog(
  String title,
  BuildContext context, {
  required void Function(DateTime date, TimeOfDay time) onConfirm,
  required void Function() onCancel,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AddEidDialog(onConfirm: onConfirm, title: title),
  );
}

class AddEidDialog extends StatefulWidget {
  const AddEidDialog({super.key, required this.onConfirm, required this.title});
  final void Function(DateTime date, TimeOfDay time) onConfirm;
  final String title;

  @override
  State<AddEidDialog> createState() => _AddEidDialogState();
}

class _AddEidDialogState extends State<AddEidDialog> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  DateTime? date;
  TimeOfDay? time;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _DialogShell(
        forceMaxHeight: true,
        maxHeight: _dialogMaxHeight(context),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ shrink-wrap
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: CacheHelper.getTimesFontFamily(),
                color: AppTheme.accentColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: _gap(context)),

            /// ✅ بدل Expanded (اللي كان بيملأ ارتفاع الديالوج)
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: dateController,
                      readOnly: true,
                      suffixIcon: Icon(
                        Icons.calendar_month,
                        color: AppTheme.primaryTextColor,
                      ),
                      hintText: LocaleKeys.date.tr(),
                      onTap: () async {
                        " date  : ${dateController.text}".log();
                        date = await showCustomDatePicker(
                          DateTime.now(),
                          context,
                        );
                        if (date != null) {
                          setState(() {
                            dateController.text = DateFormat(
                              'yyyy-MM-dd',
                            ).format(date!);
                            " date  : ${dateController.text}".log();
                          });
                        }
                      },
                    ),
                    VerticalSpace(height: 10),
                    CustomTextField(
                      controller: timeController,
                      readOnly: true,
                      suffixIcon: Icon(
                        Icons.access_time,
                        color: AppTheme.primaryTextColor,
                      ),
                      hintText: LocaleKeys.time.tr(),
                      onTap: () async {
                        time = await pickTime(context);
                        if (time != null) {
                          setState(
                            () => timeController.text = time!.format(context),
                          );
                        }
                      },
                    ),
                    VerticalSpace(height: 12),
                    AppButton(
                      color: AppTheme.accentColor,
                      onPressed: () {
                        if (date != null && time != null) {
                          widget.onConfirm(date!, time!);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        LocaleKeys.common_save.tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<DateTime?> showCustomDatePicker(DateTime now, BuildContext context) {
  final size = MediaQuery.of(context).size;

  final scaleFactor = (size.width / 390).clamp(0.9, 1.8);
  double responsiveFontSize(double baseSize) {
    return (baseSize * scaleFactor).clamp(baseSize * 0.8, baseSize * 1.5);
  }

  return showDatePicker(
    context: context,
    firstDate: DateTime(now.year - 1),
    lastDate: DateTime(now.year + 5),
    initialDate: now,
    locale: Locale(context.locale.languageCode),
    builder: (context, child) {
      final baseTheme = Theme.of(context);

      final datePickerTheme = DatePickerThemeData(
        backgroundColor: AppTheme.dialogBackgroundColor,
        headerBackgroundColor: AppTheme.dialogBackgroundColor,
        headerForegroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        headerHeadlineStyle: TextStyle(
          fontSize: responsiveFontSize(20),
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.2,
        ),
        headerHelpStyle: TextStyle(
          fontSize: responsiveFontSize(12),
          fontWeight: FontWeight.w600,
          color: Colors.white70,
          height: 1.2,
        ),
        weekdayStyle: TextStyle(
          fontSize: responsiveFontSize(12),
          fontWeight: FontWeight.w600,
          color: Colors.white70,
          height: 1.2,
        ),
        dayStyle: TextStyle(
          fontSize: responsiveFontSize(14),
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1.2,
        ),
        yearStyle: TextStyle(
          fontSize: responsiveFontSize(16),
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.2,
        ),
        yearForegroundColor: WidgetStateProperty.all(AppTheme.accentColor),
        dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.white;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected))
            return AppTheme.primaryTextColor;
          return Colors.transparent;
        }),
        todayBackgroundColor: WidgetStateProperty.all(
          AppTheme.primaryTextColor.withOpacity(0.2),
        ),
        todayBorder: BorderSide(color: AppTheme.primaryTextColor, width: 1),
        dividerColor: Colors.white24,
      );

      final maxW = (size.width * 0.9).clamp(280.0.w, 600.0.w);
      final maxH =
          (_isLandscape(context) ? size.height * 0.88 : size.height * 0.75)
              .clamp(380.0.h, 720.0.h);

      return Theme(
        data: baseTheme.copyWith(
          colorScheme: baseTheme.colorScheme.copyWith(
            primary: AppTheme.accentColor,
            onPrimary: Colors.white,
            surface: AppTheme.darkBlue,
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: AppTheme.darkBlue,
          datePickerTheme: datePickerTheme,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.accentColor,
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: responsiveFontSize(14),
                color: AppTheme.accentColor,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scaleFactor,
                vertical: 8 * scaleFactor,
              ),
            ),
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
            child: child!,
          ),
        ),
      );
    },
  );
}
