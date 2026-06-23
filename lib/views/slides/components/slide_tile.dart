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
  @override
  Widget build(BuildContext context) {
    final appCubit = AppCubit.get(context);
    final orderLabel = '${widget.index + 1}';

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.22),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.w),
      ),
      child: Row(
        children: [
          _OrderBadge(label: orderLabel),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              widget.slide.text,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 10.w),
          IconButton(
            tooltip: widget.slide.active ? 'إخفاء السلايد' : 'إظهار السلايد',
            onPressed: () async {
              await SlideHiveHelper.setActive(
                widget.slide.id,
                !widget.slide.active,
              );
              await appCubit.assignSlides();
            },
            icon: Icon(
              widget.slide.active
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: widget.slide.active
                  ? AppTheme.accentColor
                  : AppTheme.secondaryTextColor,
              size: 22.r,
            ),
          ),
          IconButton(
            tooltip: 'dhikr_edit_title'.tr(),
            onPressed: () {
              showEditDhikrDialog2(
                context,
                dhikr: widget.slide,
                onSubmit: (updated) async {
                  await SlideHiveHelper.updateSlide(updated);
                  await appCubit.assignSlides();
                },
              );
            },
            icon: Icon(Icons.edit, color: AppTheme.accentColor, size: 22.r),
          ),
          IconButton(
            onPressed: () {
              showDeleteDhikrDialog(
                context,
                dhikrText: widget.slide.text,
                onConfirm: () {
                  setState(() {
                    SlideHiveHelper.deleteSlide(widget.slide.id);
                    appCubit.assignSlides();
                  });
                },
              );
            },
            icon: Icon(Icons.close, size: 25.r),
            color: AppTheme.accentColor,
          ),
        ],
      ),
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
        color: AppTheme.primaryButtonBackground.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.55)),
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
