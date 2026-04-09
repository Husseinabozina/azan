import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/views/home/components/azkar_content.dart';
import 'package:flutter/material.dart';

class AzkarPresentationView extends StatelessWidget {
  const AzkarPresentationView({
    super.key,
    required this.resolvedSet,
    this.entry,
    this.entryIndex,
    this.totalEntries,
    this.footer,
    this.emptyMessage = 'لا توجد أذكار',
  });

  final ResolvedAzkarSet resolvedSet;
  final ResolvedAzkarEntry? entry;
  final int? entryIndex;
  final int? totalEntries;
  final Widget? footer;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Material(
      color: Colors.black.withOpacity(0.94),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = isLandscape ? 20.w : 16.w;
            final verticalPadding = isLandscape ? 16.h : 14.h;

            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.darkBlue.withOpacity(0.96),
                          Colors.black.withOpacity(0.96),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      verticalPadding,
                      horizontalPadding,
                      footer == null ? verticalPadding : 74.h,
                    ),
                    child: isLandscape
                        ? _LandscapePresentation(
                            title: resolvedSet.title,
                            entry: entry,
                            emptyMessage: emptyMessage,
                          )
                        : _PortraitPresentation(
                            title: resolvedSet.title,
                            entry: entry,
                            emptyMessage: emptyMessage,
                          ),
                  ),
                ),
                if (footer != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 14.h,
                    child: Center(child: footer),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PortraitPresentation extends StatelessWidget {
  const _PortraitPresentation({
    required this.title,
    required this.entry,
    required this.emptyMessage,
  });

  final String title;
  final ResolvedAzkarEntry? entry;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TitleBanner(title: title, isLandscape: false),
        SizedBox(height: 14.h),
        Expanded(
          child: _ReadingPanel(
            entry: entry,
            emptyMessage: emptyMessage,
            isLandscape: false,
          ),
        ),
      ],
    );
  }
}

class _LandscapePresentation extends StatelessWidget {
  const _LandscapePresentation({
    required this.title,
    required this.entry,
    required this.emptyMessage,
  });

  final String title;
  final ResolvedAzkarEntry? entry;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 150.w,
          child: _LandscapeTitleRail(title: title),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: _ReadingPanel(
            entry: entry,
            emptyMessage: emptyMessage,
            isLandscape: true,
          ),
        ),
      ],
    );
  }
}

class _TitleBanner extends StatelessWidget {
  const _TitleBanner({required this.title, required this.isLandscape});

  final String title;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppTheme.primaryTextColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 18.w,
          vertical: isLandscape ? 12.h : 13.h,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isLandscape ? 20.sp : 24.sp,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryTextColor,
          ),
        ),
      ),
    );
  }
}

class _LandscapeTitleRail extends StatelessWidget {
  const _LandscapeTitleRail({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: AppTheme.primaryTextColor.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          children: [
            Container(
              width: 42.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryTextColor.withOpacity(0.42),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryTextColor,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            Container(
              width: 42.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryTextColor.withOpacity(0.26),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingPanel extends StatelessWidget {
  const _ReadingPanel({
    required this.entry,
    required this.emptyMessage,
    required this.isLandscape,
  });

  final ResolvedAzkarEntry? entry;
  final String emptyMessage;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    final rawText = entry?.text ?? emptyMessage;
    final text = _normalizeDisplayText(rawText);

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = isLandscape ? 24.w : 18.w;
        final verticalPadding = isLandscape ? 18.h : 18.h;
        final availableWidth = constraints.maxWidth - (horizontalPadding * 2);
        final availableHeight = constraints.maxHeight - (verticalPadding * 2);
        final maxFontSize = isLandscape ? 30.sp : 38.sp;
        final minFontSize = isLandscape ? 17.sp : 20.sp;

        final fontSize = _calculateOptimalFontSize(
          text: text,
          maxWidth: availableWidth,
          targetHeight: availableHeight,
          maxFontSize: maxFontSize,
          minFontSize: minFontSize,
          lineHeight: isLandscape ? 1.58 : 1.62,
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Center(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: isLandscape ? 1.58 : 1.62,
                      fontFamily: CacheHelper.getAzkarFontFamily(),
                    ),
                    children: _parseZekrText(text, fontSize),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

double _calculateOptimalFontSize({
  required String text,
  required double maxWidth,
  required double targetHeight,
  required double maxFontSize,
  required double minFontSize,
  required double lineHeight,
}) {
  double currentFontSize = maxFontSize;
  final textPainter = TextPainter(
    textDirection: TextDirection.rtl,
    textAlign: TextAlign.center,
  );

  while (currentFontSize >= minFontSize) {
    textPainter.text = TextSpan(
      style: TextStyle(
        fontSize: currentFontSize,
        fontWeight: FontWeight.w700,
        height: lineHeight,
        fontFamily: CacheHelper.getAzkarFontFamily(),
      ),
      children: _parseZekrText(text, currentFontSize),
    );

    textPainter.layout(maxWidth: maxWidth);
    if (textPainter.height <= targetHeight) {
      return currentFontSize;
    }

    currentFontSize -= 0.5;
  }

  return minFontSize;
}

String _normalizeDisplayText(String text) {
  return text
      .replaceAll('\r\n', '\n')
      .replaceAll(RegExp(r'\n{2,}'), '\n')
      .trim();
}

List<InlineSpan> _parseZekrText(String text, double baseFontSize) {
  final spans = <InlineSpan>[];
  final buffer = StringBuffer();
  final basmalaColor = AppTheme.primaryTextColor;
  final quranicColor = const Color(0xFFD4F3D6);
  final noteColor = const Color(0xFFF9D98E);
  final noteSize = baseFontSize * 0.84;
  var index = 0;

  void flushBuffer() {
    if (buffer.isEmpty) return;
    spans.add(
      TextSpan(
        text: buffer.toString(),
        style: const TextStyle(color: Colors.white),
      ),
    );
    buffer.clear();
  }

  while (index < text.length) {
    if (text[index] == '[') {
      flushBuffer();
      final end = text.indexOf(']', index);
      if (end != -1) {
        spans.add(
          TextSpan(
            text: text.substring(index + 1, end),
            style: TextStyle(
              color: basmalaColor,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(color: basmalaColor.withOpacity(0.35), blurRadius: 8),
              ],
            ),
          ),
        );
        index = end + 1;
        continue;
      }
    }

    if (text[index] == '{') {
      flushBuffer();
      final end = text.indexOf('}', index);
      if (end != -1) {
        spans.add(
          TextSpan(
            text: text.substring(index + 1, end),
            style: TextStyle(
              color: quranicColor,
              fontWeight: FontWeight.w800,
              shadows: [
                Shadow(color: quranicColor.withOpacity(0.18), blurRadius: 8),
              ],
            ),
          ),
        );
        index = end + 1;
        continue;
      }
    }

    if (text[index] == '~') {
      flushBuffer();
      final end = text.indexOf('~', index + 1);
      if (end != -1) {
        spans.add(
          TextSpan(
            text: text.substring(index + 1, end),
            style: TextStyle(
              color: noteColor,
              fontWeight: FontWeight.w600,
              fontSize: noteSize,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
        index = end + 1;
        continue;
      }
    }

    buffer.write(text[index]);
    index++;
  }

  flushBuffer();
  return spans;
}
