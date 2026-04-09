import 'package:azan/core/models/display_announcement.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/views/display_board/components/display_board_runtime_widgets.dart';
import 'package:azan/views/home/components/display_board_runtime_base.dart';
import 'package:azan/views/home/components/home_appbar.dart';
import 'package:azan/views/home/components/prayer_row_data.dart';
import 'package:flutter/material.dart';

class DisplayBoardPortraitScreen extends StatefulWidget {
  const DisplayBoardPortraitScreen({super.key});

  @override
  State<DisplayBoardPortraitScreen> createState() =>
      _DisplayBoardPortraitScreenState();
}

class _DisplayBoardPortraitScreenState
    extends DisplayBoardRuntimeBase<DisplayBoardPortraitScreen> {
  @override
  bool get isLandscapeBoard => false;

  @override
  Widget buildBoardLayout(
    BuildContext context, {
    required List<DisplayAnnouncement> announcements,
    required DisplayAnnouncement? currentAnnouncement,
    required List<PrayerRowData> rows,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          child: HomeAppBar(
            onDrawerTap: () => scaffoldKey.currentState?.openDrawer(),
            titleFontSize: 18.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 8,
                child: SizedBox.expand(
                  child: DisplayBoardAnnouncementStage(
                    announcement: currentAnnouncement,
                    isLandscape: false,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                flex: 2,
                child: DisplayBoardPrayerRail(
                  rows: rows,
                  nextPrayerFuture: nextPrayerFuture,
                  isLandscape: false,
                  isIqamaActive: cubit.isBetweenAdhanAndIqama,
                  onHijriTap: () => handleHijriTap(),
                  clockAtSide: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
