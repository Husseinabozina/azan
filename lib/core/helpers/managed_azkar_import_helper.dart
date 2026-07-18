import 'dart:convert';
import 'dart:typed_data';

import 'package:azan/core/helpers/azkar_prayer_scope_helper.dart';
import 'package:azan/core/models/azkar_type.dart';
import 'package:azan/core/models/managed_azkar_entry.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

class ManagedAzkarImportResult {
  const ManagedAzkarImportResult({
    required this.entries,
    this.warnings = const <String>[],
  });

  final List<ManagedAzkarEntry> entries;
  final List<String> warnings;
}

class ManagedAzkarImportHelper {
  const ManagedAzkarImportHelper._();

  static ManagedAzkarImportResult parseFileContent({
    required String content,
    required String fileName,
    required AzkarType type,
  }) {
    final extension = _extensionOf(fileName);
    if (extension == 'csv') {
      return _parseCsv(content, type);
    }

    return _parsePlainText(content, type);
  }

  static ManagedAzkarImportResult parseFileBytes({
    required List<int> bytes,
    required String fileName,
    required AzkarType type,
  }) {
    final extension = _extensionOf(fileName);
    if (extension == 'xlsx') {
      return _parseXlsx(Uint8List.fromList(bytes), type);
    }

    return parseFileContent(
      content: utf8.decode(bytes, allowMalformed: true),
      fileName: fileName,
      type: type,
    );
  }

  static ManagedAzkarImportResult _parsePlainText(
    String content,
    AzkarType type,
  ) {
    final lines = _normalizeInput(content)
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    final entries = lines
        .map((line) => _draft(type: type, text: line))
        .toList(growable: false);

    return ManagedAzkarImportResult(
      entries: entries,
      warnings: entries.isEmpty
          ? const <String>['لم يتم العثور على نصوص صالحة داخل الملف.']
          : const <String>[
              'تم اعتبار كل سطر في ملف TXT كعنصر مستقل. للنصوص الطويلة متعددة الأسطر استخدم التعديل المباشر أو CSV.',
            ],
    );
  }

  static ManagedAzkarImportResult _parseCsv(String content, AzkarType type) {
    final rows = _parseCsvRows(_normalizeInput(content));
    return _parseStructuredRows(
      rows,
      type,
      emptyWarning: 'ملف CSV فارغ أو غير قابل للقراءة.',
    );
  }

  static ManagedAzkarImportResult _parseXlsx(Uint8List bytes, AzkarType type) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final sheetFile =
          archive.findFile('xl/worksheets/sheet1.xml') ??
          archive.files
              .where(
                (file) =>
                    file.isFile &&
                    file.name.startsWith('xl/worksheets/') &&
                    file.name.endsWith('.xml'),
              )
              .cast<ArchiveFile?>()
              .firstWhere((file) => file != null, orElse: () => null);
      if (sheetFile == null) {
        return const ManagedAzkarImportResult(
          entries: <ManagedAzkarEntry>[],
          warnings: <String>[
            'لم نتمكن من العثور على صفحة بيانات داخل ملف Excel.',
          ],
        );
      }

