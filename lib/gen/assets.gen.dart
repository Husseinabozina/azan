// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/asr.png
  AssetGenImage get asr => const AssetGenImage('assets/images/asr.png');

  /// File path: assets/images/background_blueGrey_gold.jpg
  AssetGenImage get backgroundBlueGreyGold =>
      const AssetGenImage('assets/images/background_blueGrey_gold.jpg');

  /// File path: assets/images/background_bround_with_mos_bird.png
  AssetGenImage get backgroundBroundWithMosBird =>
      const AssetGenImage('assets/images/background_bround_with_mos_bird.png');

  /// File path: assets/images/background_green_with.jpg
  AssetGenImage get backgroundGreenWith =>
      const AssetGenImage('assets/images/background_green_with.jpg');

  /// File path: assets/images/background_light.png
  AssetGenImage get backgroundLight =>
      const AssetGenImage('assets/images/background_light.png');

  /// File path: assets/images/background_light2.jpg
  AssetGenImage get backgroundLight2 =>
      const AssetGenImage('assets/images/background_light2.jpg');

  /// File path: assets/images/background_olive_green_with_mosq.png
  AssetGenImage get backgroundOliveGreenWithMosq =>
      const AssetGenImage('assets/images/background_olive_green_with_mosq.png');

  /// File path: assets/images/dhuhr.png
  AssetGenImage get dhuhr => const AssetGenImage('assets/images/dhuhr.png');

  /// File path: assets/images/fajr.png
  AssetGenImage get fajr => const AssetGenImage('assets/images/fajr.png');

  /// File path: assets/images/home.png
  AssetGenImage get home => const AssetGenImage('assets/images/home.png');

  /// File path: assets/images/maghrib.png
  AssetGenImage get maghrib => const AssetGenImage('assets/images/maghrib.png');

  /// File path: assets/images/oil_lamp_background.jpg
  AssetGenImage get oilLampBackground =>
      const AssetGenImage('assets/images/oil_lamp_background.jpg');

  /// File path: assets/images/sunrise.png
  AssetGenImage get sunrise => const AssetGenImage('assets/images/sunrise.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    asr,
    backgroundBlueGreyGold,
    backgroundBroundWithMosBird,
    backgroundGreenWith,
    backgroundLight,
    backgroundLight2,
    backgroundOliveGreenWithMosq,
    dhuhr,
    fajr,
    home,
    maghrib,
    oilLampBackground,
    sunrise,
  ];
}

class $AssetsSoundsGen {
  const $AssetsSoundsGen();

  /// File path: assets/sounds/alarm_sound.mp3
  String get alarmSound => 'assets/sounds/alarm_sound.mp3';

  /// File path: assets/sounds/azan.mp3
  String get azan => 'assets/sounds/azan.mp3';

  /// File path: assets/sounds/iqama.mp3
  String get iqama => 'assets/sounds/iqama.mp3';

  /// List of all assets
  List<String> get values => [alarmSound, azan, iqama];
}

class $AssetsSvgGen {
  const $AssetsSvgGen();

  /// File path: assets/svg/arrow_bottom.svg
  String get arrowBottom => 'assets/svg/arrow_bottom.svg';

  /// File path: assets/svg/asr.svg
  String get asr => 'assets/svg/asr.svg';

  /// File path: assets/svg/lang.svg
  String get lang => 'assets/svg/lang.svg';

  /// File path: assets/svg/logosvg.svg
  String get logosvg => 'assets/svg/logosvg.svg';

  /// List of all assets
  List<String> get values => [arrowBottom, asr, lang, logosvg];
}

class $AssetsTranslationsGen {
  const $AssetsTranslationsGen();

  /// File path: assets/translations/ar.json
  String get ar => 'assets/translations/ar.json';

  /// File path: assets/translations/en.json
  String get en => 'assets/translations/en.json';

  /// List of all assets
  List<String> get values => [ar, en];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsSoundsGen sounds = $AssetsSoundsGen();
  static const $AssetsSvgGen svg = $AssetsSvgGen();
  static const $AssetsTranslationsGen translations = $AssetsTranslationsGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
