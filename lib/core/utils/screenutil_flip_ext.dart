import 'dart:math' show min, max;
import 'package:flutter/widgets.dart';

typedef MQFontSizeResolver = double Function(num fontSize, MQScale instance);

class MQScale {
  MQScale._();
  static final MQScale _i = MQScale._();
  factory MQScale() => _i;

  static const Size defaultDesignSize = Size(360, 690);

  static bool Function() _enableScaleWH = () => true;
  static bool Function() _enableScaleText = () => true;

  late Size _designSize;
  late MediaQueryData _data;
  late bool _minTextAdapt;
  late bool _splitScreenMode;

  MQFontSizeResolver? fontSizeResolver;

  static void enableScale({
    bool Function()? enableWH,
    bool Function()? enableText,
  }) {
    _enableScaleWH = enableWH ?? () => true;
    _enableScaleText = enableText ?? () => true;
  }

  /// Init based on View (works even BEFORE MaterialApp)
  static void init(
    BuildContext context, {
    required Size designSize,
    bool minTextAdapt = false,
    bool splitScreenMode = false,
    MQFontSizeResolver? fontSizeResolver,
    MediaQueryData? overrideData,
  }) {
    final data = overrideData ?? _mediaQueryFromContextOrView(context);

    _i
      .._data = data
      .._designSize = designSize
      .._minTextAdapt = minTextAdapt
      .._splitScreenMode = splitScreenMode
      ..fontSizeResolver = fontSizeResolver ?? _i.fontSizeResolver;
  }

  static MediaQueryData _mediaQueryFromContextOrView(BuildContext context) {
    // 1) If MediaQuery exists, take it.
    final mq = MediaQuery.maybeOf(context);
    if (mq != null) return mq;

    // 2) Else build it from View (like ScreenUtil does)
    final view =
        View.maybeOf(context) ??
        WidgetsBinding.instance.platformDispatcher.implicitView;

    if (view != null) {
      return MediaQueryData.fromView(view);
    }

    // 3) Last resort (shouldn't happen normally)
    return const MediaQueryData(size: Size(0, 0));
  }

  // ===== getters =====
  Size get designSize => _designSize;
  double get screenWidth => _data.size.width;
  double get screenHeight => _data.size.height;
  double get textScaleFactor => _data.textScaleFactor;

  // ===== scales =====
  double get scaleWidth =>
      !_enableScaleWH() ? 1 : screenWidth / _designSize.width;

  double get scaleHeight => !_enableScaleWH()
      ? 1
      : (_splitScreenMode ? max(screenHeight, 700) : screenHeight) /
            _designSize.height;

  double get scaleText => !_enableScaleText()
      ? 1
      : (_minTextAdapt ? min(scaleWidth, scaleHeight) : scaleWidth);

  // ===== converters =====
  double setWidth(num v) => v * scaleWidth;
  double setHeight(num v) => v * scaleHeight;

  double radius(num v) => v * min(scaleWidth, scaleHeight);

  double setSp(num fontSize) =>
      fontSizeResolver?.call(fontSize, _i) ?? fontSize * scaleText;
}

/// Widget بسيط يضمن إن MQScale.init اتعمل قبل ما تستخدم .w/.h
class MQScaleInit extends StatelessWidget {
  const MQScaleInit({
    super.key,
    required this.designSize,
    this.minTextAdapt = false,
    this.splitScreenMode = false,
    this.fontSizeResolver,
    this.overrideData,
    required this.child,
  });

  final Size designSize;
  final bool minTextAdapt;
  final bool splitScreenMode;
  final MQFontSizeResolver? fontSizeResolver;
  final MediaQueryData? overrideData;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    MQScale.init(
      context,
      designSize: designSize,
      minTextAdapt: minTextAdapt,
      splitScreenMode: splitScreenMode,
      fontSizeResolver: fontSizeResolver,
      overrideData: overrideData,
    );
    return child;
  }
}

// ====== SAME NAMES AS ScreenUtil ======
extension MQScaleNumExt on num {
  double get w => MQScale().setWidth(this);
  double get h => MQScale().setHeight(this);
  double get r => MQScale().radius(this);
  double get sp => MQScale().setSp(this);

  double get sw => this * MQScale().screenWidth;
  double get sh => this * MQScale().screenHeight;
}
