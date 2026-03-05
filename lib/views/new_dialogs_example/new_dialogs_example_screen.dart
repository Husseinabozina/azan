import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/core/utils/new_dialog_system.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/components/global_copyright_footer.dart';

/// ============================================================================
/// 📝 مثال عملي لاستخدام نظام Dialogs الجديد
/// ============================================================================

class NewDialogsExampleScreen extends StatefulWidget {
  const NewDialogsExampleScreen({super.key});

  @override
  State<NewDialogsExampleScreen> createState() =>
      _NewDialogsExampleScreenState();
}

class _NewDialogsExampleScreenState extends State<NewDialogsExampleScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
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
                // Top Bar
                _TopBar(
                  onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  onClose: () => Navigator.pop(context),
                ),

                // ✅ Examples List
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 20.h),

                          // Title
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              LocaleKeys.dialogs_examples_title.tr(),
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryTextColor,
                                fontFamily: CacheHelper.getTextsFontFamily(),
                              ),
                            ),
                          ),

                          SizedBox(height: 10.h),

                          // Subtitle
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              LocaleKeys.dialogs_examples_subtitle.tr(),
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: AppTheme.secondaryTextColor,
                                fontFamily: CacheHelper.getTextsFontFamily(),
                              ),
                            ),
                          ),

                          SizedBox(height: 30.h),

                          // ✅ Example 1: Simple Alert
                          _ExampleButton(
                            title: LocaleKeys.dialog_example_1_title.tr(),
                            subtitle: LocaleKeys.dialog_example_1_subtitle.tr(),
                            icon: Icons.info_outline,
                            onTap: () => _showSimpleAlert(),
                          ),

                          SizedBox(height: 15.h),

                          // ✅ Example 2: Confirmation
                          _ExampleButton(
                            title: LocaleKeys.dialog_example_2_title.tr(),
                            subtitle: LocaleKeys.dialog_example_2_subtitle.tr(),
                            icon: Icons.help_outline,
                            onTap: () => _showConfirmation(),
                          ),

                          SizedBox(height: 15.h),

                          // ✅ Example 3: Input
                          _ExampleButton(
                            title: LocaleKeys.dialog_example_3_title.tr(),
                            subtitle: LocaleKeys.dialog_example_3_subtitle.tr(),
                            icon: Icons.edit_note_outlined,
                            onTap: () => _showInput(),
                          ),

                          SizedBox(height: 15.h),

                          // ✅ Example 4: Single Choice
                          _ExampleButton(
                            title: LocaleKeys.dialog_example_4_title.tr(),
                            subtitle: LocaleKeys.dialog_example_4_subtitle.tr(),
                            icon: Icons.list_alt,
                            onTap: () => _showSingleChoice(),
                          ),

                          SizedBox(height: 15.h),

                          // ✅ Example 5: Custom Dialog
                          _ExampleButton(
                            title: LocaleKeys.dialog_example_5_title.tr(),
                            subtitle: LocaleKeys.dialog_example_5_subtitle.tr(),
                            icon: Icons.design_services_outlined,
                            onTap: () => _showCustomDialog(),
                          ),

                          SizedBox(height: 30.h),
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

  // ════════════════════════════════════════════════════════════════════════════
  // 📝 Dialog Examples
  // ════════════════════════════════════════════════════════════════════════════

  void _showSimpleAlert() {
    showNewAlertDialog(
      context: context,
      title: LocaleKeys.dialog_alert_title.tr(),
      message: LocaleKeys.dialog_alert_message.tr(),
      confirmText: LocaleKeys.dialog_alert_confirm.tr(),
      icon: Icons.notifications_active,
      onConfirm: () {
        debugPrint('تم الضغط على تأكيد');
      },
    );
  }

  void _showConfirmation() {
    showNewConfirmDialog(
      context: context,
      title: LocaleKeys.dialog_confirm_title.tr(),
      message: LocaleKeys.dialog_confirm_message.tr(),
      confirmText: LocaleKeys.dialog_confirm_confirm.tr(),
      cancelText: LocaleKeys.dialog_confirm_cancel.tr(),
      icon: Icons.delete_forever,
      iconColor: Colors.red,
    ).then((confirmed) {
      if (confirmed == true) {
        debugPrint('تم تأكيد الحذف');
      } else {
        debugPrint('تم إلغاء الحذف');
      }
    });
  }

  void _showInput() {
    showNewInputDialog(
      context: context,
      title: LocaleKeys.dialog_input_title.tr(),
      hint: LocaleKeys.dialog_input_hint.tr(),
      initialValue: '',
      maxLines: 1,
      icon: Icons.business_outlined,
    ).then((value) {
      if (value != null && value.isNotEmpty) {
        debugPrint('الاسم المدخل: $value');
      }
    });
  }

  void _showSingleChoice() {
    final items = [
      DialogChoiceItem(
        value: 'ar',
        title: LocaleKeys.dialog_choice_arabic.tr(),
        subtitle: LocaleKeys.dialog_choice_arabic_subtitle.tr(),
        icon: Icons.language,
      ),
      DialogChoiceItem(
        value: 'en',
        title: LocaleKeys.dialog_choice_english.tr(),
        subtitle: LocaleKeys.dialog_choice_english_subtitle.tr(),
        icon: Icons.language,
      ),
      DialogChoiceItem(
        value: 'bn',
        title: LocaleKeys.dialog_choice_bengali.tr(),
        subtitle: LocaleKeys.dialog_choice_bengali_subtitle.tr(),
        icon: Icons.language,
      ),
    ];

    showNewSingleChoiceDialog(
      context: context,
      title: LocaleKeys.dialog_choice_title.tr(),
      items: items,
      initialValue: 'ar',
    ).then((selected) {
      if (selected != null) {
        debugPrint('اللغة المختارة: $selected');
      }
    });
  }

  void _showCustomDialog() {
    final sizing = NewDialogConfig.getSizing(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return NewUniversalDialogShell(
          scrollable: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Icon
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.accentColor.withOpacity(0.5),
                    width: 2.w,
                  ),
                ),
                child: Icon(
                  Icons.celebration,
                  size: 40.r,
                  color: AppTheme.accentColor,
                ),
              ),

              SizedBox(height: sizing.verticalGap),

              NewDialogTitle(
                text: LocaleKeys.dialog_custom_title.tr(),
                icon: Icons.auto_awesome,
              ),

              SizedBox(height: sizing.verticalGap * 0.5),

              NewDialogSubtitle(text: LocaleKeys.dialog_custom_subtitle.tr()),

              SizedBox(height: sizing.verticalGap),

              // Custom Content
              NewDialogContentCard(
                child: Column(
                  children: [
                    _CustomFeatureRow(
                      icon: Icons.palette_outlined,
                      text: LocaleKeys.dialog_custom_feature_1.tr(),
                    ),
                    SizedBox(height: sizing.verticalGap * 0.5),
                    _CustomFeatureRow(
                      icon: Icons.devices,
                      text: LocaleKeys.dialog_custom_feature_2.tr(),
                    ),
                    SizedBox(height: sizing.verticalGap * 0.5),
                    _CustomFeatureRow(
                      icon: Icons.visibility,
                      text: LocaleKeys.dialog_custom_feature_3.tr(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: sizing.verticalGap),

              // Actions
              NewDialogButtonRow(
                children: [
                  NewDialogButton(
                    text: LocaleKeys.dialog_custom_close.tr(),
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: AppTheme.cancelButtonBackgroundColor,
                    textColor: AppTheme.cancelButtonTextColor,
                  ),
                  NewDialogButton(
                    text: LocaleKeys.dialog_custom_ok.tr(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 🎨 Helper Widgets
// ════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMenu, required this.onClose});

  final VoidCallback onMenu;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final barHeight = isLandscape ? 72.h : 52.h;
    final iconSize = isLandscape ? 32.r : 26.r;

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

class _ExampleButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ExampleButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50.r,
              height: 50.r,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 26.r, color: AppTheme.accentColor),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryTextColor,
                        fontFamily: CacheHelper.getTextsFontFamily(),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.secondaryTextColor,
                        fontFamily: CacheHelper.getTextsFontFamily(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18.r,
              color: AppTheme.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomFeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CustomFeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: AppTheme.accentColor),
        SizedBox(width: 12.w),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppTheme.primaryTextColor,
                fontFamily: CacheHelper.getTextsFontFamily(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
