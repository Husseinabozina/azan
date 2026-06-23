import 'package:azan/core/utils/cache_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LocalizationHelper {
  static const String ar = 'ar';
  static const String en = 'en';

  static String localCode() {
    String code = CacheHelper.getLang();
    return code;
  }

  static bool isArabic() {
    if (localCode() == 'ar') {
      return true;
    } else {
      return false;
    }
  }

  static bool isArAndArNumberEnable() {
    if (CacheHelper.getLang() == 'ar' &&
        CacheHelper.getIsArabicNumbersEnabled()) {
      return true;
    } else {
      return false;
    }
  }
}
