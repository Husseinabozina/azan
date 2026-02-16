import 'dart:async';
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/components/vertical_space.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/data/data/after_prayers_azkar.dart';
import 'package:azan/data/data/evening_azkar.dart';
import 'package:azan/data/data/morning_azkar.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AzkarType { morning, evening, afterPrayer }

class AzkarView extends StatefulWidget {
  const AzkarView({super.key, required this.azkarType, this.prayerId});
  final AzkarType azkarType;
  final int? prayerId;

  @override
  State<AzkarView> createState() => _AzkarViewState();
}

class _AzkarViewState extends State<AzkarView> {
  final _rng = math.Random();
  Timer? _timer;

  late final List<String> _azkarTexts;
  final List<int> _bag = [];
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

  void _pickNextAndSchedule({bool first = false}) {
    if (_azkarTexts.isEmpty) {
      setState(() => _current = "لا توجد أذكار");
      return;
    }

    if (!first) {
      setState(() => _current = _pickNextRandom());
    } else {
      _current = _pickNextRandom();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {});
      });
    }

    _timer?.cancel();
    final d = _durationForText(_current);
    _timer = Timer(d, () {
      if (!mounted) return;
      _pickNextAndSchedule();
    });
  }

  String _pickNextRandom() {
    if (_bag.isEmpty) {
      _bag.addAll(List.generate(_azkarTexts.length, (i) => i));
      _bag.shuffle(_rng);
    }
    final idx = _bag.removeLast();
    return _azkarTexts[idx];
  }

  Duration _durationForText(String text) {
    const minSeconds = 20;
    const maxSeconds = 75;

    final words = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    final readSeconds = (words / 3.0).ceil();

    final bonus = (text.length / 120).floor() * 4;

    final seconds = (readSeconds + bonus).clamp(minSeconds, maxSeconds);
    return Duration(seconds: seconds);
  }

  List<String> _loadAzkarTexts(AzkarType type) {
    List<Map<String, String>> src;
    switch (type) {
      case AzkarType.morning:
        src = morningAzkar;
        break;
      case AzkarType.evening:
        src = eveningAzkar;
        break;
      case AzkarType.afterPrayer:
        src = widget.prayerId == 1
            ? afterPrayersAzkar
            : [...afterPrayersAzkar.take(afterPrayersAzkar.length - 1)];
        break;
    }

    return src
        .map((e) => (e["zekr"] ?? "").trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// 🎨 تحليل النص وتلوين الأجزاء المختلفة
  /// [...] = البسملة (ذهبي)
  /// {...} = الآيات القرآنية (أخضر فاتح)
  /// ~...~ = ملاحظات وتعليقات (برتقالي فاتح)
  List<InlineSpan> _parseZekrText(String text, double baseFontSize) {
    final List<InlineSpan> spans = [];
    final buffer = StringBuffer();
    int i = 0;

    const basmalaColor = Color(0xFFFFD700);
    const quranicColor = Color(0xFF90EE90);
    const noteColor = Color(0xFFFFB347);
    const normalColor = Colors.white;

    // حجم الملاحظات نسبة من الخط الأساسي
    final noteSize = baseFontSize * 0.85;

    while (i < text.length) {
      if (text[i] == '[') {
        if (buffer.isNotEmpty) {
          spans.add(
            TextSpan(
              text: buffer.toString(),
              style: const TextStyle(color: normalColor),
            ),
          );
          buffer.clear();
        }

        final end = text.indexOf(']', i);
        if (end != -1) {
          final basmala = text.substring(i + 1, end);
          spans.add(
            TextSpan(
              text: basmala,
              style: TextStyle(
                color: basmalaColor,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(color: basmalaColor.withOpacity(0.5), blurRadius: 8),
                ],
              ),
            ),
          );
          i = end + 1;
          continue;
        }
      }

      if (text[i] == '{') {
        if (buffer.isNotEmpty) {
          spans.add(
            TextSpan(
              text: buffer.toString(),
              style: const TextStyle(color: normalColor),
            ),
          );
          buffer.clear();
        }

        final end = text.indexOf('}', i);
        if (end != -1) {
          final ayah = text.substring(i + 1, end);
          spans.add(
            TextSpan(
              text: ayah,
              style: TextStyle(
                color: quranicColor,
                fontWeight: FontWeight.w800,
                shadows: [
                  Shadow(color: quranicColor.withOpacity(0.3), blurRadius: 6),
                ],
              ),
            ),
          );
          i = end + 1;
          continue;
        }
      }

      if (text[i] == '~') {
        if (buffer.isNotEmpty) {
          spans.add(
            TextSpan(
              text: buffer.toString(),
              style: const TextStyle(color: normalColor),
            ),
          );
          buffer.clear();
        }

        final end = text.indexOf('~', i + 1);
        if (end != -1) {
          final note = text.substring(i + 1, end);
          spans.add(
            TextSpan(
              text: note,
              style: TextStyle(
                color: noteColor,
                fontWeight: FontWeight.w600,
                fontSize: noteSize,
                fontStyle: FontStyle.italic,
                shadows: [
                  Shadow(color: noteColor.withOpacity(0.3), blurRadius: 4),
                ],
              ),
            ),
          );
          i = end + 1;
          continue;
        }
      }

      buffer.write(text[i]);
      i++;
    }

    if (buffer.isNotEmpty) {
      spans.add(
        TextSpan(
          text: buffer.toString(),
          style: const TextStyle(color: normalColor),
        ),
      );
    }

    return spans;
  }

  /// 🎯 حساب حجم الخط المناسب باستخدام TextPainter
  double _calculateOptimalFontSize({
    required String text,
    required double maxWidth,
    required double availableHeight,
    required double maxFontSize,
    required double minFontSize,
  }) {
    double currentFontSize = maxFontSize;
    final textPainter = TextPainter(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );

    while (currentFontSize >= minFontSize) {
      textPainter.text = TextSpan(
        style: TextStyle(
          fontSize: currentFontSize,
          fontWeight: FontWeight.bold,
          height: 1.5,
          fontFamily: CacheHelper.getAzkarFontFamily(),
        ),
        children: _parseZekrText(text, currentFontSize),
      );

      textPainter.layout(maxWidth: maxWidth);

      final lines = textPainter.computeLineMetrics().length;
      final textHeight = textPainter.height;

      // لو النص داخل في المساحة المتاحة، نرجع الحجم ده
      if (textHeight <= availableHeight) {
        break;
      }

      // نصغر الخط شوية
      currentFontSize -= 0.5;

      // نتأكد إننا ما نزلناش عن الحد الأدنى
      if (currentFontSize < minFontSize) {
        currentFontSize = minFontSize;
        break;
      }
    }

    return currentFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.95),
      child: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _pickNextAndSchedule,
          // () {
          //   UiRotationCubit().changeIsLandscape(
          //     !UiRotationCubit().isLandscape(),
          //   );
          // }
          child: OrientationBuilder(
            builder: (context, orientation) {
              final isLandscape = orientation == Orientation.landscape;

              return LayoutBuilder(
                builder: (context, constraints) {
                  // إعدادات مخصصة حسب Orientation باستخدام .h و .w
                  final horizontalPadding = isLandscape ? 30.w : 24.w;
                  final titleTopPadding = isLandscape ? 10.h : 15.h;
                  final titleFontSize = isLandscape ? 20.sp : 24.sp;
                  final bottomPadding = isLandscape ? 15.h : 30.h;

                  // حجم الخط الأساسي
                  final maxFontSize = isLandscape ? 32.sp : 38.sp;
                  final minFontSize = isLandscape ? 20.sp : 24.sp;

                  // حساب المساحة المتاحة للنص
                  final availableHeight =
                      constraints.maxHeight -
                      titleTopPadding -
                      titleFontSize -
                      20.h -
                      bottomPadding;

                  final availableWidth =
                      constraints.maxWidth - (horizontalPadding * 2);

                  // حساب حجم الخط الأمثل
                  final optimalFontSize = _calculateOptimalFontSize(
                    text: _current,
                    maxWidth: availableWidth,
                    availableHeight: availableHeight,
                    maxFontSize: maxFontSize,
                    minFontSize: minFontSize,
                  );

                  return Stack(
                    children: [
                      // العنوان
                      Positioned(
                        top: titleTopPadding,
                        left: 0,
                        right: 0,
                        child: Text(
                          widget.azkarType == AzkarType.afterPrayer
                              ? "أذكار بعد الصلاة"
                              : widget.azkarType == AzkarType.morning
                              ? "أذكار الصباح"
                              : "أذكار المساء",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                            shadows: [
                              Shadow(
                                color: AppTheme.primaryTextColor.withOpacity(
                                  0.3,
                                ),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // الذكر
                      Positioned.fill(
                        top: titleTopPadding + titleFontSize + 20.h,
                        bottom: bottomPadding,
                        left: horizontalPadding,
                        right: horizontalPadding,
                        child: Center(
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: optimalFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.5,
                                  fontFamily: CacheHelper.getAzkarFontFamily(),
                                ),
                                children: _parseZekrText(
                                  _current,
                                  optimalFontSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
