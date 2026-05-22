import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await CacheHelper.init();
    UiRotationCubit().setQuarterTurns(0);
    UiRotationCubit().syncDeviceOrientation(
      deviceIsLandscape: true,
      isMobile: false,
    );
  });

  test('rotateClockwise cycles through four quarter turns', () {
    final cubit = UiRotationCubit();

    expect(cubit.quarterTurns, 0);
    expect(cubit.isLandscape(), isTrue);

    cubit.rotateClockwise();
    expect(cubit.quarterTurns, 1);
    expect(cubit.isLandscape(), isFalse);

    cubit.rotateClockwise();
    expect(cubit.quarterTurns, 2);
    expect(cubit.isLandscape(), isTrue);

    cubit.rotateClockwise();
    expect(cubit.quarterTurns, 3);
    expect(cubit.isLandscape(), isFalse);

    cubit.rotateClockwise();
    expect(cubit.quarterTurns, 0);
    expect(cubit.isLandscape(), isTrue);
  });

  test('portrait physical screens flip layout orientation on odd turns', () {
    final cubit = UiRotationCubit();
    cubit.syncDeviceOrientation(deviceIsLandscape: false, isMobile: false);

    cubit.setQuarterTurns(0);
    expect(cubit.isLandscape(), isFalse);

    cubit.setQuarterTurns(1);
    expect(cubit.isLandscape(), isTrue);

    cubit.setQuarterTurns(2);
    expect(cubit.isLandscape(), isFalse);

    cubit.setQuarterTurns(3);
    expect(cubit.isLandscape(), isTrue);
  });

  test('mobile keeps following the real device orientation', () {
    final cubit = UiRotationCubit();

    cubit.setQuarterTurns(1);
    cubit.syncDeviceOrientation(deviceIsLandscape: false, isMobile: true);
    expect(cubit.isLandscape(), isFalse);

    cubit.syncDeviceOrientation(deviceIsLandscape: true, isMobile: true);
    expect(cubit.isLandscape(), isTrue);
  });
}
