import 'package:flutter/material.dart';

enum MosqueArchProfile { denseArch, wideArch }

@immutable
class MosqueHorizontalBounds {
  const MosqueHorizontalBounds({required this.left, required this.right});

  final double left;
  final double right;

  double get start => left;
  double get end => right;
  double get width => (right - left).clamp(0.0, 1.0);
  double get center => (left + right) / 2;
  bool get isEmpty => width <= 0;
}

@immutable
class MosqueShapeSpec {
  const MosqueShapeSpec({required this.topBoundary, required this.profile});

  // Normalized points (0..1) that describe the mosque top contour from left
  // to right. The clipper fills the full area beneath this contour.
  final List<Offset> topBoundary;
  final MosqueArchProfile profile;

  double apexY() {
    if (topBoundary.isEmpty) return 0;
    double minY = topBoundary.first.dy;
    for (final point in topBoundary) {
      if (point.dy < minY) minY = point.dy;
    }
    return _clamp(minY, 0, 1);
  }

  double yAt(double xNormalized) {
    if (topBoundary.isEmpty) return 0;
    if (topBoundary.length == 1) return _clamp(topBoundary.first.dy, 0, 1);

    final x = _clamp(xNormalized, 0, 1);
    final first = topBoundary.first;
    if (x <= first.dx) return _clamp(first.dy, 0, 1);

    for (int i = 1; i < topBoundary.length; i++) {
      final previous = topBoundary[i - 1];
      final current = topBoundary[i];
      if (x <= current.dx) {
        final span = current.dx - previous.dx;
        if (span <= 0) return _clamp(current.dy, 0, 1);
        final t = (x - previous.dx) / span;
        return _clamp(_lerp(previous.dy, current.dy, t), 0, 1);
      }
    }

    return _clamp(topBoundary.last.dy, 0, 1);
  }

  MosqueHorizontalBounds innerBoundsAt(
    double yNormalized, {
    double margin = 0.0,
    double? inset,
  }) {
    final resolvedMargin = inset ?? margin;
    final y = _clamp(yNormalized, 0, 1);
    final safeMargin = resolvedMargin.isNegative ? 0.0 : resolvedMargin;
    final intersections = <double>[];

    for (int i = 1; i < topBoundary.length; i++) {
      final previous = topBoundary[i - 1];
      final current = topBoundary[i];
      final minY = previous.dy < current.dy ? previous.dy : current.dy;
      final maxY = previous.dy > current.dy ? previous.dy : current.dy;

      if (y < minY || y > maxY) continue;

      final spanY = current.dy - previous.dy;
      if (spanY == 0) {
        intersections.add(previous.dx);
        intersections.add(current.dx);
        continue;
      }

      final t = (y - previous.dy) / spanY;
      if (t >= 0 && t <= 1) {
        intersections.add(_lerp(previous.dx, current.dx, t));
      }
    }

    if (intersections.isEmpty) {
      final fullLeft = _clamp(0.0 + safeMargin, 0, 1);
      final fullRight = _clamp(1.0 - safeMargin, 0, 1);
      return MosqueHorizontalBounds(left: fullLeft, right: fullRight);
    }

    intersections.sort();
    final left = _clamp(intersections.first + safeMargin, 0, 1);
    final right = _clamp(intersections.last - safeMargin, 0, 1);
    return MosqueHorizontalBounds(
      left: left <= right ? left : right,
      right: right >= left ? right : left,
    );
  }

  MosqueHorizontalBounds tightestInnerBoundsForBand(
    double topYNormalized,
    double heightNormalized, {
    double margin = 0.0,
    double? inset,
    int samples = 5,
  }) {
    final resolvedMargin = inset ?? margin;
    final top = _clamp(topYNormalized, 0, 1);
    final height = heightNormalized.isNegative ? 0.0 : heightNormalized;
    final bottom = _clamp(top + height, top, 1);
    final sampleCount = samples < 2 ? 2 : samples;

    double left = 0;
    double right = 1;

    for (int i = 0; i < sampleCount; i++) {
      final t = sampleCount == 1 ? 0.0 : i / (sampleCount - 1);
      final y = _lerp(top, bottom, t);
      final bounds = innerBoundsAt(y, margin: resolvedMargin);
      left = i == 0 ? bounds.left : (bounds.left > left ? bounds.left : left);
      right = i == 0
          ? bounds.right
          : (bounds.right < right ? bounds.right : right);
    }

    if (right < left) {
      return innerBoundsAt(top, margin: resolvedMargin);
    }

    return MosqueHorizontalBounds(left: left, right: right);
  }

