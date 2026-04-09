import 'package:azan/core/helpers/managed_azkar_hive_helper.dart';
import 'package:azan/core/models/azkar_type.dart';
import 'package:azan/core/models/managed_azkar_entry.dart';

class ResolvedAzkarEntry {
  const ResolvedAzkarEntry({
    required this.text,
    this.category,
    this.count,
    this.description,
    this.reference,
    this.applicablePrayerIds = const <int>{},
  });

  final String text;
  final String? category;
  final String? count;
  final String? description;
  final String? reference;
  final Set<int> applicablePrayerIds;
}

class ResolvedAzkarSet {
  const ResolvedAzkarSet({
    required this.type,
    required this.title,
    required this.entries,
    this.prayerId,
  });

  final AzkarType type;
  final String title;
  final List<ResolvedAzkarEntry> entries;
  final int? prayerId;
}

Future<ResolvedAzkarSet> loadAzkarSet(AzkarType type, {int? prayerId}) async {
  final entries = await ManagedAzkarHiveHelper.getEntriesForType(
    type,
    prayerId: prayerId,
  );

  return ResolvedAzkarSet(
    type: type,
    title: type.defaultTitle,
    prayerId: prayerId,
    entries: entries.map(_mapManagedEntry).toList(growable: false),
  );
}

ResolvedAzkarSet emptyAzkarSet(AzkarType type, {int? prayerId}) {
  return ResolvedAzkarSet(
    type: type,
    title: type.defaultTitle,
    prayerId: prayerId,
    entries: const <ResolvedAzkarEntry>[],
  );
}

ResolvedAzkarEntry _mapManagedEntry(ManagedAzkarEntry entry) {
  return ResolvedAzkarEntry(
    text: entry.text,
    category: entry.setType.defaultTitle,
    count: entry.count,
    description: entry.description,
    reference: entry.reference,
    applicablePrayerIds: entry.applicablePrayerIds.toSet(),
  );
}
