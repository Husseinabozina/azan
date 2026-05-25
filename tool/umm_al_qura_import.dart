import 'dart:convert';
import 'dart:io';

import 'package:azan/core/models/gregorian_coverage_window.dart';
import 'package:azan/core/models/umm_al_qura_bundle_manifest.dart';

Future<void> main(List<String> args) async {
  final parsed = _ImportArguments.parse(args);
  final sourceDir = Directory(parsed.sourcePath);
  final destDir = Directory(parsed.destPath);
  if (!sourceDir.existsSync()) {
    stderr.writeln('Source bundle directory not found: ${parsed.sourcePath}');
    exitCode = 1;
    return;
  }

  final manifestFile = File('${sourceDir.path}/manifest.json');
  if (!manifestFile.existsSync()) {
    stderr.writeln('manifest.json not found under ${sourceDir.path}');
    exitCode = 1;
    return;
  }

  final manifest = UmmAlQuraBundleManifest.fromJson(
    jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>,
  );
  manifest.validateShape();
  manifest.validateYearSummaryComplete();

  if (parsed.validateAllCities) {
    await _validateCoverage(
      sourceDir: sourceDir,
      manifest: manifest,
      now: DateTime.now(),
    );
  }

  final gzSourceDir = Directory('${sourceDir.path}/cities/gz');
  if (!gzSourceDir.existsSync()) {
    stderr.writeln('cities/gz directory not found under ${sourceDir.path}');
    exitCode = 1;
    return;
  }

  await _copyFile(manifestFile, File('${destDir.path}/manifest.json'));
  await _copyDirectory(gzSourceDir, Directory('${destDir.path}/cities/gz'));

  stdout.writeln('Imported Umm Al-Qura bundle to ${destDir.path}');
  stdout.writeln('Cities: ${manifest.cityCount}');
  stdout.writeln(
    'Coverage years: ${manifest.availableHijriYears.first}-${manifest.availableHijriYears.last}',
  );
}

Future<void> _validateCoverage({
  required Directory sourceDir,
  required UmmAlQuraBundleManifest manifest,
  required DateTime now,
}) async {
  final window = GregorianCoverageWindow.forToday(now);
  final expectedDays = <String>{};
  for (
    var day = window.startInclusive;
    !day.isAfter(window.endInclusive);
    day = day.add(const Duration(days: 1))
  ) {
    expectedDays.add(_ymdForDate(day));
  }

  for (final city in manifest.cities) {
    final file = File('${sourceDir.path}/${city.file}');
    if (!file.existsSync()) {
      throw FormatException('Missing city asset: ${city.file}');
    }
    final payload =
        jsonDecode(utf8.decode(gzip.decode(await file.readAsBytes())))
            as Map<String, dynamic>;
    final years = Map<String, dynamic>.from(
      payload['years'] as Map<String, dynamic>? ?? const <String, dynamic>{},
    );

    final availableDays = <String>{};
    for (final entry in years.values) {
      final yearPayload = Map<String, dynamic>.from(entry as Map);
      final days = yearPayload['days'] as List<dynamic>? ?? const [];
      for (final rawDay in days) {
        final day = Map<String, dynamic>.from(rawDay as Map);
        final gregorian = day['gregorian'] as String? ?? '';
        if (gregorian.isNotEmpty &&
            gregorian.compareTo(_ymdForDate(window.startInclusive)) >= 0 &&
            gregorian.compareTo(_ymdForDate(window.endInclusive)) <= 0) {
          availableDays.add(gregorian);
        }
      }
    }

    final missing = expectedDays.difference(availableDays);
    if (missing.isNotEmpty) {
      final sorted = missing.toList()..sort();
      throw FormatException(
        'City ${city.id} is missing ${missing.length} day(s) inside '
        '${_ymdForDate(window.startInclusive)}..${_ymdForDate(window.endInclusive)} '
        '(first ${sorted.first}, last ${sorted.last})',
      );
    }
  }
}

Future<void> _copyFile(File source, File destination) async {
  await destination.parent.create(recursive: true);
  await source.copy(destination.path);
}

Future<void> _copyDirectory(Directory source, Directory destination) async {
  if (destination.existsSync()) {
    await destination.delete(recursive: true);
  }
  await destination.create(recursive: true);

  await for (final entity in source.list(recursive: true)) {
    final relativePath = entity.path.substring(source.path.length + 1);
    final targetPath = '${destination.path}/$relativePath';
    if (entity is Directory) {
      await Directory(targetPath).create(recursive: true);
    } else if (entity is File) {
      await File(targetPath).parent.create(recursive: true);
      await entity.copy(targetPath);
    }
  }
}

String _ymdForDate(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final year = normalized.year.toString().padLeft(4, '0');
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

class _ImportArguments {
  final String sourcePath;
  final String destPath;
  final bool validateAllCities;

  const _ImportArguments({
    required this.sourcePath,
    required this.destPath,
    required this.validateAllCities,
  });

  static _ImportArguments parse(List<String> args) {
    var sourcePath = '';
    var destPath = '';
    var validateAllCities = false;

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];
      switch (arg) {
        case '--source':
          sourcePath = args[++index];
          break;
        case '--dest':
          destPath = args[++index];
          break;
        case '--validate-all-cities':
          validateAllCities = true;
          break;
      }
    }

    if (sourcePath.isEmpty || destPath.isEmpty) {
      throw ArgumentError(
        'Usage: dart run tool/umm_al_qura_import.dart --source <dir> --dest <dir> [--validate-all-cities]',
      );
    }

    return _ImportArguments(
      sourcePath: sourcePath,
      destPath: destPath,
      validateAllCities: validateAllCities,
    );
  }
}