  double safeTopForWidth(double widthFactor, {double margin = 0.018}) {
    final safeMargin = margin.isNegative ? 0.0 : margin;
    final halfSpan = _clamp(widthFactor, 0, 1) / 2;
    final startX = _clamp(0.5 - halfSpan, 0, 1);
    final endX = _clamp(0.5 + halfSpan, 0, 1);

    double maxY = yAt(startX);
    final endY = yAt(endX);
    if (endY > maxY) maxY = endY;

    for (final point in topBoundary) {
      if (point.dx >= startX && point.dx <= endX && point.dy > maxY) {
        maxY = point.dy;
      }
    }

    return _clamp(maxY + safeMargin, 0, 0.98);
  }

  double minYForInnerWidth(
    double widthFactor, {
    double margin = 0.018,
    double? inset,
  }) {
    final resolvedMargin = inset ?? margin;
    final targetWidth = _clamp(widthFactor, 0, 1);
    if (targetWidth <= 0) return apexY();

    final safeMargin = resolvedMargin.isNegative ? 0.0 : resolvedMargin;
    final startY = apexY();
    double bestY = safeTopForWidth(targetWidth, margin: safeMargin);

    for (int i = 0; i <= 240; i++) {
      final t = i / 240;
      final y = _lerp(startY, 1.0, t);
      if (innerBoundsAt(y, margin: safeMargin).width >= targetWidth) {
        bestY = y;
        break;
      }
    }

    return _clamp(bestY, 0, 0.98);
  }
}

const Set<String> legacyVrBackgrounds = {
  'assets/images/VR-0.jpg',
  'assets/images/VR-1.jpg',
  'assets/images/VR-2.jpg',
  'assets/images/VR-3.jpg',
  'assets/images/VR-4.jpg',
  'assets/images/VR-5.jpg',
  'assets/images/VR-6.jpg',
  'assets/images/VR-7.jpg',
  'assets/images/VR-8.jpg',
  'assets/images/VR-9.jpg',
  'assets/images/VR-10.jpg',
  'assets/images/VR-11.jpg',
  'assets/images/VR-12.jpg',
  'assets/images/VR-13.jpg',
  'assets/images/VR-14.jpg',
  'assets/images/VR-15.jpg',
  'assets/images/VR-16.jpg',
  'assets/images/VR-17.jpg',
  'assets/images/VR-18.jpg',
  'assets/images/VR-19.jpg',
};

final Map<String, MosqueShapeSpec> _legacyVrShapeSpecs = Map.unmodifiable({
  'assets/images/VR-0.jpg': _specForProfile(MosqueArchProfile.denseArch),
  'assets/images/VR-1.jpg': _specForProfile(MosqueArchProfile.denseArch),
  'assets/images/VR-2.jpg': _specForProfile(MosqueArchProfile.denseArch),
  'assets/images/VR-3.jpg': _specForProfile(MosqueArchProfile.denseArch),
  'assets/images/VR-4.jpg': _specForProfile(MosqueArchProfile.denseArch),
  'assets/images/VR-5.jpg': _specForProfile(MosqueArchProfile.denseArch),
  'assets/images/VR-6.jpg': _specForProfile(MosqueArchProfile.denseArch),
  'assets/images/VR-7.jpg': _specForProfile(MosqueArchProfile.wideArch),
  'assets/images/VR-8.jpg': _specForProfile(MosqueArchProfile.wideArch),
  'assets/images/VR-9.jpg': _specForProfile(MosqueArchProfile.wideArch),
  'assets/images/VR-10.jpg': _specForProfile(MosqueArchProfile.wideArch),
  'assets/images/VR-11.jpg': _specForProfile(MosqueArchProfile.wideArch),
  'assets/images/VR-12.jpg': _specForProfile(MosqueArchProfile.wideArch),
  'assets/images/VR-13.jpg': _specForProfile(MosqueArchProfile.wideArch),
  'assets/images/VR-14.jpg': _specForProfile(MosqueArchProfile.wideArch),
  'assets/images/VR-15.jpg': _specForProfile(MosqueArchProfile.wideArch),
  'assets/images/VR-16.jpg': _specForProfile(MosqueArchProfile.wideArch),
  'assets/images/VR-17.jpg': _specForProfile(MosqueArchProfile.wideArch),
  'assets/images/VR-18.jpg': _specForProfile(MosqueArchProfile.wideArch),
  'assets/images/VR-19.jpg': _specForProfile(MosqueArchProfile.wideArch),
});

