import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._(); // عشان محدش يعمل instance

  static const Color cancelButtonBackgroundColor = Colors.red;
  static const Color cancelButtonTextColor = Colors.white;

  static String get _bg => CacheHelper.getSelectedBackground();

  // =========================
  // DIALOG BODY TEXT COLOR
  // =========================
  static Color get dialogBodyTextColor {
    // ✅ الصح: نقيس على لون خلفية الديالوج نفسها
    final bgColor = dialogBackgroundColor;
    final brightness = ThemeData.estimateBrightnessForColor(bgColor);

    if (brightness == Brightness.dark) {
      // خلفية غامقة → نص فاتح لكن هادي
      return const Color(0xFFEAEFF6);
    } else {
      // خلفية فاتحة → نص غامق وواضح
      return const Color(0xFF3A2415);
    }
  }

  // =========================
  // PRIMARY TEXT
  // =========================
  static Color get primaryTextColor {
    final bg = _bg;

    // ======== الخلفيات القديمة ========
    if (bg == Assets.images.home.path) {
      return const Color(0xFFE9C06B);
    } else if (bg == Assets.images.backgroundBroundWithMosBird.path) {
      return const Color(0xFFF5E6BF);
    } else if (bg == Assets.images.backgroundOliveGreenWithMosq.path) {
      return const Color(0xFFF5E6BF);
    } else if (bg == Assets.images.backgroundGreenWith.path) {
      return const Color(0xFFF5E6BF);
    } else if (bg == Assets.images.backgroundLight2.path) {
      return const Color(0xFF5A3520);
    }

    // ======== الخلفيات الجديدة (القديمة عندك) ========
    if (bg == Assets.images.awesomeBackground.path) {
      return const Color(0xFFF4C66A);
    }
    if (bg == Assets.images.awesome2.path) {
      return const Color(0xFFF4C66A);
    }
    if (bg == Assets.images.darkBrownBackground.path) {
      return const Color(0xFFF4C66A);
    }
    if (bg == Assets.images.lightBackground1.path) {
      return const Color(0xFF5A3520);
    }
    if (bg == Assets.images.lightBrownBackground.path) {
      return const Color(0xFFF5E6BF);
    }
    if (bg == Assets.images.brownBackground.path) {
      return const Color(0xFFF5E6BF);
    }
    if (bg == Assets.images.background2.path) {
      return const Color(0xFFF4C66A);
    }
    if (bg == Assets.images.whiteBackgroundWithNaqsh.path) {
      return const Color(0xFF3A2415);
    }

    // ======== الخلفيات الجديدة (اللي انت باعتها فوق دلوقتي) ========
    // elegant_teal_arabesque_background.png (فاتح تيل)
    if (bg == Assets.images.elegantTealArabesqueBackground.path) {
      return const Color(0xFF3A2415);
    }

    // elegant_burgundy_arabesque_background.png (عنابي غامق)
    if (bg == Assets.images.elegantBurgundyArabesqueBackground.path) {
      return const Color(0xFFF4C66A);
    }

    // convinent_olive_green_background.png (زيتوني متوسط)
    if (bg == Assets.images.convinentOliveGreenBackground.path) {
      return const Color(0xFFF5E6BF);
    }

    // convinent_beige_background.png (بيج فاتح)
    if (bg == Assets.images.convinentBeigeBackground.path) {
      return const Color(0xFF3A2415);
    }

    // teal_blue_background.png (أزرق تيل غامق نسبيًا)
    if (bg == Assets.images.tealBlueBackground.path) {
      return const Color(0xFFF4C66A);
    }

    // fallback
    return const Color(0xFFE9C06B);
  }

  // =========================
  // SECONDARY TEXT
  // =========================
  static Color get secondaryTextColor {
    final bg = _bg;

    // ======== الخلفيات القديمة ========
    if (bg == Assets.images.home.path) {
      return const Color(0xFFFFFFFF);
    } else if (bg == Assets.images.backgroundBroundWithMosBird.path) {
      return const Color(0xFFFFFFFF);
    } else if (bg == Assets.images.backgroundOliveGreenWithMosq.path) {
      return const Color(0xFFE2EFF5);
    } else if (bg == Assets.images.backgroundGreenWith.path) {
      return const Color(0xFFE2EFF5);
    } else if (bg == Assets.images.backgroundLight2.path) {
      return const Color(0xFF8A5A35);
    }

    // ======== الخلفيات الجديدة (القديمة عندك) ========
    if (bg == Assets.images.awesomeBackground.path) {
      return const Color(0xFFEAEFF6);
    }
    if (bg == Assets.images.awesome2.path) {
      return const Color(0xFFEAEFF6);
    }
    if (bg == Assets.images.darkBrownBackground.path) {
      return const Color(0xFFEAEFF6);
    }
    if (bg == Assets.images.lightBackground1.path) {
      return const Color(0xFF8A5A35);
    }
    if (bg == Assets.images.lightBrownBackground.path) {
      return const Color(0xFFFFFFFF);
    }
    if (bg == Assets.images.brownBackground.path) {
      return const Color(0xFFFFFFFF);
    }
    if (bg == Assets.images.background2.path) {
      return const Color(0xFFEAEFF6);
    }
    if (bg == Assets.images.whiteBackgroundWithNaqsh.path) {
      return const Color(0xFF8A5A35);
    }

    // ======== الخلفيات الجديدة (اللي انت باعتها فوق) ========
    if (bg == Assets.images.elegantTealArabesqueBackground.path) {
      return const Color(0xFF6D4B35);
    }
    if (bg == Assets.images.elegantBurgundyArabesqueBackground.path) {
      return const Color(0xFFEAEFF6);
    }
    if (bg == Assets.images.convinentOliveGreenBackground.path) {
      return const Color(0xFFFFFFFF);
    }
    if (bg == Assets.images.convinentBeigeBackground.path) {
      return const Color(0xFF8A5A35);
    }
    if (bg == Assets.images.tealBlueBackground.path) {
      return const Color(0xFFEAEFF6);
    }

    return const Color(0xFFFFFFFF);
  }

  // =========================
  // ACCENT
  // =========================
  static Color get accentColor {
    final bg = _bg;

    // ======== الخلفيات القديمة ========
    if (bg == Assets.images.home.path) {
      return const Color(0xFF5FA8D3);
    } else if (bg == Assets.images.backgroundBroundWithMosBird.path) {
      return const Color(0xFF3BAFBF);
    } else if (bg == Assets.images.backgroundOliveGreenWithMosq.path) {
      return const Color(0xFF3BAFBF);
    } else if (bg == Assets.images.backgroundGreenWith.path) {
      return const Color(0xFFD9A441);
    } else if (bg == Assets.images.backgroundLight2.path) {
      return const Color(0xFFD9A441);
    }

    // ======== الخلفيات الجديدة (القديمة عندك) ========
    if (bg == Assets.images.awesomeBackground.path) {
      return const Color(0xFF5FA8D3);
    }
    if (bg == Assets.images.awesome2.path) {
      return const Color(0xFF3BAFBF);
    }
    if (bg == Assets.images.darkBrownBackground.path) {
      return const Color(0xFF3BAFBF);
    }
    if (bg == Assets.images.lightBackground1.path) {
      return const Color(0xFFD9A441);
    }
    if (bg == Assets.images.lightBrownBackground.path) {
      return const Color(0xFF3BAFBF);
    }
    if (bg == Assets.images.brownBackground.path) {
      return const Color(0xFF5FA8D3);
    }
    if (bg == Assets.images.background2.path) {
      return const Color(0xFF5FA8D3);
    }
    if (bg == Assets.images.whiteBackgroundWithNaqsh.path) {
      return const Color(0xFFD9A441);
    }

    // ======== الخلفيات الجديدة (اللي انت باعتها فوق) ========
    if (bg == Assets.images.elegantTealArabesqueBackground.path) {
      return const Color(0xFFD9A441); // دهبي على التيل بيبقى شيك
    }
    if (bg == Assets.images.elegantBurgundyArabesqueBackground.path) {
      return const Color(0xFF3BAFBF); // تيل بيكسر العنابي
    }
    if (bg == Assets.images.convinentOliveGreenBackground.path) {
      return const Color(0xFF3BAFBF); // تيل على الزيتوني
    }
    if (bg == Assets.images.convinentBeigeBackground.path) {
      return const Color(0xFFD9A441); // دهبي على البيج
    }
    if (bg == Assets.images.tealBlueBackground.path) {
      return const Color(0xFFD9A441); // دهبي على الأزرق التيل
    }

    return const Color(0xFF5FA8D3);
  }

  // =========================
  // BASE BACKGROUND (بديل darkBlue)
  // =========================
  static Color get darkBlue {
    final bg = _bg;

    // ======== الخلفيات القديمة ========
    if (bg == Assets.images.home.path) {
      return const Color(0xFF1B375D);
    } else if (bg == Assets.images.backgroundBroundWithMosBird.path) {
      return const Color(0xFF5A3520);
    } else if (bg == Assets.images.backgroundOliveGreenWithMosq.path) {
      return const Color(0xFF0B3B3F);
    } else if (bg == Assets.images.backgroundGreenWith.path) {
      return const Color(0xFF064635);
    } else if (bg == Assets.images.backgroundLight2.path) {
      return const Color(0xFFF7EDE0);
    }

    // ======== الخلفيات الجديدة (القديمة عندك) ========
    if (bg == Assets.images.awesomeBackground.path) {
      return const Color(0xFF1A1429);
    }
    if (bg == Assets.images.awesome2.path) {
      return const Color(0xFF131113);
    }
    if (bg == Assets.images.darkBrownBackground.path) {
      return const Color(0xFF120F0F);
    }
    if (bg == Assets.images.lightBackground1.path) {
      return const Color(0xFFFCF3E6);
    }
    if (bg == Assets.images.lightBrownBackground.path) {
      return const Color(0xFF4A4037);
    }
    if (bg == Assets.images.brownBackground.path) {
      return const Color(0xFF181614);
    }
    if (bg == Assets.images.background2.path) {
      return const Color(0xFF070605);
    }
    if (bg == Assets.images.whiteBackgroundWithNaqsh.path) {
      return const Color(0xFFFBF7F3);
    }

    // ======== الخلفيات الجديدة (اللي انت باعتها فوق) ========
    if (bg == Assets.images.elegantTealArabesqueBackground.path) {
      return const Color(0xFFEEF6F1); // فاتح قريب من التيل
    }
    if (bg == Assets.images.elegantBurgundyArabesqueBackground.path) {
      return const Color(0xFF2A0E12); // عنابي غامق
    }
    if (bg == Assets.images.convinentOliveGreenBackground.path) {
      return const Color(0xFF2F2C1B); // زيتوني غامق
    }
    if (bg == Assets.images.convinentBeigeBackground.path) {
      return const Color(0xFFFBF3E6); // بيج فاتح جدًا
    }
    if (bg == Assets.images.tealBlueBackground.path) {
      return const Color(0xFF0E3A4A); // تيل غامق
    }

    return const Color(0xFF1B375D);
  }

  // =========================
  // BUTTON COLORS
  // =========================
  static Color get primaryButtonBackground {
    final bg = _bg;

    // الخلفيات الفاتحة (قديم + جديد)
    if (bg == Assets.images.backgroundLight2.path ||
        bg == Assets.images.lightBackground1.path ||
        bg == Assets.images.whiteBackgroundWithNaqsh.path ||
        bg == Assets.images.elegantTealArabesqueBackground.path ||
        bg == Assets.images.convinentBeigeBackground.path) {
      return const Color(0xFFD9A441); // دهبي دافئ
    }

    return accentColor;
  }

  static Color get primaryButtonTextColor {
    final bg = _bg;

    // على الخلفيات الفاتحة + زر دهبي → نص بني غامق
    if (bg == Assets.images.backgroundLight2.path ||
        bg == Assets.images.lightBackground1.path ||
        bg == Assets.images.whiteBackgroundWithNaqsh.path ||
        bg == Assets.images.elegantTealArabesqueBackground.path ||
        bg == Assets.images.convinentBeigeBackground.path) {
      return const Color(0xFF5A3520);
    }

    // باقي الحالات → نص أبيض
    return const Color(0xFFFFFFFF);
  }

  // =========================
  // DIALOG BACKGROUND
  // =========================
  static Color get dialogBackgroundColor {
    final bg = _bg;

    // ======== القديم ========
    if (bg == Assets.images.home.path) {
      return const Color(0xFF163A63);
    }
    if (bg == Assets.images.backgroundBroundWithMosBird.path) {
      return const Color(0xFF4A2615);
    }
    if (bg == Assets.images.backgroundOliveGreenWithMosq.path ||
        bg == Assets.images.backgroundGreenWith.path) {
      return const Color(0xFF032D25);
    }
    if (bg == Assets.images.backgroundLight2.path) {
      return const Color(0xFF5A3520);
    }

    // ======== الجديد (القديمة عندك) ========
    if (bg == Assets.images.awesomeBackground.path) {
      return const Color(0xFF201833);
    }
    if (bg == Assets.images.awesome2.path) {
      return const Color(0xFF16110F);
    }
    if (bg == Assets.images.darkBrownBackground.path) {
      return const Color(0xFF1E1715);
    }
    if (bg == Assets.images.lightBackground1.path) {
      return const Color(0xFF5A3520);
    }
    if (bg == Assets.images.lightBrownBackground.path) {
      return const Color(0xFF3A2415);
    }
    if (bg == Assets.images.brownBackground.path) {
      return const Color(0xFF2D2520);
    }
    if (bg == Assets.images.background2.path) {
      return const Color(0xFF14110D);
    }
    if (bg == Assets.images.whiteBackgroundWithNaqsh.path) {
      return const Color(0xFF5A3520);
    }

    // ======== الجديد (اللي انت باعتها فوق) ========
    if (bg == Assets.images.elegantTealArabesqueBackground.path) {
      return const Color(0xFF5A3520); // بني غامق فوق الفاتح
    }
    if (bg == Assets.images.elegantBurgundyArabesqueBackground.path) {
      return const Color(0xFF2A0E12); // نفس روح العنابي
    }
    if (bg == Assets.images.convinentOliveGreenBackground.path) {
      return const Color(0xFF1F2418); // زيتوني غامق للحوارات
    }
    if (bg == Assets.images.convinentBeigeBackground.path) {
      return const Color(0xFF5A3520); // ثابت وجميل
    }
    if (bg == Assets.images.tealBlueBackground.path) {
      return const Color(0xFF0E3A4A); // تيل غامق
    }

    return const Color(0xFF163A63);
  }

  // =========================
  // DIALOG TITLE COLOR
  // =========================
  static Color get dialogTitleColor {
    final brightness = ThemeData.estimateBrightnessForColor(
      dialogBackgroundColor,
    );

    if (brightness == Brightness.dark) {
      return const Color(0xFFF4C66A);
    } else {
      return const Color(0xFF5A3520);
    }
  }
}
