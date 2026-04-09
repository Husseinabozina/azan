import 'package:azan/core/models/azkar_type.dart';

class ManagedAzkarEntry {
  const ManagedAzkarEntry({
    required this.id,
    required this.setType,
    required this.text,
    this.reference,
    this.description,
    this.count,
    this.applicablePrayerIds = const <int>[],
    this.active = true,
  });

  final int id;
  final AzkarType setType;
  final String text;
  final String? reference;
  final String? description;
  final String? count;
  final List<int> applicablePrayerIds;
  final bool active;

  ManagedAzkarEntry copyWith({
    int? id,
    AzkarType? setType,
    String? text,
    String? reference,
    String? description,
    String? count,
    List<int>? applicablePrayerIds,
    bool? active,
  }) {
    return ManagedAzkarEntry(
      id: id ?? this.id,
      setType: setType ?? this.setType,
      text: text ?? this.text,
      reference: reference ?? this.reference,
      description: description ?? this.description,
      count: count ?? this.count,
      applicablePrayerIds: applicablePrayerIds ?? this.applicablePrayerIds,
      active: active ?? this.active,
    );
  }

  bool appliesToPrayer(int? prayerId) {
    if (setType != AzkarType.afterPrayer) return true;
    if (applicablePrayerIds.isEmpty || prayerId == null) return true;
    return applicablePrayerIds.contains(prayerId);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'setType': setType.name,
      'text': text,
      'reference': reference,
      'description': description,
      'count': count,
      'applicablePrayerIds': applicablePrayerIds,
      'active': active,
    };
  }

  factory ManagedAzkarEntry.fromMap(Map<String, dynamic> map) {
    final typeName = map['setType'] as String? ?? AzkarType.morning.name;
    final setType = AzkarType.values.firstWhere(
      (type) => type.name == typeName,
      orElse: () => AzkarType.morning,
    );

    final rawPrayerIds =
        (map['applicablePrayerIds'] as List<dynamic>? ?? const <dynamic>[])
            .map((value) => value as int)
            .toSet()
            .toList()
          ..sort();

    return ManagedAzkarEntry(
      id: map['id'] as int,
      setType: setType,
      text: map['text'] as String? ?? '',
      reference: _readOptional(map['reference'] as String?),
      description: _readOptional(map['description'] as String?),
      count: _readOptional(map['count'] as String?),
      applicablePrayerIds: rawPrayerIds,
      active: map['active'] as bool? ?? true,
    );
  }

  static String? _readOptional(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
