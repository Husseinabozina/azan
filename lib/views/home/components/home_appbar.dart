import 'dart:io';

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

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key, this.onDrawerTap});
  final Function()? onDrawerTap;

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  String? _logoPath;
  Uint8List? _logoBytes;
  bool _bytesIsSvg = false;

  @override
  void initState() {
    super.initState();
    _logoPath = CacheHelper.getMosqueLogoPath();
  }

  bool _exists(String? path) {
    if (kIsWeb) return false;
    if (path == null || path.isEmpty) return false;
    return io.File(path).existsSync();
  }

  Future<void> _pickLogoFromDevice() async {
    final prevPath = _logoPath;
    final prevBytes = _logoBytes;
    final prevIsSvg = _bytesIsSvg;

    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp', 'svg'],
      withData: kIsWeb, // ✅ مهم للويب
    );

    if (!mounted) return;

    if (res == null || res.files.isEmpty) {
      setState(() {
        _logoPath = prevPath;
        _logoBytes = prevBytes;
        _bytesIsSvg = prevIsSvg;
      });
      return;
    }

    final f = res.files.first;
    final ext = p.extension(f.name).toLowerCase();

    if (kIsWeb) {
      final bytes = f.bytes;
      if (bytes == null) return;

      setState(() {
        _logoBytes = bytes;
        _bytesIsSvg = ext == '.svg';
        _logoPath = null;
      });
      return;
    }

    if (f.path == null) return;

    final pickedPath = f.path!;
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final savedPath = p.join(dir.path, 'mosque_logo_$ts$ext');

    await io.File(pickedPath).copy(savedPath); // ✅ io.File
    await CacheHelper.setMosqueLogoPath(savedPath);

    if (!mounted) return;
    setState(() {
      _logoPath = savedPath;
      _logoBytes = null;
      _bytesIsSvg = false;
    });
  }

  Widget _buildLogo(double logoH, double logoW) {
    // ✅ WEB: ممنوع file، اعرض bytes لو موجودة وإلا default asset
    if (kIsWeb) {
      if (_logoBytes != null) {
        return _bytesIsSvg
            ? SvgPicture.memory(
                _logoBytes!,
                height: logoH,
                width: logoW,
                fit: BoxFit.cover,
              )
            : Image.memory(
                _logoBytes!,
                height: logoH,
                width: logoW,
                fit: BoxFit.cover,
              );
      }

      return SvgPicture.asset(
        Assets.svg.logosvg,
        height: logoH,
        width: logoW,
        fit: BoxFit.contain,
      );
    }

    // ✅ Mobile/Desktop: اعرض من File path
    final path = CacheHelper.getMosqueLogoPath();

    if (_exists(path)) {
      final lower = path!.toLowerCase();

      // اقرأ bytes مرة واحدة هنا
      final bytes = io.File(path).readAsBytesSync();

      if (lower.endsWith('.svg')) {
        return SvgPicture.memory(
          bytes,
          height: logoH,
          width: logoW,
          fit: BoxFit.cover,
        );
      }

      return Image.memory(
        bytes,
        height: logoH,
        width: logoW,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => SvgPicture.asset(
          Assets.svg.logosvg,
          height: logoH,
          width: logoW,
          fit: BoxFit.cover,
        ),
      );
    }

    return SvgPicture.asset(
      Assets.svg.logosvg,
      height: logoH,
      width: logoW,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _ = UiRotationCubit().isLandscape();

    const double gap = 10;
    final double startPadding = 10.w;

    final double logoH = 31.71.h;
    final double logoW = 30.22.w;

    final double menuButtonWidth = 50.w;

    final double baseBarHeight = 50.h;
    final double oneLineAvailableHeight = 35.h;
    final double twoLinesAvailableHeight = 58.h;

    final String titleText =
        CacheHelper.getMosqueName() ?? LocaleKeys.mosque_name_label.tr();

    return LayoutBuilder(
      builder: (context, outerConstraints) {
        final double totalWidth = outerConstraints.maxWidth;

        final double maxGroupWidth = (totalWidth - menuButtonWidth).clamp(
          0.0,
          totalWidth,
        );

        final double maxTitleWidth =
            (maxGroupWidth - startPadding - logoW - gap.w).clamp(
              0.0,
              maxGroupWidth,
            );

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

        final double barHeight = needsTwoLines ? (70.h) : baseBarHeight;
        final double availableTitleHeight = needsTwoLines
            ? twoLinesAvailableHeight
            : oneLineAvailableHeight;

        return SizedBox(
          width: double.infinity,
          height: barHeight,
          child: Stack(
            children: [
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
                          GestureDetector(
                            // ✅ هنا: دوس على اللوجو → يفتح اختيار من الجهاز
                            onTap: _pickLogoFromDevice,
                            child: Container(
                              height: logoH,
                              width: logoW,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2.r),
                              ),

                              child: _buildLogo(logoH, logoW),
                            ),
                          ),
                          HorizontalSpace(width: gap),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxTitleWidth,
                            ),
                            child: Padding(
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
              PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                child: SizedBox(
                  width: menuButtonWidth,
                  child: IconButton(
                    onPressed: widget.onDrawerTap?.call,
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
