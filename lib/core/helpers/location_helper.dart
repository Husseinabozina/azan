import 'package:azan/core/models/city_location.dart';
import 'package:azan/core/models/city_option.dart';
import 'package:azan/data/data/city_country_data.dart';

class LocationHelper {
  /// دي زي ما هي: ترجع الـ CityLocation نفسها حسب الاسم (عربي أو إنجليزي)
  static CityOption? findSaudiCityByName(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return null;

    final bool looksEnglish = RegExp(r'[a-zA-Z]').hasMatch(raw);
    final normalizedEn = raw.toLowerCase();

    try {
      return kSaudiCities.firstWhere((c) {
        if (looksEnglish) {
          return c.nameEn.toLowerCase() == normalizedEn;
        } else {
          return c.nameAr == raw;
        }
      });
    } catch (_) {
      return null;
    }
  }

  /// دي الجديدة: لو دخل عربي ترجع إنجليزي، ولو دخل إنجليزي ترجع عربي
  static String? getOppositeCityName(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return null;

    final bool looksEnglish = RegExp(r'[a-zA-Z]').hasMatch(raw);

    final city = findSaudiCityByName(raw);
    if (city == null) return null;

    // لو كتب إنجليزي → رجّع عربي، ولو كتب عربي → رجّع إنجليزي
    return looksEnglish ? city.nameAr : city.nameEn;
  }
}
