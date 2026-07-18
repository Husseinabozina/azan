import 'dart:ui' as ui;

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/helpers/slide_hive_helper.dart';
import 'package:azan/core/models/diker.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/alert_dialoges.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SlideTile extends StatefulWidget {
  const SlideTile({super.key, required this.slide, required this.index});

  final Dhikr slide;
  final int index;

  @override
  State<SlideTile> createState() => _SlideTileState();
}

class _SlideTileState extends State<SlideTile> {
  Future<void> _toggleActive(AppCubit appCubit) async {
    await SlideHiveHelper.setActive(widget.slide.id, !widget.slide.active);
    await appCubit.assignSlides();
  }

  Future<void> _editSlide(AppCubit appCubit) async {
    await showEditDhikrDialog2(
      context,
      dhikr: widget.slide,
      onSubmit: (updated) async {
        await SlideHiveHelper.updateSlide(updated);
        await appCubit.assignSlides();
      },
    );
  }

  Future<void> _deleteSlide(AppCubit appCubit) async {
    await showDeleteDhikrDialog(
      context,
      dhikrText: widget.slide.text,
      onConfirm: () {
        SlideHiveHelper.deleteSlide(widget.slide.id).then((_) {
          appCubit.assignSlides();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appCubit = AppCubit.get(context);
    final orderLabel = '${widget.index + 1}';
    final active = widget.slide.active;

    return Opacity(
      opacity: active ? 1 : 0.62,
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(12.w, 10.h, 12.w, 10.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: active ? 0.24 : 0.14),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: active
                ? Colors.white.withValues(alpha: 0.18)
                : AppTheme.secondaryTextColor.withValues(alpha: 0.18),
            width: 1.w,
          ),
        ),
        child: Row(
          textDirection: ui.TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _OrderBadge(label: orderLabel),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.slide.text,
                    textAlign: TextAlign.right,
                    textDirection: ui.TextDirection.rtl,
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 7.h),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _StatusPill(active: active),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _SlideActionsButton(
              active: active,
              onToggleActive: () => _toggleActive(appCubit),
              onEdit: () => _editSlide(appCubit),
              onDelete: () => _deleteSlide(appCubit),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.accentColor : AppTheme.secondaryTextColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color.withValues(alpha: 0.38), width: 0.8.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            size: 12.r,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            active ? 'ظاهر' : 'مخفي',
            style: TextStyle(
              color: color,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideActionsButton extends StatelessWidget {
  const _SlideActionsButton({
    required this.active,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  final bool active;
  final VoidCallback onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_SlideAction>(
      tooltip: 'خيارات الشريحة',
      color: const Color(0xFF172230),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      onSelected: (action) {
        switch (action) {
          case _SlideAction.toggle:
            onToggleActive();
            break;
          case _SlideAction.edit:
            onEdit();
            break;
          case _SlideAction.delete:
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _SlideAction.toggle,
          child: _SlideMenuItem(
            icon: active ? Icons.visibility_off_rounded : Icons.visibility,
            label: active ? 'إخفاء الشريحة' : 'إظهار الشريحة',
          ),
        ),
        PopupMenuItem(
          value: _SlideAction.edit,
          child: _SlideMenuItem(
            icon: Icons.edit_rounded,
            label: 'dhikr_edit_title'.tr(),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: _SlideAction.delete,
          child: _SlideMenuItem(
            icon: Icons.delete_outline_rounded,
            label: 'حذف الشريحة',
            destructive: true,
          ),
        ),
      ],
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppTheme.accentColor.withValues(alpha: 0.34),
            width: 1.w,
          ),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          color: AppTheme.accentColor,
          size: 22.r,
        ),
      ),
    );
  }
}

enum _SlideAction { toggle, edit, delete }

class _SlideMenuItem extends StatelessWidget {
  const _SlideMenuItem({
    required this.icon,
    required this.label,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? AppTheme.cancelButtonBackgroundColor
        : AppTheme.primaryTextColor;
    return Row(
      textDirection: ui.TextDirection.rtl,
      children: [
        Icon(icon, color: color, size: 20.r),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderBadge extends StatelessWidget {
  const _OrderBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.r,
      height: 30.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.primaryButtonBackground.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.55)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.primaryTextColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
