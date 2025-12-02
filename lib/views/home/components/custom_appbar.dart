import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, this.onDrawerTap, required this.r});
  final Function()? onDrawerTap;
  final R r;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: r.blockW * 3, right: r.blockW * 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              Assets.svg.logosvg,
              height: r.blockH * 7,
              width: r.blockW * 15,
            ),
          ),
          Text(
            CacheHelper.getMosqueName() ?? '',
            style: TextStyle(
              fontSize: r.h * 0.03,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              onDrawerTap!();
            },
            icon: Icon(
              Icons.menu,
              color: AppTheme.accentColor,
              size: r.blockH * 5,
            ),
          ),
        ],
      ),
    );
  }
}
