import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const double _largeDisplayPrimaryTarget = 6.0;
const double _secondaryTarget = 4.5;
const double _accentHighlightTarget = 2.0;

void main(List<String> args) {
  final writeReportArg = args.cast<String?>().firstWhere(
    (arg) => arg != null && arg.startsWith('--write-report='),
    orElse: () => null,
  );
  final failOnIssues = args.contains('--fail-on-issues');
  final writeReportPath = writeReportArg?.substring('--write-report='.length);

  final audit = BackgroundThemeAudit(Directory.current);
  final report = audit.run();
  final markdown = report.toMarkdown();
  stdout.write(markdown);

  if (writeReportPath != null && writeReportPath.isNotEmpty) {
    final file = File(writeReportPath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(markdown);
  }

  if (failOnIssues && report.failing.isNotEmpty) {
    exitCode = 2;
  }
}

class BackgroundThemeAudit {
  BackgroundThemeAudit(this.repoRoot);

  final Directory repoRoot;

  static const String _appThemePath = 'lib/core/theme/app_theme.dart';
  static const String _backgroundSettingsPath =
      'lib/views/change_ background_settings/change_background_settings_screen.dart';
  static const String _displayBoardWidgetsPath =
      'lib/views/display_board/components/display_board_runtime_widgets.dart';
  static const String _assetsGenPath = 'lib/gen/assets.gen.dart';

  AuditReport run() {
    final assets = _parseAssetAliases();
    final themeSource = _read(_appThemePath);
    final backgroundSource = _read(_backgroundSettingsPath);
    final displayBoardSource = _read(_displayBoardWidgetsPath);

    final colorConstants = _parseColorConstants(themeSource);
    final namedPacks = _parseNamedPacks(themeSource, colorConstants);
    final backgroundPacks = _parseBackgroundPacks(
      themeSource,
      assets,
      namedPacks,
      colorConstants,
    );
    final backgroundOverlayAlphas = _parseBackgroundOverlayAlphas(
      themeSource,
      assets,
    );
    final activeBackgrounds = _parseActiveBackgrounds(backgroundSource, assets);
    final displayBoardModel = _parseDisplayBoardModel(displayBoardSource);

    final results = <BackgroundAuditResult>[];
    for (final backgroundPath in activeBackgrounds) {
      final pack = backgroundPacks[backgroundPath];
      if (pack == null) {
        results.add(
          BackgroundAuditResult.missingPack(backgroundPath: backgroundPath),
        );
        continue;
      }

      final imagePath = File('${repoRoot.path}/$backgroundPath');
      if (!imagePath.existsSync()) {
        results.add(
          BackgroundAuditResult.missingAsset(
            backgroundPath: backgroundPath,
            themePack: pack,
          ),
        );
        continue;
      }

      final bytes = imagePath.readAsBytesSync();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        results.add(
          BackgroundAuditResult.imageDecodeFailure(
            backgroundPath: backgroundPath,
            themePack: pack,
          ),
        );
        continue;
      }

      final resized = img.copyResize(decoded, width: 128, height: 128);
      final overlayAlpha = backgroundOverlayAlphas[backgroundPath] ?? 0.0;
      final analysis = ImageAnalysis.fromImage(
        resized,
      ).withDarkOverlay(overlayAlpha);
      final issues = _evaluatePack(
        pack,
        analysis,
        displayBoardModel: displayBoardModel,
      );

      ThemePackData? recommendation;
      String? recommendationName;
      if (issues.isNotEmpty) {
        final recommended = _recommendPack(
          currentPack: pack,
          analysis: analysis,
          displayBoardModel: displayBoardModel,
          namedPacks: namedPacks,
        );
        recommendation = recommended.$1;
        recommendationName = recommended.$2;
      }

      results.add(
        BackgroundAuditResult(
          backgroundPath: backgroundPath,
          themePack: pack,
          analysis: analysis,
          issues: issues,
          overlayAlpha: overlayAlpha,
          recommendedPack: recommendation,
          recommendedPackName: recommendationName,
        ),
      );
    }

    return AuditReport(
      generatedAt: DateTime.now(),
      activeBackgroundCount: activeBackgrounds.length,
      displayBoardModel: displayBoardModel,
      results: results,
    );
  }

  ThemePackRecommendation _recommendPack({
    required ThemePackData currentPack,
    required ImageAnalysis analysis,
    required DisplayBoardModel displayBoardModel,
    required Map<String, ThemePackData> namedPacks,
  }) {
    final candidates = <MapEntry<String, ThemePackData>>[
      MapEntry('current', currentPack),
      ...namedPacks.entries,
    ];

    MapEntry<String, ThemePackData>? best;
    List<AuditIssue>? bestIssues;
    double? bestScore;

    for (final candidate in candidates) {
      final issues = _evaluatePack(
        candidate.value,
        analysis,
        displayBoardModel: displayBoardModel,
      );
      final score = _packScore(candidate.value, analysis, displayBoardModel);
      final isBetterCandidate =
          best == null ||
          issues.length < bestIssues!.length ||
          (issues.length == bestIssues!.length && score > (bestScore ?? -1));
      if (isBetterCandidate) {
        best = candidate;
        bestIssues = issues;
        bestScore = score;
      }
    }

    return (best!.value, best.key);
  }

  double _packScore(
    ThemePackData pack,
    ImageAnalysis analysis,
    DisplayBoardModel displayBoardModel,
  ) {
    final derived = pack.derivedColors;
    final bgSamples = analysis.zoneRepresentatives.values.toList();
    double minPrimary = double.infinity;
    double minSecondary = double.infinity;
    double minAccent = double.infinity;
    for (final bg in bgSamples) {
      minPrimary = math.min(minPrimary, contrastRatio(pack.primaryText, bg));
      minSecondary = math.min(
        minSecondary,
        contrastRatio(pack.secondaryText, bg),
      );
      minAccent = math.min(minAccent, contrastRatio(pack.accent, bg));
    }

    double minDisplayBoard = double.infinity;
    for (final entry in analysis.zoneRepresentatives.entries) {
      final backdrop = displayBoardModel.backdropAlphaForZone(entry.key);
      final boardBg = blendOverBlack(
        entry.value,
        displayBoardModel.surfaceAlpha,
      );
      final effective = blendOverBlack(boardBg, backdrop);
      minDisplayBoard = math.min(
        minDisplayBoard,
        contrastRatio(derived.displayBoardPrimary, effective),
      );
    }

    final buttonContrast = contrastRatio(
      derived.primaryButtonText,
      derived.primaryButtonBackground,
    );
    final dialogTitleContrast = contrastRatio(
      derived.dialogTitle,
      pack.dialogBg,
    );
    final dialogBodyContrast = contrastRatio(derived.dialogBody, pack.dialogBg);

    return (minPrimary * 3) +
        (minSecondary * 2) +
        minAccent +
        (buttonContrast * 2) +
        dialogTitleContrast +
        dialogBodyContrast +
        minDisplayBoard;
  }

  List<AuditIssue> _evaluatePack(
    ThemePackData pack,
    ImageAnalysis analysis, {
    required DisplayBoardModel displayBoardModel,
  }) {
    final issues = <AuditIssue>[];
    final derived = pack.derivedColors;
    final bgSamples = analysis.zoneRepresentatives.entries.toList();

    double minPrimary = double.infinity;
    double minSecondary = double.infinity;
    double minAccent = double.infinity;
    String minPrimaryZone = '';
    String minSecondaryZone = '';
    String minAccentZone = '';

    for (final entry in bgSamples) {
      final primary = contrastRatio(pack.primaryText, entry.value);
      final secondary = contrastRatio(pack.secondaryText, entry.value);
      final accent = contrastRatio(pack.accent, entry.value);
      if (primary < minPrimary) {
        minPrimary = primary;
        minPrimaryZone = entry.key;
      }
      if (secondary < minSecondary) {
        minSecondary = secondary;
        minSecondaryZone = entry.key;
      }
      if (accent < minAccent) {
        minAccent = accent;
        minAccentZone = entry.key;
      }
    }

    if (minPrimary < _largeDisplayPrimaryTarget) {
      issues.add(
        AuditIssue(
          kind: AuditIssueKind.primaryText,
          message:
              'Primary text contrast is ${minPrimary.toStringAsFixed(2)}:1 on the $minPrimaryZone zone; large-display target is ${_largeDisplayPrimaryTarget.toStringAsFixed(1)}:1 with the app shadow model.',
        ),
      );
    }

    if (minSecondary < _secondaryTarget) {
      issues.add(
        AuditIssue(
          kind: AuditIssueKind.secondaryText,
          message:
              'Secondary text contrast is ${minSecondary.toStringAsFixed(2)}:1 on the $minSecondaryZone zone; required target is ${_secondaryTarget.toStringAsFixed(1)}:1.',
        ),
      );
    }

    if (minAccent < _accentHighlightTarget) {
      issues.add(
        AuditIssue(
          kind: AuditIssueKind.accent,
          message:
              'Accent contrast is ${minAccent.toStringAsFixed(2)}:1 on the $minAccentZone zone; it is too weak for highlight/icon use.',
        ),
      );
    }

    final buttonContrast = contrastRatio(
      derived.primaryButtonText,
      derived.primaryButtonBackground,
    );
    if (buttonContrast < 4.5) {
      issues.add(
        AuditIssue(
          kind: AuditIssueKind.button,
          message:
              'Button label contrast is ${buttonContrast.toStringAsFixed(2)}:1; required target is 4.5:1.',
        ),
      );
    }

    final dialogTitleContrast = contrastRatio(
      derived.dialogTitle,
      pack.dialogBg,
    );
    final dialogBodyContrast = contrastRatio(derived.dialogBody, pack.dialogBg);
    if (dialogTitleContrast < 4.5) {
      issues.add(
        AuditIssue(
          kind: AuditIssueKind.dialog,
          message:
              'Dialog title contrast is ${dialogTitleContrast.toStringAsFixed(2)}:1 on dialog background; target is 4.5:1.',
        ),
      );
    }
    if (dialogBodyContrast < 4.5) {
      issues.add(
        AuditIssue(
          kind: AuditIssueKind.dialog,
          message:
              'Dialog body contrast is ${dialogBodyContrast.toStringAsFixed(2)}:1 on dialog background; target is 4.5:1.',
        ),
      );
    }

    double minDisplayPrimary = double.infinity;
    double minDisplaySecondary = double.infinity;
    for (final entry in bgSamples) {
      final backdrop = displayBoardModel.backdropAlphaForZone(entry.key);
      final boardBg = blendOverBlack(
        entry.value,
        displayBoardModel.surfaceAlpha,
      );
      final effective = blendOverBlack(boardBg, backdrop);
      minDisplayPrimary = math.min(
        minDisplayPrimary,
        contrastRatio(derived.displayBoardPrimary, effective),
      );
      minDisplaySecondary = math.min(
        minDisplaySecondary,
        contrastRatio(derived.displayBoardSecondary, effective),
      );
    }
    if (minDisplayPrimary < _largeDisplayPrimaryTarget) {
      issues.add(
        AuditIssue(
          kind: AuditIssueKind.displayBoard,
          message:
              'Display-board primary text contrast drops to ${minDisplayPrimary.toStringAsFixed(2)}:1 after overlay simulation.',
        ),
      );
    }
    if (minDisplaySecondary < _secondaryTarget) {
      issues.add(
        AuditIssue(
          kind: AuditIssueKind.displayBoard,
          message:
              'Display-board secondary text contrast drops to ${minDisplaySecondary.toStringAsFixed(2)}:1 after overlay simulation.',
        ),
      );
    }

    final dominant = analysis.globalPalette.first.color;
    if (_isGoldLike(derived.primaryButtonBackground) &&
        _isWhiteLike(derived.primaryButtonText)) {
      issues.add(
        const AuditIssue(
          kind: AuditIssueKind.largeDisplayFragility,
          message:
              'White or near-white text on a gold button is fragile on bright large displays and must be rejected.',
        ),
      );
    }

    if (_isLightLike(derived.primaryButtonBackground) &&
        _isLightLike(derived.primaryButtonText)) {
      issues.add(
        const AuditIssue(
          kind: AuditIssueKind.largeDisplayFragility,
          message:
              'Light text on a light button surface is too fragile for bright mosque display screens.',
        ),
      );
    }

    if (_isBrownLike(pack.primaryText) &&
        _isBlueLike(dominant) &&
        minPrimary < 4.5) {
      issues.add(
        const AuditIssue(
          kind: AuditIssueKind.largeDisplayFragility,
          message:
              'Dark brown text on a saturated blue background is visually weak and should not be used on large bright screens.',
        ),
      );
    }

    return issues;
  }

  Map<String, String> _parseAssetAliases() {
    final source = _read(_assetsGenPath);
    final aliases = <String, String>{};
    final matches = RegExp(
      r"AssetGenImage get ([A-Za-z0-9_]+)\s*=>\s*const AssetGenImage\(\s*'([^']+)'\s*,?\s*\);",
    ).allMatches(source);
    for (final match in matches) {
      aliases[match.group(1)!] = match.group(2)!;
    }
    return aliases;
  }

  List<String> _parseActiveBackgrounds(
    String source,
    Map<String, String> assetAliases,
  ) {
    final values = <String>{};
    final assetMatches = RegExp(
      r'Assets\.images\.([A-Za-z0-9_]+)\.path',
    ).allMatches(source);
    for (final match in assetMatches) {
      final key = match.group(1)!;
      final path = assetAliases[key];
      if (path != null) {
        values.add(path);
      }
    }

    final literalMatches = RegExp(
      r"'(assets/images/[^']+)'",
    ).allMatches(source);
    for (final match in literalMatches) {
      values.add(match.group(1)!);
    }

    return values.toList()..sort();
  }

  DisplayBoardModel _parseDisplayBoardModel(String source) {
    final surfaceAlphas = RegExp(
      r'alpha: (0\.\d+)',
    ).allMatches(source).map((m) => double.parse(m.group(1)!)).toList();

    final surface = surfaceAlphas.length >= 2
        ? (surfaceAlphas[0] + surfaceAlphas[1]) / 2
        : 0.64;
    final backdrop = surfaceAlphas.length >= 6
        ? <String, double>{
            'top': surfaceAlphas[3],
            'center': surfaceAlphas[4],
            'bottom': surfaceAlphas[5],
          }
        : const <String, double>{'top': 0.28, 'center': 0.42, 'bottom': 0.56};

    return DisplayBoardModel(surfaceAlpha: surface, backdropAlphas: backdrop);
  }

  Map<String, ColorValue> _parseColorConstants(String source) {
    final colors = <String, ColorValue>{};
    final matches = RegExp(
      r'static const Color ([A-Za-z0-9_]+) = Color\(0x([0-9A-Fa-f]{8})\);',
    ).allMatches(source);
    for (final match in matches) {
      colors[match.group(1)!] = ColorValue.fromArgbHex(match.group(2)!);
    }
    return colors;
  }

  Map<String, ThemePackData> _parseNamedPacks(
    String source,
    Map<String, ColorValue> colorConstants,
  ) {
    final packs = <String, ThemePackData>{};
    final matches = RegExp(
      r'static const _ThemePack ([A-Za-z0-9_]+) = _ThemePack\(([\s\S]*?)\);\n',
    ).allMatches(source);
    for (final match in matches) {
      packs[match.group(1)!] = _parseThemePackBody(
        match.group(2)!,
        colorConstants,
        sourceName: match.group(1)!,
      );
    }
    return packs;
  }

  Map<String, ThemePackData> _parseBackgroundPacks(
    String source,
    Map<String, String> assetAliases,
    Map<String, ThemePackData> namedPacks,
    Map<String, ColorValue> colorConstants,
  ) {
    final packs = <String, ThemePackData>{};
    final mapStart = source.indexOf(
      'static final Map<String, _ThemePack> _packs = {',
    );
    final mapEnd = source.indexOf('};', mapStart);
    final mapSource = source.substring(mapStart, mapEnd);

    final directMatches = RegExp(
      r"(Assets\.images\.([A-Za-z0-9_]+)\.path|'(assets/images/[^']+)'):\s*const _ThemePack\(([\s\S]*?)\n\s*\),",
    ).allMatches(mapSource);

    for (final match in directMatches) {
      final alias = match.group(2);
      final literal = match.group(3);
      final body = match.group(4)!;
      final backgroundPath = alias != null ? assetAliases[alias] : literal;
      if (backgroundPath == null) {
        throw StateError('Unable to resolve background path for alias: $alias');
      }
      packs[backgroundPath] = _parseThemePackBody(
        body,
        colorConstants,
        sourceName: backgroundPath,
      );
    }

    final sharedMatches = RegExp(
      r"(Assets\.images\.([A-Za-z0-9_]+)\.path|'(assets/images/[^']+)'):\s*([A-Za-z0-9_]+),",
    ).allMatches(mapSource);

    for (final match in sharedMatches) {
      final alias = match.group(2);
      final literal = match.group(3);
      final packRef = match.group(4)!;
      if (!namedPacks.containsKey(packRef)) {
        continue;
      }
      final backgroundPath = alias != null ? assetAliases[alias] : literal;
      if (backgroundPath == null) {
        throw StateError('Unable to resolve background path for alias: $alias');
      }
      packs[backgroundPath] = namedPacks[packRef]!.copyWith(
        sourceName: packRef,
      );
    }

    return packs;
  }

  Map<String, double> _parseBackgroundOverlayAlphas(
    String source,
    Map<String, String> assetAliases,
  ) {
    final overlays = <String, double>{};
    final mapStart = source.indexOf(
      'static const Map<String, double> _backgroundReadabilityOverlayAlpha = {',
    );
    if (mapStart == -1) {
      return overlays;
    }
    final mapEnd = source.indexOf('};', mapStart);
    final mapSource = source.substring(mapStart, mapEnd);

    final matches = RegExp(
      r"(Assets\.images\.([A-Za-z0-9_]+)\.path|'(assets/images/[^']+)'):\s*([0-9.]+),",
    ).allMatches(mapSource);

    for (final match in matches) {
      final alias = match.group(2);
      final literal = match.group(3);
      final backgroundPath = alias != null ? assetAliases[alias] : literal;
      if (backgroundPath == null) {
        continue;
      }
      overlays[backgroundPath] = double.parse(match.group(4)!);
    }

    return overlays;
  }

  ThemePackData _parseThemePackBody(
    String body,
    Map<String, ColorValue> colorConstants, {
    required String sourceName,
  }) {
    final fields = <String, ColorValue>{};
    String? appBarExpr;

    final matches = RegExp(r'([A-Za-z0-9_]+):\s*([^,\n]+),').allMatches(body);
    for (final match in matches) {
      final key = match.group(1)!;
      final expr = match.group(2)!.trim();
      if (key == 'appBarForeground') {
        appBarExpr = expr;
        continue;
      }
      fields[key] = _resolveColor(expr, colorConstants);
    }

    return ThemePackData(
      sourceName: sourceName,
      primaryText: fields['primaryText']!,
      secondaryText: fields['secondaryText']!,
      accent: fields['accent']!,
      baseBg: fields['baseBg']!,
      dialogBg: fields['dialogBg']!,
      appBarForeground: appBarExpr == null
          ? fields['primaryText']!
          : _resolveColor(appBarExpr, colorConstants),
    );
  }

  ColorValue _resolveColor(
    String expr,
    Map<String, ColorValue> colorConstants,
  ) {
    if (expr.startsWith('Color(')) {
      final match = RegExp(r'0x([0-9A-Fa-f]{8})').firstMatch(expr);
      if (match == null) {
        throw StateError('Unsupported color expression: $expr');
      }
      return ColorValue.fromArgbHex(match.group(1)!);
    }
    final color = colorConstants[expr];
    if (color == null) {
      throw StateError('Unknown color constant: $expr');
    }
    return color;
  }

  String _read(String relativePath) {
    return File('${repoRoot.path}/$relativePath').readAsStringSync();
  }
}

