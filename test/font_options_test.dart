import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await CacheHelper.init();
  });

  test('app font choices keep only bold fonts plus Sultan', () {
    expect(allAppFonts, const [
      freeSerifBoldFont,
      freeSansBoldFont,
      amiriBoldFont,
      sultanFont,
    ]);
  });

  test('cached removed font choices fall back to approved fonts', () async {
    await CacheHelper.setTextsFontFamily(amiriFont);
    await CacheHelper.setAzkarFontFamily(ksaFont);

    expect(CacheHelper.getTextsFontFamily(), amiriBoldFont);
    expect(CacheHelper.getAzkarFontFamily(), sultanFont);
  });
}
