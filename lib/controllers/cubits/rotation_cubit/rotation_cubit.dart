import 'package:azan/core/utils/cache_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The state is the number of clockwise quarter turns applied to the large
/// screen UI: 0, 1, 2, 3. Mobile keeps following the physical sensor.

class UiRotationCubit extends Cubit<int> {
  // singleton
  static final UiRotationCubit _instance = UiRotationCubit._internal();
  factory UiRotationCubit() => _instance;
  UiRotationCubit._internal() : super(CacheHelper.getUiRotationQuarterTurns());

  bool _deviceIsLandscape = false;
  bool _isMobile = false;

  int get quarterTurns => _normalizeQuarterTurns(state);

  void syncDeviceOrientation({
    required bool deviceIsLandscape,
    required bool isMobile,
  }) {
    _deviceIsLandscape = deviceIsLandscape;
    _isMobile = isMobile;
  }

  void rotateClockwise() {
    setQuarterTurns(quarterTurns + 1);
  }

  void setQuarterTurns(int value) {
    final normalized = _normalizeQuarterTurns(value);
    CacheHelper.setUiRotationQuarterTurns(normalized);
    emit(normalized);
  }

  void changeIsLandscape(bool v) {
    final nextQuarterTurns = v == _deviceIsLandscape ? 0 : 1;
    CacheHelper.setIsLandscape(v);
    setQuarterTurns(_isMobile ? 0 : nextQuarterTurns);
  }

  bool isLandscape() {
    if (_isMobile) {
      return _deviceIsLandscape;
    }
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
