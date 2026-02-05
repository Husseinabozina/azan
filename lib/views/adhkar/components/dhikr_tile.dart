import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/helpers/dhikr_hive_helper.dart';
import 'package:azan/core/models/diker.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/alert_dialoges.dart';
import 'package:azan/core/utils/azkar_scheduling_enums.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/views/adhkar/components/custom_check_box.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';

class DhikrTile extends StatefulWidget {
  DhikrTile({super.key, required this.dhikr});

  Dhikr dhikr;

  @override
  State<DhikrTile> createState() => _DhikrTileState();
}

class _DhikrTileState extends State<DhikrTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              // iconSize: 40.r,
              // style: ButtonStyle(
              //   minimumSize: MaterialStateProperty.all(Size(40.r, 40.r)),
              //   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              // ),
              onPressed: () {
                showDeleteDhikrDialog(
                  context,
                  dhikrText: widget.dhikr.text,
                  onConfirm: () {
                    setState(() {
                      DhikrHiveHelper.deleteDhikr(widget.dhikr.id);
                      AppCubit.get(context).assignAdhkar();
                    });
                  },
                );
                // DhikrHiveHelper.deleteDhikr(widget.dhikr.id);
              },
              icon: Icon(Icons.close, size: 25.r),
              color: AppTheme.accentColor,
            ),

            Expanded(
              child: Text(
                widget.dhikr.text,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ),
            HorizontalSpace(width: 8),

            Text(
              widget.dhikr.schedule?.toArabicText() ?? '',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryTextColor,
              ),
            ),
            HorizontalSpace(width: 5),
            CustomCheckbox(
              size: 22.r,
              activeColor: AppTheme.accentColor,
              value: widget.dhikr.active,
              onChanged: (value) {
                setState(() {
                  widget.dhikr.active = value!;
                  DhikrHiveHelper.updateDhikr(widget.dhikr);
                });
              },
            ),
          ],
        ),
        if (widget.dhikr.schedule?.type == DhikrScheduleType.weekly &&
            widget.dhikr.schedule!.weekdays!.length > 1)
          Wrap(
            children: [
              ...widget.dhikr.schedule!.weekdays!.map((day) {
                return Padding(
                  padding: EdgeInsets.all(3.r),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        day.toWeekDay().toArabicWeekDay(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),

                      Text(
                        ',',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
      ],
    );
  }
}
