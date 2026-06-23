import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Widget واحدة:
/// - بتعرض آية عشوائية من ayat
/// - Auto rotate كل [interval]
/// - Tap يغير فورًا
/// - Auto font sizing (يحاول يخلّي النص يدخل في maxLines + availableHeight)
class RotatingAyahBanner extends StatefulWidget {
  const RotatingAyahBanner({
    super.key,
    required this.ayat,
    this.textOf,
    required this.height,
    this.availableHeight,
    required this.maxFontSize,
    required this.minFontSize,
    this.interval = const Duration(seconds: 20),
    this.autoRotate = true,
    this.randomOrder = true,
    this.avoidRepeat = true,
    this.maxLines = 2,
    this.padding,
    this.fontFamily,
    this.textColor,
    this.textDirection = TextDirection.rtl,
    this.placeholder = '﴿ ... ﴾',
    this.wrapWithBrackets = true,
  });

  /// ممكن تكون List<String> أو List<Model>
  final List<dynamic> ayat;

  /// لو عناصر ayat مش String (مثلاً Model فيه text) ابعت resolver:
  /// textOf: (x) => x.text
  final String Function(dynamic item)? textOf;

  final double height;
  final double? availableHeight;

  final double maxFontSize;
  final double minFontSize;

  final Duration interval;
  final bool autoRotate;
  final bool randomOrder;
  final bool avoidRepeat;

  final int maxLines;

  final EdgeInsetsGeometry? padding;
  final String? fontFamily;
  final Color? textColor;
  final TextDirection textDirection;

  final String placeholder;

  /// لو عايز النص يظهر كـ ﴿ الآية ﴾
  final bool wrapWithBrackets;

  @override
  State<RotatingAyahBanner> createState() => _RotatingAyahBannerState();
}

class _RotatingAyahBannerState extends State<RotatingAyahBanner> {
  final Random _rnd = Random();
  Timer? _timer;

  String _currentAya = '';
  int _lastIndex = -1;
  int _orderedIndex = -1;

  double _fitFontSize({
    required String text,
    required double maxWidth,
    required double maxHeight,
  }) {
    // لو مفيش مساحة أصلاً
    if (maxWidth <= 0 || maxHeight <= 0) return widget.minFontSize;

    final painter = TextPainter(
      textDirection: widget.textDirection,
      textAlign: TextAlign.center,
      maxLines: widget.maxLines,
      ellipsis: '…',
    );

    double size = widget.maxFontSize;

    while (size >= widget.minFontSize) {
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
          height: 1,
          fontFamily: widget.fontFamily,
          color: widget.textColor,
        ),
      );

      painter.layout(maxWidth: maxWidth);

      // ✅ عدد الأسطر الفعلي
      final lines = painter.computeLineMetrics().length;
      final h = painter.height;

      // ✅ لو داخل في القيود
      if (lines <= widget.maxLines && h <= maxHeight) return size;

      // قلّل تدريجيًا
      size -= 1;
    }

    return widget.minFontSize;
  }

  String _normalizeText(dynamic item) {
    final raw =
        widget.textOf?.call(item) ?? (item is String ? item : item.toString());
    return raw.trim();
  }

  void _pickNext({bool setStateNow = true}) {
    if (widget.ayat.isEmpty) return;

    // فلترة العناصر الفاضية
    final valid = <dynamic>[];
    for (final a in widget.ayat) {
      final t = _normalizeText(a);
      if (t.isNotEmpty) valid.add(a);
    }
    if (valid.isEmpty) return;

    late final String picked;
    if (widget.randomOrder) {
      int idx = _rnd.nextInt(valid.length);
      if (widget.avoidRepeat && valid.length > 1) {
        while (idx == _lastIndex) {
          idx = _rnd.nextInt(valid.length);
        }
      }
      _lastIndex = idx;
      picked = _normalizeText(valid[idx]);
    } else {
      _orderedIndex = (_orderedIndex + 1) % valid.length;
      _lastIndex = _orderedIndex;
      picked = _normalizeText(valid[_orderedIndex]);
    }

    if (!mounted) return;

    if (setStateNow) {
      setState(() => _currentAya = picked);
    } else {
      _currentAya = picked;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (!widget.autoRotate) return;

    // أول مرة فورًا
    _pickNext(setStateNow: true);

    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted) return;
      _pickNext(setStateNow: true);
    });
  }

  @override
  void initState() {
    super.initState();
    // لو مش autoRotate، برضه نختار آية أول مرة
    _pickNext(setStateNow: false);
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant RotatingAyahBanner oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldTexts = oldWidget.ayat
        .map(_normalizeText)
        .where((t) => t.isNotEmpty)
        .toList(growable: false);
    final newTexts = widget.ayat
        .map(_normalizeText)
        .where((t) => t.isNotEmpty)
        .toList(growable: false);

    final listChanged = !listEquals(oldTexts, newTexts);
    final intervalChanged = oldWidget.interval != widget.interval;
    final autoChanged = oldWidget.autoRotate != widget.autoRotate;
    final orderChanged = oldWidget.randomOrder != widget.randomOrder;

    if (listChanged || orderChanged) {
      _lastIndex = -1;
      _orderedIndex = -1;
      _pickNext(setStateNow: true);
    }

    if (intervalChanged || autoChanged || orderChanged) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;
    final availH = widget.availableHeight ?? widget.height;

    final raw = _currentAya.isEmpty ? '' : _currentAya;
    final displayText = raw.isEmpty
        ? widget.placeholder
        : (widget.wrapWithBrackets ? '﴿ $raw ﴾' : raw);

    return GestureDetector(
      onTap: () => _pickNext(setStateNow: true),
      child: SizedBox(
        height: h,
        child: Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fs = _fitFontSize(
                text: displayText,
                maxWidth: constraints.maxWidth,
                maxHeight: availH,
              );

              return Center(
                child: Text(
                  displayText,
                  textAlign: TextAlign.center,
                  textDirection: widget.textDirection,
                  maxLines: widget.maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fs,
                    fontWeight: FontWeight.bold,
                    fontFamily: widget.fontFamily,
                    color:
                        widget.textColor ??
                        Theme.of(context).colorScheme.onSurface,
                    // height: ,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
