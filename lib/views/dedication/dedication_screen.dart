import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/components/global_copyright_footer.dart';

class DedicationScreen extends StatefulWidget {
  const DedicationScreen({super.key});

  @override
  State<DedicationScreen> createState() => _DedicationScreenState();
}

class _DedicationScreenState extends State<DedicationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    // ✅ Metrics responsive بناءً على orientation
    final metrics = _DedicationMetrics.auto(isLandscape: isLandscape);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const GlobalCopyrightFooter(),
      key: _scaffoldKey,
      drawer: CustomDrawer(context: context),
      body: Stack(
        children: [
          // ✅ Background
          Positioned.fill(
            child: Image.asset(
              CacheHelper.getSelectedBackground(),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fill,
            ),
          ),

          // ✅ Content
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  onClose: () => Navigator.pop(context),
                  metrics: metrics,
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: metrics.contentPadding,
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: metrics.topSpacer),

                            // ✅ Logo/Icon
                            Container(
                              width: metrics.iconSize,
                              height: metrics.iconSize,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  metrics.iconSize * 0.2,
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: metrics.iconBorderWidth,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.favorite,
                                size: metrics.iconSize * 0.5,
                                color: AppTheme.accentColor,
                              ),
                            ),

                            SizedBox(height: metrics.iconGap),

                            // ✅ Main Title
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                LocaleKeys.dedication_title.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: metrics.titleSize,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryTextColor,
                                  fontFamily: CacheHelper.getTextsFontFamily(),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),

                            SizedBox(height: metrics.subtitleGap),

                            // ✅ Subtitle
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                LocaleKeys.dedication_subtitle.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: metrics.subtitleSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondaryTextColor,
                                  fontFamily: CacheHelper.getTextsFontFamily(),
                                ),
                              ),
                            ),

                            SizedBox(height: metrics.messageGap),

                            // ✅ Main Message Card
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(metrics.cardPadding),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(
                                  metrics.cardRadius,
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: metrics.cardBorderWidth,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    LocaleKeys.dedication_card_title.tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: metrics.cardTitleSize,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.accentColor,
                                      fontFamily:
                                          CacheHelper.getTextsFontFamily(),
                                    ),
                                  ),

                                  SizedBox(height: metrics.cardContentGap),

                                  Text(
                                    LocaleKeys.dedication_card_text.tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: metrics.cardTextSize,
                                      height: 1.8,
                                      color: AppTheme.primaryTextColor,
                                      fontFamily:
                                          CacheHelper.getTextsFontFamily(),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: metrics.thanksGap),

                            // ✅ Thanks Section
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(metrics.thanksPadding),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.accentColor.withOpacity(0.3),
                                    AppTheme.accentColor.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(
                                  metrics.thanksRadius,
                                ),
                                border: Border.all(
                                  color: AppTheme.accentColor.withOpacity(0.3),
                                  width: metrics.thanksBorderWidth,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.volunteer_activism,
                                    size: metrics.thanksIconSize,
                                    color: AppTheme.accentColor,
                                  ),

                                  SizedBox(height: metrics.thanksTextGap),

                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      LocaleKeys.dedication_thanks.tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: metrics.thanksSize,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.secondaryTextColor,
                                        fontFamily:
                                            CacheHelper.getTextsFontFamily(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: metrics.bottomSpacer),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ✅ Bottom Bar
                Padding(
                  padding: EdgeInsets.only(bottom: metrics.bottomBarPadding),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: metrics.bottomBarPaddingX,
                      vertical: metrics.bottomBarPaddingY,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(
                        metrics.bottomBarRadius,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: metrics.bottomBarBorderWidth,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_outline,
                            size: metrics.bottomBarIconSize,
                            color: AppTheme.accentColor,
                          ),
                          SizedBox(width: metrics.bottomBarIconGap),
                          Text(
                            LocaleKeys.dedication_bottom_bar.tr(),
                            style: TextStyle(
                              fontSize: metrics.bottomBarSize,
                              color: AppTheme.primaryTextColor,
                              fontFamily: CacheHelper.getTextsFontFamily(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ Top Bar Widget
// ════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onMenu,
    required this.onClose,
    required this.metrics,
  });

  final VoidCallback onMenu;
  final VoidCallback onClose;
  final _DedicationMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: metrics.barHeight,
      padding: EdgeInsets.symmetric(horizontal: metrics.barPaddingX),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onMenu,
            icon: Icon(
              Icons.menu,
              color: AppTheme.primaryTextColor,
              size: metrics.barIconSize,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: metrics.iconButtonSize,
              minHeight: metrics.iconButtonSize,
            ),
          ),

          const Spacer(),

          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close,
              color: AppTheme.accentColor,
              size: metrics.barIconSize,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: metrics.iconButtonSize,
              minHeight: metrics.iconButtonSize,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ Responsive Metrics
// ════════════════════════════════════════════════════════════════════════════

class _DedicationMetrics {
  // Bar
  final double barHeight;
  final double barPaddingX;
  final double barIconSize;
  final double iconButtonSize;

  // Content
  final double contentPadding;
  final double topSpacer;
  final double bottomSpacer;

  // Icon
  final double iconSize;
  final double iconBorderWidth;
  final double iconGap;

  // Title
  final double titleSize;
  final double subtitleSize;
  final double subtitleGap;

  // Message Card
  final double messageGap;
  final double cardPadding;
  final double cardRadius;
  final double cardBorderWidth;
  final double cardTitleSize;
  final double cardContentGap;
  final double cardTextSize;

  // Thanks Section
  final double thanksGap;
  final double thanksPadding;
  final double thanksRadius;
  final double thanksBorderWidth;
  final double thanksIconSize;
  final double thanksTextGap;
  final double thanksSize;

  // Bottom Bar
  final double bottomBarPadding;
  final double bottomBarPaddingX;
  final double bottomBarPaddingY;
  final double bottomBarRadius;
  final double bottomBarBorderWidth;
  final double bottomBarSize;
  final double bottomBarIconSize;
  final double bottomBarIconGap;

  const _DedicationMetrics({
    required this.barHeight,
    required this.barPaddingX,
    required this.barIconSize,
    required this.iconButtonSize,
    required this.contentPadding,
    required this.topSpacer,
    required this.bottomSpacer,
    required this.iconSize,
    required this.iconBorderWidth,
    required this.iconGap,
    required this.titleSize,
    required this.subtitleSize,
    required this.subtitleGap,
    required this.messageGap,
    required this.cardPadding,
    required this.cardRadius,
    required this.cardBorderWidth,
    required this.cardTitleSize,
    required this.cardContentGap,
    required this.cardTextSize,
    required this.thanksGap,
    required this.thanksPadding,
    required this.thanksRadius,
    required this.thanksBorderWidth,
    required this.thanksIconSize,
    required this.thanksTextGap,
    required this.thanksSize,
    required this.bottomBarPadding,
    required this.bottomBarPaddingX,
    required this.bottomBarPaddingY,
    required this.bottomBarRadius,
    required this.bottomBarBorderWidth,
    required this.bottomBarSize,
    required this.bottomBarIconSize,
    required this.bottomBarIconGap,
  });

  factory _DedicationMetrics.auto({required bool isLandscape}) {
    return isLandscape
        ? _DedicationMetrics.landscape()
        : _DedicationMetrics.portrait();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ✅ PORTRAIT Metrics (Design: 393 x 852)
  // ════════════════════════════════════════════════════════════════════════════
  factory _DedicationMetrics.portrait() {
    return _DedicationMetrics(
      // Bar
      barHeight: 52.h,
      barPaddingX: 6.w,
      barIconSize: 26.r,
      iconButtonSize: 48.r,

      // Content
      contentPadding: 20.w,
      topSpacer: 25.h,
      bottomSpacer: 35.h,

      // Icon
      iconSize: 90.r,
      iconBorderWidth: 2.w,
      iconGap: 20.h,

      // Title
      titleSize: 36.sp,
      subtitleSize: 24.sp,
      subtitleGap: 8.h,

      // Message Card
      messageGap: 25.h,
      cardPadding: 24.w,
      cardRadius: 16.r,
      cardBorderWidth: 1.5.w,
      cardTitleSize: 22.sp,
      cardContentGap: 16.h,
      cardTextSize: 18.sp,

      // Thanks Section
      thanksGap: 25.h,
      thanksPadding: 20.w,
      thanksRadius: 14.r,
      thanksBorderWidth: 1.5.w,
      thanksIconSize: 50.r,
      thanksTextGap: 12.h,
      thanksSize: 24.sp,

      // Bottom Bar
      bottomBarPadding: 12.h,
      bottomBarPaddingX: 16.w,
      bottomBarPaddingY: 10.h,
      bottomBarRadius: 10.r,
      bottomBarBorderWidth: 1.w,
      bottomBarSize: 18.sp,
      bottomBarIconSize: 22.r,
      bottomBarIconGap: 10.w,
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ✅ LANDSCAPE Metrics (Design: 960 x 540)
  // ════════════════════════════════════════════════════════════════════════════
  factory _DedicationMetrics.landscape() {
    return _DedicationMetrics(
      // Bar
      barHeight: 72.h,
      barPaddingX: 12.w,
      barIconSize: 32.r,
      iconButtonSize: 56.r,

      // Content
      contentPadding: 40.w,
      topSpacer: 35.h,
      bottomSpacer: 45.h,

      // Icon
      iconSize: 130.r,
      iconBorderWidth: 3.w,
      iconGap: 28.h,

      // Title
      titleSize: 52.sp,
      subtitleSize: 32.sp,
      subtitleGap: 12.h,

      // Message Card
      messageGap: 35.h,
      cardPadding: 40.w,
      cardRadius: 24.r,
      cardBorderWidth: 2.w,
      cardTitleSize: 32.sp,
      cardContentGap: 24.h,
      cardTextSize: 26.sp,

      // Thanks Section
      thanksGap: 35.h,
      thanksPadding: 32.w,
      thanksRadius: 20.r,
      thanksBorderWidth: 2.w,
      thanksIconSize: 70.r,
      thanksTextGap: 18.h,
      thanksSize: 32.sp,

      // Bottom Bar
      bottomBarPadding: 18.h,
      bottomBarPaddingX: 24.w,
      bottomBarPaddingY: 14.h,
      bottomBarRadius: 14.r,
      bottomBarBorderWidth: 1.5.w,
      bottomBarSize: 24.sp,
      bottomBarIconSize: 28.r,
      bottomBarIconGap: 14.w,
    );
  }
}