typedef ThemePackRecommendation = (ThemePackData, String);

class AuditReport {
  AuditReport({
    required this.generatedAt,
    required this.activeBackgroundCount,
    required this.displayBoardModel,
    required this.results,
  });

  final DateTime generatedAt;
  final int activeBackgroundCount;
  final DisplayBoardModel displayBoardModel;
  final List<BackgroundAuditResult> results;

  List<BackgroundAuditResult> get passing =>
      results.where((result) => result.issues.isEmpty).toList();

  List<BackgroundAuditResult> get failing =>
      results.where((result) => result.issues.isNotEmpty).toList();

  String toMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Background Theme Audit Report')
      ..writeln()
      ..writeln('- Generated at: `${generatedAt.toIso8601String()}`')
      ..writeln('- Active backgrounds audited: `$activeBackgroundCount`')
      ..writeln('- Passing backgrounds: `${passing.length}`')
      ..writeln('- Failing backgrounds: `${failing.length}`')
      ..writeln(
        '- Display-board model: `surface alpha ${displayBoardModel.surfaceAlpha.toStringAsFixed(2)}`, '
        'backdrop alphas `${displayBoardModel.backdropAlphas}`',
      )
      ..writeln();

    if (failing.isEmpty) {
      buffer.writeln('All audited backgrounds passed the current rules.');
      return buffer.toString();
    }

