import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GlobalCopyrightFooter extends StatelessWidget {
  const GlobalCopyrightFooter({super.key});

  static const String _brand = 'sajdh.org';
  static const String _fallbackCity = '--';
  static const String _fallbackVersion = '--';
  static final Future<String> _versionFuture = _resolveAppVersion();

  static Future<String> _resolveAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version.trim();
      if (version.isNotEmpty) return version;

      final buildNumber = packageInfo.buildNumber.trim();
      if (buildNumber.isNotEmpty) return buildNumber;
    } catch (_) {
      // Keep the footer visible even if platform package info is unavailable.
    }

    return _fallbackVersion;
  }

  String _resolveCityEn(AppCubit cubit) {
    final fromCubit = cubit.getCity()?.nameEn.trim();
    if (fromCubit != null && fromCubit.isNotEmpty) return fromCubit;

    final fromCache = CacheHelper.getCity()?.nameEn.trim();
    if (fromCache != null && fromCache.isNotEmpty) return fromCache;

    return _fallbackCity;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 4.h),
        child: BlocBuilder<AppCubit, AppState>(
          buildWhen: (_, state) => state is AppInitial || state is AppChanged,
          builder: (context, state) {
            final cubit = context.read<AppCubit>();
            if (cubit.isBlackScreenVisible) return const SizedBox.shrink();

            final cityEn = _resolveCityEn(cubit);
            return FutureBuilder<String>(
              future: _versionFuture,
              builder: (context, snapshot) {
                final version = snapshot.data ?? _fallbackVersion;
                final cityLabel = cityEn.toLowerCase();

                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$_brand $version | sa.$cityLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
