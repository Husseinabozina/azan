import 'dart:async';

import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:flutter/material.dart';

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
  }

  void _startTypingAnimation() {
    // زمن ثابت ومتساوي لكل حرف عشان الإحساس يكون ناعم ومتواصل
    const charDelay = Duration(milliseconds: 90);
    int index = 0;

    _textTimer = Timer.periodic(charDelay, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (index < _basmala.length) {
        setState(() {
          _visibleText = _basmala.substring(0, index + 1);
        });
        index++;
      } else {
        timer.cancel();
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const HomeScreen(),
      ),
    );
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

    final double logoSize = (isPortrait ? 220.0 : 160.0).w;
    final double spacing = (isPortrait ? 28.0 : 20.0).h;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1), // أزرق غامق في الأعلى
              Color(0xFF1976D2), // أزرق أفتح في الأسفل
            ],
          ),
        ),
        child: SafeArea(
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
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: spacing),
                    Text(
                      _visibleText,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontSize: 32.sp,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