      final sharedStrings = _readXlsxSharedStrings(archive);
      final rows = _readXlsxRows(sheetFile, sharedStrings);
      return _parseStructuredRows(
        rows,
        type,
        emptyWarning: 'ملف Excel فارغ أو غير قابل للقراءة.',
      );
    } catch (_) {
      return const ManagedAzkarImportResult(
        entries: <ManagedAzkarEntry>[],
        warnings: <String>[
          'لم نتمكن من قراءة ملف Excel. احفظه بصيغة XLSX أو CSV ثم جرّب مرة أخرى.',
        ],
      );
    }
  }

  static ManagedAzkarImportResult _parseStructuredRows(
    List<List<String>> rows,
    AzkarType type, {
    required String emptyWarning,
  }) {
    if (rows.isEmpty) {
      return ManagedAzkarImportResult(
        entries: <ManagedAzkarEntry>[],
        warnings: <String>[emptyWarning],
      );
    }

    final warnings = <String>[];
    final header = _looksLikeHeader(rows.first) ? rows.first : null;
    final dataRows = header == null ? rows : rows.skip(1).toList();
    final columns = header == null ? const <String, int>{} : _mapHeader(header);

    final entries = <ManagedAzkarEntry>[];
    for (var i = 0; i < dataRows.length; i++) {
      final row = dataRows[i];
      final text = _cell(row, columns, const [
        'text',
        'zekr',
        'dhikr',
        'content',
        'نص',
        'النص',
        'ذكر',
        'الذكر',
        'دعاء',
        'الدعاء',
        'حديث',
        'الحديث',
        'آية',
        'ايات',
        'آيات',
        'الاية',
        'الآية',
      ], fallbackIndex: 0);

      if (text.trim().isEmpty) {
        warnings.add('تم تجاهل صف رقم ${i + 1} لأنه بدون نص.');
        continue;
      }

      entries.add(
        _draft(
          type: type,
          text: text,
          reference: _cell(row, columns, const [
            'reference',
            'source',
            'ref',
            'مصدر',
            'المصدر',
            'مرجع',
            'المرجع',
          ], fallbackIndex: 1),
          count: _cell(row, columns, const [
            'count',
            'repeat',
            'repeats',
            'عدد',
            'العدد',
            'تكرار',
            'التكرار',
          ], fallbackIndex: 2),
          description: _cell(row, columns, const [
            'description',
            'note',
            'notes',
            'فضل',
            'الوصف',
            'ملاحظة',
          ], fallbackIndex: 3),
          prayerIds: _parsePrayerIds(
            _cell(row, columns, const [
              'prayerids',
              'prayers',
              'prayer_ids',
              'صلوات',
              'الصلوات',
              'الصلاة',
            ], fallbackIndex: 4),
          ),
        ),
      );
    }

    if (entries.isEmpty) {
      warnings.add('لم يتم العثور على صفوف صالحة للاستيراد.');
    }

    return ManagedAzkarImportResult(entries: entries, warnings: warnings);
  }

  static List<String> _readXlsxSharedStrings(Archive archive) {
    final file = archive.findFile('xl/sharedStrings.xml');
    if (file == null) return const <String>[];

    final xmlContent = _archiveFileText(file);
    final document = XmlDocument.parse(xmlContent);
    return document
        .findAllElements('si')
        .map((element) {
          return element
              .findAllElements('t')
              .map((text) => text.innerText)
              .join();
        })
        .toList(growable: false);
  }

  static List<List<String>> _readXlsxRows(
    ArchiveFile sheetFile,
    List<String> sharedStrings,
  ) {
    final document = XmlDocument.parse(_archiveFileText(sheetFile));
    final rows = <List<String>>[];

    for (final rowElement in document.findAllElements('row')) {
      final row = <String>[];
      var fallbackColumn = 0;

      for (final cell in rowElement.findElements('c')) {
        final reference = cell.getAttribute('r') ?? '';
        final columnIndex = _xlsxColumnIndex(reference) ?? fallbackColumn;
        while (row.length <= columnIndex) {
          row.add('');
        }

        row[columnIndex] = _xlsxCellValue(cell, sharedStrings);
        fallbackColumn = columnIndex + 1;
      }

      if (row.any((cell) => cell.trim().isNotEmpty)) {
        rows.add(row);
      }
    }

    return rows;
  }

  static String _xlsxCellValue(XmlElement cell, List<String> sharedStrings) {
    final type = cell.getAttribute('t');
    if (type == 'inlineStr') {
      return cell.findAllElements('t').map((text) => text.innerText).join();
    }

    final value = cell.findElements('v').firstOrNull?.innerText ?? '';
    if (type == 's') {
      final index = int.tryParse(value);
      if (index == null || index < 0 || index >= sharedStrings.length) {
        return '';
      }
      return sharedStrings[index];
    }

    return value;
  }

  static int? _xlsxColumnIndex(String reference) {
    final letters = RegExp(
      r'^[A-Z]+',
      caseSensitive: false,
    ).firstMatch(reference)?.group(0)?.toUpperCase();
    if (letters == null || letters.isEmpty) return null;

    var index = 0;
    for (final codeUnit in letters.codeUnits) {
      index = index * 26 + (codeUnit - 64);
    }
    return index - 1;
  }

  static String _archiveFileText(ArchiveFile file) {
    return utf8.decode(file.readBytes() ?? const <int>[], allowMalformed: true);
  }

  static ManagedAzkarEntry _draft({
    required AzkarType type,
    required String text,
    String? reference,
    String? count,
    String? description,
    List<int> prayerIds = const <int>[],
  }) {
    return ManagedAzkarEntry(
      id: 0,
      setType: type,
      text: _clean(text),
      reference: _optional(reference),
      count: _optional(count),
      description: _optional(description),
      applicablePrayerIds: prayerIds,
    );
  }

  static String _normalizeInput(String value) {
    return value
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(
          RegExp('[\u200E\u200F\u202A-\u202E\u2066-\u2069\uFEFF]'),
          '',
        )
        .trim();
  }

  static String _clean(String value) {
    return _normalizeInput(value)
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  static String? _optional(String? value) {
    final cleaned = _clean(value ?? '');
    return cleaned.isEmpty ? null : cleaned;
  }

  static String _extensionOf(String fileName) {
    final index = fileName.lastIndexOf('.');
    if (index == -1) return '';
    return fileName.substring(index + 1).trim().toLowerCase();
  }

  static bool _looksLikeHeader(List<String> row) {
    return row.any((cell) {
      final key = _headerKey(cell);
      return const {
        'text',
        'zekr',
        'dhikr',
        'content',
        'نص',
        'النص',
        'reference',
        'source',
        'count',
        'description',
        'prayerids',
      }.contains(key);
    });
  }

  static Map<String, int> _mapHeader(List<String> header) {
    final result = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      result[_headerKey(header[i])] = i;
    }
    return result;
  }

  static String _cell(
    List<String> row,
    Map<String, int> columns,
    List<String> keys, {
    required int fallbackIndex,
  }) {
    for (final key in keys) {
      final index = columns[_headerKey(key)];
      if (index != null && index >= 0 && index < row.length) {
        return row[index];
      }
    }

    if (columns.isEmpty && fallbackIndex >= 0 && fallbackIndex < row.length) {
      return row[fallbackIndex];
    }

    return '';
  }

  static String _headerKey(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_\-]+'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا');
  }

  static List<int> _parsePrayerIds(String raw) {
    return AzkarPrayerScopeHelper.normalizePrayerIds(
      raw
          .split(RegExp(r'[,،;]+'))
          .expand(_parsePrayerTokenGroup)
          .whereType<int>(),
    );
  }

  static Iterable<int?> _parsePrayerTokenGroup(String value) {
    final direct = AzkarPrayerScopeHelper.parsePrayerToken(value);
    if (direct != null) return <int>[direct];
    return value
        .split(RegExp(r'\s+'))
        .map(AzkarPrayerScopeHelper.parsePrayerToken);
  }

  static List<List<String>> _parseCsvRows(String content) {
    final rows = <List<String>>[];
    final row = <String>[];
    final cell = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < content.length; i++) {
      final char = content[i];
      final next = i + 1 < content.length ? content[i + 1] : '';

      if (char == '"') {
        if (inQuotes && next == '"') {
          cell.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
        continue;
      }

      if (!inQuotes && (char == ',' || char == ';' || char == '\t')) {
        row.add(cell.toString().trim());
        cell.clear();
        continue;
      }

      if (!inQuotes && char == '\n') {
        row.add(cell.toString().trim());
        cell.clear();
        if (row.any((value) => value.trim().isNotEmpty)) {
          rows.add(List<String>.from(row));
        }
        row.clear();
        continue;
      }

      cell.write(char);
    }

    row.add(cell.toString().trim());
    if (row.any((value) => value.trim().isNotEmpty)) {
      rows.add(row);
    }

    return rows;
  }
}
