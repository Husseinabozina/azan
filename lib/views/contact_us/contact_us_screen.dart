import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:azan/core/components/appbutton.dart';
import 'package:azan/core/components/global_copyright_footer.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/dialoge_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  static const String _supportEmail = 'rawayie1448@gmail.com';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    FocusScope.of(context).unfocus();

    // Build the query manually so spaces are encoded as %20 (not '+').
    // Uri's queryParameters uses application/x-www-form-urlencoded encoding,
    // which turns spaces into '+', and Gmail shows those '+' literally in the
    // subject instead of decoding them back to spaces.
    final subject = LocaleKeys.contact_us_email_subject.tr();
    final body = _messageController.text.trim();
    final mailUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query:
          'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    final opened = await launchUrl(
      mailUri,
      mode: LaunchMode.externalApplication,
    );

    if (!mounted || opened) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocaleKeys.contact_us_launch_error.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.size.width > mediaQuery.size.height;

    return Scaffold(
      extendBody: true,
      key: _scaffoldKey,
      drawer: CustomDrawer(context: context),
      bottomNavigationBar: const GlobalCopyrightFooter(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              CacheHelper.getSelectedBackground(),
              fit: BoxFit.fill,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.black.withOpacity(0.12),
                    Colors.black.withOpacity(0.20),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  onClose: () => Navigator.pop(context),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final metrics = _ContactUsMetrics.fromConstraints(
                        constraints: constraints,
                        isLandscape: isLandscape,
                      );

                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(
                          metrics.horizontalPadding,
                          metrics.topPadding,
                          metrics.horizontalPadding,
                          math.max(
                            metrics.bottomPadding,
                            mediaQuery.viewInsets.bottom +
                                metrics.bottomPadding,
                          ),
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: math.max(
                                0,
                                constraints.maxHeight - metrics.topPadding,
                              ),
                              maxWidth: metrics.contentMaxWidth,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _HeaderPill(metrics: metrics),
                                SizedBox(height: metrics.sectionGap),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  spacing: metrics.panelGap,
                                  runSpacing: metrics.panelGap,
                                  children: [
                                    SizedBox(
                                      width: metrics.heroPanelWidth,
                                      child: _HeroPanel(
                                        metrics: metrics,
                                        supportEmail: _supportEmail,
                                      ),
                                    ),
                                    SizedBox(
                                      width: metrics.formPanelWidth,
                                      child: _ComposerPanel(
                                        metrics: metrics,
                                        formKey: _formKey,
                                        messageController: _messageController,
                                        onSend: _sendMessage,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMenu, required this.onClose});

  final VoidCallback onMenu;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final iconSize = isLandscape ? 31.r : 27.r;
    final barHeight = isLandscape ? 72.h : 56.h;

    return SizedBox(
      height: barHeight,
      child: Row(
        children: [
          IconButton(
            onPressed: onMenu,
            icon: Icon(
              Icons.menu_rounded,
              color: AppTheme.primaryTextColor,
              size: iconSize,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close_rounded,
              color: AppTheme.accentColor,
              size: iconSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.metrics});

  final _ContactUsMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.pillHorizontalPadding,
        vertical: metrics.pillVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(metrics.pillRadius),
        border: Border.all(color: Colors.white.withOpacity(0.26), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          LocaleKeys.contact_us.tr(),
          style: TextStyle(
            fontSize: metrics.pillTitleSize,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryTextColor,
            fontFamily: CacheHelper.getTextsFontFamily(),
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.metrics, required this.supportEmail});

  final _ContactUsMetrics metrics;
  final String supportEmail;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: EdgeInsets.all(metrics.panelPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MailHeroBadge(metrics: metrics),
          SizedBox(height: metrics.heroGap),
          Text(
            LocaleKeys.contact_us_intro_title.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: metrics.heroTitleSize,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryTextColor,
              fontFamily: CacheHelper.getTextsFontFamily(),
            ),
          ),
          SizedBox(height: metrics.textGap),
          Text(
            LocaleKeys.contact_us_intro_body.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: metrics.bodySize,
              height: 1.7,
              color: AppTheme.secondaryTextColor,
              fontFamily: CacheHelper.getTextsFontFamily(),
            ),
          ),
          SizedBox(height: metrics.textGap),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: metrics.emailHorizontalPadding,
              vertical: metrics.emailVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(metrics.emailRadius),
              border: Border.all(
                color: AppTheme.accentColor.withOpacity(0.32),
                width: 1,
              ),
            ),
            child: Text(
              supportEmail,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: metrics.emailSize,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MailHeroBadge extends StatelessWidget {
  const _MailHeroBadge({required this.metrics});

  final _ContactUsMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: metrics.heroSize,
      height: metrics.heroSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.40),
                  Colors.white.withOpacity(0.14),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.32),
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
          ),
          Container(
            width: metrics.heroSize * 0.74,
            height: metrics.heroSize * 0.74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          Container(
            width: metrics.heroSize * 0.38,
            height: metrics.heroSize * 0.38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(metrics.heroSize * 0.10),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A73E8), Color(0xFF34A853)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.mail_rounded,
              color: Colors.white,
              size: metrics.heroSize * 0.20,
            ),
          ),
          Positioned(
            top: metrics.heroSize * 0.17,
            right: metrics.heroSize * 0.16,
            child: Container(
              width: metrics.heroSize * 0.14,
              height: metrics.heroSize * 0.14,
              decoration: BoxDecoration(
                color: const Color(0xFFEA4335),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.92),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerPanel extends StatelessWidget {
  const _ComposerPanel({
    required this.metrics,
    required this.formKey,
    required this.messageController,
    required this.onSend,
  });

  final _ContactUsMetrics metrics;
  final GlobalKey<FormState> formKey;
  final TextEditingController messageController;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: EdgeInsets.all(metrics.panelPadding),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocaleKeys.contact_us_message_label.tr(),
              style: TextStyle(
                fontSize: metrics.formTitleSize,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryTextColor,
                fontFamily: CacheHelper.getTextsFontFamily(),
              ),
            ),
            SizedBox(height: metrics.smallGap),
            Text(
              LocaleKeys.contact_us_delivery_note.tr(),
              style: TextStyle(
                fontSize: metrics.helperSize,
                height: 1.5,
                color: AppTheme.secondaryTextColor,
                fontFamily: CacheHelper.getTextsFontFamily(),
              ),
            ),
            SizedBox(height: metrics.fieldGap),
            VirtualTextField(
              key: const ValueKey('contact-us-message-field'),
              controller: messageController,
              maxLines: metrics.messageMaxLines,
              hintText: LocaleKeys.contact_us_message_hint.tr(),
              textAlign: TextAlign.right,
              textDirection: ui.TextDirection.rtl,
              minFieldHeight:
                  metrics.bodySize * metrics.messageMinLines * 1.35,
              borderRadius: metrics.fieldRadius,
              contentPadding: EdgeInsets.symmetric(
                horizontal: metrics.fieldHorizontalPadding,
                vertical: metrics.fieldVerticalPadding,
              ),
              textStyle: TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: metrics.bodySize,
                fontFamily: CacheHelper.getTextsFontFamily(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return LocaleKeys.contact_us_empty_error.tr();
                }
                return null;
              },
              theme: VirtualKeyboardFieldTheme(
                fillColor: Colors.white.withOpacity(0.10),
                borderColor: Colors.white.withOpacity(0.20),
                activeBorderColor: AppTheme.accentColor.withOpacity(0.88),
                errorBorderColor: const Color(0xFFE57373),
                textColor: AppTheme.primaryTextColor,
                hintColor: AppTheme.secondaryTextColor.withOpacity(0.82),
                labelColor: AppTheme.secondaryTextColor,
                keyboardTextColor: const Color(0xFF18202A),
                keyboardBackgroundColor: Colors.white,
                keyboardBorderColor: const Color(0x66D4A64A),
                keyboardShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
            ),
            SizedBox(height: metrics.fieldGap),
            LayoutBuilder(
              builder: (context, constraints) {
                return AppButton(
                  key: const ValueKey('contact-us-send-button'),
                  width: constraints.maxWidth,
                  height: metrics.buttonHeight,
                  radius: metrics.buttonRadius,
                  color: AppTheme.primaryButtonBackground,
                  borderColor: AppTheme.primaryButtonBackground,
                  onPressed: onSend,
                  child: Text(
                    LocaleKeys.contact_us_send.tr(),
                    style: TextStyle(
                      fontSize: metrics.buttonTextSize,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryButtonTextColor,
                      fontFamily: CacheHelper.getTextsFontFamily(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.30),
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ContactUsMetrics {
  const _ContactUsMetrics({
    required this.contentMaxWidth,
    required this.horizontalPadding,
    required this.topPadding,
    required this.bottomPadding,
    required this.sectionGap,
    required this.panelGap,
    required this.heroPanelWidth,
    required this.formPanelWidth,
    required this.panelPadding,
    required this.pillHorizontalPadding,
    required this.pillVerticalPadding,
    required this.pillRadius,
    required this.pillTitleSize,
    required this.heroSize,
    required this.heroGap,
    required this.heroTitleSize,
    required this.bodySize,
    required this.textGap,
    required this.emailHorizontalPadding,
    required this.emailVerticalPadding,
    required this.emailRadius,
    required this.emailSize,
    required this.formTitleSize,
    required this.helperSize,
    required this.smallGap,
    required this.fieldGap,
    required this.fieldHorizontalPadding,
    required this.fieldVerticalPadding,
    required this.fieldRadius,
    required this.messageMinLines,
    required this.messageMaxLines,
    required this.buttonHeight,
    required this.buttonRadius,
    required this.buttonTextSize,
  });

  final double contentMaxWidth;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;
  final double sectionGap;
  final double panelGap;
  final double heroPanelWidth;
  final double formPanelWidth;
  final double panelPadding;
  final double pillHorizontalPadding;
  final double pillVerticalPadding;
  final double pillRadius;
  final double pillTitleSize;
  final double heroSize;
  final double heroGap;
  final double heroTitleSize;
  final double bodySize;
  final double textGap;
  final double emailHorizontalPadding;
  final double emailVerticalPadding;
  final double emailRadius;
  final double emailSize;
  final double formTitleSize;
  final double helperSize;
  final double smallGap;
  final double fieldGap;
  final double fieldHorizontalPadding;
  final double fieldVerticalPadding;
  final double fieldRadius;
  final int messageMinLines;
  final int messageMaxLines;
  final double buttonHeight;
  final double buttonRadius;
  final double buttonTextSize;

  factory _ContactUsMetrics.fromConstraints({
    required BoxConstraints constraints,
    required bool isLandscape,
  }) {
    final contentMaxWidth = isLandscape
        ? math.min(constraints.maxWidth * 0.94, 1180.0)
        : math.min(constraints.maxWidth * 0.92, 680.0);
    final wideLayout = isLandscape && contentMaxWidth >= 860;
    final panelGap = wideLayout ? 22.w : 16.w;
    final heroPanelWidth = wideLayout
        ? math.min((contentMaxWidth - panelGap) * 0.42, 430.0)
        : contentMaxWidth;
    final formPanelWidth = wideLayout
        ? math.min((contentMaxWidth - panelGap) * 0.58, 640.0)
        : contentMaxWidth;

    return _ContactUsMetrics(
      contentMaxWidth: contentMaxWidth,
      horizontalPadding: wideLayout ? 24.w : 18.w,
      topPadding: wideLayout ? 10.h : 8.h,
      bottomPadding: wideLayout ? 18.h : 14.h,
      sectionGap: wideLayout ? 22.h : 18.h,
      panelGap: panelGap,
      heroPanelWidth: heroPanelWidth,
      formPanelWidth: formPanelWidth,
      panelPadding: wideLayout ? 22.r : 18.r,
      pillHorizontalPadding: wideLayout ? 32.w : 24.w,
      pillVerticalPadding: wideLayout ? 10.h : 8.h,
      pillRadius: wideLayout ? 30.r : 26.r,
      pillTitleSize: wideLayout ? 25.sp : 22.sp,
      heroSize: wideLayout ? 172.r : 144.r,
      heroGap: wideLayout ? 18.h : 14.h,
      heroTitleSize: wideLayout ? 25.sp : 22.sp,
      bodySize: wideLayout ? 16.sp : 14.sp,
      textGap: wideLayout ? 14.h : 10.h,
      emailHorizontalPadding: wideLayout ? 18.w : 14.w,
      emailVerticalPadding: wideLayout ? 10.h : 8.h,
      emailRadius: wideLayout ? 20.r : 16.r,
      emailSize: wideLayout ? 14.sp : 13.sp,
      formTitleSize: wideLayout ? 22.sp : 19.sp,
      helperSize: wideLayout ? 13.sp : 12.sp,
      smallGap: wideLayout ? 8.h : 6.h,
      fieldGap: wideLayout ? 16.h : 12.h,
      fieldHorizontalPadding: wideLayout ? 18.w : 14.w,
      fieldVerticalPadding: wideLayout ? 18.h : 14.h,
      fieldRadius: wideLayout ? 24.r : 20.r,
      messageMinLines: wideLayout ? 9 : 7,
      messageMaxLines: wideLayout ? 12 : 10,
      buttonHeight: wideLayout ? 60.h : 56.h,
      buttonRadius: wideLayout ? 24.r : 22.r,
      buttonTextSize: wideLayout ? 18.sp : 17.sp,
    );
  }
}
