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
    UiRotationCubit().syncDeviceOrientation(deviceIsLandscape: true);
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
    cubit.syncDeviceOrientation(deviceIsLandscape: false);

    cubit.setQuarterTurns(0);
    expect(cubit.isLandscape(), isFalse);

    cubit.setQuarterTurns(1);
    expect(cubit.isLandscape(), isTrue);

    cubit.setQuarterTurns(2);
    expect(cubit.isLandscape(), isFalse);

    cubit.setQuarterTurns(3);
    expect(cubit.isLandscape(), isTrue);
  });

  test('zero rotation keeps mobile following the real device orientation', () {
    final cubit = UiRotationCubit();

    cubit.setQuarterTurns(0);
    cubit.syncDeviceOrientation(deviceIsLandscape: false);
    expect(cubit.isLandscape(), isFalse);

    cubit.syncDeviceOrientation(deviceIsLandscape: true);
    expect(cubit.isLandscape(), isTrue);
  });

  test('manual quarter turns are honored after pressing rotate on mobile', () {
    final cubit = UiRotationCubit();

    cubit.setQuarterTurns(1);
    cubit.syncDeviceOrientation(deviceIsLandscape: false);
    expect(cubit.isLandscape(), isTrue);

    cubit.setQuarterTurns(2);
    expect(cubit.isLandscape(), isFalse);
  });

  test('selectDisplayDirection jumps directly to target direction', () {
    final cubit = UiRotationCubit();

    cubit.selectDisplayDirection(3);
    expect(cubit.quarterTurns, 3);

    cubit.selectDisplayDirection(1);
    expect(cubit.quarterTurns, 1);

    cubit.selectDisplayDirection(6);
    expect(cubit.quarterTurns, 2);
  });

  test('selectDisplayDirection persists all four direction values', () async {
    final cubit = UiRotationCubit();

    for (final quarterTurns in <int>[0, 1, 2, 3]) {
      cubit.selectDisplayDirection(quarterTurns);
      await Future<void>.delayed(Duration.zero);

      expect(CacheHelper.getUiRotationQuarterTurns(), quarterTurns);
    }
  });

  test(
    'selecting the current direction does not emit a duplicate state',
    () async {
      final cubit = UiRotationCubit();
      cubit.selectDisplayDirection(2);

      var emitted = false;
      final subscription = cubit.stream.listen((_) => emitted = true);
      cubit.selectDisplayDirection(2);
      await Future<void>.delayed(Duration.zero);

      expect(emitted, isFalse);
      await subscription.cancel();
    },
  );
}
