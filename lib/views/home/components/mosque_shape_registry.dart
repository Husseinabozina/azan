import 'package:flutter/material.dart';

enum MosqueArchProfile { denseArch, wideArch }

@immutable
class MosqueShapeSpec {
  const MosqueShapeSpec({required this.topBoundary, required this.profile});

  // Normalized points (0..1) that describe the mosque top contour from left
  // to right. The clipper fills the full area beneath this contour.
  final List<Offset> topBoundary;
  final MosqueArchProfile profile;

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
  Offset(0.090, 0.302),
  Offset(0.120, 0.287),
  Offset(0.150, 0.266),
  Offset(0.180, 0.246),
  Offset(0.210, 0.231),
  Offset(0.240, 0.214),
  Offset(0.270, 0.197),
  Offset(0.300, 0.182),
  Offset(0.330, 0.164),
  Offset(0.360, 0.146),
  Offset(0.390, 0.128),
  Offset(0.420, 0.111),
  Offset(0.450, 0.093),
  Offset(0.480, 0.066),
  Offset(0.500, 0.039),
  Offset(0.520, 0.066),
  Offset(0.550, 0.093),
  Offset(0.580, 0.111),
  Offset(0.610, 0.128),
  Offset(0.640, 0.146),
  Offset(0.670, 0.164),
  Offset(0.700, 0.182),
  Offset(0.730, 0.197),
  Offset(0.760, 0.214),
  Offset(0.790, 0.231),
  Offset(0.820, 0.246),
  Offset(0.850, 0.266),
  Offset(0.880, 0.287),
  Offset(0.910, 0.302),
  Offset(0.940, 0.313),
  Offset(0.970, 0.325),
  Offset(1.000, 0.338),
];

const List<Offset> _wideArchBoundary = [
  Offset(0.000, 0.286),
  Offset(0.030, 0.275),
  Offset(0.060, 0.264),
  Offset(0.090, 0.253),
  Offset(0.120, 0.238),
  Offset(0.150, 0.221),
  Offset(0.180, 0.208),
  Offset(0.210, 0.196),
  Offset(0.240, 0.183),
  Offset(0.270, 0.170),
  Offset(0.300, 0.157),
  Offset(0.330, 0.143),
  Offset(0.360, 0.129),
  Offset(0.390, 0.115),
  Offset(0.420, 0.102),
  Offset(0.450, 0.088),
  Offset(0.480, 0.064),
  Offset(0.500, 0.038),
  Offset(0.520, 0.064),
  Offset(0.550, 0.088),
  Offset(0.580, 0.102),
  Offset(0.610, 0.115),
  Offset(0.640, 0.129),
  Offset(0.670, 0.143),
  Offset(0.700, 0.157),
  Offset(0.730, 0.170),
  Offset(0.760, 0.183),
  Offset(0.790, 0.196),
  Offset(0.820, 0.208),
  Offset(0.850, 0.221),
  Offset(0.880, 0.238),
  Offset(0.910, 0.253),
  Offset(0.940, 0.264),
  Offset(0.970, 0.275),
  Offset(1.000, 0.286),
];
