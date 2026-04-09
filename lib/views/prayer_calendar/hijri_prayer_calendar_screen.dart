import 'dart:ui' as ui;

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/components/global_copyright_footer.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/prayer_calendar_helper.dart';
import 'package:azan/core/models/prayer.dart';
import 'package:azan/core/models/prayer_calendar_day.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/dialoge_helper.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter/rendering.dart';

class HijriPrayerCalendarScreen extends StatefulWidget {
  const HijriPrayerCalendarScreen({super.key});

  @override
  State<HijriPrayerCalendarScreen> createState() =>
      _HijriPrayerCalendarScreenState();
}

class _HijriPrayerCalendarScreenState extends State<HijriPrayerCalendarScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<int, GlobalKey> _mobileMonthChipKeys = <int, GlobalKey>{};
  final Map<int, GlobalKey> _sideMonthChipKeys = <int, GlobalKey>{};
  final ScrollController _mobileMonthsController = ScrollController();
  final ScrollController _sideMonthsController = ScrollController();

  late AppCubit cubit;
  late final int _currentHijriYear;
  late final List<int> _availableHijriYears;
  late int _selectedHijriYear;
  bool _isLoading = true;
  List<_CalendarDayVm> _days = const <_CalendarDayVm>[];
  List<int> _monthOrder = const <int>[];
  int? _selectedMonth;
  String? _expandedDayYmd;

  @override
  void initState() {
    super.initState();
    cubit = AppCubit.get(context);
    _currentHijriYear = cubit.currentDisplayedHijriYearRange.hijriYear;
    _availableHijriYears = List<int>.generate(
      6,
      (index) => _currentHijriYear + index,
    );
    _selectedHijriYear = _currentHijriYear;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCalendar();
    });
  }

  bool get _isLandscape => MediaQuery.of(context).size.width > 700.w;

  String _weekdayLabel(DateTime date) {
    switch (date.weekday) {
      case DateTime.saturday:
        return LocaleKeys.day_saturday.tr();
      case DateTime.sunday:
        return LocaleKeys.day_sunday.tr();
      case DateTime.monday:
        return LocaleKeys.day_monday.tr();
      case DateTime.tuesday:
        return LocaleKeys.day_tuesday.tr();
      case DateTime.wednesday:
        return LocaleKeys.day_wednesday.tr();
      case DateTime.thursday:
        return LocaleKeys.day_thursday.tr();
      case DateTime.friday:
        return LocaleKeys.day_friday.tr();
      default:
        return '';
    }
  }

  String _localizeDigits(String raw) {
    return CacheHelper.getIsArabicNumbersEnabled()
        ? DateHelper.toArabicDigits(raw)
        : DateHelper.toWesternDigits(raw);
  }

  String _gregorianLabel(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return _localizeDigits('$year/$month/$day');
  }

  Future<void> _loadCalendar() async {
    setState(() => _isLoading = true);

    final baseIqama = await cubit.getStoredIqamaMinutes();
    final days = await cubit.loadHijriYearPrayerCalendar(
      hijriYear: _selectedHijriYear,
      city: cubit.getCity()?.nameEn,
    );

    final offsetDays = CacheHelper.getHijriOffsetDays();
    final langCode = CacheHelper.getLang();

    final mapped =
        days.map((day) {
            final hijri = PrayerCalendarHelper.hijriPartsForDate(
              day.gregorianDate,
              offsetDays: offsetDays,
              langCode: langCode,
            );
            final defaultIqamaOffsets =
                PrayerCalendarHelper.defaultIqamaMinutesForDate(
                  baseIqamaMinutes: baseIqama,
                  date: day.gregorianDate,
                  fridayMinutes: CacheHelper.getFridayTime(),
                );

            return _CalendarDayVm(
              day: day,
              hijriDay: hijri.day,
              hijriMonth: hijri.month,
              hijriYear: hijri.year,
              hijriMonthName: hijri.monthName,
              weekdayLabel: _weekdayLabel(day.gregorianDate),
              gregorianLabel: _gregorianLabel(day.gregorianDate),
              editable: cubit.isPrayerCalendarDateEditable(day.gregorianDate),
              defaultIqamaOffsets: defaultIqamaOffsets,
            );
          }).toList()
          ..sort((a, b) => a.day.gregorianDate.compareTo(b.day.gregorianDate));

    final monthOrder = mapped.map((item) => item.hijriMonth).toSet().toList()
      ..sort();

    final currentMonth = PrayerCalendarHelper.hijriPartsForDate(
      DateTime.now(),
      offsetDays: offsetDays,
      langCode: langCode,
    ).month;

    if (!mounted) return;
    final expandedStillExists = mapped.any(
      (day) => day.day.gregorianYmd == _expandedDayYmd,
    );
    setState(() {
      _days = mapped;
      _monthOrder = monthOrder;
      _selectedMonth = monthOrder.contains(_selectedMonth)
          ? _selectedMonth
          : (_selectedHijriYear == _currentHijriYear &&
                    monthOrder.contains(currentMonth)
                ? currentMonth
                : (monthOrder.isNotEmpty ? monthOrder.first : null));
      _expandedDayYmd = expandedStillExists ? _expandedDayYmd : null;
      _isLoading = false;
    });
    _scheduleSelectedMonthVisibility();
  }

  List<_CalendarDayVm> get _selectedMonthDays {
    if (_selectedMonth == null) return _days;
    return _days.where((day) => day.hijriMonth == _selectedMonth).toList();
  }

  int? _monthIndexFor(int? month) {
    if (month == null) return null;
    final index = _monthOrder.indexOf(month);
    return index == -1 ? null : index;
  }

  int? _adjacentMonth(int delta) {
    final currentIndex = _monthIndexFor(_selectedMonth);
    if (currentIndex == null) return null;
    final targetIndex = currentIndex + delta;
    if (targetIndex < 0 || targetIndex >= _monthOrder.length) return null;
    return _monthOrder[targetIndex];
  }

  GlobalKey _monthChipKey(int month, {required bool isLandscape}) {
    final bucket = isLandscape ? _sideMonthChipKeys : _mobileMonthChipKeys;
    return bucket.putIfAbsent(month, GlobalKey.new);
  }

  void _scheduleSelectedMonthVisibility() {
    final month = _selectedMonth;
    if (month == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureMonthChipVisible(
        key: _mobileMonthChipKeys[month],
        controller: _mobileMonthsController,
      );
      _ensureMonthChipVisible(
        key: _sideMonthChipKeys[month],
        controller: _sideMonthsController,
      );
    });
  }

  void _ensureMonthChipVisible({
    required GlobalKey? key,
    required ScrollController controller,
  }) {
    if (!controller.hasClients) return;
    final targetContext = key?.currentContext;
    if (targetContext == null) return;
    final renderObject = targetContext.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;
    final viewport = RenderAbstractViewport.of(renderObject);

    final revealOffset = viewport.getOffsetToReveal(renderObject, 0.5).offset;
    final clampedOffset = revealOffset.clamp(
      controller.position.minScrollExtent,
      controller.position.maxScrollExtent,
    );
    final targetOffset = (clampedOffset as num).toDouble();
    if ((controller.offset - targetOffset).abs() < 1) return;

    controller.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _selectMonth(int month) {
    if (_selectedMonth == month) {
      _scheduleSelectedMonthVisibility();
      return;
    }
    setState(() => _selectedMonth = month);
    _scheduleSelectedMonthVisibility();
  }

  void _moveMonth(int delta) {
    final targetMonth = _adjacentMonth(delta);
    if (targetMonth == null) return;
    _selectMonth(targetMonth);
  }

  String _yearChipLabel(int year) => _localizeDigits(year.toString());

  Future<void> _selectHijriYear(int year) async {
    if (_selectedHijriYear == year) return;
    setState(() {
      _selectedHijriYear = year;
      _expandedDayYmd = null;
    });
    await _loadCalendar();
  }

  @override
  void dispose() {
    _mobileMonthsController.dispose();
    _sideMonthsController.dispose();
    super.dispose();
  }

  Future<void> _openEditor(_CalendarDayVm dayVm) async {
    if (!dayVm.editable) return;

    final changed = await showAppDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _PrayerCalendarEditorDialog(cubit: cubit, dayVm: dayVm);
      },
    );

    if (changed == true && mounted) {
      await _loadCalendar();
    }
  }

  void _toggleExpandedDay(_CalendarDayVm dayVm) {
    setState(() {
      _expandedDayYmd = _expandedDayYmd == dayVm.day.gregorianYmd
          ? null
          : dayVm.day.gregorianYmd;
    });
  }

  String _monthChipLabel(int month) {
    final monthVm = _days.cast<_CalendarDayVm?>().firstWhere(
      (day) => day?.hijriMonth == month,
      orElse: () => null,
    );
    if (monthVm == null) return '';
    return monthVm.hijriMonthName;
  }

  @override
  Widget build(BuildContext context) {
    final city = cubit.getCity();
    final selectedYear = _selectedHijriYear;
    final selectedYearLabel =
        '${LocaleKeys.prayer_calendar_hijri_year.tr()} ${_localizeDigits(selectedYear.toString())}';

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      bottomNavigationBar: const GlobalCopyrightFooter(),
      drawer: CustomDrawer(context: context),
      body: Stack(
        children: [
          Image.asset(
            CacheHelper.getSelectedBackground(),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fill,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.42),
                  Colors.black.withValues(alpha: 0.18),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _CalendarTopBar(
                  onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  onClose: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryTextColor,
                            ),
                          )
                        : _isLandscape
                        ? Row(
                            children: [
                              SizedBox(
                                width: 265.w,
                                child: _CalendarSidePanel(
                                  title: LocaleKeys.hijriPrayerCalendarTitle
                                      .tr(),
                                  note: LocaleKeys.prayer_calendar_note.tr(),
                                  cityName: city == null
                                      ? '--'
                                      : (CacheHelper.getLang() == 'en'
                                            ? city.nameEn
                                            : city.nameAr),
                                  hijriYearLabel: selectedYearLabel,
                                  availableHijriYears: _availableHijriYears,
                                  selectedHijriYear: _selectedHijriYear,
                                  hijriYearChipLabelBuilder: _yearChipLabel,
                                  onHijriYearSelected: _selectHijriYear,
                                  monthOrder: _monthOrder,
                                  selectedMonth: _selectedMonth,
                                  monthLabelBuilder: _monthChipLabel,
                                  monthsScrollController: _sideMonthsController,
                                  monthChipKeyBuilder: (month) =>
                                      _monthChipKey(month, isLandscape: true),
                                  onMonthSelected: _selectMonth,
                                  selectedMonthLabel: _selectedMonth == null
                                      ? LocaleKeys.hijriPrayerCalendarTitle.tr()
                                      : _monthChipLabel(_selectedMonth!),
                                  onLeftArrowTap: _adjacentMonth(1) == null
                                      ? null
                                      : () => _moveMonth(1),
                                  onRightArrowTap: _adjacentMonth(-1) == null
                                      ? null
                                      : () => _moveMonth(-1),
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: _CalendarDaysPanel(
                                  title: _selectedMonth == null
                                      ? LocaleKeys.hijriPrayerCalendarTitle.tr()
                                      : _monthChipLabel(_selectedMonth!),
                                  subtitle:
                                      '${LocaleKeys.prayer_calendar_editable_today_future.tr()} • ${LocaleKeys.prayer_calendar_read_only_past.tr()}',
                                  days: _selectedMonthDays,
                                  expandedDayYmd: _expandedDayYmd,
                                  onToggleDay: _toggleExpandedDay,
                                  onEditDay: _openEditor,
                                  formatTime: (dateTime) =>
                                      _formatDateTime(dateTime),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _CalendarSummaryCard(
                                title: LocaleKeys.hijriPrayerCalendarTitle.tr(),
                                note: LocaleKeys.prayer_calendar_note.tr(),
                                cityName: city == null
                                    ? '--'
                                    : (CacheHelper.getLang() == 'en'
                                          ? city.nameEn
                                          : city.nameAr),
                                hijriYearLabel: selectedYearLabel,
                                availableHijriYears: _availableHijriYears,
                                selectedHijriYear: _selectedHijriYear,
                                hijriYearChipLabelBuilder: _yearChipLabel,
                                onHijriYearSelected: _selectHijriYear,
                              ),
                              SizedBox(height: 12.h),
                              _CalendarMonthSelectorBar(
                                onLeftArrowTap: _adjacentMonth(1) == null
                                    ? null
                                    : () => _moveMonth(1),
                                onRightArrowTap: _adjacentMonth(-1) == null
                                    ? null
                                    : () => _moveMonth(-1),
                                child: Directionality(
                                  textDirection: ui.TextDirection.rtl,
                                  child: SizedBox(
                                    height: 48.h,
                                    child: SingleChildScrollView(
                                      controller: _mobileMonthsController,
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        textDirection: ui.TextDirection.rtl,
                                        children: [
                                          for (
                                            var index = 0;
                                            index < _monthOrder.length;
                                            index++
                                          ) ...[
                                            if (index > 0) SizedBox(width: 8.w),
                                            _CalendarMonthChip(
                                              key: _monthChipKey(
                                                _monthOrder[index],
                                                isLandscape: false,
                                              ),
                                              label: _monthChipLabel(
                                                _monthOrder[index],
                                              ),
                                              selected:
                                                  _monthOrder[index] ==
                                                  _selectedMonth,
                                              dense: true,
                                              onTap: () => _selectMonth(
                                                _monthOrder[index],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Expanded(
                                child: _CalendarDaysPanel(
                                  title: _selectedMonth == null
                                      ? LocaleKeys.hijriPrayerCalendarTitle.tr()
                                      : _monthChipLabel(_selectedMonth!),
                                  subtitle:
                                      '${LocaleKeys.prayer_calendar_editable_today_future.tr()} • ${LocaleKeys.prayer_calendar_read_only_past.tr()}',
                                  days: _selectedMonthDays,
                                  expandedDayYmd: _expandedDayYmd,
                                  onToggleDay: _toggleExpandedDay,
                                  onEditDay: _openEditor,
                                  formatTime: (dateTime) =>
                                      _formatDateTime(dateTime),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    final timeOfDay = TimeOfDay.fromDateTime(dateTime);
    return DateHelper.formatTimeWithSettings(timeOfDay, context);
  }
}

class _CalendarTopBar extends StatelessWidget {
  const _CalendarTopBar({required this.onMenu, required this.onClose});

  final VoidCallback onMenu;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close,
              color: AppTheme.primaryTextColor,
              size: 26.r,
            ),
          ),
          Expanded(
            child: Text(
              LocaleKeys.hijriPrayerCalendarTitle.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                fontFamily: CacheHelper.getTextsFontFamily(),
              ),
            ),
          ),
          IconButton(
            onPressed: onMenu,
            icon: Icon(
              Icons.menu,
              color: AppTheme.primaryTextColor,
              size: 26.r,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarSummaryCard extends StatelessWidget {
  const _CalendarSummaryCard({
    required this.title,
    required this.note,
    required this.cityName,
    required this.hijriYearLabel,
    required this.availableHijriYears,
    required this.selectedHijriYear,
    required this.hijriYearChipLabelBuilder,
    required this.onHijriYearSelected,
  });

  final String title;
  final String note;
  final String cityName;
  final String hijriYearLabel;
  final List<int> availableHijriYears;
  final int selectedHijriYear;
  final String Function(int year) hijriYearChipLabelBuilder;
  final ValueChanged<int> onHijriYearSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryTextColor,
              fontFamily: CacheHelper.getTextsFontFamily(),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            note,
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.5,
              color: AppTheme.primaryTextColor.withValues(alpha: 0.88),
              fontFamily: CacheHelper.getTextsFontFamily(),
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _InfoBadge(label: cityName),
              _InfoBadge(label: hijriYearLabel),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            LocaleKeys.prayer_calendar_hijri_year.tr(),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryTextColor.withValues(alpha: 0.90),
              fontFamily: CacheHelper.getTextsFontFamily(),
            ),
          ),
          SizedBox(height: 8.h),
          _CalendarYearDropdown(
            availableHijriYears: availableHijriYears,
            selectedHijriYear: selectedHijriYear,
            hijriYearLabelBuilder: hijriYearChipLabelBuilder,
            onHijriYearSelected: onHijriYearSelected,
          ),
        ],
      ),
    );
  }
}

class _CalendarSidePanel extends StatelessWidget {
  const _CalendarSidePanel({
    required this.title,
    required this.note,
    required this.cityName,
    required this.hijriYearLabel,
    required this.availableHijriYears,
    required this.selectedHijriYear,
    required this.hijriYearChipLabelBuilder,
    required this.onHijriYearSelected,
    required this.monthOrder,
    required this.selectedMonth,
    required this.monthLabelBuilder,
    required this.monthsScrollController,
    required this.monthChipKeyBuilder,
    required this.onMonthSelected,
    required this.selectedMonthLabel,
    this.onLeftArrowTap,
    this.onRightArrowTap,
  });

  final String title;
  final String note;
  final String cityName;
  final String hijriYearLabel;
  final List<int> availableHijriYears;
  final int selectedHijriYear;
  final String Function(int year) hijriYearChipLabelBuilder;
  final ValueChanged<int> onHijriYearSelected;
  final List<int> monthOrder;
  final int? selectedMonth;
  final String Function(int month) monthLabelBuilder;
  final ScrollController monthsScrollController;
  final Key Function(int month) monthChipKeyBuilder;
  final ValueChanged<int> onMonthSelected;
  final String selectedMonthLabel;
  final VoidCallback? onLeftArrowTap;
  final VoidCallback? onRightArrowTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CalendarSummaryCard(
            title: title,
            note: note,
            cityName: cityName,
            hijriYearLabel: hijriYearLabel,
            availableHijriYears: availableHijriYears,
            selectedHijriYear: selectedHijriYear,
            hijriYearChipLabelBuilder: hijriYearChipLabelBuilder,
            onHijriYearSelected: onHijriYearSelected,
          ),
          SizedBox(height: 16.h),
          _CalendarMonthSelectorBar(
            onLeftArrowTap: onLeftArrowTap,
            onRightArrowTap: onRightArrowTap,
            child: _CalendarCurrentMonthBadge(label: selectedMonthLabel),
          ),
          SizedBox(height: 14.h),
          Expanded(
            child: SingleChildScrollView(
              controller: monthsScrollController,
              child: Column(
                children: [
                  for (var index = 0; index < monthOrder.length; index++) ...[
                    if (index > 0) SizedBox(height: 10.h),
                    _CalendarMonthChip(
                      key: monthChipKeyBuilder(monthOrder[index]),
                      label: monthLabelBuilder(monthOrder[index]),
                      selected: monthOrder[index] == selectedMonth,
                      onTap: () => onMonthSelected(monthOrder[index]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarMonthSelectorBar extends StatelessWidget {
  const _CalendarMonthSelectorBar({
    required this.child,
    this.onLeftArrowTap,
    this.onRightArrowTap,
  });

  final Widget child;
  final VoidCallback? onLeftArrowTap;
  final VoidCallback? onRightArrowTap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Row(
        children: [
          _CalendarMonthArrowButton(pointsLeft: true, onTap: onLeftArrowTap),
          SizedBox(width: 8.w),
          Expanded(child: child),
          SizedBox(width: 8.w),
          _CalendarMonthArrowButton(pointsLeft: false, onTap: onRightArrowTap),
        ],
      ),
    );
  }
}

class _CalendarCurrentMonthBadge extends StatelessWidget {
  const _CalendarCurrentMonthBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: AppTheme.dialogBackgroundColor.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15.5.sp,
          fontWeight: FontWeight.w800,
          color: AppTheme.dialogBodyTextColor,
          fontFamily: CacheHelper.getTextsFontFamily(),
        ),
      ),
    );
  }
}

class _CalendarMonthChip extends StatelessWidget {
  const _CalendarMonthChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dense = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(dense ? 16.r : 18.r);
    final backgroundColor = selected
        ? AppTheme.primaryButtonBackground
        : AppTheme.dialogBackgroundColor.withValues(alpha: 0.62);
    final textColor = selected
        ? AppTheme.primaryButtonTextColor
        : AppTheme.dialogBodyTextColor;

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: dense ? 14.w : 16.w,
          vertical: dense ? 10.h : 12.h,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: radius,
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: 0.26)
                : Colors.white.withValues(alpha: 0.10),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: (dense ? 14.5 : 16).sp,
            fontWeight: FontWeight.w700,
            color: textColor,
            fontFamily: CacheHelper.getTextsFontFamily(),
          ),
        ),
      ),
    );
  }
}

class _CalendarYearDropdown extends StatelessWidget {
  const _CalendarYearDropdown({
    required this.availableHijriYears,
    required this.selectedHijriYear,
    required this.hijriYearLabelBuilder,
    required this.onHijriYearSelected,
  });

  final List<int> availableHijriYears;
  final int selectedHijriYear;
  final String Function(int year) hijriYearLabelBuilder;
  final ValueChanged<int> onHijriYearSelected;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18.r);

    return DropdownButtonFormField<int>(
      initialValue: selectedHijriYear,
      isExpanded: true,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppTheme.primaryTextColor,
        size: 24.r,
      ),
      borderRadius: radius,
      dropdownColor: AppTheme.dialogBackgroundColor,
      menuMaxHeight: 280.h,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.dialogBackgroundColor.withValues(alpha: 0.68),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: AppTheme.primaryButtonBackground.withValues(alpha: 0.92),
            width: 1.6,
          ),
        ),
      ),
      style: TextStyle(
        fontSize: 14.5.sp,
        fontWeight: FontWeight.w700,
        color: AppTheme.dialogBodyTextColor,
        fontFamily: CacheHelper.getTextsFontFamily(),
      ),
      selectedItemBuilder: (context) {
        return availableHijriYears
            .map(
              (year) => Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  hijriYearLabelBuilder(year),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.dialogBodyTextColor,
                    fontFamily: CacheHelper.getTextsFontFamily(),
                  ),
                ),
              ),
            )
            .toList();
      },
      items: [
        for (final year in availableHijriYears)
          DropdownMenuItem<int>(
            value: year,
            child: Text(
              hijriYearLabelBuilder(year),
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.dialogBodyTextColor,
                fontFamily: CacheHelper.getTextsFontFamily(),
              ),
            ),
          ),
      ],
      onChanged: (year) {
        if (year == null) return;
        onHijriYearSelected(year);
      },
    );
  }
}

