import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppTheme {
  AppTheme._(); // عشان محدش يعمل instance

  static const Color cancelButtonBackgroundColor = Colors.red;

  static const Color cancelButtonTextColor = Colors.white;
  // ---------- PRIMARY TEXT ----
  //
  // ------

  // ---------- DIALOG BODY TEXT COLOR ----------
  static Color get dialogBodyTextColor {
    final bgColor = primaryTextColor;

    final brightness = ThemeData.estimateBrightnessForColor(bgColor);

    if (brightness != Brightness.dark) {
      // خلفية غامقة → نص فاتح لكن أهدى من الأبيض الفاقع
      return const Color(0xFFEAEFF6); // off-white مائل لأزرق خفيف
    } else {
      // خلفية فاتحة → نص غامق وواضح
      return const Color(0xFF3A2415); // أغمق شوية من 0xFF5A3520
    }
  }

  static Color get primaryTextColor {
    final bg = CacheHelper.getSelectedBackground();

    if (bg == Assets.images.home.path) {
      return const Color(0xFFE9C06B);
    } else if (bg == Assets.images.backgroundBlueGreyGold.path) {
      return const Color(0xFFE9C06B);
    } else if (bg == Assets.images.backgroundBroundWithMosBird.path) {
      return const Color(0xFFF5E6BF);
    } else if (bg == Assets.images.backgroundLight.path) {
      return const Color(0xFF5A3520);
    } else if (bg == Assets.images.oilLampBackground.path) {
      return const Color(0xFFF4C66A);
    } else if (bg == Assets.images.backgroundOliveGreenWithMosq.path) {
      return const Color(0xFFF5E6BF);
    } else if (bg == Assets.images.backgroundGreenWith.path) {
      return const Color(0xFFF5E6BF);
    } else if (bg == Assets.images.backgroundLight2.path) {
      return const Color(0xFF5A3520);
    }

    // fallback لو مفيش حاجة متخزنة
    return const Color(0xFFE9C06B);
  }

  // ---------- SECONDARY TEXT ----------
  static Color get secondaryTextColor {
    final bg = CacheHelper.getSelectedBackground();

    if (bg == Assets.images.home.path) {
      return const Color(0xFFFFFFFF);
    } else if (bg == Assets.images.backgroundBlueGreyGold.path) {
      return const Color(0xFFFFFFFF);
    } else if (bg == Assets.images.backgroundBroundWithMosBird.path) {
      return const Color(0xFFFFFFFF);
    } else if (bg == Assets.images.backgroundLight.path) {
      return const Color(0xFF8A5A35);
    } else if (bg == Assets.images.oilLampBackground.path) {
      return const Color(0xFFE2EFF5);
    } else if (bg == Assets.images.backgroundOliveGreenWithMosq.path) {
      return const Color(0xFFE2EFF5);
    } else if (bg == Assets.images.backgroundGreenWith.path) {
      return const Color(0xFFE2EFF5);
    } else if (bg == Assets.images.backgroundLight2.path) {
      return const Color(0xFF8A5A35);
    }

    return const Color(0xFFFFFFFF);
  }

  // ---------- ACCENT ----------
  static Color get accentColor {
    final bg = CacheHelper.getSelectedBackground();

    if (bg == Assets.images.home.path) {
      return const Color(0xFF5FA8D3);
    } else if (bg == Assets.images.backgroundBlueGreyGold.path) {
      return const Color(0xFF5FA8D3);
    } else if (bg == Assets.images.backgroundBroundWithMosBird.path) {
      return const Color(0xFF3BAFBF);
    } else if (bg == Assets.images.backgroundLight.path) {
      return const Color(0xFFD9A441);
    } else if (bg == Assets.images.oilLampBackground.path) {
      return const Color(0xFF5FA8D3);
    } else if (bg == Assets.images.backgroundOliveGreenWithMosq.path) {
      return const Color(0xFF3BAFBF);
    } else if (bg == Assets.images.backgroundGreenWith.path) {
      return const Color(0xFFD9A441);
    } else if (bg == Assets.images.backgroundLight2.path) {
      return const Color(0xFFD9A441);
    }

    return const Color(0xFF5FA8D3);
  }

  // ---------- BASE BACKGROUND (بديل darkBlue) ----------
  static Color get darkBlue {
    final bg = CacheHelper.getSelectedBackground();

    if (bg == Assets.images.home.path) {
      return const Color(0xFF1B375D); // الأزرق القديم
    } else if (bg == Assets.images.backgroundBlueGreyGold.path) {
      return const Color(0xFF1B375D);
    } else if (bg == Assets.images.backgroundBroundWithMosBird.path) {
      return const Color(0xFF5A3520); // بني
    } else if (bg == Assets.images.backgroundLight.path) {
      return const Color(0xFFF7E8CF); // كريمي فاتح
    } else if (bg == Assets.images.oilLampBackground.path) {
      return const Color(0xFF071D2B); // أزرق داكن جداً
    } else if (bg == Assets.images.backgroundOliveGreenWithMosq.path) {
      return const Color(0xFF0B3B3F); // تيل غامق
    } else if (bg == Assets.images.backgroundGreenWith.path) {
      return const Color(0xFF064635); // أخضر غامق
    } else if (bg == Assets.images.backgroundLight2.path) {
      return const Color(0xFFF7EDE0); // فاتح جداً
    }

    return const Color(0xFF1B375D);
  }

  // ---------- BUTTON COLORS ----------
  static Color get primaryButtonBackground {
    final bg = CacheHelper.getSelectedBackground();

    // الخلفيات الفاتحة (كريمي)
    if (bg == Assets.images.backgroundLight.path ||
        bg == Assets.images.backgroundLight2.path) {
      return const Color(0xFFD9A441); // دهبي دافئ
    }

    // باقي الخلفيات → استخدم accentColor اللي فوق
    return accentColor;
  }

  static Color get primaryButtonTextColor {
    final bg = CacheHelper.getSelectedBackground();

    // على الخلفيات الفاتحة + زر دهبي → نص بني غامق
    if (bg == Assets.images.backgroundLight.path ||
        bg == Assets.images.backgroundLight2.path) {
      return const Color(0xFF5A3520); // بني غامق واضح
    }

    // على الخلفيات الغامقة → زر أزرق/تيل → نص أبيض
    return const Color(0xFFFFFFFF);
  }

  // ---------- DIALOG BACKGROUND ----------
  static Color get dialogBackgroundColor {
    final bg = CacheHelper.getSelectedBackground();

    // الأزرقات / النيلي
    if (bg == Assets.images.home.path ||
        bg == Assets.images.backgroundBlueGreyGold.path ||
        bg == Assets.images.oilLampBackground.path) {
      return const Color(0xFF163A63); // الأزرق الغامق اللي كنت بتستخدمه
    }

    // الخلفية البني بالمئذنة والطيور
    if (bg == Assets.images.backgroundBroundWithMosBird.path) {
      return const Color(0xFF4A2615); // بني غامق شوية عن الخلفية
    }

    // الخلفيات التيل / الأخضر المزرق
    if (bg == Assets.images.backgroundOliveGreenWithMosq.path ||
        bg == Assets.images.backgroundGreenWith.path) {
      return const Color(0xFF032D25); // أخضر غامق مريح
    }

    // الخلفيات الفاتحة الكريمي
    if (bg == Assets.images.backgroundLight.path ||
        bg == Assets.images.backgroundLight2.path) {
      return const Color(
        0xFF5A3520,
      ); // بني غامق، يطلع رايق مع الذهبـي والنص الأبيض
    }

    // fallback لو مفيش حاجة متخزّنة
    return const Color(0xFF163A63);
  }

  // ---------- DIALOG TITLE COLOR ----------
  static Color get dialogTitleColor {
    final bgColor = dialogBackgroundColor;

    // نحدد إذا كانت الخلفية فاتحة ولا غامقة
    final brightness = ThemeData.estimateBrightnessForColor(bgColor);

    if (brightness == Brightness.dark) {
      // خلفية غامقة → عنوان فاتح (ذهبي/كريمي)
      return const Color(0xFFF4C66A); // الذهبي اللي بتحبه
    } else {
      // خلفية فاتحة → عنوان غامق
      return const Color(0xFF5A3520); // بني غامق واضح
    }
  }
}
