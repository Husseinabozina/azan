import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azan/core/utils/cache_helper.dart';

/// qt:
/// 0 => Landscape UI
/// 1 => Portrait UI

class UiRotationCubit extends Cubit<bool> {
  // singleton
  static final UiRotationCubit _instance = UiRotationCubit._internal();
  factory UiRotationCubit() => _instance;
  UiRotationCubit._internal() : super(false);

  void changeIsLandscape(bool v) {
    CacheHelper.setIsLandscape(v);
    emit(v);
  }

  bool isLandscape() => state;
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
