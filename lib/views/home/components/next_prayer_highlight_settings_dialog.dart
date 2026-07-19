import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/dialoge_helper.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<void> showNextPrayerHighlightSettingsDialog(BuildContext context) {
  return showAppDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return const UniversalDialogShell(
        forceMaxHeight: true,
        child: _NextPrayerHighlightSettingsDialog(),
      );
    },
  );
}

class _NextPrayerHighlightSettingsDialog extends StatefulWidget {
  const _NextPrayerHighlightSettingsDialog();

  @override
  State<_NextPrayerHighlightSettingsDialog> createState() =>
      _NextPrayerHighlightSettingsDialogState();
}

class _NextPrayerHighlightSettingsDialogState
    extends State<_NextPrayerHighlightSettingsDialog> {
  late bool _useCustomColor;
  late Color _selectedColor;
  late double _opacity;

  List<Color> get _palette => <Color>[
    AppTheme.defaultNextPrayerHighlightColor,
    const Color(0xFFD4A64A),
    const Color(0xFFF5E4B8),
    const Color(0xFF7A4A18),
    const Color(0xFF2FAF8F),
    const Color(0xFFC8F1E7),
    const Color(0xFF0E6F62),
    const Color(0xFF2E86C1),
    const Color(0xFFB8E3FF),
    const Color(0xFF123E6A),
    const Color(0xFF7D4BC6),
    const Color(0xFFEBC7FF),
    const Color(0xFF47218A),
    const Color(0xFFC65151),
    const Color(0xFFFFC9C9),
    const Color(0xFF7A1D1D),
    const Color(0xFF2F6F3E),
    const Color(0xFFE6FFB3),
    const Color(0xFF183F23),
    const Color(0xFFF2E6C9),
    const Color(0xFFE4E7EC),
    const Color(0xFF2B3038),
    const Color(0xFFFFFFFF),
    const Color(0xFF000000),
    const Color(0xFFB83232),
    const Color(0xFFD96824),
    const Color(0xFFD6A51F),
    const Color(0xFF9BB61F),
    const Color(0xFF35A852),
    const Color(0xFF24A39A),
    const Color(0xFF2579B8),
    const Color(0xFF374FC7),
    const Color(0xFF6E3BB8),
    const Color(0xFFB33DA2),
    const Color(0xFFC74274),
    const Color(0xFF8C5C24),
  ];

  @override
  void initState() {
    super.initState();
    _useCustomColor = CacheHelper.getNextPrayerHighlightUseCustomColor();
    final storedColor = CacheHelper.getNextPrayerHighlightColorValue();
    _selectedColor = storedColor == null
        ? AppTheme.defaultNextPrayerHighlightColor
        : Color(storedColor);
    _opacity = CacheHelper.getNextPrayerHighlightOpacity();
  }

  Color get _previewColor => _useCustomColor
      ? _selectedColor
      : AppTheme.defaultNextPrayerHighlightColor;

  Color get _previewTextColor {
    final blended = Color.alphaBlend(
      _previewColor.withValues(alpha: _opacity),
      DialogPalette.backgroundColor,
    );
    return blended.computeLuminance() > 0.46
        ? const Color(0xFF1C150A)
        : Colors.white;
  }

  void _setCustomColor(Color color) {
    setState(() {
      _useCustomColor = true;
      _selectedColor = color;
    });
  }

  Future<void> _save() async {
    await CacheHelper.setNextPrayerHighlightUseCustomColor(_useCustomColor);
    await CacheHelper.setNextPrayerHighlightOpacity(_opacity);
    if (_useCustomColor) {
      await CacheHelper.setNextPrayerHighlightColorValue(
        _selectedColor.toARGB32(),
      );
    }
    AppCubit().notifyAppChanged();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _reset() async {
    await CacheHelper.resetNextPrayerHighlightStyle();
    AppCubit().notifyAppChanged();
    if (!mounted) return;
    setState(() {
      _useCustomColor = false;
      _selectedColor = AppTheme.defaultNextPrayerHighlightColor;
      _opacity = AppTheme.defaultNextPrayerHighlightOpacity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DialogTitle(LocaleKeys.next_prayer_highlight_settings.tr()),
        SizedBox(height: sizing.verticalGap * 0.7),
        _PreviewRow(
          color: _previewColor,
          opacity: _opacity,
          textColor: _previewTextColor,
        ),
        SizedBox(height: sizing.verticalGap * 0.65),
        Flexible(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogContentCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile.adaptive(
                        value: _useCustomColor,
                        activeThumbColor: DialogPalette.primaryButtonBackground,
                        activeTrackColor: DialogPalette.primaryButtonBackground
                            .withValues(alpha: 0.35),
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          LocaleKeys.next_prayer_highlight_use_custom_color
                              .tr(),
                          style: TextStyle(
                            color: DialogPalette.bodyTextColor,
                            fontWeight: FontWeight.w700,
                            fontSize: sizing.bodyFontSize,
                          ),
                        ),
                        subtitle: Text(
                          LocaleKeys.next_prayer_highlight_default_theme_hint
                              .tr(),
                          style: TextStyle(
                            color: DialogPalette.mutedTextColor,
                            fontSize: sizing.bodyFontSize * 0.82,
                            height: 1.35,
                          ),
                        ),
                        onChanged: (value) =>
                            setState(() => _useCustomColor = value),
                      ),
                      SizedBox(height: sizing.verticalGap * 0.45),
                      Text(
                        LocaleKeys.next_prayer_highlight_color.tr(),
                        style: TextStyle(
                          color: DialogPalette.titleTextColor,
                          fontWeight: FontWeight.w700,
                          fontSize: sizing.bodyFontSize * 0.95,
                        ),
                      ),
                      SizedBox(height: sizing.verticalGap * 0.35),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final color in _palette)
                            _ColorSwatchButton(
                              color: color,
                              selected:
                                  _useCustomColor &&
                                  color.toARGB32() == _selectedColor.toARGB32(),
                              onTap: () => _setCustomColor(color),
                            ),
                        ],
                      ),
                      SizedBox(height: sizing.verticalGap * 0.65),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              LocaleKeys.next_prayer_highlight_opacity.tr(),
                              style: TextStyle(
                                color: DialogPalette.titleTextColor,
                                fontWeight: FontWeight.w700,
                                fontSize: sizing.bodyFontSize * 0.95,
                              ),
                            ),
                          ),
                          Text(
                            '${(_opacity * 100).round()}%',
                            style: TextStyle(
                              color: DialogPalette.bodyTextColor,
                              fontWeight: FontWeight.w700,
                              fontSize: sizing.bodyFontSize * 0.9,
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor:
                              DialogPalette.primaryButtonBackground,
                          inactiveTrackColor: DialogPalette.dividerColor,
                          thumbColor: DialogPalette.primaryButtonBackground,
                          overlayColor: DialogPalette.primaryButtonBackground
                              .withValues(alpha: 0.16),
                        ),
                        child: Slider(
                          value: _opacity,
                          min: 0.20,
                          max: 1.0,
                          divisions: 16,
                          onChanged: (value) =>
                              setState(() => _opacity = value),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: sizing.verticalGap * 0.8),
        DialogButtonRow(
          children: [
            DialogButton(
              text: LocaleKeys.next_prayer_highlight_reset.tr(),
              variant: DialogButtonVariant.secondary,
              onPressed: _reset,
            ),
            DialogButton(
              text: LocaleKeys.common_cancel.tr(),
              variant: DialogButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
            DialogButton(text: LocaleKeys.common_save.tr(), onPressed: _save),
          ],
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.color,
    required this.opacity,
    required this.textColor,
  });

  final Color color;
  final double opacity;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: sizing.screenWidth * 0.035,
        vertical: sizing.verticalGap * 0.45,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(sizing.borderRadius * 0.75),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(
              alpha: (opacity * 0.82).clamp(0.16, 1.0).toDouble(),
            ),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              LocaleKeys.next_prayer_highlight_preview.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: sizing.bodyFontSize,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            LocaleKeys.dhuhr.tr(),
            style: TextStyle(
              color: textColor,
              fontSize: sizing.bodyFontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatchButton extends StatelessWidget {
  const _ColorSwatchButton({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? DialogPalette.primaryButtonBackground
                : Colors.white.withValues(alpha: 0.22),
            width: selected ? 3 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: DialogPalette.primaryButtonBackground.withValues(
                      alpha: 0.24,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: selected
            ? Icon(
                Icons.check,
                color: color.computeLuminance() > 0.50
                    ? const Color(0xFF1C150A)
                    : Colors.white,
              )
            : null,
      ),
    );
  }
}