class _CalendarDaysPanel extends StatelessWidget {
  const _CalendarDaysPanel({
    required this.title,
    required this.subtitle,
    required this.days,
    required this.expandedDayYmd,
    required this.onToggleDay,
    required this.onEditDay,
    required this.formatTime,
  });

  final String title;
  final String subtitle;
  final List<_CalendarDayVm> days;
  final String? expandedDayYmd;
  final ValueChanged<_CalendarDayVm> onToggleDay;
  final ValueChanged<_CalendarDayVm> onEditDay;
  final String Function(DateTime? dateTime) formatTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryTextColor,
              fontFamily: CacheHelper.getTextsFontFamily(),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.45,
              color: AppTheme.primaryTextColor.withValues(alpha: 0.82),
              fontFamily: CacheHelper.getTextsFontFamily(),
            ),
          ),
          SizedBox(height: 14.h),
          Expanded(
            child: days.isEmpty
                ? Center(
                    child: Text(
                      LocaleKeys.prayer_calendar_no_days.tr(),
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: CacheHelper.getTextsFontFamily(),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemBuilder: (context, index) {
                      final dayVm = days[index];
                      return _PrayerCalendarDayCard(
                        dayVm: dayVm,
                        isExpanded: expandedDayYmd == dayVm.day.gregorianYmd,
                        formatTime: formatTime,
                        onToggle: () => onToggleDay(dayVm),
                        onEdit: dayVm.editable ? () => onEditDay(dayVm) : null,
                      );
                    },
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemCount: days.length,
                  ),
          ),
        ],
      ),
    );
  }
}