bool isLegacyVrBackground(String path) {
  return legacyVrBackgrounds.contains(_normalizePath(path));
}

MosqueShapeSpec? specFor(String path) {
  return _legacyVrShapeSpecs[_normalizePath(path)];
}

double legacyMosqueBodyContentWidthFactor(MosqueArchProfile profile) {
  switch (profile) {
    case MosqueArchProfile.denseArch:
      return 0.86;
    case MosqueArchProfile.wideArch:
      return 0.90;
  }
}

double legacyMosqueBandInset(MosqueArchProfile profile, {bool meta = false}) {
  switch (profile) {
    case MosqueArchProfile.denseArch:
      return meta ? 0.036 : 0.022;
    case MosqueArchProfile.wideArch:
      return meta ? 0.032 : 0.020;
  }
}

class MosqueBackgroundClipper extends CustomClipper<Path> {
  const MosqueBackgroundClipper(this.spec);

  final MosqueShapeSpec spec;

  @override
  Path getClip(Size size) {
    if (size.isEmpty || spec.topBoundary.length < 2) {
      return Path()..addRect(Offset.zero & size);
    }

    final points = spec.topBoundary.map((p) => _denormalize(p, size)).toList();
    final path = Path()..moveTo(0, size.height);
    path.lineTo(points.first.dx, points.first.dy);

    Offset previous = points.first;
    for (int i = 1; i < points.length; i++) {
      final current = points[i];
      final mid = Offset(
        (previous.dx + current.dx) / 2,
        (previous.dy + current.dy) / 2,
      );
      path.quadraticBezierTo(previous.dx, previous.dy, mid.dx, mid.dy);
      previous = current;
    }

    path.lineTo(points.last.dx, points.last.dy);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant MosqueBackgroundClipper oldClipper) {
    return oldClipper.spec != spec;
  }
}

class MosqueClipCutoutDebugOverlay extends StatelessWidget {
  const MosqueClipCutoutDebugOverlay({
    super.key,
    required this.spec,
    this.fillColor = const Color(0x55FF2D55),
    this.strokeColor = const Color(0xCCFF2D55),
  });

