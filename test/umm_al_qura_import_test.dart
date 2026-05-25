import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('import tool copies and validates the final bundle', () async {
    final tempDir = await Directory.systemTemp.createTemp('umm_al_qura_import');
    addTearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    final result = await Process.run('dart', [
      'run',
      'tool/umm_al_qura_import.dart',
      '--source',
      '/Users/husseinabozina/Desktop/UmmAlQura_PDFs/server_bundle/v1',
      '--dest',
      tempDir.path,
      '--validate-all-cities',
    ], workingDirectory: '/Users/husseinabozina/azan');

    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(File('${tempDir.path}/manifest.json').existsSync(), isTrue);
    expect(
      Directory(
        '${tempDir.path}/cities/gz',
      ).listSync().whereType<File>().length,
      118,
    );
  });
}