class _CalendarMonthArrowButton extends StatelessWidget {
  const _CalendarMonthArrowButton({
    required this.pointsLeft,
    required this.onTap,
  });

  final bool pointsLeft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        width: 42.r,
        height: 42.r,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.primaryButtonBackground.withValues(alpha: 0.96)
              : AppTheme.dialogBackgroundColor.withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: enabled ? 0.18 : 0.06),
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : const [],
        ),
        child: Icon(
          pointsLeft ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
          color: enabled
              ? AppTheme.primaryButtonTextColor
              : AppTheme.dialogBodyTextColor.withValues(alpha: 0.35),
          size: 25.r,
          textDirection: ui.TextDirection.ltr,
        ),
      ),
    );
  }
}

class _PrayerCalendarDayCard extends StatelessWidget {
  const _PrayerCalendarDayCard({
    required this.dayVm,
    required this.isExpanded,
    required this.formatTime,
    required this.onToggle,
    this.onEdit,
  });

  final _CalendarDayVm dayVm;
  final bool isExpanded;
  final String Function(DateTime? dateTime) formatTime;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final cubit = AppCubit.get(context);
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(22.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: dayVm.editable
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: dayVm.edited
                ? AppTheme.primaryButtonBackground.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dayVm.hijriDay} ${dayVm.hijriMonthName}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryTextColor,
                          fontFamily: CacheHelper.getTextsFontFamily(),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        dayVm.weekdayLabel,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondaryTextColor,
                          fontFamily: CacheHelper.getTextsFontFamily(),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${LocaleKeys.prayer_calendar_gregorian.tr()}: ${dayVm.gregorianLabel}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.primaryTextColor.withValues(
                            alpha: 0.88,
                          ),
                          fontFamily: CacheHelper.getTextsFontFamily(),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StateBadge(
                      label: dayVm.edited
                          ? LocaleKeys.prayer_calendar_edited.tr()
                          : (dayVm.editable
                                ? LocaleKeys
                                      .prayer_calendar_editable_today_future
                                      .tr()
                                : LocaleKeys.prayer_calendar_read_only_past
                                      .tr()),
                      highlighted: dayVm.edited,
                    ),
                    SizedBox(height: 10.h),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.primaryTextColor.withValues(alpha: 0.88),
                      size: 24.r,
                    ),
                    if (dayVm.editable && isExpanded) ...[
                      SizedBox(height: 8.h),
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(999.r),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryButtonBackground.withValues(
                              alpha: 0.16,
                            ),
                            borderRadius: BorderRadius.circular(999.r),
                            border: Border.all(
                              color: AppTheme.primaryButtonBackground
                                  .withValues(alpha: 0.36),
                            ),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            color: AppTheme.primaryTextColor,
                            size: 17.r,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: EdgeInsets.only(top: 14.h),
                child: Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: List<Widget>.generate(6, (index) {
                    final prayerId = index + 1;
                    final prayer = Prayer(
                      id: prayerId,
                      title: prayerId == 3
                          ? (PrayerCalendarHelper.isFriday(
                                  dayVm.day.gregorianDate,
                                )
                                ? LocaleKeys.friday.tr()
                                : LocaleKeys.dhuhr.tr())
                          : _prayerTitle(prayerId),
                      time: null,
                      dateTime: cubit.effectiveAdhanTimeForCalendarDay(
                        dayVm.day,
                        prayerId,
                      ),
                      time24: null,
                    );
                    final iqama = cubit.effectiveIqamaTimeForCalendarDay(
                      dayVm.day,
                      prayerId,
                      defaultIqamaOffsets: dayVm.defaultIqamaOffsets,
                    );
                    return _PrayerPreviewPill(
                      prayerName: prayer.title,
                      adhanTime: formatTime(prayer.dateTime),
                      iqamaTime: formatTime(iqama),
                    );
                  }),
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
              sizeCurve: Curves.easeOutCubic,
              firstCurve: Curves.easeOutCubic,
              secondCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    );
  }

  String _prayerTitle(int prayerId) {
    switch (prayerId) {
      case 1:
        return LocaleKeys.fajr.tr();
      case 2:
        return LocaleKeys.sunrise.tr();
      case 4:
        return LocaleKeys.asr.tr();
      case 5:
        return LocaleKeys.maghrib.tr();
      case 6:
        return LocaleKeys.isha.tr();
      default:
        return LocaleKeys.dhuhr.tr();
    }
  }
}

