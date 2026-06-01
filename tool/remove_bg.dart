import 'dart:io';
import 'dart:collection';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

// Flood fill — returns boolean mask of identified background pixels
List<bool> identifyBackground(
  img.Image image,
  List<(int, int)> seeds,
  int threshold,
  int bgR,
  int bgG,
  int bgB,
) {
  final w = image.width;
  final h = image.height;
  final mask = List.filled(w * h, false);
  final queue = Queue<int>();

  void enqueue(int x, int y) {
    final idx = y * w + x;
    if (!mask[idx]) {
      mask[idx] = true;
      queue.add(idx);
    }
  }

  for (final (sx, sy) in seeds) enqueue(sx, sy);

  while (queue.isNotEmpty) {
    final idx = queue.removeFirst();
    final x = idx % w;
    final y = idx ~/ w;
    final p = image.getPixel(x, y);

    // Spread through already-transparent pixels
    if (p.a.toInt() == 0) {
      if (x > 0) enqueue(x - 1, y);
      if (x < w - 1) enqueue(x + 1, y);
      if (y > 0) enqueue(x, y - 1);
      if (y < h - 1) enqueue(x, y + 1);
      continue;
    }

    final d = (p.r.toInt() - bgR).abs() +
        (p.g.toInt() - bgG).abs() +
        (p.b.toInt() - bgB).abs();

    if (d < threshold) {
      if (x > 0) enqueue(x - 1, y);
      if (x < w - 1) enqueue(x + 1, y);
      if (y > 0) enqueue(x, y - 1);
      if (y < h - 1) enqueue(x, y + 1);
    }
  }
  return mask;
}

// Color-to-alpha on a single pixel — smooth anti-aliasing at edges
void processPixel(img.Image image, int x, int y, int bgR, int bgG, int bgB) {
  final p = image.getPixel(x, y);
  if (p.a.toInt() == 0) return;

  final r = p.r.toInt();
  final g = p.g.toInt();
  final b = p.b.toInt();

  double aR = 0, aG = 0, aB = 0;

  // Skip near-zero channels to avoid division instability
  if (bgR >= 10) {
    aR = r > bgR
        ? (r - bgR) / (255.0 - bgR)
        : (bgR - r) / bgR.toDouble();
  }
  if (bgG >= 10) {
    aG = g > bgG
        ? (g - bgG) / (255.0 - bgG)
        : (bgG - g) / bgG.toDouble();
  }
  if (bgB >= 10) {
    aB = b > bgB
        ? (b - bgB) / (255.0 - bgB)
        : (bgB - b) / bgB.toDouble();
  }

  final alpha = math.max(aR, math.max(aG, aB));

  if (alpha < 0.001) {
    image.setPixelRgba(x, y, 0, 0, 0, 0);
    return;
  }

  final newR = ((r - bgR * (1 - alpha)) / alpha).round().clamp(0, 255);
  final newG = ((g - bgG * (1 - alpha)) / alpha).round().clamp(0, 255);
  final newB = ((b - bgB * (1 - alpha)) / alpha).round().clamp(0, 255);
  final newA = (alpha * 255).round().clamp(0, 255);

  image.setPixelRgba(x, y, newR, newG, newB, newA);
}

void main() {
  final bytes = File('assets/images/rawayie_app_icon.png').readAsBytesSync();
  final src = img.decodePng(bytes)!;
  final w = src.width;
  final h = src.height;

  // Build RGBA copy
  final out = img.Image(width: w, height: h, numChannels: 4);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final p = src.getPixel(x, y);
      out.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), 255);
    }
  }

  // ── Step 1: identify outer white background ──
  const outerR = 253, outerG = 253, outerB = 253;
  final outerMask = identifyBackground(
    out,
    [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)],
    30,
    outerR, outerG, outerB,
  );

  // Remove outer background
  int outerCount = 0;
  for (int i = 0; i < outerMask.length; i++) {
    if (!outerMask[i]) continue;
    final x = i % w;
    final y = i ~/ w;
    if (out.getPixel(x, y).a.toInt() > 0) {
      out.setPixelRgba(x, y, 0, 0, 0, 0);
      outerCount++;
    }
  }
  print('Outer bg removed: $outerCount pixels');

  // ── Step 2: identify inner dark background ──
  final offset = (w * 0.10).toInt();
  final innerSample = out.getPixel(offset, offset);
  final innerR = innerSample.r.toInt();
  final innerG = innerSample.g.toInt();
  final innerB = innerSample.b.toInt();
  print('Inner bg color: rgb($innerR, $innerG, $innerB)');

  final innerMask = identifyBackground(
    out,
    [
      (offset, offset),
      (w - 1 - offset, offset),
      (offset, h - 1 - offset),
      (w - 1 - offset, h - 1 - offset),
    ],
    30,
    innerR, innerG, innerB,
  );

  // Remove inner background
  int innerCount = 0;
  for (int i = 0; i < innerMask.length; i++) {
    if (!innerMask[i]) continue;
    final x = i % w;
    final y = i ~/ w;
    if (out.getPixel(x, y).a.toInt() > 0) {
      out.setPixelRgba(x, y, 0, 0, 0, 0);
      innerCount++;
    }
  }
  print('Inner bg removed: $innerCount pixels');

  // ── Step 3: color-to-alpha ONLY on boundary pixels ──
  // Boundary = non-background pixel adjacent to a background pixel
  // This restores smooth anti-aliasing without touching logo interior
  final processed = List.filled(w * h, false);
  int boundaryCount = 0;

  const dirs = [(-1, 0), (1, 0), (0, -1), (0, 1),
                (-1, -1), (1, -1), (-1, 1), (1, 1)];

  for (int i = 0; i < w * h; i++) {
    if (!outerMask[i] && !innerMask[i]) continue;

    final bx = i % w;
    final by = i ~/ w;
    final isInner = innerMask[i];

    for (final (dx, dy) in dirs) {
      final nx = bx + dx;
      final ny = by + dy;
      if (nx < 0 || nx >= w || ny < 0 || ny >= h) continue;
      final ni = ny * w + nx;
      if (outerMask[ni] || innerMask[ni] || processed[ni]) continue;
      if (out.getPixel(nx, ny).a.toInt() == 0) continue;

      processPixel(
        out, nx, ny,
        isInner ? innerR : outerR,
        isInner ? innerG : outerG,
        isInner ? innerB : outerB,
      );
      processed[ni] = true;
      boundaryCount++;
    }
  }
  print('Boundary pixels processed: $boundaryCount');

  File('assets/images/rawayie_logo_transparent.png')
      .writeAsBytesSync(img.encodePng(out));
  print('Done!');
}
