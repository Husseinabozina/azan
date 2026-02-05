import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/utils/screenutil_flip_ext.dart';
import 'package:flutter_svg/svg.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, this.onDrawerTap});
  final Function()? onDrawerTap;

  @override
  Widget build(BuildContext context) {
    // Single layout for both portrait & landscape (no duplicated Row)
    final _ = UiRotationCubit()
        .isLandscape(); // keep orientation dependency (if you need it later)

    // Keep current sizes as much as possible
    const double gap = 10;
    final double startPadding = 10.w;

    final double logoH = 31.71.h;
    final double logoW = 30.22.w;

    // Reserved fixed trailing space for the menu button (content must never overlap)
    final double menuButtonWidth = 50.w;

    // Base heights (we'll bump dynamically only when we detect 2 lines are needed)
    final double baseBarHeight = 50.h;
    final double oneLineAvailableHeight = 35.h;
    final double twoLinesAvailableHeight =
        58.h; // enough for 2 lines (avoid clipping)

    final String titleText =
        CacheHelper.getMosqueName() ?? LocaleKeys.mosque_name_label.tr();

    return LayoutBuilder(
      builder: (context, outerConstraints) {
        final double totalWidth = outerConstraints.maxWidth;

        final double maxGroupWidth = (totalWidth - menuButtonWidth).clamp(
          0.0,
          totalWidth,
        );

        // Max width available for the title inside the group
        final double maxTitleWidth =
            (maxGroupWidth - startPadding - logoW - gap.w).clamp(
              0.0,
              maxGroupWidth,
            );

        // 1) Determine if group can stay centered when single-line width fits
        final TextPainter oneLineMeasure = TextPainter(
          text: TextSpan(
            text: titleText,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              fontFamily: CacheHelper.getTextsFontFamily(),
              height: 1.15,
            ),
          ),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: double.infinity);

        final double groupOneLineWidth =
            startPadding + logoW + gap.w + oneLineMeasure.width;

        final bool shouldCenterGroup = groupOneLineWidth <= maxGroupWidth;

        // 2) Determine if text will require 2 lines under the actual maxTitleWidth
        final TextPainter twoLinesMeasure = TextPainter(
          text: TextSpan(
            text: titleText,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              fontFamily: CacheHelper.getTextsFontFamily(),
              height: 1.15,
            ),
          ),

          maxLines: 2,

          textDirection: Directionality.of(context),
          ellipsis: '…',
        )..layout(maxWidth: maxTitleWidth);

        final int neededLines = twoLinesMeasure.computeLineMetrics().length;
        final bool needsTwoLines = neededLines > 1;

        // 3) Dynamically increase bar/title height only when 2 lines are needed
        final double barHeight = needsTwoLines ? (70.h) : baseBarHeight;
        final double availableTitleHeight = needsTwoLines
            ? twoLinesAvailableHeight
            : oneLineAvailableHeight;

        return Container(
          // color: Colors.red,
          width: double.infinity,
          height: barHeight,

          child: Stack(
            children: [
              // Center group area (everything except the menu reserved width)
              PositionedDirectional(
                start: 0,
                end: menuButtonWidth,
                top: 0,
                bottom: 0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxGroupWidth),
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: startPadding),
                    child: Align(
                      alignment: shouldCenterGroup
                          ? AlignmentDirectional.center
                          : AlignmentDirectional.centerStart,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            Assets.svg.logosvg,
                            height: logoH,
                            width: logoW,
                          ),
                          HorizontalSpace(width: gap),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxTitleWidth,
                            ),
                            child: Padding(
                              // Keep same top padding, but ensure the text box can grow
                              padding: EdgeInsets.only(top: 5.h),
                              child: _AdaptiveTitleText(
                                text: titleText,
                                fontFamily: CacheHelper.getTextsFontFamily(),
                                maxFontSize: 20.sp,
                                minFontSize: 16.sp,
                                availableHeight: availableTitleHeight,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Menu button (fixed trailing position + fixed reserved width)
              PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                child: SizedBox(
                  width: menuButtonWidth,
                  child: IconButton(
                    onPressed: onDrawerTap?.call,
                    icon: Icon(
                      Icons.menu,
                      color: AppTheme.accentColor,
                      size: 30.r,
                    ),
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

class _AdaptiveTitleText extends StatelessWidget {
  final String text;
  final double maxFontSize;
  final double minFontSize;
  final double availableHeight;
  final String? fontFamily;
  final TextAlign textAlign;

  const _AdaptiveTitleText({
    required this.text,
    required this.maxFontSize,
    required this.minFontSize,
    required this.availableHeight,
    this.fontFamily,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        double currentFontSize = maxFontSize;

        final textPainter = TextPainter(
          textDirection: Directionality.of(context),
          textAlign: textAlign,
          ellipsis: '…',
          maxLines: 2,
        );

        // Find the largest font size that fits in <= 2 lines and within availableHeight
        while (currentFontSize >= minFontSize) {
          textPainter.text = TextSpan(
            text: text,
            style: TextStyle(
              fontSize: currentFontSize,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily ?? CacheHelper.getAzkarFontFamily(),
              color: AppTheme.primaryTextColor,
              height: 1.15,
            ),
          );

          textPainter.layout(maxWidth: width);

          final int lines = textPainter.computeLineMetrics().length;
          final double textHeight = textPainter.height;

          if (lines <= 2 && textHeight <= availableHeight) break;

          currentFontSize -= 0.5;

          if (currentFontSize < minFontSize) {
            currentFontSize = minFontSize;
            break;
          }
        }

        // IMPORTANT: Don't force a tight height that could clip; let Text size itself.
        return Text(
          text,
          style: TextStyle(
            fontSize: currentFontSize,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
            fontFamily: fontFamily ?? CacheHelper.getAzkarFontFamily(),
            height: 1.15,
          ),
          textAlign: textAlign,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        );
      },
    );
  }
}
