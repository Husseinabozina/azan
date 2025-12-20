import 'package:azan/core/utils/cache_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LocalizationHelper {
  static const String ar = 'ar';
  static const String en = 'en';

  static String localCode(BuildContext context) {
    String code = context.locale.languageCode;
    return code;
  }

  static bool isArabic(BuildContext context) {
    if (localCode(context) == 'ar') {
      return true;
    } else {
      return false;
    }
  }

  static bool isArAndArNumberEnable(BuildContext context) {
    if (localCode(context) == 'ar' && CacheHelper.getIsArabicNumbersEnabled()) {
      return true;
    } else {
      return false;
    }
  }
}
