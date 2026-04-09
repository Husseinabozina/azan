import 'dart:async';

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/components/global_copyright_footer.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/display_board_hive_helper.dart';
import 'package:azan/core/helpers/display_board_schedule_helper.dart';
import 'package:azan/core/models/display_announcement.dart';
import 'package:azan/core/models/display_board_schedule.dart';
import 'package:azan/core/models/home_display_mode.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/dialoge_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/additional_settings/additional_settings_screen.dart';
import 'package:azan/views/display_board/components/display_board_palette.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

String _boardStyleText({required String ar, required String en}) {
  return CacheHelper.getLang() == 'ar' ? ar : en;
}

class DisplayBoardSettingsScreen extends StatefulWidget {
  const DisplayBoardSettingsScreen({super.key});

  @override
  State<DisplayBoardSettingsScreen> createState() =>
      _DisplayBoardSettingsScreenState();
}

class _DisplayBoardSettingsScreenState
    extends State<DisplayBoardSettingsScreen> {
  late AppCubit cubit;
  late int _rotationSeconds;
  late int _titleSize;
  late int _bodySize;
  late String _titleFont;
  late String _bodyFont;
  late bool _titleBold;
  late bool _titleItalic;
  late bool _bodyBold;
  late bool _bodyItalic;
  late int _titleColorIndex;
  late int _bodyColorIndex;

  @override
  void initState() {
    super.initState();
    cubit = AppCubit.get(context);
    cubit.assignDisplayAnnouncements();
    _rotationSeconds = CacheHelper.getDisplayBoardRotationSeconds();
    _titleSize = CacheHelper.getDisplayBoardTitleSize();
    _bodySize = CacheHelper.getDisplayBoardBodySize();
    _titleFont = CacheHelper.getDisplayBoardTitleFontFamily();
    _bodyFont = CacheHelper.getDisplayBoardBodyFontFamily();
    _titleBold = CacheHelper.getDisplayBoardTitleBold();
    _titleItalic = CacheHelper.getDisplayBoardTitleItalic();
    _bodyBold = CacheHelper.getDisplayBoardBodyBold();
    _bodyItalic = CacheHelper.getDisplayBoardBodyItalic();
    _titleColorIndex = CacheHelper.getDisplayBoardTitleColorIndex();
    _bodyColorIndex = CacheHelper.getDisplayBoardBodyColorIndex();
  }

  bool _isLandscape() => UiRotationCubit().isLandscape();

  Future<void> _goHome() async {
    await DisplayBoardScheduleResolver.switchBackToHomeMode(
      items: cubit.displayAnnouncementList ?? const [],
      now: DateTime.now(),
      dismissCurrentScheduled: true,
    );
    await cubit.assignDisplayAnnouncements();
    if (!mounted) return;
    AppNavigator.pushAndRemoveUntil(context, const HomeScreen());
  }

  Future<void> _reloadAnnouncements() async {
    await cubit.assignDisplayAnnouncements();
    if (!mounted) return;
    setState(() {});
  }

  void _setRotationSeconds(int value) {
    final next = value.clamp(3, 120);
    setState(() => _rotationSeconds = next);
    CacheHelper.setDisplayBoardRotationSeconds(next);
  }

  void _setTitleSize(int value) {
    final next = value.clamp(30, 120);
    setState(() => _titleSize = next);
    CacheHelper.setDisplayBoardTitleSize(next);
  }

  void _setBodySize(int value) {
    final next = value.clamp(18, 90);
    setState(() => _bodySize = next);
    CacheHelper.setDisplayBoardBodySize(next);
  }

  void _setTitleFont(String value) {
    setState(() => _titleFont = value);
    CacheHelper.setDisplayBoardTitleFontFamily(value);
  }

  void _setBodyFont(String value) {
    setState(() => _bodyFont = value);
    CacheHelper.setDisplayBoardBodyFontFamily(value);
  }

  void _setTitleBold(bool value) {
    setState(() => _titleBold = value);
    CacheHelper.setDisplayBoardTitleBold(value);
  }

  void _setTitleItalic(bool value) {
    setState(() => _titleItalic = value);
    CacheHelper.setDisplayBoardTitleItalic(value);
  }

  void _setBodyBold(bool value) {
    setState(() => _bodyBold = value);
    CacheHelper.setDisplayBoardBodyBold(value);
  }

  void _setBodyItalic(bool value) {
    setState(() => _bodyItalic = value);
    CacheHelper.setDisplayBoardBodyItalic(value);
  }

  void _setTitleColorIndex(int value) {
    setState(() => _titleColorIndex = value);
    CacheHelper.setDisplayBoardTitleColorIndex(value);
  }

  void _setBodyColorIndex(int value) {
    setState(() => _bodyColorIndex = value);
    CacheHelper.setDisplayBoardBodyColorIndex(value);
  }

  HomeDisplayMode _effectiveDisplayMode([DateTime? now]) {
    return DisplayBoardScheduleResolver.effectiveDisplayMode(
      manualMode: CacheHelper.getHomeDisplayMode(),
      items: cubit.displayAnnouncementList ?? const [],
      now: now,
    );
  }

  String _formatScheduleDate(DateTime? value) {
    if (value == null) {
      return _boardStyleText(ar: 'اختيار التاريخ', en: 'Pick date');
    }
    return DateFormat.yMd(context.locale.languageCode).format(value);
  }

  String _formatScheduleTime(DateTime? value) {
    if (value == null) {
      return _boardStyleText(ar: 'اختيار الوقت', en: 'Pick time');
    }
    return DateHelper.formatTimeWithSettings(
      TimeOfDay.fromDateTime(value),
      context,
    );
  }


  Future<void> _toggleBoardMode() async {
    final now = DateTime.now();
    final currentMode = _effectiveDisplayMode(now);
    final next = currentMode == HomeDisplayMode.displayBoard
        ? HomeDisplayMode.standard
        : HomeDisplayMode.displayBoard;

    if (currentMode == HomeDisplayMode.displayBoard &&
        CacheHelper.getHomeDisplayMode() != HomeDisplayMode.displayBoard) {
      await DisplayBoardScheduleResolver.switchBackToHomeMode(
        items: cubit.displayAnnouncementList ?? const [],
        now: now,
        dismissCurrentScheduled: true,
      );
      await cubit.assignDisplayAnnouncements();
    } else {
      await CacheHelper.setHomeDisplayMode(next);
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _showFontPickerDialog({
    required String title,
    required String selected,
    required ValueChanged<String> onSelected,
  }) async {
    String temp = selected;
    final size = MediaQuery.sizeOf(context);
    final isLandscape = _isLandscape();

    await showAppDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocal) {
            return UniversalDialogShell(
              customMaxWidth: isLandscape ? 540.w : size.width - 24.w,
              customMaxHeight: isLandscape
                  ? size.height * 0.72
                  : size.height * 0.68,
              forceMaxHeight: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: DialogPalette.titleTextColor,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: allAppFonts.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (context, index) {
                        final font = allAppFonts[index];
                        final selectedFont = font == temp;
                        return InkWell(
                          onTap: () => setLocal(() => temp = font),
                          borderRadius: BorderRadius.circular(18.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.r),
                              color: selectedFont
                                  ? DialogPalette.primaryButtonBackground
                                        .withValues(alpha: 0.16)
                                  : DialogPalette.surfaceRaisedColor,
                              border: Border.all(
                                color: selectedFont
                                    ? DialogPalette.primaryButtonBackground
                                    : DialogPalette.dividerColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    font,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: font,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: selectedFont
                                          ? DialogPalette.titleTextColor
                                          : DialogPalette.bodyTextColor,
                                    ),
                                  ),
                                ),
                                if (selectedFont)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color:
                                        DialogPalette.primaryButtonBackground,
                                    size: 22.r,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: _BoardActionButton(
                          label: LocaleKeys.common_cancel.tr(),
                          onPressed: () => Navigator.pop(dialogContext),
                          filled: false,
                          foregroundColor: DialogPalette.bodyTextColor,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _BoardActionButton(
                          label: LocaleKeys.common_save.tr(),
                          onPressed: () {
                            onSelected(temp);
                            Navigator.pop(dialogContext);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showColorPickerDialog({
    required String title,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) async {
    int temp = selectedIndex;
    final size = MediaQuery.sizeOf(context);
    final isLandscape = _isLandscape();

    await showAppDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocal) {
            return UniversalDialogShell(
              customMaxWidth: isLandscape ? 520.w : size.width - 24.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: DialogPalette.titleTextColor,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: List.generate(kDisplayBoardPalette.length, (
                      index,
                    ) {
                      final color = kDisplayBoardPalette[index];
                      final isSelected = temp == index;
                      return InkWell(
                        onTap: () => setLocal(() => temp = index),
                        borderRadius: BorderRadius.circular(999.r),
                        child: Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2.4,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.42),
                                      blurRadius: 14,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _BoardActionButton(
                          label: LocaleKeys.common_cancel.tr(),
                          onPressed: () => Navigator.pop(dialogContext),
                          filled: false,
                          foregroundColor: DialogPalette.bodyTextColor,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _BoardActionButton(
                          label: LocaleKeys.common_save.tr(),
                          onPressed: () {
                            onSelected(temp);
                            Navigator.pop(dialogContext);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAnnouncementEditor({DisplayAnnouncement? initial}) async {
    final titleController = TextEditingController(text: initial?.title ?? '');
    final bodyController = TextEditingController(text: initial?.body ?? '');
    bool active = initial?.active ?? true;
    bool pinned = initial?.pinned ?? false;
    String titleFont = initial?.titleFontFamily.isNotEmpty == true
        ? initial!.titleFontFamily
        : _titleFont;
    String bodyFont = initial?.bodyFontFamily.isNotEmpty == true
        ? initial!.bodyFontFamily
        : _bodyFont;
    bool titleBold = initial?.titleBold ?? _titleBold;
    bool titleItalic = initial?.titleItalic ?? _titleItalic;
    bool bodyBold = initial?.bodyBold ?? _bodyBold;
    bool bodyItalic = initial?.bodyItalic ?? _bodyItalic;
    int titleSize = (initial?.titleSize ?? 0) > 0
        ? initial!.titleSize
        : _titleSize;
    int bodySize = (initial?.bodySize ?? 0) > 0 ? initial!.bodySize : _bodySize;
    int titleColorIndex = (initial?.titleColorIndex ?? -1) >= 0
        ? initial!.titleColorIndex
        : _titleColorIndex;
    int bodyColorIndex = (initial?.bodyColorIndex ?? -1) >= 0
        ? initial!.bodyColorIndex
        : _bodyColorIndex;
    DisplayBoardSchedule? schedule = initial?.schedule;

    await showAppDialog(
      context: context,
      builder: (dialogContext) {
        final navigator = Navigator.of(dialogContext);
        return StatefulBuilder(
          builder: (dialogContext, setLocal) {
            DateTime fallbackStart() {
              final now = DateTime.now();
              final minuteBucket = ((now.minute / 5).round() * 5) % 60;
              return DateTime(
                now.year,
                now.month,
                now.day,
                now.hour,
                minuteBucket,
              );
            }

            DateTime scheduleValue(bool isStart) {
              final localSchedule = schedule;
              if (localSchedule != null) {
                if (isStart && localSchedule.startAt != null) {
                  return localSchedule.startAt!;
                }
                if (!isStart && localSchedule.endAt != null) {
                  return localSchedule.endAt!;
                }
              }

              final start = fallbackStart();
              return isStart ? start : start.add(const Duration(hours: 1));
            }

            Future<void> pickScheduleDate(bool isStart) async {
              final current = scheduleValue(isStart);
              final picked = await showUniversalDatePicker(
                dialogContext,
                initialDate: current,
              );
              if (picked == null) return;
              setLocal(() {
                final nextValue = DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  current.hour,
                  current.minute,
                );
                final nextSchedule =
                    schedule ?? const DisplayBoardSchedule(enabled: true);
                schedule = isStart
                    ? nextSchedule.copyWith(
                        enabled: true,
                        startAt: nextValue,
                        clearDismissedUntilEndAt: true,
                      )
                    : nextSchedule.copyWith(
                        enabled: true,
                        endAt: nextValue,
                        clearDismissedUntilEndAt: true,
                      );
              });
            }

            Future<void> pickScheduleTime(bool isStart) async {
              final current = scheduleValue(isStart);
              final picked = await showUniversalTimePicker(
                dialogContext,
                initialTime: TimeOfDay.fromDateTime(current),
                initialEntryMode: TimePickerEntryMode.input,
              );
              if (picked == null) return;
              setLocal(() {
                final nextValue = DateTime(
                  current.year,
                  current.month,
                  current.day,
                  picked.hour,
                  picked.minute,
                );
                final nextSchedule =
                    schedule ?? const DisplayBoardSchedule(enabled: true);
                schedule = isStart
                    ? nextSchedule.copyWith(
                        enabled: true,
                        startAt: nextValue,
                        clearDismissedUntilEndAt: true,
                      )
                    : nextSchedule.copyWith(
                        enabled: true,
                        endAt: nextValue,
                        clearDismissedUntilEndAt: true,
                      );
              });
            }

            String scheduleSummary() {
              if (schedule == null) {
                return _boardStyleText(
                  ar: 'بدون مؤقت: تظهر اللوحة دائمًا عند فتح شاشة لوحات العرض يدويًا.',
                  en: 'No timer: this board stays available when display board mode is opened manually.',
                );
              }
              if (!schedule!.hasWindow) {
                return _boardStyleText(
                  ar: 'حدد بداية ونهاية لهذه اللوحة.',
                  en: 'Pick a start and end window for this board.',
                );
              }
              if (!schedule!.isValidWindow) {
                return _boardStyleText(
                  ar: 'وقت نهاية هذه اللوحة يجب أن يكون بعد البداية.',
                  en: 'This board end time must be after the start time.',
                );
              }

              final start = schedule!.startAt!;
              final end = schedule!.endAt!;
              return '${_formatScheduleDate(start)}  ${_formatScheduleTime(start)}'
                  '  →  ${_formatScheduleDate(end)}  ${_formatScheduleTime(end)}';
            }

            return UniversalDialogShell(
              customMaxWidth: _isLandscape()
                  ? 760.w
                  : MediaQuery.sizeOf(context).width - 36.w,
              forceMaxHeight: true,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (initial == null
                              ? LocaleKeys.display_board_add_announcement
                              : LocaleKeys.display_board_edit_announcement)
                          .tr(),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: DialogPalette.titleTextColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _EditorField(
                      controller: titleController,
                      label: LocaleKeys.display_board_title.tr(),
                      maxLines: 1,
                    ),
                    SizedBox(height: 12.h),
                    _EditorField(
                      controller: bodyController,
                      label: LocaleKeys.display_board_body.tr(),
                      maxLines: 5,
                    ),
                    SizedBox(height: 14.h),
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _boardStyleText(
                              ar: 'تنسيق هذه اللوحة',
                              en: 'This board style',
                            ),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: DialogPalette.titleTextColor,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          PlusAndMinusWidget(
                            onChange: (value) => setLocal(
                              () => titleSize = value.clamp(30, 120),
                            ),
                            value: titleSize,
                            title: LocaleKeys.display_board_title_size.tr(),
                            duration: 'sp',
                            layout: PlusMinusLayout.wrap,
                            compact: true,
                            min: 30,
                            max: 120,
                          ),
                          SizedBox(height: 8.h),
                          PlusAndMinusWidget(
                            onChange: (value) =>
                                setLocal(() => bodySize = value.clamp(18, 90)),
                            value: bodySize,
                            title: LocaleKeys.display_board_body_size.tr(),
                            duration: 'sp',
                            layout: PlusMinusLayout.wrap,
                            compact: true,
                            min: 18,
                            max: 90,
                          ),
                          SizedBox(height: 12.h),
                          _FontSection(
                            label: LocaleKeys.display_board_title_font.tr(),
                            selected: titleFont,
                            bold: titleBold,
                            onBoldChanged: (value) =>
                                setLocal(() => titleBold = value),
                            italic: titleItalic,
                            onItalicChanged: (value) =>
                                setLocal(() => titleItalic = value),
                            onTap: () => _showFontPickerDialog(
                              title: LocaleKeys.display_board_title_font.tr(),
                              selected: titleFont,
                              onSelected: (value) =>
                                  setLocal(() => titleFont = value),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _FontSection(
                            label: LocaleKeys.display_board_body_font.tr(),
                            selected: bodyFont,
                            bold: bodyBold,
                            onBoldChanged: (value) =>
                                setLocal(() => bodyBold = value),
                            italic: bodyItalic,
                            onItalicChanged: (value) =>
                                setLocal(() => bodyItalic = value),
                            onTap: () => _showFontPickerDialog(
                              title: LocaleKeys.display_board_body_font.tr(),
                              selected: bodyFont,
                              onSelected: (value) =>
                                  setLocal(() => bodyFont = value),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _ColorSection(
                            label: LocaleKeys.display_board_title_color.tr(),
                            selectedIndex: titleColorIndex,
                            onTap: () => _showColorPickerDialog(
                              title: LocaleKeys.display_board_title_color.tr(),
                              selectedIndex: titleColorIndex,
                              onSelected: (value) =>
                                  setLocal(() => titleColorIndex = value),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _ColorSection(
                            label: LocaleKeys.display_board_body_color.tr(),
                            selectedIndex: bodyColorIndex,
                            onTap: () => _showColorPickerDialog(
                              title: LocaleKeys.display_board_body_color.tr(),
                              selectedIndex: bodyColorIndex,
                              onSelected: (value) =>
                                  setLocal(() => bodyColorIndex = value),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _PreviewCard(
                            titleFont: titleFont,
                            bodyFont: bodyFont,
                            titleBold: titleBold,
                            titleItalic: titleItalic,
                            bodyBold: bodyBold,
                            bodyItalic: bodyItalic,
                            titleColorIndex: titleColorIndex,
                            bodyColorIndex: bodyColorIndex,
                            titleSize: titleSize,
                            bodySize: bodySize,
                          ),
                          SizedBox(height: 12.h),
                          _PerBoardScheduleSection(
                            enabled: schedule != null,
                            scheduleIsValid: schedule?.isValidWindow ?? true,
                            summaryText: scheduleSummary(),
                            startDateText: schedule == null
                                ? _formatScheduleDate(null)
                                : _formatScheduleDate(schedule!.startAt),
                            startTimeText: schedule == null
                                ? _formatScheduleTime(null)
                                : _formatScheduleTime(schedule!.startAt),
                            endDateText: schedule == null
                                ? _formatScheduleDate(null)
                                : _formatScheduleDate(schedule!.endAt),
                            endTimeText: schedule == null
                                ? _formatScheduleTime(null)
                                : _formatScheduleTime(schedule!.endAt),
                            onEnabledChanged: (value) => setLocal(() {
                              if (!value) {
                                schedule = null;
                                return;
                              }
                              final start = fallbackStart();
                              schedule = DisplayBoardSchedule(
                                enabled: true,
                                startAt: start,
                                endAt: start.add(const Duration(hours: 1)),
                              );
                            }),
                            onPickStartDate: () => pickScheduleDate(true),
                            onPickStartTime: () => pickScheduleTime(true),
                            onPickEndDate: () => pickScheduleDate(false),
                            onPickEndTime: () => pickScheduleTime(false),
                            onClear: () => setLocal(() => schedule = null),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: active,
                      onChanged: (value) => setLocal(() => active = value),
                      title: Text(
                        LocaleKeys.display_board_active.tr(),
                        style: TextStyle(
                          color: DialogPalette.bodyTextColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 17.sp,
                        ),
                      ),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: pinned,
                      onChanged: (value) => setLocal(() {
                        pinned = value;
                        if (value) active = true;
                      }),
                      title: Text(
                        LocaleKeys.display_board_pinned.tr(),
                        style: TextStyle(
                          color: DialogPalette.bodyTextColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 17.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _BoardActionButton(
                            label: LocaleKeys.common_cancel.tr(),
                            onPressed: () => Navigator.pop(dialogContext),
                            filled: false,
                            foregroundColor: DialogPalette.bodyTextColor,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _BoardActionButton(
                            label: LocaleKeys.common_save.tr(),
                            onPressed: () async {
                              final title = titleController.text.trim();
                              final body = bodyController.text.trim();
                              if (title.isEmpty && body.isEmpty) {
                                return;
                              }
                              if (schedule != null && !schedule!.isValidWindow) {
                                return;
                              }

                              if (initial == null) {
                                await DisplayBoardHiveHelper.addAnnouncement(
                                  title: title,
                                  body: body,
                                  active: active,
                                  pinned: pinned,
                                  titleFontFamily: titleFont,
                                  bodyFontFamily: bodyFont,
                                  titleBold: titleBold,
                                  titleItalic: titleItalic,
                                  bodyBold: bodyBold,
                                  bodyItalic: bodyItalic,
                                  titleSize: titleSize,
                                  bodySize: bodySize,
                                  titleColorIndex: titleColorIndex,
                                  bodyColorIndex: bodyColorIndex,
                                  schedule: schedule,
                                );
                              } else {
                                await DisplayBoardHiveHelper.updateAnnouncement(
                                  initial.copyWith(
                                    title: title,
                                    body: body,
                                    active: active,
                                    pinned: pinned,
                                    titleFontFamily: titleFont,
                                    bodyFontFamily: bodyFont,
                                    titleBold: titleBold,
                                    titleItalic: titleItalic,
                                    bodyBold: bodyBold,
                                    bodyItalic: bodyItalic,
                                    titleSize: titleSize,
                                    bodySize: bodySize,
                                    titleColorIndex: titleColorIndex,
                                    bodyColorIndex: bodyColorIndex,
                                    schedule: schedule,
                                    clearSchedule: schedule == null,
                                  ),
                                );
                              }

                              if (!mounted) return;
                              navigator.pop();
                              await _reloadAnnouncements();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = _isLandscape();
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const GlobalCopyrightFooter(),
      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {},
        builder: (context, state) {
          final announcements = cubit.displayAnnouncementList ?? const [];
          final isBoardEnabled =
              _effectiveDisplayMode(DateTime.now()) ==
              HomeDisplayMode.displayBoard;
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
                        onClose: _goHome,
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
                                        child: _SettingsPanel(
                                          isBoardEnabled: isBoardEnabled,
                                          onToggleBoardMode: _toggleBoardMode,
                                          rotationSeconds: _rotationSeconds,
                                          onRotationSeconds:
                                              _setRotationSeconds,
                                          titleSize: _titleSize,
                                          onTitleSize: _setTitleSize,
                                          bodySize: _bodySize,
                                          onBodySize: _setBodySize,
                                          titleFont: _titleFont,
                                          onTitleFont: _setTitleFont,
                                          titleBold: _titleBold,
                                          onTitleBold: _setTitleBold,
                                          titleItalic: _titleItalic,
                                          onTitleItalic: _setTitleItalic,
                                          bodyFont: _bodyFont,
                                          onBodyFont: _setBodyFont,
                                          bodyBold: _bodyBold,
                                          onBodyBold: _setBodyBold,
                                          bodyItalic: _bodyItalic,
                                          onBodyItalic: _setBodyItalic,
                                          titleColorIndex: _titleColorIndex,
                                          onTitleColorIndex:
                                              _setTitleColorIndex,
                                          bodyColorIndex: _bodyColorIndex,
                                          onBodyColorIndex: _setBodyColorIndex,
                                          onAdd: () =>
                                              _showAnnouncementEditor(),
                                          onOpenTitleFontPicker: () =>
                                              _showFontPickerDialog(
                                                title: LocaleKeys
                                                    .display_board_title_font
                                                    .tr(),
                                                selected: _titleFont,
                                                onSelected: _setTitleFont,
                                              ),
                                          onOpenBodyFontPicker: () =>
                                              _showFontPickerDialog(
                                                title: LocaleKeys
                                                    .display_board_body_font
                                                    .tr(),
                                                selected: _bodyFont,
                                                onSelected: _setBodyFont,
                                              ),
                                          onOpenTitleColorPicker: () =>
                                              _showColorPickerDialog(
                                                title: LocaleKeys
                                                    .display_board_title_color
                                                    .tr(),
                                                selectedIndex: _titleColorIndex,
                                                onSelected: _setTitleColorIndex,
                                              ),
                                          onOpenBodyColorPicker: () =>
                                              _showColorPickerDialog(
                                                title: LocaleKeys
                                                    .display_board_body_color
                                                    .tr(),
                                                selectedIndex: _bodyColorIndex,
                                                onSelected: _setBodyColorIndex,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    flex: 8,
                                    child: _GlassPanel(
                                      padding: EdgeInsets.all(16.r),
                                      child: _AnnouncementsList(
                                        announcements: announcements,
                                        onAdd: () => _showAnnouncementEditor(),
                                        onEdit: (item) =>
                                            _showAnnouncementEditor(
                                              initial: item,
                                            ),
                                        onRefresh: _reloadAnnouncements,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : _PortraitLayout(
                                isBoardEnabled: isBoardEnabled,
                                onToggleBoardMode: _toggleBoardMode,
                                rotationSeconds: _rotationSeconds,
                                onRotationSeconds: _setRotationSeconds,
                                titleSize: _titleSize,
                                onTitleSize: _setTitleSize,
                                bodySize: _bodySize,
                                onBodySize: _setBodySize,
                                titleFont: _titleFont,
                                onTitleFont: _setTitleFont,
                                titleBold: _titleBold,
                                onTitleBold: _setTitleBold,
                                titleItalic: _titleItalic,
                                onTitleItalic: _setTitleItalic,
                                bodyFont: _bodyFont,
                                onBodyFont: _setBodyFont,
                                bodyBold: _bodyBold,
                                onBodyBold: _setBodyBold,
                                bodyItalic: _bodyItalic,
                                onBodyItalic: _setBodyItalic,
                                titleColorIndex: _titleColorIndex,
                                onTitleColorIndex: _setTitleColorIndex,
                                bodyColorIndex: _bodyColorIndex,
                                onBodyColorIndex: _setBodyColorIndex,
                                onAdd: () => _showAnnouncementEditor(),
                                onOpenTitleFontPicker: () =>
                                    _showFontPickerDialog(
                                      title: LocaleKeys.display_board_title_font
                                          .tr(),
                                      selected: _titleFont,
                                      onSelected: _setTitleFont,
                                    ),
                                onOpenBodyFontPicker: () =>
                                    _showFontPickerDialog(
                                      title: LocaleKeys.display_board_body_font
                                          .tr(),
                                      selected: _bodyFont,
                                      onSelected: _setBodyFont,
                                    ),
                                onOpenTitleColorPicker: () =>
                                    _showColorPickerDialog(
                                      title: LocaleKeys
                                          .display_board_title_color
                                          .tr(),
                                      selectedIndex: _titleColorIndex,
                                      onSelected: _setTitleColorIndex,
                                    ),
                                onOpenBodyColorPicker: () =>
                                    _showColorPickerDialog(
                                      title: LocaleKeys.display_board_body_color
                                          .tr(),
                                      selectedIndex: _bodyColorIndex,
                                      onSelected: _setBodyColorIndex,
                                    ),
                                announcements: announcements,
                                onEdit: (item) =>
                                    _showAnnouncementEditor(initial: item),
                                onRefresh: _reloadAnnouncements,
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

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({
    required this.isBoardEnabled,
    required this.onToggleBoardMode,
    required this.rotationSeconds,
    required this.onRotationSeconds,
    required this.titleSize,
    required this.onTitleSize,
    required this.bodySize,
    required this.onBodySize,
    required this.titleFont,
    required this.onTitleFont,
    required this.titleBold,
    required this.onTitleBold,
    required this.titleItalic,
    required this.onTitleItalic,
    required this.bodyFont,
    required this.onBodyFont,
    required this.bodyBold,
    required this.onBodyBold,
    required this.bodyItalic,
    required this.onBodyItalic,
    required this.titleColorIndex,
    required this.onTitleColorIndex,
    required this.bodyColorIndex,
    required this.onBodyColorIndex,
    required this.onAdd,
    required this.onOpenTitleFontPicker,
    required this.onOpenBodyFontPicker,
    required this.onOpenTitleColorPicker,
    required this.onOpenBodyColorPicker,
    required this.announcements,
    required this.onEdit,
    required this.onRefresh,
  });

  final bool isBoardEnabled;
  final Future<void> Function() onToggleBoardMode;
  final int rotationSeconds;
  final ValueChanged<int> onRotationSeconds;
  final int titleSize;
  final ValueChanged<int> onTitleSize;
  final int bodySize;
  final ValueChanged<int> onBodySize;
  final String titleFont;
  final ValueChanged<String> onTitleFont;
  final bool titleBold;
  final ValueChanged<bool> onTitleBold;
  final bool titleItalic;
  final ValueChanged<bool> onTitleItalic;
  final String bodyFont;
  final ValueChanged<String> onBodyFont;
  final bool bodyBold;
  final ValueChanged<bool> onBodyBold;
  final bool bodyItalic;
  final ValueChanged<bool> onBodyItalic;
  final int titleColorIndex;
  final ValueChanged<int> onTitleColorIndex;
  final int bodyColorIndex;
  final ValueChanged<int> onBodyColorIndex;
  final VoidCallback onAdd;
  final VoidCallback onOpenTitleFontPicker;
  final VoidCallback onOpenBodyFontPicker;
  final VoidCallback onOpenTitleColorPicker;
  final VoidCallback onOpenBodyColorPicker;
  final List<DisplayAnnouncement> announcements;
  final ValueChanged<DisplayAnnouncement> onEdit;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: EdgeInsets.all(16.r),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsPanel(
                    isBoardEnabled: isBoardEnabled,
                    onToggleBoardMode: onToggleBoardMode,
                    rotationSeconds: rotationSeconds,
                    onRotationSeconds: onRotationSeconds,
                    titleSize: titleSize,
                    onTitleSize: onTitleSize,
                    bodySize: bodySize,
                    onBodySize: onBodySize,
                    titleFont: titleFont,
                    onTitleFont: onTitleFont,
                    titleBold: titleBold,
                    onTitleBold: onTitleBold,
                    titleItalic: titleItalic,
                    onTitleItalic: onTitleItalic,
                    bodyFont: bodyFont,
                    onBodyFont: onBodyFont,
                    bodyBold: bodyBold,
                    onBodyBold: onBodyBold,
                    bodyItalic: bodyItalic,
                    onBodyItalic: onBodyItalic,
                    titleColorIndex: titleColorIndex,
                    onTitleColorIndex: onTitleColorIndex,
                    bodyColorIndex: bodyColorIndex,
                    onBodyColorIndex: onBodyColorIndex,
                    onAdd: onAdd,
                    onOpenTitleFontPicker: onOpenTitleFontPicker,
                    onOpenBodyFontPicker: onOpenBodyFontPicker,
                    onOpenTitleColorPicker: onOpenTitleColorPicker,
                    onOpenBodyColorPicker: onOpenBodyColorPicker,
                  ),
                  SizedBox(height: 14.h),
                  _AnnouncementsList(
                    announcements: announcements,
                    onAdd: onAdd,
                    onEdit: onEdit,
                    onRefresh: onRefresh,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.isBoardEnabled,
    required this.onToggleBoardMode,
    required this.rotationSeconds,
    required this.onRotationSeconds,
    required this.titleSize,
    required this.onTitleSize,
    required this.bodySize,
    required this.onBodySize,
    required this.titleFont,
    required this.onTitleFont,
    required this.titleBold,
    required this.onTitleBold,
    required this.titleItalic,
    required this.onTitleItalic,
    required this.bodyFont,
    required this.onBodyFont,
    required this.bodyBold,
    required this.onBodyBold,
    required this.bodyItalic,
    required this.onBodyItalic,
    required this.titleColorIndex,
    required this.onTitleColorIndex,
    required this.bodyColorIndex,
    required this.onBodyColorIndex,
    required this.onAdd,
    required this.onOpenTitleFontPicker,
    required this.onOpenBodyFontPicker,
    required this.onOpenTitleColorPicker,
    required this.onOpenBodyColorPicker,
  });

  final bool isBoardEnabled;
  final Future<void> Function() onToggleBoardMode;
  final int rotationSeconds;
  final ValueChanged<int> onRotationSeconds;
  final int titleSize;
  final ValueChanged<int> onTitleSize;
  final int bodySize;
  final ValueChanged<int> onBodySize;
  final String titleFont;
  final ValueChanged<String> onTitleFont;
  final bool titleBold;
  final ValueChanged<bool> onTitleBold;
  final bool titleItalic;
  final ValueChanged<bool> onTitleItalic;
  final String bodyFont;
  final ValueChanged<String> onBodyFont;
  final bool bodyBold;
  final ValueChanged<bool> onBodyBold;
  final bool bodyItalic;
  final ValueChanged<bool> onBodyItalic;
  final int titleColorIndex;
  final ValueChanged<int> onTitleColorIndex;
  final int bodyColorIndex;
  final ValueChanged<int> onBodyColorIndex;
  final VoidCallback onAdd;
  final VoidCallback onOpenTitleFontPicker;
  final VoidCallback onOpenBodyFontPicker;
  final VoidCallback onOpenTitleColorPicker;
  final VoidCallback onOpenBodyColorPicker;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.display_board_management.tr(),
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: AppTheme.dialogTitleColor,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          LocaleKeys.display_board_note.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.dialogMutedTextColor,
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.display_board_mode.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.dialogBodyTextColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isBoardEnabled
                          ? LocaleKeys.display_board_enabled.tr()
                          : LocaleKeys.display_board_disabled.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.dialogMutedTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              _BoardActionButton(
                onPressed: onToggleBoardMode,
                compact: true,
                minWidth: 84.w,
                maxWidth: 128.w,
                label: isBoardEnabled
                    ? LocaleKeys.display_board_return_main.tr()
                    : LocaleKeys.display_board_enable.tr(),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        PlusAndMinusWidget(
          onChange: onRotationSeconds,
          value: rotationSeconds,
          title: LocaleKeys.display_board_rotation_duration.tr(),
          duration: LocaleKeys.second.tr(),
          layout: PlusMinusLayout.wrap,
          compact: true,
          min: 3,
          max: 120,
        ),
        SizedBox(height: 8.h),
        PlusAndMinusWidget(
          onChange: onTitleSize,
          value: titleSize,
          title: LocaleKeys.display_board_title_size.tr(),
          duration: 'sp',
          layout: PlusMinusLayout.wrap,
          compact: true,
          min: 30,
          max: 120,
        ),
        SizedBox(height: 8.h),
        PlusAndMinusWidget(
          onChange: onBodySize,
          value: bodySize,
          title: LocaleKeys.display_board_body_size.tr(),
          duration: 'sp',
          layout: PlusMinusLayout.wrap,
          compact: true,
          min: 18,
          max: 90,
        ),
        SizedBox(height: 16.h),
        _FontSection(
          label: LocaleKeys.display_board_title_font.tr(),
          selected: titleFont,
          bold: titleBold,
          onBoldChanged: onTitleBold,
          italic: titleItalic,
          onItalicChanged: onTitleItalic,
          onTap: onOpenTitleFontPicker,
        ),
        SizedBox(height: 12.h),
        _FontSection(
          label: LocaleKeys.display_board_body_font.tr(),
          selected: bodyFont,
          bold: bodyBold,
          onBoldChanged: onBodyBold,
          italic: bodyItalic,
          onItalicChanged: onBodyItalic,
          onTap: onOpenBodyFontPicker,
        ),
        SizedBox(height: 12.h),
        _ColorSection(
          label: LocaleKeys.display_board_title_color.tr(),
          selectedIndex: titleColorIndex,
          onTap: onOpenTitleColorPicker,
        ),
        SizedBox(height: 12.h),
        _ColorSection(
          label: LocaleKeys.display_board_body_color.tr(),
          selectedIndex: bodyColorIndex,
          onTap: onOpenBodyColorPicker,
        ),
        SizedBox(height: 14.h),
        _PreviewCard(
          titleFont: titleFont,
          bodyFont: bodyFont,
          titleBold: titleBold,
          titleItalic: titleItalic,
          bodyBold: bodyBold,
          bodyItalic: bodyItalic,
          titleColorIndex: titleColorIndex,
          bodyColorIndex: bodyColorIndex,
          titleSize: titleSize,
          bodySize: bodySize,
        ),
        SizedBox(height: 14.h),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _BoardActionButton(
            onPressed: onAdd,
            compact: true,
            minWidth: 108.w,
            maxWidth: 144.w,
            icon: Icons.add_rounded,
            label: LocaleKeys.display_board_add_announcement.tr(),
          ),
        ),
      ],
    );
  }
}

class _PerBoardScheduleSection extends StatelessWidget {
  const _PerBoardScheduleSection({
    required this.enabled,
    required this.scheduleIsValid,
    required this.summaryText,
    required this.startDateText,
    required this.startTimeText,
    required this.endDateText,
    required this.endTimeText,
    required this.onEnabledChanged,
    required this.onPickStartDate,
    required this.onPickStartTime,
    required this.onPickEndDate,
    required this.onPickEndTime,
    required this.onClear,
  });

  final bool enabled;
  final bool scheduleIsValid;
  final String summaryText;
  final String startDateText;
  final String startTimeText;
  final String endDateText;
  final String endTimeText;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndDate;
  final VoidCallback onPickEndTime;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final summaryColor = scheduleIsValid || !enabled
        ? AppTheme.dialogMutedTextColor
        : Colors.amber.shade300;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _boardStyleText(
                        ar: 'مؤقت هذه اللوحة',
                        en: 'This board timer',
                      ),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.dialogBodyTextColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _boardStyleText(
                        ar: 'فعّل مؤقتًا خاصًا لهذه اللوحة فقط.',
                        en: 'Enable a timer for this board only.',
                      ),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppTheme.dialogMutedTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: enabled,
                onChanged: onEnabledChanged,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _ScheduleRangeBlock(
            title: _boardStyleText(ar: 'بداية الفترة', en: 'Start'),
            dateText: startDateText,
            timeText: startTimeText,
            onDateTap: onPickStartDate,
            onTimeTap: onPickStartTime,
          ),
          SizedBox(height: 10.h),
          _ScheduleRangeBlock(
            title: _boardStyleText(ar: 'نهاية الفترة', en: 'End'),
            dateText: endDateText,
            timeText: endTimeText,
            onDateTap: onPickEndDate,
            onTimeTap: onPickEndTime,
          ),
          SizedBox(height: 12.h),
          Text(
            summaryText,
            style: TextStyle(
              fontSize: 13.4.sp,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: summaryColor,
            ),
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _BoardActionButton(
              label: _boardStyleText(ar: 'مسح الجدولة', en: 'Clear schedule'),
              compact: true,
              filled: false,
              icon: Icons.delete_outline_rounded,
              minWidth: 118.w,
              maxWidth: 168.w,
              onPressed: onClear,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRangeBlock extends StatelessWidget {
  const _ScheduleRangeBlock({
    required this.title,
    required this.dateText,
    required this.timeText,
    required this.onDateTap,
    required this.onTimeTap,
  });

  final String title;
  final String dateText;
  final String timeText;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w800,
            color: AppTheme.dialogBodyTextColor,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _ScheduleValueButton(
                icon: Icons.calendar_month_outlined,
                label: dateText,
                onTap: onDateTap,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _ScheduleValueButton(
                icon: Icons.schedule_outlined,
                label: timeText,
                onTap: onTimeTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScheduleValueButton extends StatelessWidget {
  const _ScheduleValueButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.dialogIconColor, size: 18.r),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.3.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.dialogBodyTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementsList extends StatelessWidget {
  const _AnnouncementsList({
    required this.announcements,
    required this.onAdd,
    required this.onEdit,
    required this.onRefresh,
    this.shrinkWrap = false,
    this.physics,
  });

  final List<DisplayAnnouncement> announcements;
  final VoidCallback onAdd;
  final ValueChanged<DisplayAnnouncement> onEdit;
  final Future<void> Function() onRefresh;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    if (announcements.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 56.r,
              color: AppTheme.dialogIconColor,
            ),
            SizedBox(height: 12.h),
            Text(
              LocaleKeys.display_board_empty_state.tr(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.dialogBodyTextColor,
              ),
            ),
            SizedBox(height: 12.h),
            _BoardActionButton(
              onPressed: onAdd,
              compact: true,
              minWidth: 108.w,
              maxWidth: 144.w,
              icon: Icons.add_rounded,
              label: LocaleKeys.display_board_add_announcement.tr(),
            ),
          ],
        ),
      );
    }

    final sorted = [...announcements]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: sorted.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final item = sorted[index];
        return _AnnouncementTile(
          item: item,
          isFirst: index == 0,
          isLast: index == sorted.length - 1,
          onEdit: () => onEdit(item),
          onRefresh: onRefresh,
        );
      },
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.onEdit,
    required this.onRefresh,
  });

  final DisplayAnnouncement item;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onEdit;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title.isEmpty
                      ? LocaleKeys.display_board_no_title.tr()
                      : item.title,
                  style: TextStyle(
                    fontFamily: item.titleFontFamily,
                    fontSize: (item.titleSize * 0.32).clamp(18.0, 24.0).sp,
                    fontWeight: item.titleBold
                        ? FontWeight.w800
                        : FontWeight.w500,
                    fontStyle: item.titleItalic
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color: displayBoardPaletteColor(item.titleColorIndex),
                  ),
                ),
              ),
              if (item.pinned)
                Icon(
                  Icons.push_pin_rounded,
                  color: AppTheme.accentColor,
                  size: 20.r,
                ),
            ],
          ),
          if (item.body.isNotEmpty) SizedBox(height: 6.h),
          if (item.body.isNotEmpty)
            Text(
              item.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: item.bodyFontFamily,
                fontSize: (item.bodySize * 0.40).clamp(13.0, 17.0).sp,
                fontWeight: item.bodyBold ? FontWeight.w700 : FontWeight.w400,
                fontStyle: item.bodyItalic
                    ? FontStyle.italic
                    : FontStyle.normal,
                color: displayBoardPaletteColor(item.bodyColorIndex),
                height: 1.2,
              ),
            ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _MiniActionChip(
                icon: item.active ? Icons.visibility : Icons.visibility_off,
                label: item.active
                    ? LocaleKeys.display_board_active.tr()
                    : LocaleKeys.display_board_inactive.tr(),
                onTap: () async {
                  await DisplayBoardHiveHelper.updateAnnouncement(
                    item.copyWith(active: !item.active),
                  );
                  await onRefresh();
                },
              ),
              _MiniActionChip(
                icon: Icons.push_pin_rounded,
                label: item.pinned
                    ? LocaleKeys.display_board_pinned.tr()
                    : LocaleKeys.display_board_pin.tr(),
                onTap: () async {
                  await DisplayBoardHiveHelper.togglePinnedAnnouncement(
                    item.id,
                  );
                  await onRefresh();
                },
              ),
              _MiniActionChip(
                icon: Icons.edit_outlined,
                label: LocaleKeys.dhikr_edit_title.tr(),
                onTap: onEdit,
              ),
              if (!isFirst)
                _MiniActionChip(
                  icon: Icons.arrow_upward,
                  label: LocaleKeys.display_board_move_up.tr(),
                  onTap: () async {
                    await DisplayBoardHiveHelper.moveAnnouncementUp(item.id);
                    await onRefresh();
                  },
                ),
              if (!isLast)
                _MiniActionChip(
                  icon: Icons.arrow_downward,
                  label: LocaleKeys.display_board_move_down.tr(),
                  onTap: () async {
                    await DisplayBoardHiveHelper.moveAnnouncementDown(item.id);
                    await onRefresh();
                  },
                ),
              _MiniActionChip(
                icon: Icons.delete_outline,
                label: LocaleKeys.delete.tr(),
                onTap: () async {
                  await DisplayBoardHiveHelper.deleteAnnouncement(item.id);
                  await onRefresh();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniActionChip extends StatelessWidget {
  const _MiniActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          color: Colors.white.withValues(alpha: 0.06),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.r, color: AppTheme.dialogIconColor),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.dialogBodyTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.titleFont,
    required this.bodyFont,
    required this.titleBold,
    required this.titleItalic,
    required this.bodyBold,
    required this.bodyItalic,
    required this.titleColorIndex,
    required this.bodyColorIndex,
    required this.titleSize,
    required this.bodySize,
  });

  final String titleFont;
  final String bodyFont;
  final bool titleBold;
  final bool titleItalic;
  final bool bodyBold;
  final bool bodyItalic;
  final int titleColorIndex;
  final int bodyColorIndex;
  final int titleSize;
  final int bodySize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.55),
            Colors.black.withValues(alpha: 0.38),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.display_board_preview_title.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: titleFont,
              fontSize: (titleSize * 0.42).sp,
              fontWeight: titleBold ? FontWeight.w800 : FontWeight.w500,
              fontStyle: titleItalic ? FontStyle.italic : FontStyle.normal,
              color: displayBoardPaletteColor(titleColorIndex),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            LocaleKeys.display_board_preview_body.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: bodyFont,
              fontSize: (bodySize * 0.48).sp,
              fontWeight: bodyBold ? FontWeight.w700 : FontWeight.w400,
              fontStyle: bodyItalic ? FontStyle.italic : FontStyle.normal,
              color: displayBoardPaletteColor(bodyColorIndex),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSection extends StatelessWidget {
  const _ColorSection({
    required this.label,
    required this.selectedIndex,
    required this.onTap,
  });

  final String label;
  final int selectedIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppTheme.dialogBodyTextColor,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(
                  width: 26.r,
                  height: 26.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: displayBoardPaletteColor(selectedIndex),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.82),
                      width: 1.5,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: List.generate(6, (index) {
                      final color = kDisplayBoardPalette[index];
                      return Container(
                        width: 14.r,
                        height: 14.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.palette_outlined,
                  color: AppTheme.dialogIconColor,
                  size: 18.r,
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.dialogMutedTextColor,
                  size: 20.r,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BoardActionButton extends StatelessWidget {
  const _BoardActionButton({
    required this.label,
    required this.onPressed,
    this.filled = true,
    this.compact = false,
    this.icon,
    this.minWidth,
    this.maxWidth,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final bool compact;
  final IconData? icon;
  final double? minWidth;
  final double? maxWidth;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final foreground =
        foregroundColor ??
        (filled ? AppTheme.primaryButtonTextColor : AppTheme.primaryTextColor);

    final buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: compact ? 15.r : 17.r),
          SizedBox(width: 6.w),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              fontSize: compact ? 12.6.sp : 14.6.sp,
              fontWeight: FontWeight.w800,
              fontFamily: CacheHelper.getTextsFontFamily(),
            ),
          ),
        ),
      ],
    );

    final style = filled
        ? FilledButton.styleFrom(
            backgroundColor: AppTheme.primaryButtonBackground,
            foregroundColor: foreground,
            minimumSize: Size(minWidth ?? 0, compact ? 38.h : 44.h),
            maximumSize: Size(
              maxWidth ?? double.infinity,
              compact ? 38.h : 44.h,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12.w : 16.w,
              vertical: compact ? 8.h : 10.h,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(compact ? 14.r : 16.r),
            ),
            elevation: 0,
          )
        : OutlinedButton.styleFrom(
            foregroundColor: foreground,
            backgroundColor: Colors.white.withValues(alpha: 0.04),
            minimumSize: Size(minWidth ?? 0, compact ? 38.h : 44.h),
            maximumSize: Size(
              maxWidth ?? double.infinity,
              compact ? 38.h : 44.h,
            ),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12.w : 16.w,
              vertical: compact ? 8.h : 10.h,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(compact ? 14.r : 16.r),
            ),
          );

    return filled
        ? FilledButton(onPressed: onPressed, style: style, child: buttonChild)
        : OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: buttonChild,
          );
  }
}

class _FontSection extends StatelessWidget {
  const _FontSection({
    required this.label,
    required this.selected,
    required this.bold,
    required this.onBoldChanged,
    required this.italic,
    required this.onItalicChanged,
    required this.onTap,
  });

  final String label;
  final String selected;
  final bool bold;
  final ValueChanged<bool> onBoldChanged;
  final bool italic;
  final ValueChanged<bool> onItalicChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppTheme.dialogBodyTextColor,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: selected,
                      fontSize: 15.sp,
                      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                      color: AppTheme.dialogBodyTextColor,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.font_download_outlined,
                  color: AppTheme.dialogIconColor,
                  size: 18.r,
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.dialogMutedTextColor,
                  size: 20.r,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _StyleToggleChip(
              label: _boardStyleText(ar: 'غامق', en: 'Bold'),
              selected: bold,
              icon: Icons.format_bold_rounded,
              onTap: () => onBoldChanged(!bold),
            ),
            _StyleToggleChip(
              label: _boardStyleText(ar: 'مائل', en: 'Italic'),
              selected: italic,
              icon: Icons.format_italic_rounded,
              onTap: () => onItalicChanged(!italic),
            ),
          ],
        ),
      ],
    );
  }
}

class _StyleToggleChip extends StatelessWidget {
  const _StyleToggleChip({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999.r),
          color: selected
              ? AppTheme.primaryButtonBackground.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: selected
                ? AppTheme.primaryButtonBackground
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.r,
              color: selected
                  ? AppTheme.primaryButtonBackground
                  : AppTheme.dialogMutedTextColor,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: selected
                    ? AppTheme.primaryButtonBackground
                    : AppTheme.dialogBodyTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorField extends StatelessWidget {
  const _EditorField({
    required this.controller,
    required this.label,
    required this.maxLines,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        color: AppTheme.dialogBodyTextColor,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppTheme.dialogBodyTextColor.withValues(alpha: 0.78),
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
        floatingLabelStyle: TextStyle(
          color: AppTheme.accentColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        color: Colors.black.withValues(alpha: 0.52),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(padding: padding ?? EdgeInsets.all(16.r), child: child),
    );
  }
}