  final MosqueShapeSpec spec;
  final Color fillColor;
  final Color strokeColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _MosqueClipCutoutDebugPainter(
          spec: spec,
          fillColor: fillColor,
          strokeColor: strokeColor,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _MosqueClipCutoutDebugPainter extends CustomPainter {
  const _MosqueClipCutoutDebugPainter({
    required this.spec,
    required this.fillColor,
    required this.strokeColor,
  });

  final MosqueShapeSpec spec;
  final Color fillColor;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || spec.topBoundary.length < 2) return;

    final points = spec.topBoundary.map((p) => _denormalize(p, size)).toList();
    final cutoutPath = Path()..moveTo(0, 0);
    cutoutPath.lineTo(points.first.dx, points.first.dy);

    Offset previous = points.first;
    for (int i = 1; i < points.length; i++) {
      final current = points[i];
      final mid = Offset(
        (previous.dx + current.dx) / 2,
        (previous.dy + current.dy) / 2,
      );
      cutoutPath.quadraticBezierTo(previous.dx, previous.dy, mid.dx, mid.dy);
      previous = current;
    }

    cutoutPath.lineTo(points.last.dx, points.last.dy);
    cutoutPath.lineTo(size.width, 0);
    cutoutPath.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(cutoutPath, fillPaint);

    final contourPath = Path()..moveTo(points.first.dx, points.first.dy);
    Offset previousContour = points.first;
    for (int i = 1; i < points.length; i++) {
      final current = points[i];
      final mid = Offset(
        (previousContour.dx + current.dx) / 2,
        (previousContour.dy + current.dy) / 2,
      );
      contourPath.quadraticBezierTo(
        previousContour.dx,
        previousContour.dy,
        mid.dx,
        mid.dy,
      );
      previousContour = current;
    }
    contourPath.lineTo(points.last.dx, points.last.dy);

    canvas.drawPath(contourPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _MosqueClipCutoutDebugPainter oldDelegate) {
    return oldDelegate.spec != spec ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor;
  }
}

String _normalizePath(String path) => path.replaceAll('\\', '/');

Offset _denormalize(Offset point, Size size) {
  return Offset(
    _clamp(point.dx, 0, 1) * size.width,
    _clamp(point.dy, 0, 1) * size.height,
  );
}

double _clamp(double value, double min, double max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

double _lerp(double a, double b, double t) => a + ((b - a) * t);

MosqueShapeSpec _specForProfile(MosqueArchProfile profile) {
  return MosqueShapeSpec(
    profile: profile,
    topBoundary: profile == MosqueArchProfile.denseArch
        ? _denseArchBoundary
        : _wideArchBoundary,
  );
}

const List<Offset> _denseArchBoundary = [
  Offset(0.000, 0.338),
  Offset(0.030, 0.325),
  Offset(0.060, 0.313),
  Offset(0.090, 0.258),
  Offset(0.120, 0.202),
  Offset(0.150, 0.152),
  Offset(0.180, 0.114),
  Offset(0.210, 0.086),
  Offset(0.240, 0.064),
  Offset(0.270, 0.064),
  Offset(0.300, 0.044),
  Offset(0.330, 0.028),
  Offset(0.360, 0.016),
  Offset(0.390, 0.006),
  Offset(0.420, 0.000),
  Offset(0.440, 0.000),
  Offset(0.460, 0.000),
  Offset(0.480, 0.000),
  Offset(0.500, 0.000),
  Offset(0.520, 0.000),
  Offset(0.540, 0.000),
  Offset(0.560, 0.000),
  Offset(0.580, 0.000),
  Offset(0.610, 0.006),
  Offset(0.640, 0.016),
  Offset(0.670, 0.028),
  Offset(0.700, 0.044),
  Offset(0.730, 0.064),
  Offset(0.760, 0.064),
  Offset(0.790, 0.086),
  Offset(0.820, 0.114),
  Offset(0.850, 0.152),
  Offset(0.880, 0.202),
  Offset(0.910, 0.258),
  Offset(0.940, 0.313),
  Offset(0.970, 0.325),
  Offset(1.000, 0.338),
];

const List<Offset> _wideArchBoundary = [
  Offset(0.000, 0.286),
  Offset(0.030, 0.275),
  Offset(0.060, 0.264),
  Offset(0.090, 0.214),
  Offset(0.120, 0.166),
  Offset(0.150, 0.128),
  Offset(0.180, 0.100),
  Offset(0.210, 0.078),
  Offset(0.240, 0.060),
  Offset(0.270, 0.056),
  Offset(0.300, 0.038),
  Offset(0.330, 0.024),
  Offset(0.360, 0.014),
  Offset(0.390, 0.006),
  Offset(0.420, 0.000),
  Offset(0.440, 0.000),
  Offset(0.460, 0.000),
  Offset(0.480, 0.000),
  Offset(0.500, 0.000),
  Offset(0.520, 0.000),
  Offset(0.540, 0.000),
  Offset(0.560, 0.000),
  Offset(0.580, 0.000),
  Offset(0.610, 0.006),
  Offset(0.640, 0.014),
  Offset(0.670, 0.024),
  Offset(0.700, 0.038),
  Offset(0.730, 0.056),
  Offset(0.760, 0.060),
  Offset(0.790, 0.078),
  Offset(0.820, 0.100),
  Offset(0.850, 0.128),
  Offset(0.880, 0.166),
  Offset(0.910, 0.214),
  Offset(0.940, 0.264),
  Offset(0.970, 0.275),
  Offset(1.000, 0.286),
];
