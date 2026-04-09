import 'package:azan/views/home/components/black_screen_info_overlay.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class IqamaLastMinuteCountdownOverlay extends StatelessWidget {
  const IqamaLastMinuteCountdownOverlay({
    super.key,
    required this.secondsText,
    this.fontSizeOverride,
  });

  final String secondsText;
  final double? fontSizeOverride;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final shortestSide = size.shortestSide;
    final fontSize =
        fontSizeOverride ?? (shortestSide * 0.55).clamp(120.0, 360.0);

    return TimedHomeBackground(
      child: Container(
        key: const ValueKey('iqama-last-minute-overlay'),
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.08,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              secondsText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.homeSecondaryTextColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                height: 1.0,
                shadows: const [
                  Shadow(
                    color: Color(0x99000000),
                    blurRadius: 18,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
