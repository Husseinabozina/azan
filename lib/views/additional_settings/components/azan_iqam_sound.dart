import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/adhkar/components/custom_check_box.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/helpers/simple_sound_player.dart';
import 'package:azan/gen/assets.gen.dart'; // عدّل لو مسارات assets مختلفة

/// Widget: خيارات صوت الأذان/الإقامة (بنفس ستايل CustomCheckTile)
class AzanIqamaSoundOptions extends StatefulWidget {
  const AzanIqamaSoundOptions({
    super.key,
    required this.initialUseMp3,
    required this.initialShortAzan,
    required this.initialShortIqama,
    required this.onUseMp3Changed,
    required this.onShortAzanChanged,
    required this.onShortIqamaChanged,
    this.checkBoxSize,
    this.titleFontSize,
    this.subTitleFontSize,
    this.verticalGap,
  });

  final bool initialUseMp3; // (1)
  final bool initialShortAzan; // (2)
  final bool initialShortIqama; // (3)

  final ValueChanged<bool> onUseMp3Changed;
  final ValueChanged<bool> onShortAzanChanged;
  final ValueChanged<bool> onShortIqamaChanged;

  final double? checkBoxSize;
  final double? titleFontSize;
  final double? subTitleFontSize;
  final double? verticalGap;

  @override
  State<AzanIqamaSoundOptions> createState() => _AzanIqamaSoundOptionsState();
}

class _AzanIqamaSoundOptionsState extends State<AzanIqamaSoundOptions> {
  final _player = SimpleSoundPlayer();

  late bool _useMp3;
  late bool _shortAzan;
  late bool _shortIqama;

  @override
  void initState() {
    super.initState();
    _useMp3 = widget.initialUseMp3;
    _shortAzan = widget.initialShortAzan;
    _shortIqama = widget.initialShortIqama;
  }

  // paths من flutter_gen
  String get _azanLongPath => Assets.sounds.azanLong; // azan_long.mp3
  String get _azanShortPath => Assets.sounds.azan; // azan.mp3
  String get _iqamaPath => Assets.sounds.iqama; // iqama.mp3

  Future<void> _toggleUseMp3(bool v) async {
    setState(() {
      _useMp3 = v;
      if (!_useMp3) {
        _shortAzan = false;
        _shortIqama = false;
      }
    });

    widget.onUseMp3Changed(_useMp3);
    widget.onShortAzanChanged(_shortAzan);
    widget.onShortIqamaChanged(_shortIqama);

    if (_useMp3) {
      // Preview: azan_long
      await _player.playAsset(_azanLongPath);
    }
  }

  Future<void> _toggleShortAzan(bool v) async {
    if (!_useMp3) return;
    setState(() => _shortAzan = v);
    widget.onShortAzanChanged(_shortAzan);

    if (_shortAzan) {
      await _player.playAsset(_azanShortPath);
    }
  }

  Future<void> _toggleShortIqama(bool v) async {
    if (!_useMp3) return;
    setState(() => _shortIqama = v);
    widget.onShortIqamaChanged(_shortIqama);

    if (_shortIqama) {
      await _player.playAsset(_iqamaPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cbSize = widget.checkBoxSize ?? 20.r;
    final titleSize = widget.titleFontSize ?? 16.sp;
    final subSize = widget.subTitleFontSize ?? 15.sp;
    final gap = widget.verticalGap ?? 10.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SoundCheckTile(
          title: LocaleKeys.azan_sound_use_mp3.tr(),
          value: _useMp3,
          enabled: true,
          checkBoxSize: cbSize,
          fontSize: titleSize,
          onChanged: _toggleUseMp3,
        ),
        SizedBox(height: gap),

        _SoundCheckTile(
          title: LocaleKeys.short_azan_sound.tr(),
          value: _shortAzan,
          enabled: _useMp3,
          checkBoxSize: cbSize,
          fontSize: subSize,
          onChanged: _toggleShortAzan,
        ),
        SizedBox(height: gap),

        _SoundCheckTile(
          title: LocaleKeys.short_iqama_sound.tr(),
          value: _shortIqama,
          enabled: _useMp3,
          checkBoxSize: cbSize,
          fontSize: subSize,
          onChanged: _toggleShortIqama,
        ),
      ],
    );
  }
}

class _SoundCheckTile extends StatelessWidget {
  const _SoundCheckTile({
    required this.title,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.checkBoxSize,
    required this.fontSize,
  });

  final String title;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final double checkBoxSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? AppTheme.primaryTextColor
        : AppTheme.primaryTextColor.withOpacity(0.45);

    return IgnorePointer(
      ignoring: !enabled,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Opacity(
          opacity: enabled ? 1 : 0.65,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomCheckbox(
                size: checkBoxSize,
                activeColor: AppTheme.accentColor,
                value: value,
                onChanged: (v) => onChanged(v),
              ),
              HorizontalSpace(width: 6.w),

              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
