import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/prayer_row_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jhijri/_src/_jHijri.dart';

List<bool> computePastIqamaFlags(BuildContext context, AppCubit cubit) {
  final now = DateTime.now();
  return cubit.prayers(context).map((p) {
    if (p.dateTime == null ||
        cubit.iqamaMinutes == null ||
        cubit.iqamaMinutes!.length < p.id) {
      return false;
    }

    final iqamaTime = p.dateTime!.add(
      Duration(minutes: cubit.iqamaMinutes![p.id - 1]),
    );

    return iqamaTime.isBefore(now);
  }).toList();
}

({int day, int month, int year}) _todayHijriParts() {
  final offsetDays = CacheHelper.getHijriOffsetDays();
  final g = DateTime.now().add(Duration(days: offsetDays));
  final h = JHijri(fDate: g);
  return (day: h.day, month: h.month, year: h.year);
}

bool _isTodayHijri({required int day, required int month}) {
  final h = _todayHijriParts();
  return h.day == day && h.month == month;
}

PrayerRowData? _buildEidRow({
  required BuildContext context,
  required String? rawEid,
  required bool shouldShow,
  required String fallbackName,
  required String nextFajrPrayer,
}) {
  if (!shouldShow || rawEid == null || rawEid.length < 2) return null;

  final rawTime = rawEid.trim();
  if (rawTime.isEmpty || rawTime == '--:--') return null;

  final eidTime = DateHelper.displayHHmmNoPeriod(rawTime, context);

  bool eidDimmed = false;
  try {
    final now = DateTime.now();
    final parts = eidTime.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), ''));
      final m = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));
      if (h != null && m != null) {
        final eidDateTime = DateTime(now.year, now.month, now.day, h, m);
        eidDimmed = now.isAfter(eidDateTime);
      }
    }
  } catch (_) {
    eidDimmed = false;
  }

  return PrayerRowData(
    prayerName: fallbackName,
    adhanTime: eidTime,
    iqamaTime: '',
    dimmed: eidDimmed,
    nextFajrPrayer: nextFajrPrayer,
    isSpecial: true,
  );
}

List<PrayerRowData> buildDisplayBoardPrayerRows(
  BuildContext context,
  AppCubit cubit,
  List<bool> pastIqamaFlags,
) {
  final prayers = cubit.prayers(context);
  final iqamaMinutes = cubit.iqamaMinutes;
  final nextFajrPrayer = cubit.nextFajrPrayer?.time24 ?? '--:--';

  final rows = List<PrayerRowData>.generate(prayers.length, (index) {
    final p = prayers[index];
    final dimmed = index < pastIqamaFlags.length && pastIqamaFlags[index];

    final baseTimeStr = CacheHelper.getUse24HoursFormat()
        ? (p.time24 ?? p.time)
        : (p.time ?? p.time24);

    final adhanStr = baseTimeStr != null
        ? DateHelper.displayHHmmNoPeriod(baseTimeStr, context)
        : '--:--';

    final idx = p.id - 1;
    final iqamaStr =
        (baseTimeStr != null &&
            iqamaMinutes != null &&
            idx >= 0 &&
            idx < iqamaMinutes.length)
        ? DateHelper.addMinutesDisplayHHmmNoPeriod(
            baseTimeStr,
            iqamaMinutes[idx],
            context,
          )
        : '--:--';

    return PrayerRowData(
      prayerName: p.title,
      adhanTime: adhanStr,
      iqamaTime: iqamaStr,
      dimmed: dimmed,
      nextFajrPrayer: nextFajrPrayer,
    );
  });

  final showFitr =
      CacheHelper.getShowFitrEid() && _isTodayHijri(day: 1, month: 10);
  final showAdha =
      CacheHelper.getShowAdhaEid() && _isTodayHijri(day: 10, month: 12);

  final fitrRow = _buildEidRow(
    context: context,
    rawEid: CacheHelper.getFitrEid(),
    shouldShow: showFitr,
    fallbackName: LocaleKeys.eid_al_fitr.tr(),
    nextFajrPrayer: nextFajrPrayer,
  );
  final adhaRow = _buildEidRow(
    context: context,
    rawEid: CacheHelper.getAdhaEid(),
    shouldShow: showAdha,
    fallbackName: LocaleKeys.eid_al_adha.tr(),
    nextFajrPrayer: nextFajrPrayer,
  );

  if (fitrRow != null) rows.insert(0, fitrRow);
  if (adhaRow != null) rows.insert(0, adhaRow);
  return rows;
}
