import 'package:auto_size_text/auto_size_text.dart';
import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/components/horizontal_space.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/views/home/components/home_appbar.dart';
import 'package:flutter/material.dart';

class LandscapeTop extends StatelessWidget {
  const LandscapeTop({
    super.key,
    required this.onDrawerTap,
    required this.height,
    required this.gregDate,
    required this.hijriDate,
    required this.titleFontSize,
    required this.hijiriFontSize,
  });

  final void Function()? onDrawerTap;
  final double height;
  final String gregDate;

  final String hijriDate;
  final double titleFontSize;
  final double hijiriFontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: 5.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await CacheHelper.stepHijriOffsetCycle();
                    await AppCubit.get(context).getTodayHijriDate(context);
                  },
                  child: Center(
                    child: Builder(
                      builder: (_) {
                        final text = hijriDate;
                        if (text == null || text.isEmpty) {
                          return Text(
                            "--:--",
                            style: TextStyle(
                              fontSize: hijiriFontSize,
                              // fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryTextColor,
                            ),
                          );
                        }

                        // ناخد آخر 4 chars (السنة)
                        final int yearLen = 4;
                        final String yearPart = text.length >= yearLen
                            ? text.substring(text.length - yearLen)
                            : text;

                        final String prefixPart = text.length >= yearLen
                            ? text.substring(0, text.length - yearLen)
                            : "";

                        return RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: prefixPart,
                                style: TextStyle(
                                  fontSize: hijiriFontSize,
                                  // fontSize: 25.sp,
                                  // fontWeight: FontWeight.bold,
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                              TextSpan(
                                text: yearPart,
                                style: TextStyle(
                                  fontSize: hijiriFontSize,
                                  // fontSize: 25.sp,
                                  // fontWeight: FontWeight.bold,
                                  color: AppTheme.secondaryTextColor,
                                  letterSpacing:
                                      .4.w, // 👈 هنا المسافة بين أرقام السنة
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // GestureDetector(
                //   onTap: ,

                //   child: _infoLine(hijriDate, fontSize: hijiriFontSize)),
                // HorizontalSpace(width: 10),
                _infoLine(" ، ${gregDate}", fontSize: hijiriFontSize),
                Expanded(
                  child: HomeAppBar(
                    onDrawerTap: () {
                      onDrawerTap!();
                    },
                    titleFontSize: titleFontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLine(String v, {double? fontSize}) {
    return AutoSizeText(
      v,
      maxLines: 1,
      minFontSize: 16, // ✅ raw (NOT sp)
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize ?? 24.sp,
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryTextColor,
      ),
    );
  }
}
