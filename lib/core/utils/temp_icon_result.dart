import 'package:azan/controllers/cubits/appcubit/app_cubit.dart' show AppCubit;
import 'package:azan/core/utils/extenstions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/theme/app_theme.dart';

import 'package:azan/gen/assets.gen.dart';

class TempIconResult {
  final AssetGenImage asset;
  final String label;
  const TempIconResult(this.asset, this.label);
}

/// Open-Meteo (WMO) weather codes -> icons
TempIconResult weatherIconForCode(double? tempC, {required bool isDay}) {
  if (tempC == null) return TempIconResult(Assets.images.unknown, 'Unknown');

  // ❄️ Freezing
  if (tempC <= 0) {
    return TempIconResult(Assets.images.fog, 'Freezing');
  }

  // 🥶 Cold
  if (tempC <= 10) {
    return TempIconResult(Assets.images.cloudy, 'Cold');
  }

  // 🌥 Mild / comfortable
  if (tempC <= 20) {
    return TempIconResult(Assets.images.haze, 'Mild');
  }

  // ☀️ Warm
  if (tempC <= 32) {
    return TempIconResult(
      isDay ? Assets.images.clearDay : Assets.images.clearNight,
      'Warm',
    );
  }

  // 🔥 Hot
  if (tempC <= 40) {
    return TempIconResult(Assets.images.haze, 'Hot');
  }

  // 🔥🔥 Very hot
  return TempIconResult(Assets.images.haze, 'Very hot');
}

double safeSp(BuildContext context, double v) {
  try {
    return v.sp;
  } catch (_) {
    return v;
  }
}

double safeW(BuildContext context, double v) {
  try {
    return v.w;
  } catch (_) {
    return v;
  }
}

// TempIconResult tempIconForCelsius(double? tempC) {
//   if (tempC == null) return const TempIconResult(Icons.help_outline, 'Unknown');

//   if (tempC <= 0) return const TempIconResult(Icons.ac_unit, 'Freezing');
//   if (tempC <= 10) return const TempIconResult(Icons.cloudy_snowing, 'Cold');
//   if (tempC <= 20) return const TempIconResult(Icons.cloud, 'Cloudy');
//   if (tempC <= 28)
//     return const TempIconResult(Icons.wb_cloudy_outlined, 'Mild');
//   if (tempC <= 35)
//     return const TempIconResult(Icons.wb_sunny_outlined, 'Sunny');
//   if (tempC <= 42) return const TempIconResult(Icons.whatshot, 'Hot');
//   return const TempIconResult(Icons.local_fire_department, 'Very hot');
// }
class TemperatureBadge extends StatelessWidget {
  const TemperatureBadge({
    super.key,
    this.iconSize,
    this.textSize,
    this.gapWidth,
    this.isDay,
  });

  final double? iconSize;
  final double? textSize;
  final double? gapWidth;
  final bool? isDay;

  @override
  Widget build(BuildContext context) {
    final day = isDay ?? (DateTime.now().hour >= 6 && DateTime.now().hour < 18);

    // ✅ خُد القيم من الكيوبت
    final tempC = context.watch<AppCubit>().todayMaxTemp;
    final weatherCode = context.watch<AppCubit>().todayWeatherCode;

    // ✅ الأيقونة بناءً على الكود
    final r = weatherIconForCode(tempC, isDay: day);

    // ✅ النص
    final tempText = tempC == null
        ? "--"
        : (LocalizationHelper.isArAndArNumberEnable()
              ? DateHelper.toArabicDigits(tempC.toInt().toString())
              : tempC.toInt().toString());

    final iconPx = iconSize ?? safeSp(context, 22);
    final textPx = textSize ?? safeSp(context, 30);
    final gap = gapWidth ?? safeW(context, 6);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        children: [
          SizedBox(
            width: iconPx,
            height: iconPx,
            child: r.asset.image(fit: BoxFit.contain),
          ),
          SizedBox(width: gap),
          Text(
            "$tempText°",
            style: TextStyle(
              fontSize: textPx,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
