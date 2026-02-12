import 'dart:async';

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/views/home/components/azkar_view.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:azan/views/home/components/azkar_view.dart'; // AzkarType
import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/views/home/components/azkar_view.dart'; // AzkarType
import 'package:flutter/foundation.dart'; // ValueNotifier

// =====================================================
//  Time helper
// =====================================================

class AzkarTimeHelper {
  static const int fajrId = 1;
  static const int sunriseId = 2;
  static const int dhuhrId = 3;
  static const int asrId = 4;
  static const int maghribId = 5;
  static const int ishaId = 6;

  static DateTime? _adhanTime(int id) => AppCubit().adjustedPrayerTimeById(id);
  static DateTime? _startAfterPrayerThenAfterAfterPrayerAzkar(int prayerId) {
    final base = _startAfterPrayer(prayerId);
    if (base == null) return null;

    if (!CacheHelper.getAfterPrayerAzkarEnabled()) return base;

    final mins = CacheHelper.getAfterPrayerAzkarWindowMinutes();
    return base.add(Duration(minutes: mins));
  }

  static void test(int prayerId) {
    final adhan = _adhanTime(prayerId);

    final iqama = adhan!.add(Duration(minutes: _iqamaOffsetMinutes(prayerId)));
    final azkarTime = iqama.add(_prayerHideDuration(prayerId));
    'adhan adhan $adhan iqama iqama $iqama iqamaDuration iqamaDuration $azkarTime'
        .log();
  }

  static int _iqamaOffsetMinutes(int prayerId) {
    final m = AppCubit().iqamaMinutes;
    if (m == null || m.length < prayerId) return 0;
    return m[prayerId - 1];
  }

  static int? durationIndexForPrayerId(int prayerId) {
    switch (prayerId) {
      case fajrId:
        return 0;
      case dhuhrId:
        return 1;
      case asrId:
        return 2;
      case maghribId:
        return 3;
      case ishaId:
        return 4;
      default:
        return null; // sunrise أو أي ID مش محسوب
    }
  }

  static Duration _prayerHideDuration(int prayerId) {
    // final list = AppCubit().prayersDuration; // طولها 5
    // final idx = durationIndexForPrayerId(prayerId);

    // if (idx == null || list == null) {
    //   return const Duration(minutes: 7);
    // }
    // return Duration(minutes: list[idx]);
    // 'nnn'.log();
    return Duration(minutes: AppCubit().getPrayerDurationForId(prayerId));
  }

  /// ✅ بداية نافذة الأذكار بعد الإقامة + مدة الصلاة
  static DateTime? _startAfterPrayer(int prayerId) {
    final adhan = _adhanTime(prayerId);
    if (adhan == null) return null;

    final iqama = adhan.add(Duration(minutes: _iqamaOffsetMinutes(prayerId)));
    return iqama.add(_prayerHideDuration(prayerId));
  }

  static AzkarWindow? _morningWindow(DateTime n) {
    if (!CacheHelper.getMorningAzkarEnabled()) return null;

    final start = _startAfterPrayerThenAfterAfterPrayerAzkar(fajrId);
    if (start == null) return null;

    final end = start.add(
      Duration(minutes: CacheHelper.getMorningAzkarWindowMinutes()),
    );

    if (!n.isBefore(start) && n.isBefore(end)) {
      return AzkarWindow(type: AzkarType.morning, start: start, end: end);
    }
    return null;
  }

  static AzkarWindow? _eveningWindow(DateTime n) {
    if (!CacheHelper.getEveningAzkarEnabled()) return null;

    final start = _startAfterPrayerThenAfterAfterPrayerAzkar(maghribId);
    if (start == null) return null;

    final end = start.add(
      Duration(minutes: CacheHelper.getEveningAzkarWindowMinutes()),
    );

    if (!n.isBefore(start) && n.isBefore(end)) {
      return AzkarWindow(type: AzkarType.evening, start: start, end: end);
    }
    return null;
  }

  static AzkarWindow? _afterPrayerWindow(DateTime n) {
    if (!CacheHelper.getAfterPrayerAzkarEnabled()) return null;

    for (final id in const [fajrId, dhuhrId, asrId, maghribId, ishaId]) {
      final w = _afterPrayerWindowForId(n, id);
      if (w != null) return w;
    }
    return null;
  }

  static int? boolTest() {
    for (final id in const [fajrId, dhuhrId, asrId, maghribId, ishaId]) {
      return id;
    }
    return null;
  }

  static AzkarWindow? _afterPrayerWindowForId(DateTime n, int id) {
    if (!CacheHelper.getAfterPrayerAzkarEnabled()) return null;

    final start = _startAfterPrayer(id);
    if (start == null) return null;

    final end = start.add(
      Duration(minutes: CacheHelper.getAfterPrayerAzkarWindowMinutes()),
    );

    if (!n.isBefore(start) && n.isBefore(end)) {
      return AzkarWindow(
        type: AzkarType.afterPrayer,
        start: start,
        end: end,
        prayerId: id,
      );
    }
    return null;
  }

  static AzkarWindow? currentWindow({DateTime? now}) {
    final n = now ?? DateTime.now();

    final m = _morningWindow(n);
    if (m != null) return m;

    final e = _eveningWindow(n);
    if (e != null) return e;

    return _afterPrayerWindow(n);
  }
}

// =====================================================
//  Window model
// =====================================================
class AzkarWindow {
  final AzkarType type;
  final DateTime start;
  final DateTime end;
  final int? prayerId; // للأذكار بعد الصلاة

  const AzkarWindow({
    required this.type,
    required this.start,
    required this.end,
    this.prayerId,
  });

  String get signature =>
      '${type.name}-${prayerId ?? 0}-${start.millisecondsSinceEpoch}';
}

// =====================================================
//  Overlay controller (ValueListenable-ready)
// =====================================================
class AzkarOverlayController extends ValueNotifier<AzkarWindow?> {
  AzkarOverlayController() : super(null);

  AzkarWindow? _activeWindow;
  String? _dismissedSignature;

  bool get hasActiveWindow => _activeWindow != null;

  /// نادِ عليها من `_tickTimer` بتاع الهوم (كل ثانية).
  void tick({DateTime? now}) {
    final w = AzkarTimeHelper.currentWindow(now: now);

    // مفيش نافذة -> اقفل الأذكار وامسح dismissed
    if (w == null) {
      _activeWindow = null;
      _dismissedSignature = null;
      if (value != null) value = null;
      return;
    }

    final newSig = w.signature;
    final oldSig = _activeWindow?.signature;

    // نافذة جديدة
    if (oldSig != newSig) {
      _activeWindow = w;
      _dismissedSignature = null;
      value = w;
      return;
    }

    // نفس النافذة
    _activeWindow = w;
    final dismissed = (_dismissedSignature == newSig);

    if (dismissed) {
      if (value != null) value = null;
    } else {
      if (value == null) value = w;
    }
  }

  /// المستخدم قفل الأذكار لهذه النافذة فقط
  void dismissForNow() {
    if (_activeWindow == null) return;
    _dismissedSignature = _activeWindow!.signature;
    if (value != null) value = null;
  }

  /// افتحها تاني لو نفس النافذة لسه شغالة
  void showAgain() {
    if (_activeWindow == null) return;
    _dismissedSignature = null;
    value = _activeWindow;
  }
}
