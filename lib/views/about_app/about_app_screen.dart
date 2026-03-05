import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:azan/core/components/global_copyright_footer.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _openSite() async {
    final uri = Uri.parse('https://sajdh.org');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open ${uri.host}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const GlobalCopyrightFooter(),
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
                              'SAJDH.ORG',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 33.sp,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryTextColor,
                                fontFamily: CacheHelper.getTextsFontFamily(),
                              ),
                            ),
                            SizedBox(height: 30.h),
                            Text(
                              LocaleKeys.about_app_dedicated_message.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 27.sp,
                                height: 1.65,
                                color: AppTheme.primaryTextColor,
                                fontFamily: CacheHelper.getTextsFontFamily(),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'This application is 100% freeware!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24.sp,
                                height: 1.55,
                                color: AppTheme.primaryTextColor,
                                fontFamily: CacheHelper.getTextsFontFamily(),
                              ),
                            ),
                            SizedBox(height: 26.h),
                            GestureDetector(
                              onTap: _openSite,
                              child: Text(
                                'Sajdh.org',
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