    buffer.writeln('## Failing Backgrounds');
    buffer.writeln();
    for (final result in failing) {
      buffer.writeln('### `${result.backgroundLabel}`');
      buffer.writeln();
      buffer.writeln('- Asset: `${result.backgroundPath}`');
      if (result.overlayAlpha > 0) {
        buffer.writeln(
          '- Readability overlay: `${result.overlayAlpha.toStringAsFixed(2)}` black alpha',
        );
      }
      if (result.themePack != null) {
        buffer.writeln('- Current pack: ${result.themePack!.inlineSummary}');
      }
      if (result.analysis != null) {
        buffer.writeln(
          '- Dominant palette: ${result.analysis!.globalPalette.take(5).map((s) => s.label).join(', ')}',
        );
      }
      if (result.recommendedPack != null) {
        buffer.writeln(
          '- Recommended replacement'
          '${result.recommendedPackName == null ? '' : ' (`${result.recommendedPackName}`)'}: '
          '${result.recommendedPack!.inlineSummary}',
        );
      }
      buffer.writeln('- Issues:');
      for (final issue in result.issues) {
        buffer.writeln('  - ${issue.message}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }
}

class BackgroundAuditResult {
  BackgroundAuditResult({
    required this.backgroundPath,
    required this.themePack,
    required this.analysis,
    required this.issues,
    this.overlayAlpha = 0.0,
    this.recommendedPack,
    this.recommendedPackName,
  });

  BackgroundAuditResult.missingPack({required String backgroundPath})
    : this(
        backgroundPath: backgroundPath,
        themePack: null,
        analysis: null,
        issues: const [
          AuditIssue(
            kind: AuditIssueKind.packCoverage,
            message: 'No theme pack was found for this active background.',
          ),
        ],
      );

  BackgroundAuditResult.missingAsset({
    required String backgroundPath,
    required ThemePackData themePack,
  }) : this(
         backgroundPath: backgroundPath,
         themePack: themePack,
         analysis: null,
         issues: const [
           AuditIssue(
             kind: AuditIssueKind.asset,
             message: 'The background asset file does not exist on disk.',
           ),
         ],
       );

  BackgroundAuditResult.imageDecodeFailure({
    required String backgroundPath,
    required ThemePackData themePack,
  }) : this(
         backgroundPath: backgroundPath,
         themePack: themePack,
         analysis: null,
         issues: const [
           AuditIssue(
             kind: AuditIssueKind.asset,
             message: 'The background image could not be decoded.',
           ),
         ],
       );

  final String backgroundPath;
  final ThemePackData? themePack;
  final ImageAnalysis? analysis;
  final List<AuditIssue> issues;
  final double overlayAlpha;
  final ThemePackData? recommendedPack;
  final String? recommendedPackName;

  String get backgroundLabel => backgroundPath.split('/').last;
}

class ImageAnalysis {
  ImageAnalysis({
    required this.globalPalette,
    required this.zoneRepresentatives,
  });

  factory ImageAnalysis.fromImage(img.Image image) {
    final topEnd = image.height ~/ 3;
    final centerEnd = (image.height * 2) ~/ 3;
    return ImageAnalysis(
      globalPalette: dominantSwatches(_collectPixels(image, 0, image.height)),
      zoneRepresentatives: {
        'top': dominantSwatches(_collectPixels(image, 0, topEnd)).first.color,
        'center': dominantSwatches(
          _collectPixels(image, topEnd, centerEnd),
        ).first.color,
        'bottom': dominantSwatches(
          _collectPixels(image, centerEnd, image.height),
        ).first.color,
      },
    );
  }

  final List<Swatch> globalPalette;
  final Map<String, ColorValue> zoneRepresentatives;

  ImageAnalysis withDarkOverlay(double alpha) {
    if (alpha <= 0) return this;
    return ImageAnalysis(
      globalPalette: globalPalette
          .map(
            (swatch) => Swatch(
              color: blendOverBlack(swatch.color, alpha),
              share: swatch.share,
            ),
          )
          .toList(),
      zoneRepresentatives: {
        for (final entry in zoneRepresentatives.entries)
          entry.key: blendOverBlack(entry.value, alpha),
      },
    );
  }
}

class Swatch {
  const Swatch({required this.color, required this.share});

  final ColorValue color;
  final double share;

  String get label => '${color.hex} ${(share * 100).toStringAsFixed(1)}%';
}

class ThemePackData {
  const ThemePackData({
    required this.sourceName,
    required this.primaryText,
    required this.secondaryText,
    required this.accent,
    required this.baseBg,
    required this.dialogBg,
    required this.appBarForeground,
  });

  final String sourceName;
  final ColorValue primaryText;
  final ColorValue secondaryText;
  final ColorValue accent;
  final ColorValue baseBg;
  final ColorValue dialogBg;
  final ColorValue appBarForeground;

  ThemePackData copyWith({String? sourceName}) {
    return ThemePackData(
      sourceName: sourceName ?? this.sourceName,
      primaryText: primaryText,
      secondaryText: secondaryText,
      accent: accent,
      baseBg: baseBg,
      dialogBg: dialogBg,
      appBarForeground: appBarForeground,
    );
  }

  DerivedColors get derivedColors {
    final isLightBase = estimateBrightness(baseBg) == BrightnessLike.light;
    final primaryButtonBackground = isLightBase
        ? const ColorValue(0xD9, 0xA4, 0x41)
        : accent;
    return DerivedColors(
      dialogTitle: estimateBrightness(dialogBg) == BrightnessLike.dark
          ? const ColorValue(0xF4, 0xC6, 0x6A)
          : const ColorValue(0x5A, 0x35, 0x20),
      dialogBody: estimateBrightness(dialogBg) == BrightnessLike.dark
          ? const ColorValue(0xEA, 0xEF, 0xF6)
          : const ColorValue(0x3A, 0x24, 0x15),
      primaryButtonBackground: primaryButtonBackground,
      primaryButtonText:
          estimateBrightness(primaryButtonBackground) == BrightnessLike.dark
          ? const ColorValue(0xFF, 0xFF, 0xFF)
          : const ColorValue(0x3A, 0x24, 0x15),
      displayBoardPrimary: ensureDarkSurfaceContrast(
        primaryText,
        fallback: const ColorValue(0xEA, 0xEF, 0xF6),
        minContrast: _largeDisplayPrimaryTarget,
      ),
      displayBoardSecondary: ensureDarkSurfaceContrast(
        secondaryText,
        fallback: const ColorValue(0xD8, 0xE7, 0xFF),
        minContrast: _secondaryTarget,
      ),
      displayBoardAccent: ensureDarkSurfaceContrast(
        accent,
        fallback: const ColorValue(0xF4, 0xC6, 0x6A),
        minContrast: _accentHighlightTarget,
      ),
    );
  }

  String get inlineSummary =>
      '`primary ${primaryText.hex}`, `secondary ${secondaryText.hex}`, '
      '`accent ${accent.hex}`, `base ${baseBg.hex}`, `dialog ${dialogBg.hex}`';
}

class DerivedColors {
  const DerivedColors({
    required this.dialogTitle,
    required this.dialogBody,
    required this.primaryButtonBackground,
    required this.primaryButtonText,
    required this.displayBoardPrimary,
    required this.displayBoardSecondary,
    required this.displayBoardAccent,
  });

  final ColorValue dialogTitle;
  final ColorValue dialogBody;
  final ColorValue primaryButtonBackground;
  final ColorValue primaryButtonText;
  final ColorValue displayBoardPrimary;
  final ColorValue displayBoardSecondary;
  final ColorValue displayBoardAccent;
}

class ColorValue {
  const ColorValue(this.r, this.g, this.b);

  factory ColorValue.fromArgbHex(String hex) {
    final value = int.parse(hex, radix: 16);
    return ColorValue((value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF);
  }

  final int r;
  final int g;
  final int b;

  String get hex =>
      '#${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';

  double get red => r / 255.0;
  double get green => g / 255.0;
  double get blue => b / 255.0;

  @override
  bool operator ==(Object other) =>
      other is ColorValue && other.r == r && other.g == g && other.b == b;

  @override
  int get hashCode => Object.hash(r, g, b);
}

class DisplayBoardModel {
  const DisplayBoardModel({
    required this.surfaceAlpha,
    required this.backdropAlphas,
  });

  final double surfaceAlpha;
  final Map<String, double> backdropAlphas;

  double backdropAlphaForZone(String zone) => backdropAlphas[zone] ?? 0.42;
}

class AuditIssue {
  const AuditIssue({required this.kind, required this.message});

  final AuditIssueKind kind;
  final String message;
}

enum AuditIssueKind {
  packCoverage,
  asset,
  primaryText,
  secondaryText,
  accent,
  dialog,
  button,
  displayBoard,
  largeDisplayFragility,
}

enum BrightnessLike { light, dark }

List<ColorValue> _collectPixels(img.Image image, int yStart, int yEnd) {
  final pixels = <ColorValue>[];
  for (var y = yStart; y < yEnd; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      pixels.add(ColorValue(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()));
    }
  }
  return pixels;
}

List<Swatch> dominantSwatches(List<ColorValue> pixels, {int limit = 5}) {
  final counts = <String, int>{};
  final bucketColors = <String, ColorValue>{};

  for (final pixel in pixels) {
    final bucket = _bucketColor(pixel);
    counts.update(bucket.hex, (value) => value + 1, ifAbsent: () => 1);
    bucketColors[bucket.hex] = bucket;
  }

  final total = pixels.length.toDouble();
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted
      .take(limit)
      .map(
        (entry) =>
            Swatch(color: bucketColors[entry.key]!, share: entry.value / total),
      )
      .toList();
}

ColorValue _bucketColor(ColorValue color) {
  int roundChannel(int value) => ((value / 8).floor() * 8).clamp(0, 248);
  return ColorValue(
    roundChannel(color.r),
    roundChannel(color.g),
    roundChannel(color.b),
  );
}

BrightnessLike estimateBrightness(ColorValue color) {
  final luminance = computeLuminance(color);
  final threshold = (luminance + 0.05) * (luminance + 0.05);
  return threshold > 0.15 ? BrightnessLike.light : BrightnessLike.dark;
}

double contrastRatio(ColorValue a, ColorValue b) {
  final l1 = computeLuminance(a);
  final l2 = computeLuminance(b);
  final bright = math.max(l1, l2);
  final dark = math.min(l1, l2);
  return (bright + 0.05) / (dark + 0.05);
}

double computeLuminance(ColorValue color) {
  double linearize(double channel) {
    if (channel <= 0.03928) return channel / 12.92;
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = linearize(color.red);
  final g = linearize(color.green);
  final b = linearize(color.blue);
  return (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
}

ColorValue blendOverBlack(ColorValue color, double alpha) {
  return ColorValue(
    (color.r * (1 - alpha)).round(),
    (color.g * (1 - alpha)).round(),
    (color.b * (1 - alpha)).round(),
  );
}

ColorValue ensureDarkSurfaceContrast(
  ColorValue candidate, {
  required ColorValue fallback,
  required double minContrast,
}) {
  const reference = ColorValue(0x12, 0x17, 0x1D);
  return contrastRatio(candidate, reference) >= minContrast
      ? candidate
      : fallback;
}

bool _isWhiteLike(ColorValue color) {
  final hsl = toHsl(color);
  return computeLuminance(color) > 0.82 && hsl.$2 < 0.18;
}

bool _isLightLike(ColorValue color) => computeLuminance(color) > 0.65;

bool _isGoldLike(ColorValue color) {
  final hsl = toHsl(color);
  return hsl.$1 >= 35 &&
      hsl.$1 <= 65 &&
      hsl.$2 >= 0.35 &&
      hsl.$3 >= 0.30 &&
      hsl.$3 <= 0.78;
}

bool _isBrownLike(ColorValue color) {
  final hsl = toHsl(color);
  return hsl.$1 >= 10 && hsl.$1 <= 40 && hsl.$2 >= 0.20 && hsl.$3 <= 0.38;
}

bool _isBlueLike(ColorValue color) {
  final hsl = toHsl(color);
  return hsl.$1 >= 180 && hsl.$1 <= 260 && hsl.$2 >= 0.25;
}

(double, double, double) toHsl(ColorValue color) {
  final r = color.red;
  final g = color.green;
  final b = color.blue;
  final maxChannel = math.max(r, math.max(g, b));
  final minChannel = math.min(r, math.min(g, b));
  final delta = maxChannel - minChannel;
  final lightness = (maxChannel + minChannel) / 2;

  double hue = 0;
  double saturation = 0;

  if (delta != 0) {
    saturation = delta / (1 - (2 * lightness - 1).abs());
    if (maxChannel == r) {
      hue = 60 * (((g - b) / delta) % 6);
    } else if (maxChannel == g) {
      hue = 60 * (((b - r) / delta) + 2);
    } else {
      hue = 60 * (((r - g) / delta) + 4);
    }
  }

  if (hue < 0) {
    hue += 360;
  }

  return (hue, saturation.isNaN ? 0 : saturation, lightness);
}
