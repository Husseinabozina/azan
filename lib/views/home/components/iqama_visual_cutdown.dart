import 'dart:math' as math;
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';

class IqamaVisualCountdown extends StatefulWidget {
  const IqamaVisualCountdown({
    super.key,
    required this.totalDuration,
    this.size = 220,
    this.strokeWidth = 14,
    this.startAngle = -math.pi / 2,
    this.reverse = true,
    this.backgroundStrokeColor = const Color(0x33FFFFFF),
    this.progressColor = Colors.white,
    this.warningColor = const Color(0xFFFFD54F),
    this.dangerColor = const Color(0xFFFF5252),
    this.warningThreshold = 0.20,
    this.dangerThreshold = 0.08,
    this.centerChild,
    this.onFinished,
  });

  final Duration totalDuration;
  final double size;
  final double strokeWidth;
  final double startAngle;
  final bool reverse;

  final Color backgroundStrokeColor;
  final Color progressColor;
  final Color warningColor;
  final Color dangerColor;

  final double warningThreshold;
  final double dangerThreshold;

  final Widget? centerChild;
  final VoidCallback? onFinished;

  @override
  State<IqamaVisualCountdown> createState() => _IqamaVisualCountdownState();
}

class _IqamaVisualCountdownState extends State<IqamaVisualCountdown>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: widget.totalDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.onFinished?.call();
            }
          });

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant IqamaVisualCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.totalDuration != widget.totalDuration) {
      _controller
        ..stop()
        ..duration = widget.totalDuration
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _pickColor(double remainingRatio) {
    if (remainingRatio <= widget.dangerThreshold) {
      return CacheHelper.getIsChangeCounterEnabled()
          ? widget.dangerColor
          : widget.warningColor;
    }
    if (remainingRatio <= widget.warningThreshold) return widget.warningColor;
    return widget.progressColor;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ الـ size و strokeWidth جايين من الـ parent (_AzanMetrics)
    // هنستخدمهم زي ما هم لأن الـ parent بيحسبهم صح
    final actualSize = widget.size;
    final actualStroke = widget.strokeWidth;

    // ✅ الـ fontSize يكون نسبة من الـ ring size
    final fontSize = actualSize * 0.136; // ~30/220

    return SizedBox(
      width: actualSize,
      height: actualSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final elapsed = _controller.value;
          final remainingRatio = 1.0 - elapsed;

          final progress = widget.reverse ? remainingRatio : elapsed;
          final color = _pickColor(remainingRatio);

          final totalMs = widget.totalDuration.inMilliseconds;
          final remainingMs = (totalMs * remainingRatio).round();
          final remaining = Duration(
            milliseconds: remainingMs.clamp(0, totalMs),
          );

          return CustomPaint(
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: actualStroke,
              startAngle: widget.startAngle,
              bgColor: widget.backgroundStrokeColor,
              progressColor: color,
            ),
            child: Center(
              child: Text(
                _format(remaining),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTextColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _format(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final m = two(d.inMinutes.remainder(60));
  final s = two(d.inSeconds.remainder(60));
  return '$m:$s';
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.startAngle,
    required this.bgColor,
    required this.progressColor,
  });

  final double progress;
  final double strokeWidth;
  final double startAngle;
  final Color bgColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - strokeWidth / 2;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi * 2,
      false,
      bgPaint,
    );

    final sweep = (math.pi * 2) * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.bgColor != bgColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.startAngle != startAngle;
  }
}
