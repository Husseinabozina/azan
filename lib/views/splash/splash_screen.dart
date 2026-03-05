import 'dart:async';

import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  static const String _basmala = 'بسم الله الرحمن الرحيم';
  String _visibleText = '';
  Timer? _textTimer;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _logoController.forward();
    _startTypingAnimation();
    _scheduleNavigation();
  }

  void _startTypingAnimation() {
    const charDelay = Duration(milliseconds: 80);
    int index = 0;

    _textTimer = Timer.periodic(charDelay, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (index >= _basmala.length) {
        timer.cancel();
        return;
      }

      setState(() {
        _visibleText = _basmala.substring(0, index + 1);
      });

      index++;
    });
  }

  void _scheduleNavigation() {
    // أبسط حاجة: زمن ثابت يغطي أنيميشن اللوجو + كتابة النص
    const totalDuration = Duration(milliseconds: 3200);

    Future.delayed(totalDuration, () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    final double logoSize = (isPortrait ? 160.0 : 120.0).w;
    final double spacing = (isPortrait ? 24.0 : 16.0).h;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: SizedBox(
                        width: logoSize,
                        height: logoSize,
                        child: SvgPicture.asset(
                          Assets.svg.logosvg,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),
                  Text(
                    _visibleText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 24.sp,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

