import 'package:azan/core/utils/cache_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The state is the number of clockwise quarter turns applied to the UI:
/// 0, 1, 2, 3. At 0 the UI follows the physical device orientation.

class UiRotationCubit extends Cubit<int> {
  // singleton
  static final UiRotationCubit _instance = UiRotationCubit._internal();
  factory UiRotationCubit() => _instance;
  UiRotationCubit._internal() : super(CacheHelper.getUiRotationQuarterTurns());

  bool _deviceIsLandscape = false;

  int get quarterTurns => _normalizeQuarterTurns(state);

  void syncDeviceOrientation({required bool deviceIsLandscape}) {
    _deviceIsLandscape = deviceIsLandscape;
  }

  Future<void> rotateClockwise() {
    return setQuarterTurns(quarterTurns + 1);
  }

  Future<void> selectDisplayDirection(int value) {
    return setQuarterTurns(value);
  }

  Future<void> setQuarterTurns(int value) async {
    final normalized = _normalizeQuarterTurns(value);
    await CacheHelper.setUiRotationQuarterTurns(normalized);
    if (normalized == state) return;
    emit(normalized);
  }

  Future<void> changeIsLandscape(bool v) async {
    final nextQuarterTurns = v == _deviceIsLandscape ? 0 : 1;
    await CacheHelper.setIsLandscape(v);
    await setQuarterTurns(nextQuarterTurns);
  }

  bool isLandscape() {
    return isLandscapeForDevice(_deviceIsLandscape);
  }

  bool isLandscapeForDevice(bool deviceIsLandscape) {
    return quarterTurns.isOdd ? !deviceIsLandscape : deviceIsLandscape;
  }

  static int _normalizeQuarterTurns(int value) {
    final normalized = value % 4;
    return normalized < 0 ? normalized + 4 : normalized;
  }
}

// class UiRotationCubit extends Cubit<UiRotationState> {
//   // UiRotationCubit() : super(UIRotationInitial());
//   // do singleton
//   static final UiRotationCubit _instance = UiRotationCubit._internal();
//   factory UiRotationCubit() => _instance;
//   UiRotationCubit._internal() : super(UIRotationInitial());

//   // get

//   // static UiRotationCubit get(context) => BlocProvider.of(context);

//   static int _initialQt() {
//     // final v = CacheHelper.get(key: 'ui_qt');
//     // if (v is int) return v % 2;

//     // final view = ui.PlatformDispatcher.instance.views.first;
//     // final size = view.physicalSize / view.devicePixelRatio;
//     // final physicalPortrait = size.height >= size.width;

//     // default لأول مرة فقط
//     return 1;
//   }

//   Future<void> toggle() async {
//     // final next = (state == 0) ? 1 : 0;
//     // emit(next);
//     // await CacheHelper.save(key: 'ui_qt', value: next);
//   }

//   Future<void> setQt(int qt) async {
//     // final v = qt % 2;
//     // emit(v);
//     // await CacheHelper.save(key: 'ui_qt', value: v);
//   }

//   bool _isLandscapeVar = false;

//   bool isLandscape() => _isLandscapeVar;

//   void changeIsLandscape(bool value) {
//     emit(UIRotationChanged());
//     _isLandscapeVar = value;
//     emit(UIRotationInitial());
//   }
// }
