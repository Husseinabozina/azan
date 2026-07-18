import 'package:azan/core/helpers/managed_azkar_import_helper.dart';
import 'package:azan/core/helpers/azkar_prayer_scope_helper.dart';
import 'package:azan/core/models/azkar_type.dart';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ManagedAzkarImportHelper', () {
    test('imports plain text as one entry per non-empty line', () {
      final result = ManagedAzkarImportHelper.parseFileContent(
        content: 'ذكر أول\n\nذكر ثاني\n',
        fileName: 'azkar.txt',
        type: AzkarType.morning,
      );

      expect(result.entries.map((entry) => entry.text), [
        'ذكر أول',
        'ذكر ثاني',
      ]);
      expect(
        result.entries.every((entry) => entry.setType == AzkarType.morning),
        isTrue,
      );
    });

    test('imports csv with Arabic headers and optional metadata', () {
      final result = ManagedAzkarImportHelper.parseFileContent(
        content:
            'النص,المصدر,التكرار,الوصف,الصلوات\n'
            '"سُبْحَانَ الله","مسلم","33","تسبيح بعد الصلاة","1,5"\n',
        fileName: 'azkar.csv',
        type: AzkarType.afterPrayer,
      );

      expect(result.entries, hasLength(1));
      final entry = result.entries.single;
      expect(entry.text, 'سُبْحَانَ الله');
      expect(entry.reference, 'مسلم');
      expect(entry.count, '33');
      expect(entry.description, 'تسبيح بعد الصلاة');
      expect(entry.applicablePrayerIds, [1, 5]);
    });

    test('imports friday prayer scope from human-readable csv value', () {
      final result = ManagedAzkarImportHelper.parseFileContent(
        content:
            'النص,المصدر,التكرار,الوصف,الصلوات\n'
            '"ذكر خاص بالجمعة","اختبار","1","خاص","الجمعة"\n',
        fileName: 'azkar.csv',
        type: AzkarType.afterPrayer,
      );

      expect(result.entries, hasLength(1));
      expect(result.entries.single.applicablePrayerIds, [
        AzkarPrayerScopeHelper.fridayId,
      ]);
    });

    test('imports xlsx first sheet with Arabic headers', () {
      final archive = Archive()
        ..addFile(
          ArchiveFile.string('xl/sharedStrings.xml', '''
<sst>
  <si><t>النص</t></si>
  <si><t>المصدر</t></si>
  <si><t>التكرار</t></si>
  <si><t>الوصف</t></si>
  <si><t>الصلوات</t></si>
  <si><t>قُلْ هُوَ اللَّهُ أَحَدٌ</t></si>
  <si><t>الإخلاص</t></si>
  <si><t>3</t></si>
  <si><t>سورة قصيرة</t></si>
  <si><t>1,5</t></si>
</sst>
'''),
        )
        ..addFile(
          ArchiveFile.string('xl/worksheets/sheet1.xml', '''
<worksheet>
  <sheetData>
    <row r="1">
      <c r="A1" t="s"><v>0</v></c>
      <c r="B1" t="s"><v>1</v></c>
      <c r="C1" t="s"><v>2</v></c>
      <c r="D1" t="s"><v>3</v></c>
      <c r="E1" t="s"><v>4</v></c>
    </row>
    <row r="2">
      <c r="A2" t="s"><v>5</v></c>
      <c r="B2" t="s"><v>6</v></c>
      <c r="C2" t="s"><v>7</v></c>
      <c r="D2" t="s"><v>8</v></c>
      <c r="E2" t="s"><v>9</v></c>
    </row>
  </sheetData>
</worksheet>
'''),
        );
      final bytes = ZipEncoder().encode(archive);

      final result = ManagedAzkarImportHelper.parseFileBytes(
        bytes: bytes,
        fileName: 'azkar.xlsx',
        type: AzkarType.morning,
      );

      expect(result.entries, hasLength(1));
      final entry = result.entries.single;
      expect(entry.text, 'قُلْ هُوَ اللَّهُ أَحَدٌ');
      expect(entry.reference, 'الإخلاص');
      expect(entry.count, '3');
      expect(entry.description, 'سورة قصيرة');
      expect(entry.applicablePrayerIds, [1, 5]);
    });
  });
}
