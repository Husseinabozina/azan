import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/core/models/prayer.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await CacheHelper.init();
    AppCubit.configure(dio: Dio());
  });

  Prayer testPrayer(DateTime adhanTime) {
    return Prayer(id: 3, title: 'الجمعة', time: '12:20', dateTime: adhanTime);
  }

  test('finishPrayerAzanCycle closes active prayer overlay state', () {
    final cubit = AppCubit();
    final adhanTime = DateTime(2026, 7, 17, 12, 20);

    cubit.startAdhanCycle(
      prayer: testPrayer(adhanTime),
      adhanTime: adhanTime,
      iqamaTime: adhanTime.add(const Duration(minutes: 35)),
    );
    cubit.showPrayerAzanPage = true;
    cubit.startAzanAtIqamaPhase = true;
    cubit.markBetweenAdhanAndIqama();
    cubit.setAzanBlackScreenVisible(true);

    cubit.finishPrayerAzanCycle();

    expect(cubit.showPrayerAzanPage, isFalse);
    expect(cubit.startAzanAtIqamaPhase, isFalse);
    expect(cubit.isBetweenAdhanAndIqama, isFalse);
    expect(cubit.currentAdhanTime, isNull);
    expect(cubit.currentIqamaTime, isNull);
    expect(cubit.currentPrayerEndsAt, isNull);
    expect(cubit.prayerCyclePhase, PrayerCyclePhase.ended);
    expect(cubit.isAzanBlackScreenVisible, isFalse);
  });

  test(
    'enabling hide during an active prayer shows the prayer hide screen',
    () async {
      final cubit = AppCubit();
      final adhanTime = DateTime(2026, 7, 17, 12, 20);
      final prayerStartedAt = DateTime(2026, 7, 17, 12, 55);

      await CacheHelper.setEnableHidingScreenDuringPrayer(false);
      cubit.startAdhanCycle(
        prayer: testPrayer(adhanTime),
        adhanTime: adhanTime,
        iqamaTime: adhanTime.add(const Duration(minutes: 35)),
      );

      cubit.startPrayerPhase(durationMinutes: 7, startedAt: prayerStartedAt);

      expect(cubit.isPrayerActiveNow(prayerStartedAt), isTrue);
      expect(cubit.shouldShowPrayerHideScreen(prayerStartedAt), isFalse);
      expect(cubit.isAzanBlackScreenVisible, isFalse);

      await CacheHelper.setEnableHidingScreenDuringPrayer(true);
      cubit.handleHideDuringPrayerSettingChanged(true, prayerStartedAt);

      expect(cubit.isPrayerActiveNow(prayerStartedAt), isTrue);
      expect(cubit.shouldShowPrayerHideScreen(prayerStartedAt), isTrue);
      expect(cubit.isAzanBlackScreenVisible, isTrue);
    },
  );

  test(
    'disabling hide during an active prayer keeps the prayer cycle alive',
    () async {
      final cubit = AppCubit();
      final adhanTime = DateTime(2026, 7, 17, 12, 20);
      final prayerStartedAt = DateTime(2026, 7, 17, 12, 55);

      await CacheHelper.setEnableHidingScreenDuringPrayer(true);
      cubit.startAdhanCycle(
        prayer: testPrayer(adhanTime),
        adhanTime: adhanTime,
        iqamaTime: adhanTime.add(const Duration(minutes: 35)),
      );
      cubit.startPrayerPhase(durationMinutes: 7, startedAt: prayerStartedAt);
      expect(cubit.isAzanBlackScreenVisible, isTrue);

      await CacheHelper.setEnableHidingScreenDuringPrayer(false);
      cubit.handleHideDuringPrayerSettingChanged(false, prayerStartedAt);

      expect(cubit.isPrayerActiveNow(prayerStartedAt), isTrue);
      expect(cubit.prayerCyclePhase, PrayerCyclePhase.prayerActive);
      expect(cubit.currentPrayerEndsAt, isNotNull);
      expect(cubit.showPrayerAzanPage, isFalse);
      expect(cubit.isAzanBlackScreenVisible, isFalse);
    },
  );
}
