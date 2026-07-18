import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/components/global_copyright_footer.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  static const String _websiteQrAsset = 'assets/images/rawayie_website_qr.png';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _openSite() async {
    final uri = Uri.parse('https://rawayie.sa');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open ${uri.host}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final qrSize = isLandscape ? 112.r : 148.r;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const GlobalCopyrightFooter(cityOnly: true),
      key: _scaffoldKey,
      drawer: CustomDrawer(context: context),
      body: Stack(
        children: [
          Image.asset(
            CacheHelper.getSelectedBackground(),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fill,
          ),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  onClose: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              'RAWAYIE.SA',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 33.sp,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryTextColor,
                                fontFamily: CacheHelper.getTextsFontFamily(),
                              ),
                            ),
                            SizedBox(height: 30.h),

                            SizedBox(height: 10.h),
                            Text(
                              LocaleKeys.about_app_details.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 27.sp,
                                height: 1.65,
                                color: AppTheme.primaryTextColor,
                                fontFamily: "SULTAN",
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              LocaleKeys.unified_number.tr() + unifiedNumber,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 27.sp,
                                height: 1.65,
                                color: AppTheme.primaryTextColor,
                                fontFamily: "SULTAN",
                              ),
                            ),
                            SizedBox(height: 26.h),
                            Text(
                              LocaleKeys.website.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 27.sp,
                                height: 1.65,
                                color: AppTheme.primaryTextColor,
                                fontFamily: CacheHelper.getTextsFontFamily(),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            GestureDetector(
                              onTap: _openSite,
                              child: Text(
                                'rawayie.sa',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  color: AppTheme.secondaryTextColor,
                                  fontFamily: CacheHelper.getTextsFontFamily(),
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Semantics(
                              label: 'rawayie.sa QR code',
                              button: true,
                              child: GestureDetector(
                                onTap: _openSite,
                                child: Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: Colors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Image.asset(
                                    _websiteQrAsset,
                                    width: qrSize,
                                    height: qrSize,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMenu, required this.onClose});

  final VoidCallback onMenu;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double barHeight = isLandscape ? 72.h : 52.h;
    final double iconSize = isLandscape ? 32.r : 26.r;

    return Container(
      height: barHeight,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onMenu,
            icon: Icon(
              Icons.menu,
              color: AppTheme.primaryTextColor,
              size: iconSize,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close,
              color: AppTheme.accentColor,
              size: iconSize,
            ),
          ),
        ],
      ),
    );
  }
}
