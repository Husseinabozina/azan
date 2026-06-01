// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _sourceIconPath = '/Users/husseinabozina/Downloads/1.jpeg';
const _sourceLogoPath = '/Users/husseinabozina/Downloads/2.jpeg';
const _outputFullIconPath =
    '/Users/husseinabozina/azan/assets/images/rawayie_app_icon_full.png';
const _outputForegroundPath =
    '/Users/husseinabozina/azan/assets/images/rawayie_app_icon_foreground.png';
const _outputSplashLogoPath =
    '/Users/husseinabozina/azan/assets/images/rawayie_splash_logo.png';

const _navyR = 0x01;
const _navyG = 0x0A;
const _navyB = 0x2A;

bool _isNearWhite(img.Pixel pixel) {
  return pixel.r > 232 && pixel.g > 232 && pixel.b > 232;
}

bool _isLightNeutral(img.Pixel pixel) {
  final r = pixel.r.toInt();
  final g = pixel.g.toInt();
  final b = pixel.b.toInt();
  final maxChannel = math.max(r, math.max(g, b));
  final minChannel = math.min(r, math.min(g, b));
  final luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  return luminance > 158 && maxChannel - minChannel < 46;
}

bool _isVisibleLogoPixel(img.Pixel pixel) {
  final r = pixel.r.toInt();
  final g = pixel.g.toInt();
  final b = pixel.b.toInt();
  final luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  return luminance > 18 && r > b + 18 && g > b + 8;
}

img.Image _decode(String path) {
  final image = img.decodeImage(File(path).readAsBytesSync());
  if (image == null) {
    throw StateError('Could not decode $path');
  }
  return image;
}

img.Image _cropToInterestingArea(
  img.Image source,
  bool Function(img.Pixel pixel) isInteresting, {
  int padding = 0,
}) {
  var minX = source.width;
  var minY = source.height;
  var maxX = 0;
  var maxY = 0;

  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      if (!isInteresting(source.getPixel(x, y))) continue;
      minX = math.min(minX, x);
      minY = math.min(minY, y);
      maxX = math.max(maxX, x);
      maxY = math.max(maxY, y);
    }
  }

  if (minX > maxX || minY > maxY) {
    throw StateError('Could not find a useful crop area');
  }

  minX = math.max(0, minX - padding);
  minY = math.max(0, minY - padding);
  maxX = math.min(source.width - 1, maxX + padding);
  maxY = math.min(source.height - 1, maxY + padding);

  final width = maxX - minX + 1;
  final height = maxY - minY + 1;
  final size = math.max(width, height);
  final centerX = minX + width / 2;
  final centerY = minY + height / 2;
  var left = (centerX - size / 2).round();
  var top = (centerY - size / 2).round();

  left = left.clamp(0, source.width - size);
  top = top.clamp(0, source.height - size);

  return img.copyCrop(source, x: left, y: top, width: size, height: size);
}

img.Image _createCanvas(int size, {bool transparent = false}) {
  final canvas = img.Image(width: size, height: size, numChannels: 4);
  img.fill(
    canvas,
    color: transparent
        ? img.ColorRgba8(0, 0, 0, 0)
        : img.ColorRgba8(_navyR, _navyG, _navyB, 255),
  );
  return canvas;
}

void _buildFullIcon() {
  final source = _decode(_sourceIconPath);

  // Image 1 is a presentation mockup with an outer white canvas and drop shadow.
  // Crop the actual navy/gold artwork square before resizing it into app assets.
  final artworkSize = (math.min(source.width, source.height) * 0.795).round();
  final crop = img.copyCrop(
    source,
    x: ((source.width - artworkSize) / 2).round(),
    y: (source.height * 0.086).round(),
    width: artworkSize,
    height: artworkSize,
  );
  final resized = img.copyResize(
    crop,
    width: 1024,
    height: 1024,
    interpolation: img.Interpolation.average,
  );

  for (var y = 0; y < resized.height; y++) {
    for (var x = 0; x < resized.width; x++) {
      final pixel = resized.getPixel(x, y);
      if (_isNearWhite(pixel) || _isLightNeutral(pixel)) {
        resized.setPixelRgba(x, y, _navyR, _navyG, _navyB, 255);
      } else {
        resized.setPixelRgba(
          x,
          y,
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
          255,
        );
      }
    }
  }

  File(_outputFullIconPath).writeAsBytesSync(img.encodePng(resized));
}

img.Image _transparentLogo({
  required int canvasSize,
  required double fillRatio,
}) {
  final source = _decode(_sourceLogoPath);
  final crop = _cropToInterestingArea(source, _isVisibleLogoPixel, padding: 18);

  final transparentCrop = img.Image(
    width: crop.width,
    height: crop.height,
    numChannels: 4,
  );

  for (var y = 0; y < crop.height; y++) {
    for (var x = 0; x < crop.width; x++) {
      final pixel = crop.getPixel(x, y);
      if (_isVisibleLogoPixel(pixel)) {
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
        final alpha = (((luminance - 14) / 38) * 255).clamp(0, 255).round();
        transparentCrop.setPixelRgba(x, y, r, g, b, alpha);
      } else {
        transparentCrop.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }

  final maxLogoSize = (canvasSize * fillRatio).round();
  final resized = img.copyResize(
    transparentCrop,
    width: maxLogoSize,
    maintainAspect: true,
    interpolation: img.Interpolation.average,
  );

  final canvas = _createCanvas(canvasSize, transparent: true);
  img.compositeImage(
    canvas,
    resized,
    dstX: ((canvasSize - resized.width) / 2).round(),
    dstY: ((canvasSize - resized.height) / 2).round(),
    blend: img.BlendMode.alpha,
  );
  return canvas;
}

void _buildForegroundLogo() {
  final foreground = _transparentLogo(canvasSize: 1024, fillRatio: 0.66);
  File(_outputForegroundPath).writeAsBytesSync(img.encodePng(foreground));
}

void _buildSplashLogo() {
  final logo = _transparentLogo(canvasSize: 1400, fillRatio: 0.78);
  File(_outputSplashLogoPath).writeAsBytesSync(img.encodePng(logo));
}

void main() {
  _buildFullIcon();
  _buildForegroundLogo();
  _buildSplashLogo();

  print('Generated:');
  print('  $_outputFullIconPath');
  print('  $_outputForegroundPath');
  print('  $_outputSplashLogoPath');
}
