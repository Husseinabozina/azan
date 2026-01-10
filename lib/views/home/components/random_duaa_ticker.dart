import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RandomDuaaTicker extends StatefulWidget {
  const RandomDuaaTicker({
    super.key,
    required this.items,
    this.interval = const Duration(seconds: 10),
    this.textStyle,
    this.fadeDuration = const Duration(milliseconds: 500),
  });

  final List<String> items;
  final Duration interval;
  final TextStyle? textStyle;
  final Duration fadeDuration;

  @override
  State<RandomDuaaTicker> createState() => _RandomDuaaTickerState();
}

class _RandomDuaaTickerState extends State<RandomDuaaTicker> {
  Timer? _timer;
  final _rand = Random();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (widget.items.isNotEmpty) {
      _index = _rand.nextInt(widget.items.length);
      _start();
    }
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted) return;
      if (widget.items.length == 1) return;

      int next = _rand.nextInt(widget.items.length);
      // ✅ منع تكرار نفس العنصر مرتين
      while (next == _index) {
        next = _rand.nextInt(widget.items.length);
      }

      setState(() => _index = next);
    });
  }

  @override
  void didUpdateWidget(covariant RandomDuaaTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لو الليست/المدة اتغيرت
    if (oldWidget.interval != widget.interval ||
        oldWidget.items.length != widget.items.length) {
      if (widget.items.isEmpty) {
        _timer?.cancel();
      } else {
        _index = _rand.nextInt(widget.items.length);
        _start();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final text = widget.items[_index];

    return AnimatedSwitcher(
      duration: widget.fadeDuration,
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: Text(
        text,
        key: ValueKey(text),
        textAlign: TextAlign.center,
        style:
            widget.textStyle ??
            TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
      ),
    );
  }
}
