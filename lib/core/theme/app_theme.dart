import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color cancelButtonBackgroundColor = Colors.red;
  static const Color cancelButtonTextColor = Colors.white;

  static String get _bg => CacheHelper.getSelectedBackground();

  // ألوان ثابتة بنستخدمها كتيمة
  static const Color _gold = Color(0xFFD9A441);
  static const Color _goldText = Color(0xFFF4C66A);
  static const Color _creamText = Color(0xFFF5E6BF);
  static const Color _softWhite = Color(0xFFEAEFF6);
  static const Color _brownDark = Color(0xFF3A2415);
  static const Color _brown = Color(0xFF5A3520);
  static const Color _brown2 = Color(0xFF8A5A35);
  static const Color _teal = Color(0xFF3BAFBF);
  static const Color _blue = Color(0xFF5FA8D3);

  // =========================
  // THEME PACK
  // =========================
  static final Map<String, _ThemePack> _packs = {
    // =========================
    // OLD BACKGROUNDS
    // =========================
    Assets.images.home.path: const _ThemePack(
      primaryText: Color(0xFFE9C06B),
      secondaryText: Color(0xFFFFFFFF),
      accent: _blue,
      baseBg: Color(0xFF1B375D),
      dialogBg: Color(0xFF163A63),
    ),
    Assets.images.backgroundBroundWithMosBird.path: const _ThemePack(
      primaryText: _creamText,
      secondaryText: Color(0xFFFFFFFF),
      accent: _teal,
      baseBg: _brown,
      dialogBg: Color(0xFF4A2615),
    ),
    Assets.images.backgroundOliveGreenWithMosq.path: const _ThemePack(
      primaryText: _creamText,
      secondaryText: Color(0xFFE2EFF5),
      accent: _teal,
      baseBg: Color(0xFF0B3B3F),
      dialogBg: Color(0xFF032D25),
    ),
    Assets.images.backgroundGreenWith.path: const _ThemePack(
      primaryText: _creamText,
      secondaryText: Color(0xFFE2EFF5),
      accent: _gold,
      baseBg: Color(0xFF064635),
      dialogBg: Color(0xFF032D25),
    ),
    Assets.images.backgroundLight2.path: const _ThemePack(
      primaryText: _brown,
      secondaryText: _brown2,
      accent: _gold,
      baseBg: Color(0xFFF7EDE0),
      dialogBg: _brown,
    ),

    // =========================
    // YOUR "OLD NEW" BACKGROUNDS
    // =========================
    Assets.images.awesomeBackground.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _blue,
      baseBg: Color(0xFF1A1429),
      dialogBg: Color(0xFF201833),
    ),
    Assets.images.awesome2.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _teal,
      baseBg: Color(0xFF131113),
      dialogBg: Color(0xFF16110F),
    ),
    Assets.images.darkBrownBackground.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _teal,
      baseBg: Color(0xFF120F0F),
      dialogBg: Color(0xFF1E1715),
    ),
    Assets.images.lightBackground1.path: const _ThemePack(
      primaryText: _brown,
      secondaryText: _brown2,
      accent: _gold,
      baseBg: Color(0xFFFCF3E6),
      dialogBg: _brown,
    ),
    Assets.images.lightBrownBackground.path: const _ThemePack(
      primaryText: _creamText,
      secondaryText: Color(0xFFFFFFFF),
      accent: _teal,
      baseBg: Color(0xFF4A4037),
      dialogBg: _brownDark,
    ),
    Assets.images.brownBackground.path: const _ThemePack(
      primaryText: _creamText,
      secondaryText: Color(0xFFFFFFFF),
      accent: _blue,
      baseBg: Color(0xFF181614),
      dialogBg: Color(0xFF2D2520),
    ),
    Assets.images.background2.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _blue,
      baseBg: Color(0xFF070605),
      dialogBg: Color(0xFF14110D),
    ),
    Assets.images.whiteBackgroundWithNaqsh.path: const _ThemePack(
      primaryText: _brownDark,
      secondaryText: _brown2,
      accent: _gold,
      baseBg: Color(0xFFFBF7F3),
      dialogBg: _brown,
    ),

    // =========================
    // THE 5 BACKGROUNDS YOU ADDED BEFORE
    // =========================
    Assets.images.elegantTealArabesqueBackground.path: const _ThemePack(
      primaryText: _brownDark,
      secondaryText: Color(0xFF6D4B35),
      accent: _gold,
      baseBg: Color(0xFFEEF6F1),
      dialogBg: _brown,
    ),
    Assets.images.elegantBurgundyArabesqueBackground.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _teal,
      baseBg: Color(0xFF2A0E12),
      dialogBg: Color(0xFF2A0E12),
    ),
    Assets.images.convinentOliveGreenBackground.path: const _ThemePack(
      primaryText: _creamText,
      secondaryText: Color(0xFFFFFFFF),
      accent: _teal,
      baseBg: Color(0xFF2F2C1B),
      dialogBg: Color(0xFF1F2418),
    ),
    Assets.images.convinentBeigeBackground.path: const _ThemePack(
      primaryText: _brownDark,
      secondaryText: _brown2,
      accent: _gold,
      baseBg: Color(0xFFFBF3E6),
      dialogBg: _brown,
    ),
    Assets.images.tealBlueBackground.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF0E3A4A),
      dialogBg: Color(0xFF0E3A4A),
    ),

    // =========================
    // HR PACKS (hr_0 ... hr_17)
    // =========================
    // لو flutter_gen عندك بيطلع hr_0 بدل hr0 → بدّل الأسماء هنا
    Assets.images.hr0.path: const _ThemePack(
      primaryText: _creamText,
      secondaryText: Color(0xFFFFFFFF),
      accent: _gold,
      baseBg: Color(0xFF181614),
      dialogBg: Color(0xFF2D2520),
    ),
    Assets.images.hr1.path: const _ThemePack(
      primaryText: _brownDark,
      secondaryText: _brown2,
      accent: _gold,
      baseBg: Color(0xFFFBF3E6),
      dialogBg: _brown,
    ),
    Assets.images.hr2.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _teal,
      baseBg: Color(0xFF2A0E12),
      dialogBg: Color(0xFF1D0A0D),
    ),
    Assets.images.hr3.path: const _ThemePack(
      primaryText: _brownDark,
      secondaryText: _brown2,
      accent: _gold,
      baseBg: Color(0xFFEEF6F1),
      dialogBg: _brown,
    ),
    Assets.images.hr4.path: const _ThemePack(
      primaryText: _creamText,
      secondaryText: Color(0xFFFFFFFF),
      accent: _gold,
      baseBg: Color(0xFF2F2C1B),
      dialogBg: Color(0xFF1F2418),
    ),
    Assets.images.hr5.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF0E3A4A),
      dialogBg: Color(0xFF081C31),
    ),

    // HR-6 → HR-10 (اللي كنت كاتبهم لك قبل كده)
    Assets.images.hr6.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF0E3A4A),
      dialogBg: Color(0xFF081C31),
    ),
    Assets.images.hr7.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: Color(0xFFFFF7E6),
      accent: _teal,
      baseBg: Color(0xFF4A0D12),
      dialogBg: Color(0xFF2A0E12),
    ),
    Assets.images.hr8.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _teal,
      baseBg: Color(0xFF2A0E12),
      dialogBg: Color(0xFF1D0A0D),
    ),
    Assets.images.hr9.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF0B2A4A),
      dialogBg: Color(0xFF081C31),
    ),
    Assets.images.hr10.path: const _ThemePack(
      primaryText: _creamText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF122A2F),
      dialogBg: Color(0xFF0B1C1F),
    ),

    // HR-11 (Night lantern + mosque) — غامق جدًا
    Assets.images.hr11.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF070A0A),
      dialogBg: Color(0xFF0B1C1F),
    ),

    // HR-12 (Teal pattern) — غامق متوسط
    Assets.images.hr12.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF0E3A4A),
      dialogBg: Color(0xFF081C31),
    ),

    // HR-13 (Red pattern)
    Assets.images.hr13.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _teal,
      baseBg: Color(0xFF4A0D12),
      dialogBg: Color(0xFF2A0E12),
    ),

    // HR-14 (Blue pattern)
    Assets.images.hr14.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF0B2A4A),
      dialogBg: Color(0xFF081C31),
    ),

    // HR-15 (Blue mosque scene)
    Assets.images.hr15.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF0B2A4A),
      dialogBg: Color(0xFF081C31),
    ),

    // HR-16 (Red pattern - another shade)
    Assets.images.hr16.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _teal,
      baseBg: Color(0xFF4A0D12),
      dialogBg: Color(0xFF2A0E12),
    ),

    // HR-17 (Brown pattern)
    Assets.images.hr17.path: const _ThemePack(
      primaryText: _creamText,
      secondaryText: Color(0xFFFFFFFF),
      accent: _gold,
      baseBg: Color(0xFF2D2520),
      dialogBg: _brownDark,
    ),
    Assets.images.hr18.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF0F2E2F),
      dialogBg: Color(0xFF081C1D),
    ),

    Assets.images.hr19.path: const _ThemePack(
      primaryText: _brownDark,
      secondaryText: _brown2,
      accent: _gold,
      baseBg: Color(0xFFE9F1F8),
      dialogBg: _brown,
    ),
    Assets.images.hr20.path: const _ThemePack(
      primaryText: _creamText,
      secondaryText: Color(0xFFFFFFFF),
      accent: _gold,
      baseBg: Color(0xFF0E3B2E),
      dialogBg: Color(0xFF07261E),
    ),
    Assets.images.hr21.path: const _ThemePack(
      primaryText: _creamText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF13463A),
      dialogBg: Color(0xFF0A2C25),
    ),
    Assets.images.hr22.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _teal,
      baseBg: Color(0xFF5A0F14),
      dialogBg: Color(0xFF2A0E12),
    ),
    Assets.images.hr23.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF050505),
      dialogBg: Color(0xFF111111),
    ),
    Assets.images.hr24.path: const _ThemePack(
      primaryText: _softWhite,
      secondaryText: Color(0xFFD6E2EF),
      accent: _gold,
      baseBg: Color(0xFF2F3E4F),
      dialogBg: Color(0xFF1E2A35),
    ),
    // HR-25 — Teal mosque silhouette (غامق وهادي)
    Assets.images.hr25.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF0B2C31),
      dialogBg: Color(0xFF061A1D),
    ),

    // HR-26 — Dome of the rock photo (فوتو غامق - محتاج نص ذهبي/أبيض)
    Assets.images.hr26.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF121519),
      dialogBg: Color(0xFF0A0C0E),
    ),

    // HR-27 — Teal geometric pattern (متوسط غامق - نظيف للنص الأبيض)
    Assets.images.hr27.path: const _ThemePack(
      primaryText: _softWhite,
      secondaryText: Color(0xFFD6E7E8),
      accent: _gold,
      baseBg: Color(0xFF0F4650),
      dialogBg: Color(0xFF0A2F36),
    ),

    // HR-28 — Blue islamic pattern (أزرق ملكي)
    Assets.images.hr28.path: const _ThemePack(
      primaryText: _softWhite,
      secondaryText: Color(0xFFD7E3F3),
      accent: _gold,
      baseBg: Color(0xFF1E4F8F),
      dialogBg: Color(0xFF112C4F),
    ),

    // HR-29 — Red islamic pattern (خمري قوي)
    Assets.images.hr29.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _teal,
      baseBg: Color(0xFF7A0F12),
      dialogBg: Color(0xFF2C0C0E),
    ),

    // HR-30 — Blue scallop pattern (أزرق هادي)
    Assets.images.hr30.path: const _ThemePack(
      primaryText: _softWhite,
      secondaryText: Color(0xFFD5E6FF),
      accent: _gold,
      baseBg: Color(0xFF1F5E93),
      dialogBg: Color(0xFF123B5E),
    ),

    // HR-31 — Red scallop pattern (أحمر غامق فخم)
    Assets.images.hr31.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF8B1216),
      dialogBg: Color(0xFF300C0E),
    ),
    // HR-32 — Dark lanterns (أسود فخم - ذهب + أبيض)
    Assets.images.hr32.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF070707),
      dialogBg: Color(0xFF121212),
    ),

    // HR-33 — Kaaba wide crowd (فوتو غامق - ذهب + أبيض)
    Assets.images.hr33.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF0B0B0C),
      dialogBg: Color(0xFF141416),
    ),

    // HR-34 — Kaaba close (فوتو غامق - ذهب + أبيض)
    Assets.images.hr34.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF0A0A0A),
      dialogBg: Color(0xFF151515),
    ),

    // HR-35 — Mosque facade (إضاءة دافية - كريمي + ذهبي)
    Assets.images.hr35.path: const _ThemePack(
      primaryText: _creamText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF11110F),
      dialogBg: Color(0xFF1A1A17),
    ),

    // HR-36 — Blue smoky texture (أزرق غامق - أبيض)
    Assets.images.hr36.path: const _ThemePack(
      primaryText: _softWhite,
      secondaryText: Color(0xFFD7E6FF),
      accent: _gold,
      baseBg: Color(0xFF0E2A44),
      dialogBg: Color(0xFF081826),
    ),

    // HR-37 — Red pattern (أحمر متوسط - ذهب + أبيض)
    Assets.images.hr37.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF8E1618),
      dialogBg: Color(0xFF2F0D0E),
    ),

    // HR-38 — Dark navy star pattern (كحلي فخم - أبيض)
    Assets.images.hr38.path: const _ThemePack(
      primaryText: _softWhite,
      secondaryText: Color(0xFFD7E3F3),
      accent: _gold,
      baseBg: Color(0xFF081E33),
      dialogBg: Color(0xFF04101C),
    ),

    // =========================
    Assets.images.vr20.path: const _ThemePack(
      primaryText: _softWhite,
      secondaryText: Color(0xFFD6E7E8),
      accent: _gold,
      baseBg: Color(0xFF0F4650),
      dialogBg: Color(0xFF0A2F36),
    ),

    // VR-21 — Red pattern (خمري)
    Assets.images.vr21.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _teal,
      baseBg: Color(0xFF4A0D12),
      dialogBg: Color(0xFF2A0E12),
    ),

    // VR-22 — Dark pattern (أسود فخم)
    Assets.images.vr22.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF050505),
      dialogBg: Color(0xFF111111),
    ),

    // VR-23 — Dark lantern/ornament (غامق جدًا)
    Assets.images.vr23.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF070707),
      dialogBg: Color(0xFF121212),
    ),

    // VR-24 — Blue royal pattern
    Assets.images.vr24.path: const _ThemePack(
      primaryText: _softWhite,
      secondaryText: Color(0xFFD7E3F3),
      accent: _gold,
      baseBg: Color(0xFF1E4F8F),
      dialogBg: Color(0xFF112C4F),
    ),

    // VR-25 — Dark photo (فوتو غامق)
    Assets.images.vr25.path: const _ThemePack(
      primaryText: _goldText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF0A0A0A),
      dialogBg: Color(0xFF151515),
    ),

    // VR-26 — Warm mosque/lantern photo (دافي)
    Assets.images.vr26.path: const _ThemePack(
      primaryText: _creamText,
      secondaryText: _softWhite,
      accent: _gold,
      baseBg: Color(0xFF11110F),
      dialogBg: Color(0xFF1A1A17),
    ),

    // VR-27 — Blue smoky texture
    Assets.images.vr27.path: const _ThemePack(
      primaryText: _softWhite,
      secondaryText: Color(0xFFD7E6FF),
      accent: _gold,
      baseBg: Color(0xFF0E2A44),
      dialogBg: Color(0xFF081826),
    ),
  };

  static _ThemePack get _p =>
      _packs[_bg] ??
      const _ThemePack(
        primaryText: Color(0xFFE9C06B),
        secondaryText: Color(0xFFFFFFFF),
        accent: _blue,
        baseBg: Color(0xFF1B375D),
        dialogBg: Color(0xFF163A63),
      );

  static bool get _isLightBase =>
      ThemeData.estimateBrightnessForColor(_p.baseBg) == Brightness.light;

  // =========================
  // PRIMARY TEXT
  // =========================
  static Color get primaryTextColor => _p.primaryText;

  // =========================
  // SECONDARY TEXT
  // =========================
  static Color get secondaryTextColor => _p.secondaryText;

  // =========================
  // ACCENT
  // =========================
  static Color get accentColor => _p.accent;

  // =========================
  // BASE BACKGROUND (بديل darkBlue)
  // =========================
  static Color get darkBlue => _p.baseBg;

  // =========================
  // DIALOG BACKGROUND
  // =========================
  static Color get dialogBackgroundColor => _p.dialogBg;

  // =========================
  // DIALOG TITLE COLOR
  // =========================
  static Color get dialogTitleColor {
    final brightness = ThemeData.estimateBrightnessForColor(
      dialogBackgroundColor,
    );
    return brightness == Brightness.dark ? _goldText : _brown;
  }

  // =========================
  // DIALOG BODY TEXT COLOR
  // =========================
  static Color get dialogBodyTextColor {
    final brightness = ThemeData.estimateBrightnessForColor(
      dialogBackgroundColor,
    );
    return brightness == Brightness.dark ? _softWhite : _brownDark;
  }

  // =========================
  // BUTTON COLORS
  // =========================
  static Color get primaryButtonBackground {
    // لو الـ base فاتح: زر دهبي ثابت
    if (_isLightBase) return _gold;
    return accentColor;
  }

  static Color get primaryButtonTextColor {
    // لو الـ base فاتح + زر دهبي: نص بني
    if (_isLightBase) return _brown;
    return const Color(0xFFFFFFFF);
  }
}

class _ThemePack {
  final Color primaryText;
  final Color secondaryText;
  final Color accent;
  final Color baseBg;
  final Color dialogBg;

  const _ThemePack({
    required this.primaryText,
    required this.secondaryText,
    required this.accent,
    required this.baseBg,
    required this.dialogBg,
  });
}
