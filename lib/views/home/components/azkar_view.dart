import 'dart:async';
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';
import 'package:azan/core/utils/constants.dart'; // <-- هنا عندك morningAzkar/eveningAzkar/afterPrayerAzkar
import 'package:azan/data/data/after_prayers_azkar.dart';
import 'package:azan/data/data/evening_azkar.dart';
import 'package:azan/data/data/morning_azkar.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AzkarType { morning, evening, afterPrayer }

class AzkarView extends StatefulWidget {
  const AzkarView({super.key, required this.azkarType});
  final AzkarType azkarType;

  @override
  State<AzkarView> createState() => _AzkarViewState();
}

class _AzkarViewState extends State<AzkarView> {
  final _rng = math.Random();
  Timer? _timer;

  late final List<String> _azkarTexts; // بنخزن النصوص الجاهزة للعرض
  final List<int> _bag = []; // indices shuffled bag (عشان ميكررش لحد ما يخلص)
  String _current = '';

  @override
  void initState() {
    super.initState();

    _azkarTexts = _loadAzkarTexts(widget.azkarType);
    _pickNextAndSchedule(first: true);
  }

  @override
  void didUpdateWidget(covariant AzkarView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // لو نوع الأذكار اتغير (Morning/Evening/AfterPrayer) نعيد التهيئة
    if (oldWidget.azkarType != widget.azkarType) {
      _timer?.cancel();
      _bag.clear();
      _azkarTexts
        ..clear()
        ..addAll(_loadAzkarTexts(widget.azkarType));
      _pickNextAndSchedule(first: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // =========================
  //  Core: pick + schedule
  // =========================
  void _pickNextAndSchedule({bool first = false}) {
    if (_azkarTexts.isEmpty) {
      setState(() => _current = "لا توجد أذكار");
      return;
    }

    if (!first) {
      setState(() => _current = _pickNextRandom());
    } else {
      _current = _pickNextRandom();
      // أول مرة: اعمل setState مرة واحدة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {});
      });
    }

    _timer?.cancel();
    final d = _durationForText(_current); // ✅ هنا الزيادة حسب طول الذكر
    _timer = Timer(d, () {
      if (!mounted) return;
      _pickNextAndSchedule();
    });
  }

  String _pickNextRandom() {
    // bag empty => refill and shuffle
    if (_bag.isEmpty) {
      _bag.addAll(List.generate(_azkarTexts.length, (i) => i));
      _bag.shuffle(_rng);
    }
    final idx = _bag.removeLast();
    return _azkarTexts[idx];
  }

  // =========================
  //  Duration حسب طول الذكر
  // =========================
  Duration _durationForText(String text) {
    const minSeconds = 20; // ✅ الحد الأدنى زي ما طلبت
    const maxSeconds = 75; // امنع إنه يقعد كتير قوي

    // تقدير بسيط لزمن القراءة:
    // ~ 180 كلمة/دقيقة => 3 كلمات/ثانية
    final words = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    final readSeconds = (words / 3.0).ceil();

    // Bonus بسيطة (عشان الآيات الطويلة)
    final bonus = (text.length / 120).floor() * 4; // كل 120 حرف +4 ثواني

    final seconds = (readSeconds + bonus).clamp(minSeconds, maxSeconds);
    return Duration(seconds: seconds);
  }

  // =========================
  //  Load texts من constants
  // =========================
  List<String> _loadAzkarTexts(AzkarType type) {
    List<Map<String, String>> src;
    switch (type) {
      case AzkarType.morning:
        src = morningAzkar; // من constants
        break;
      case AzkarType.evening:
        src = eveningAzkar;
        break;
      case AzkarType.afterPrayer:
        src = afterPrayersAzkar;
        break;
    }

    // ناخد فقط zekr ونشيل الفاضي
    return src
        .map((e) => (e["zekr"] ?? "").trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ مهم جدًا: متعملش UiRotationCubit() جديد.. خده من الـBloc
    final isLandscape = context.watch<UiRotationCubit>().isLandscape();

    // if (!isLandscape) return const SizedBox.shrink();

    return Container(
      width: 1.sw,
      height: 1.sh,
      color: Colors.black.withOpacity(0.95),
      child: GestureDetector(
        onTap: () {
          AppCubit().getPrayerDurationForId(1);
          _pickNextAndSchedule(); // اختياري: tap يجيب ذكر جديد فورًا
        },
        child: SafeArea(
          child: Column(
            children: [
              // ✅ Title فوق خالص
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    widget.azkarType == AzkarType.afterPrayer
                        ? "اذكار"
                        : widget.azkarType == AzkarType.morning
                        ? "اذكار صباح"
                        : "اذكار مساء",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                ),
              ),

              // ✅ الذكر في النص
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: AutoSizeText(
                      _current,
                      textAlign: TextAlign.center,
                      maxLines: 12,
                      minFontSize: 14,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryTextColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
