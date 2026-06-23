import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/utils/dialoge_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DisplayDirectionPicker extends StatelessWidget {
  const DisplayDirectionPicker({super.key, this.onDirectionSelected});

  final VoidCallback? onDirectionSelected;

  static const List<_DirectionOption> _options = [
    _DirectionOption(
      quarterTurns: 0,
      labelKey: LocaleKeys.display_direction_normal,
      descriptionKey: LocaleKeys.display_direction_normal_desc,
      icon: Icons.screen_rotation_alt_outlined,
    ),
    _DirectionOption(
      quarterTurns: 1,
      labelKey: LocaleKeys.display_direction_rotate_right,
      descriptionKey: LocaleKeys.display_direction_rotate_right_desc,
      icon: Icons.rotate_right,
    ),
    _DirectionOption(
      quarterTurns: 2,
      labelKey: LocaleKeys.display_direction_upside_down,
      descriptionKey: LocaleKeys.display_direction_upside_down_desc,
      icon: Icons.flip_to_back_outlined,
    ),
    _DirectionOption(
      quarterTurns: 3,
      labelKey: LocaleKeys.display_direction_rotate_left,
      descriptionKey: LocaleKeys.display_direction_rotate_left_desc,
      icon: Icons.rotate_left,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = UiRotationCubit();

    return BlocBuilder<UiRotationCubit, int>(
      bloc: cubit,
      builder: (context, state) {
        final selectedQuarterTurns = cubit.quarterTurns;

        return ConstrainedBox(
          key: const ValueKey('display-direction-picker'),
          constraints: BoxConstraints(maxWidth: 520.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DialogTitle(
                LocaleKeys.display_direction_title.tr(),
                icon: Icons.screen_rotation_alt_outlined,
              ),
              SizedBox(height: 14.h),
              ..._options.map(
                (option) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _DirectionOptionTile(
                    option: option,
                    selected: option.quarterTurns == selectedQuarterTurns,
                    onTap: () {
                      cubit.selectDisplayDirection(option.quarterTurns);
                      onDirectionSelected?.call();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DirectionOption {
  const _DirectionOption({
    required this.quarterTurns,
    required this.labelKey,
    required this.descriptionKey,
    required this.icon,
  });

  final int quarterTurns;
  final String labelKey;
  final String descriptionKey;
  final IconData icon;
}

class _DirectionOptionTile extends StatelessWidget {
  const _DirectionOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _DirectionOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? DialogPalette.primaryButtonBackground
        : DialogPalette.dividerColor;
    final backgroundColor = selected
        ? DialogPalette.primaryButtonBackground.withValues(alpha: 0.16)
        : DialogPalette.cardBackground;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('display-direction-option-${option.quarterTurns}'),
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(
                option.icon,
                size: 26.r,
                color: selected
                    ? DialogPalette.primaryButtonBackground
                    : DialogPalette.mutedTextColor,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.labelKey.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      option.descriptionKey.tr(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.25,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) ...[
                SizedBox(width: 10.w),
                Semantics(
                  selected: true,
                  child: Container(
                    key: ValueKey(
                      'display-direction-selected-${option.quarterTurns}',
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: DialogPalette.primaryButtonBackground,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check,
                          size: 14.r,
                          color: DialogPalette.primaryButtonText,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          LocaleKeys.display_direction_current.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: DialogPalette.primaryButtonText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
