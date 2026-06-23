// import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
// import 'package:azan/core/components/horizontal_space.dart';
// import 'package:azan/core/helpers/dhikr_hive_helper.dart';
// import 'package:azan/core/models/diker.dart';
// import 'package:azan/core/theme/app_theme.dart';
// import 'package:azan/core/utils/alert_dialoges.dart';
// import 'package:azan/core/utils/azkar_scheduling_enums.dart';
// import 'package:azan/core/utils/extenstions.dart';
// import 'package:azan/views/adhkar/components/custom_check_box.dart';
// import 'package:flutter/material.dart';
// import 'package:azan/core/utils/screenutil_flip_ext.dart';

// class DhikrTile extends StatefulWidget {
//   DhikrTile({super.key, required this.dhikr});

//   Dhikr dhikr;

//   @override
//   State<DhikrTile> createState() => _DhikrTileState();
// }

// class _DhikrTileState extends State<DhikrTile> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             IconButton(
//               // iconSize: 40.r,
//               // style: ButtonStyle(
//               //   minimumSize: MaterialStateProperty.all(Size(40.r, 40.r)),
//               //   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               // ),
//               onPressed: () {
//                 showDeleteDhikrDialog(
//                   context,
//                   dhikrText: widget.dhikr.text,
//                   onConfirm: () {
//                     setState(() {
//                       DhikrHiveHelper.deleteDhikr(widget.dhikr.id);
//                       AppCubit.get(context).assignAdhkar();
//                     });
//                   },
//                 );
//                 // DhikrHiveHelper.deleteDhikr(widget.dhikr.id);
//               },
//               icon: Icon(Icons.close, size: 25.r),
//               color: AppTheme.accentColor,
//             ),

//             Expanded(
//               child: Text(
//                 widget.dhikr.text,
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                   color: AppTheme.secondaryTextColor,
//                 ),
//               ),
//             ),
//             HorizontalSpace(width: 8),

//             Text(
//               widget.dhikr.schedule?.toArabicText() ?? '',
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.bold,
//                 color: AppTheme.secondaryTextColor,
//               ),
//             ),
//             HorizontalSpace(width: 5),
//             CustomCheckbox(
//               size: 22.r,
//               activeColor: AppTheme.accentColor,
//               value: widget.dhikr.active,
//               onChanged: (value) {
//                 setState(() {
//                   widget.dhikr.active = value!;
//                   DhikrHiveHelper.updateDhikr(widget.dhikr);
//                 });
//               },
//             ),
//           ],
//         ),
//         if (widget.dhikr.schedule?.type == DhikrScheduleType.weekly &&
//             widget.dhikr.schedule!.weekdays!.length > 1)
//           Wrap(
//             children: [
//               ...widget.dhikr.schedule!.weekdays!.map((day) {
//                 return Padding(
//                   padding: EdgeInsets.all(3.r),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         day.toWeekDay().toArabicWeekDay(),
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.bold,
//                           color: AppTheme.secondaryTextColor,
//                         ),
//                       ),

//                       Text(
//                         ',',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.bold,
//                           color: AppTheme.secondaryTextColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//             ],
//           ),
//       ],
//     );
//   }
// }

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/helpers/dhikr_hive_helper.dart';
import 'package:azan/core/models/diker.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/core/utils/alert_dialoges.dart'; // هنا هنضيف الديالوج الجديد
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DhikrTile extends StatefulWidget {
  const DhikrTile({super.key, required this.dhikr, required this.index});

  final Dhikr dhikr;
  final int index;

  @override
  State<DhikrTile> createState() => _DhikrTileState();
}

class _DhikrTileState extends State<DhikrTile> {
  @override
  Widget build(BuildContext context) {
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
          // النص
          Expanded(
            child: Text(
              widget.dhikr.text,
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

          // ✅ Edit button
          IconButton(
            tooltip: widget.dhikr.active ? 'إخفاء الذكر' : 'إظهار الذكر',
            onPressed: () async {
              final appCubit = AppCubit.get(context);
              await DhikrHiveHelper.setActive(
                widget.dhikr.id,
                !widget.dhikr.active,
              );
              await appCubit.assignAdhkar();
            },
            icon: Icon(
              widget.dhikr.active
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: widget.dhikr.active
                  ? AppTheme.accentColor
                  : AppTheme.secondaryTextColor,
              size: 22.r,
            ),
          ),
          IconButton(
            tooltip: LocaleKeys.dhikr_edit_title.tr(),
            onPressed: () {
              showEditDhikrDialog2(context, dhikr: widget.dhikr);
            },
            icon: Icon(Icons.edit, color: AppTheme.accentColor, size: 22.r),
          ),

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
