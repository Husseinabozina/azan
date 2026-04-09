enum AzkarType { morning, evening, afterPrayer }

extension AzkarTypeX on AzkarType {
  String get defaultTitle {
    switch (this) {
      case AzkarType.morning:
        return 'أذكار الصباح';
      case AzkarType.evening:
        return 'أذكار المساء';
      case AzkarType.afterPrayer:
        return 'أذكار بعد الصلاة';
    }
  }
}