class _PrayerPreviewPill extends StatelessWidget {
  const _PrayerPreviewPill({
    required this.prayerName,
    required this.adhanTime,
    required this.iqamaTime,
  });

  final String prayerName;
  final String adhanTime;
  final String iqamaTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.26),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prayerName,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryTextColor,
              fontFamily: CacheHelper.getTextsFontFamily(),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '${LocaleKeys.adhan.tr()}: $adhanTime',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppTheme.secondaryTextColor,
              fontWeight: FontWeight.w700,
              fontFamily: CacheHelper.getTextsFontFamily(),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '${LocaleKeys.iqama_time.tr()}: $iqamaTime',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.w700,
              fontFamily: CacheHelper.getTextsFontFamily(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerCalendarEditorDialog extends StatefulWidget {
  const _PrayerCalendarEditorDialog({required this.cubit, required this.dayVm});

  final AppCubit cubit;
  final _CalendarDayVm dayVm;

  @override
  State<_PrayerCalendarEditorDialog> createState() =>
      _PrayerCalendarEditorDialogState();
}

class _PrayerCalendarEditorDialogState
    extends State<_PrayerCalendarEditorDialog> {
  late PrayerCalendarDay _workingDay;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _workingDay = widget.dayVm.day;
  }

  DateTime? _effectiveAdhan(int prayerId) {
    return widget.cubit.effectiveAdhanTimeForCalendarDay(_workingDay, prayerId);
  }

  DateTime? _effectiveIqama(int prayerId) {
    return widget.cubit.effectiveIqamaTimeForCalendarDay(
      _workingDay,
      prayerId,
      defaultIqamaOffsets: widget.dayVm.defaultIqamaOffsets,
    );
  }

  String _localizeDigits(String raw) {
    return CacheHelper.getIsArabicNumbersEnabled()
        ? DateHelper.toArabicDigits(raw)
        : DateHelper.toWesternDigits(raw);
  }

  String _prayerTitle(int prayerId) {
    switch (prayerId) {
      case 1:
        return LocaleKeys.fajr.tr();
      case 2:
        return LocaleKeys.sunrise.tr();
      case 3:
        return PrayerCalendarHelper.isFriday(_workingDay.gregorianDate)
            ? LocaleKeys.friday.tr()
            : LocaleKeys.dhuhr.tr();
      case 4:
        return LocaleKeys.asr.tr();
      case 5:
        return LocaleKeys.maghrib.tr();
      case 6:
        return LocaleKeys.isha.tr();
      default:
        return LocaleKeys.dhuhr.tr();
    }
  }

  void _adjustTime({
    required int prayerId,
    required bool isIqama,
    required int deltaMinutes,
  }) {
    final current = isIqama
        ? _effectiveIqama(prayerId)
        : _effectiveAdhan(prayerId);
    if (current == null) return;

    final totalMinutes = (current.hour * 60) + current.minute + deltaMinutes;
    final normalized = ((totalMinutes % 1440) + 1440) % 1440;
    final minutes = normalized;

    setState(() {
      _workingDay = _workingDay.withPrayerOverride(
        prayerId: prayerId,
        manualAdhanMinutes: isIqama ? null : minutes,
        manualIqamaMinutes: isIqama ? minutes : null,
      );
    });
  }

  void _setManualTime({
    required int prayerId,
    required bool isIqama,
    required int hour,
    required int minute,
  }) {
    final totalMinutes = (hour * 60) + minute;

    setState(() {
      _workingDay = _workingDay.withPrayerOverride(
        prayerId: prayerId,
        manualAdhanMinutes: isIqama ? null : totalMinutes,
        manualIqamaMinutes: isIqama ? totalMinutes : null,
      );
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await widget.cubit.savePrayerCalendarDayOverrides(
      date: _workingDay.gregorianDate,
      manualAdhanMinutesByPrayerId: _workingDay.manualAdhanMinutesByPrayerId,
      manualIqamaMinutesByPrayerId: _workingDay.manualIqamaMinutesByPrayerId,
      city: widget.cubit.getCity()?.nameEn,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _resetDay() async {
    setState(() => _isSaving = true);
    await widget.cubit.resetPrayerCalendarDayOverrides(
      date: _workingDay.gregorianDate,
      city: widget.cubit.getCity()?.nameEn,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    final isCompactPortrait =
        mediaSize.width < 700 && mediaSize.height > mediaSize.width;
    final dialogWidth = isCompactPortrait
        ? mediaSize.width - 24.w
        : (mediaSize.width > 1100 ? 780.w : 700.w);
    final actionButtonHeight = isCompactPortrait ? 54.h : 50.h;
    final actionLabelStyle = TextStyle(
      fontSize: isCompactPortrait ? 15.sp : 14.sp,
      fontWeight: FontWeight.w800,
      fontFamily: CacheHelper.getTextsFontFamily(),
    );

    final cancelStyle = OutlinedButton.styleFrom(
      minimumSize: Size(double.infinity, actionButtonHeight),
      foregroundColor: AppTheme.primaryTextColor,
      backgroundColor: Colors.white.withValues(alpha: 0.04),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      textStyle: actionLabelStyle,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    );
    final resetStyle = OutlinedButton.styleFrom(
      minimumSize: Size(double.infinity, actionButtonHeight),
      foregroundColor: AppTheme.primaryTextColor,
      backgroundColor: AppTheme.primaryButtonBackground.withValues(alpha: 0.12),
      side: BorderSide(
        color: AppTheme.primaryButtonBackground.withValues(alpha: 0.36),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      textStyle: actionLabelStyle,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    );
    final saveStyle = FilledButton.styleFrom(
      minimumSize: Size(double.infinity, actionButtonHeight),
      backgroundColor: DialogPalette.primaryButtonBackground,
      foregroundColor: DialogPalette.primaryButtonText,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      textStyle: actionLabelStyle,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    );

    return UniversalDialogShell(
      customMaxWidth: dialogWidth,
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.hijriPrayerCalendarTitle.tr(),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: DialogPalette.titleTextColor,
                  fontFamily: CacheHelper.getTextsFontFamily(),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                '${widget.dayVm.weekdayLabel} • ${widget.dayVm.hijriDay} ${widget.dayVm.hijriMonthName} • ${widget.dayVm.gregorianLabel}',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: DialogPalette.mutedTextColor,
                  fontWeight: FontWeight.w700,
                  fontFamily: CacheHelper.getTextsFontFamily(),
                ),
              ),
              SizedBox(height: 16.h),
              ...List<Widget>.generate(6, (index) {
                final prayerId = index + 1;
                final adhan = _effectiveAdhan(prayerId);
                final iqama = _effectiveIqama(prayerId);
                final hasOverride = _workingDay.hasPrayerOverride(prayerId);

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: hasOverride
                            ? DialogPalette.primaryButtonBackground.withValues(
                                alpha: 0.55,
                              )
                            : DialogPalette.dividerColor,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _prayerTitle(prayerId),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: DialogPalette.bodyTextColor,
                                  fontFamily: CacheHelper.getTextsFontFamily(),
                                ),
                              ),
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: DialogPalette.mutedTextColor,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.05,
                                ),
                                textStyle: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: CacheHelper.getTextsFontFamily(),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 8.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _workingDay = _workingDay
                                      .clearPrayerOverrides(prayerId);
                                });
                              },
                              icon: Icon(
                                Icons.refresh_rounded,
                                size: 18.r,
                                color: DialogPalette.mutedTextColor,
                              ),
                              label: Text(LocaleKeys.reset.tr()),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(
                              child: _InlineTimeEditor(
                                label: LocaleKeys.adhan.tr(),
                                initial: adhan,
                                use24Hour: CacheHelper.getUse24HoursFormat(),
                                localizeDigits: _localizeDigits,
                                onAdjustMinutes: (delta) => _adjustTime(
                                  prayerId: prayerId,
                                  isIqama: false,
                                  deltaMinutes: delta,
                                ),
                                onSetManual: (hour, minute) => _setManualTime(
                                  prayerId: prayerId,
                                  isIqama: false,
                                  hour: hour,
                                  minute: minute,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _InlineTimeEditor(
                                label: LocaleKeys.iqama_time.tr(),
                                initial: iqama,
                                use24Hour: CacheHelper.getUse24HoursFormat(),
                                localizeDigits: _localizeDigits,
                                onAdjustMinutes: (delta) => _adjustTime(
                                  prayerId: prayerId,
                                  isIqama: true,
                                  deltaMinutes: delta,
                                ),
                                onSetManual: (hour, minute) => _setManualTime(
                                  prayerId: prayerId,
                                  isIqama: true,
                                  hour: hour,
                                  minute: minute,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 6.h),
              if (isCompactPortrait) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: cancelStyle,
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, size: 18.r),
                    label: Text(LocaleKeys.common_cancel.tr()),
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: resetStyle,
                    onPressed: _isSaving ? null : _resetDay,
                    icon: Icon(Icons.restart_alt_rounded, size: 18.r),
                    label: Text(
                      LocaleKeys.prayer_calendar_reset_day.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: saveStyle,
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? SizedBox(
                            height: 16.r,
                            width: 16.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryButtonTextColor,
                            ),
                          )
                        : Icon(Icons.check_rounded, size: 18.r),
                    label: Text(LocaleKeys.common_save.tr()),
                  ),
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: cancelStyle,
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, size: 18.r),
                        label: Text(LocaleKeys.common_cancel.tr()),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: resetStyle,
                        onPressed: _isSaving ? null : _resetDay,
                        icon: Icon(Icons.restart_alt_rounded, size: 18.r),
                        label: Text(
                          LocaleKeys.prayer_calendar_reset_day.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: FilledButton.icon(
                        style: saveStyle,
                        onPressed: _isSaving ? null : _save,
                        icon: _isSaving
                            ? SizedBox(
                                height: 16.r,
                                width: 16.r,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryButtonTextColor,
                                ),
                              )
                            : Icon(Icons.check_rounded, size: 18.r),
                        label: Text(LocaleKeys.common_save.tr()),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// ⏰ Inline Time Editor — تعديل مباشر بالساعة والدقيقة
/// ============================================================================

class _InlineTimeEditor extends StatelessWidget {
  const _InlineTimeEditor({
    required this.label,
    required this.initial,
    required this.use24Hour,
    required this.localizeDigits,
    required this.onAdjustMinutes,
    required this.onSetManual,
  });

  final String label;
  final DateTime? initial;
  final bool use24Hour;
  final String Function(String raw) localizeDigits;
  final ValueChanged<int> onAdjustMinutes;
  final void Function(int hour, int minute) onSetManual;

  TimeOfDay get _timeOfDay {
    if (initial == null) return TimeOfDay.now();
    return TimeOfDay.fromDateTime(initial!);
  }

  int get _hourDisplay {
    if (use24Hour) return _timeOfDay.hour;
    final h = _timeOfDay.hourOfPeriod == 0 ? 12 : _timeOfDay.hourOfPeriod;
    return h;
  }

  String get _periodSuffix {
    if (use24Hour) return '';
    return _timeOfDay.period == DayPeriod.am
        ? (CacheHelper.getLang() == 'ar' ? 'ص' : 'AM')
        : (CacheHelper.getLang() == 'ar' ? 'م' : 'PM');
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = initial != null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.secondaryTextColor,
              fontWeight: FontWeight.w700,
              fontFamily: CacheHelper.getTextsFontFamily(),
            ),
          ),
          SizedBox(height: 6.h),
          if (!hasValue)
            Center(
              child: Text(
                '--:--',
                style: TextStyle(
                  fontSize: 17.sp,
                  color: AppTheme.primaryTextColor.withValues(alpha: 0.35),
                  fontWeight: FontWeight.w800,
                  fontFamily: CacheHelper.getTimesFontFamily(),
                ),
              ),
            )
          else
            Center(
              child: Directionality(
                textDirection: widgets.TextDirection.ltr,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Hour stepper (always on right in RTL)
                      _StepperColumn(
                        title: localizeDigits(
                          _hourDisplay.toString().padLeft(2, '0'),
                        ),
                        onMinus: () => onAdjustMinutes(
                          -(use24Hour ? 60 : (_timeOfDay.hour >= 12 ? 60 : 60)),
                        ),
                        onPlus: () => onAdjustMinutes(
                          use24Hour ? 60 : (_timeOfDay.hour >= 12 ? 60 : 60),
                        ),
                        onTapField: () => _openHourNumpad(context),
                      ),
                      // Colon
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: AppTheme.primaryTextColor,
                            fontWeight: FontWeight.w800,
                            fontFamily: CacheHelper.getTimesFontFamily(),
                          ),
                        ),
                      ),
                      // Minute stepper (always on left in RTL)
                      _StepperColumn(
                        title: localizeDigits(
                          _timeOfDay.minute.toString().padLeft(2, '0'),
                        ),
                        onMinus: () => onAdjustMinutes(-1),
                        onPlus: () => onAdjustMinutes(1),
                        onTapField: () => _openMinuteNumpad(context),
                      ),
                      if (_periodSuffix.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(left: 3.w),
                          child: Text(
                            _periodSuffix,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.w800,
                              fontFamily: CacheHelper.getTextsFontFamily(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openHourNumpad(BuildContext context) {
    if (initial == null) return;
    _openNumpad(
      context,
      title: LocaleKeys.time_hour.tr(),
      initialValue: _hourDisplay,
      max: use24Hour ? 23 : 12,
      min: use24Hour ? 0 : 1,
      onSubmit: (val) {
        int adjustedHour = val;
        if (!use24Hour) {
          // Convert 12h display back to 24h
          final isPM = _timeOfDay.period == DayPeriod.pm;
          if (isPM && adjustedHour != 12) {
            adjustedHour += 12;
          } else if (!isPM && adjustedHour == 12) {
            adjustedHour = 0;
          }
        }
        onSetManual(adjustedHour, _timeOfDay.minute);
      },
    );
  }

  void _openMinuteNumpad(BuildContext context) {
    if (initial == null) return;
    _openNumpad(
      context,
      title: LocaleKeys.time_minute.tr(),
      initialValue: _timeOfDay.minute,
      max: 59,
      min: 0,
      onSubmit: (val) => onSetManual(_timeOfDay.hour, val),
    );
  }

  void _openNumpad(
    BuildContext context, {
    required String title,
    required int initialValue,
    required int max,
    required int min,
    required ValueChanged<int> onSubmit,
  }) {
    // Use rootNavigator to work from within a dialog context where
    // showBottomSheet would fail (no Scaffold ancestor available).
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (ctx) => _TimeNumpad(
        title: title,
        initialValue: localizeDigits(initialValue.toString().padLeft(2, '0')),
        initialValueRaw: initialValue.toString().padLeft(2, '0'),
        max: max,
        min: min,
        localizeDigits: localizeDigits,
        onSubmit: onSubmit,
      ),
    );
  }
}

/// Small stepper column: minus button, value tap, plus button
class _StepperColumn extends StatelessWidget {
  const _StepperColumn({
    required this.title,
    required this.onMinus,
    required this.onPlus,
    required this.onTapField,
  });

  final String title;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onTapField;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Plus
        SizedBox(
          width: 32.w,
          height: 24.h,
          child: Material(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.r),
            child: InkWell(
              onTap: onPlus,
              borderRadius: BorderRadius.circular(8.r),
              child: Icon(
                Icons.add_rounded,
                size: 18.r,
                color: AppTheme.primaryTextColor,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        // Value
        InkWell(
          onTap: onTapField,
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.w800,
                fontFamily: CacheHelper.getTimesFontFamily(),
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        // Minus
        SizedBox(
          width: 32.w,
          height: 24.h,
          child: Material(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.r),
            child: InkWell(
              onTap: onMinus,
              borderRadius: BorderRadius.circular(8.r),
              child: Icon(
                Icons.remove_rounded,
                size: 18.r,
                color: AppTheme.primaryTextColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ============================================================================
/// 🔢 Time Numpad — لوحة أرقام سريعة
/// ============================================================================

class _TimeNumpad extends StatefulWidget {
  const _TimeNumpad({
    required this.title,
    required this.initialValue,
    required this.initialValueRaw,
    required this.max,
    required this.min,
    required this.localizeDigits,
    required this.onSubmit,
  });

  final String title;
  final String initialValue;
  final String initialValueRaw;
  final int max;
  final int min;
  final String Function(String raw) localizeDigits;
  final ValueChanged<int> onSubmit;

  @override
  State<_TimeNumpad> createState() => _TimeNumpadState();
}

class _TimeNumpadState extends State<_TimeNumpad>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animController;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValueRaw);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_controller.text.length >= 2) {
      _controller.text = digit;
    } else {
      _controller.text = _controller.text + digit;
    }
  }

  void _onBackspace() {
    final current = _controller.text;
    if (current.isNotEmpty) {
      _controller.text = current.substring(0, current.length - 1);
    }
  }

  void _onSubmit() {
    final val = int.tryParse(_controller.text);
    if (val != null && val >= widget.min && val <= widget.max) {
      widget.onSubmit(val);
      Navigator.pop(context);
    }
  }

  Widget _numKey(String label, {VoidCallback? onTap, IconData? icon}) {
    return SizedBox(
      width: 96.w,
      height: 52.h,
      child: Material(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onTap ?? () => _onDigit(label),
          borderRadius: BorderRadius.circular(14.r),
          child: Center(
            child: icon != null
                ? Icon(icon, size: 22.r, color: AppTheme.primaryTextColor)
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryTextColor,
                      fontFamily: CacheHelper.getTimesFontFamily(),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_slideAnim),
      child: Container(
        padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 20.h),
        decoration: BoxDecoration(
          color: AppTheme.dialogBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppTheme.secondaryTextColor,
                fontWeight: FontWeight.w700,
                fontFamily: CacheHelper.getTextsFontFamily(),
              ),
            ),
            SizedBox(height: 6.h),
            // Display value — use ValueListenableBuilder to react to _controller changes
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (_, value, __) {
                final displayText = widget.localizeDigits(
                  value.text.isEmpty ? '0' : value.text.padLeft(2, '0'),
                );
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Text(
                    displayText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryTextColor,
                      fontFamily: CacheHelper.getTimesFontFamily(),
                      letterSpacing: 2,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 12.h),
            // Numpad keys
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _numKey('1'),
                    SizedBox(width: 8.w),
                    _numKey('2'),
                    SizedBox(width: 8.w),
                    _numKey('3'),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _numKey('4'),
                    SizedBox(width: 8.w),
                    _numKey('5'),
                    SizedBox(width: 8.w),
                    _numKey('6'),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _numKey('7'),
                    SizedBox(width: 8.w),
                    _numKey('8'),
                    SizedBox(width: 8.w),
                    _numKey('9'),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _numKey(
                      '⌫',
                      onTap: _onBackspace,
                      icon: Icons.backspace_rounded,
                    ),
                    SizedBox(width: 8.w),
                    _numKey('0'),
                    SizedBox(width: 8.w),
                    _numKey('✓', onTap: _onSubmit, icon: Icons.check_rounded),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.label, required this.highlighted});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: highlighted
            ? AppTheme.primaryButtonBackground.withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          color: highlighted
              ? AppTheme.primaryButtonTextColor
              : AppTheme.primaryTextColor,
          fontFamily: CacheHelper.getTextsFontFamily(),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryTextColor,
          fontFamily: CacheHelper.getTextsFontFamily(),
        ),
      ),
    );
  }
}

class _CalendarDayVm {
  const _CalendarDayVm({
    required this.day,
    required this.hijriDay,
    required this.hijriMonth,
    required this.hijriYear,
    required this.hijriMonthName,
    required this.weekdayLabel,
    required this.gregorianLabel,
    required this.editable,
    required this.defaultIqamaOffsets,
  });

  final PrayerCalendarDay day;
  final int hijriDay;
  final int hijriMonth;
  final int hijriYear;
  final String hijriMonthName;
  final String weekdayLabel;
  final String gregorianLabel;
  final bool editable;
  final List<int> defaultIqamaOffsets;

  bool get edited => day.hasManualOverrides;
}
