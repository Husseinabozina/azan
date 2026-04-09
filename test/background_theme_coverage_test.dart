import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every active background has a theme pack entry', () {
    final backgroundSource = File(
      'lib/views/change_ background_settings/change_background_settings_screen.dart',
    ).readAsStringSync();
    final themeSource = File(
      'lib/core/theme/app_theme.dart',
    ).readAsStringSync();
    final assetsSource = File('lib/gen/assets.gen.dart').readAsStringSync();

    final assetAliases = <String, String>{};
    for (final match in RegExp(
      r"AssetGenImage get ([A-Za-z0-9_]+)\s*=>\s*const AssetGenImage\(\s*'([^']+)'\s*,?\s*\);",
    ).allMatches(assetsSource)) {
      assetAliases[match.group(1)!] = match.group(2)!;
    }

    final activeBackgrounds = <String>{};
    for (final match in RegExp(
      r'Assets\.images\.([A-Za-z0-9_]+)\.path',
    ).allMatches(backgroundSource)) {
      final key = match.group(1)!;
      final path = assetAliases[key];
      expect(path, isNotNull, reason: 'Missing asset alias for $key');
      activeBackgrounds.add(path!);
    }
    for (final match in RegExp(
      r"'(assets/images/[^']+)'",
    ).allMatches(backgroundSource)) {
      activeBackgrounds.add(match.group(1)!);
    }

    final themePackPaths = <String>{};
    for (final match in RegExp(
      r'Assets\.images\.([A-Za-z0-9_]+)\.path: const _ThemePack\(',
    ).allMatches(themeSource)) {
      final key = match.group(1)!;
      final path = assetAliases[key];
      expect(path, isNotNull, reason: 'Missing asset alias for $key');
      themePackPaths.add(path!);
    }
    for (final match in RegExp(
      r'Assets\.images\.([A-Za-z0-9_]+)\.path:\s*_[A-Za-z0-9_]+,',
    ).allMatches(themeSource)) {
      final key = match.group(1)!;
      final path = assetAliases[key];
      expect(path, isNotNull, reason: 'Missing asset alias for $key');
      themePackPaths.add(path!);
    }
    for (final match in RegExp(
      r"'(assets/images/[^']+)':\s*(?:const _ThemePack\(|_[A-Za-z0-9_]+Pack,)",
    ).allMatches(themeSource)) {
      themePackPaths.add(match.group(1)!);
    }

    expect(
      activeBackgrounds.difference(themePackPaths),
      isEmpty,
      reason:
          'Every active background should resolve to an explicit theme pack.',
    );
  });
}
