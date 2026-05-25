import 'dart:io';
import 'dart:collection';
import 'package:image/image.dart' as img;

void floodFill(img.Image image, List<(int, int)> seeds, int threshold) {
  final w = image.width;
  final h = image.height;
  final visited = List.filled(w * h, false);
  final queue = Queue<int>();

  // Sample background color from the first seed that has alpha > 0
  int bgR = 0, bgG = 0, bgB = 0;
  for (final (sx, sy) in seeds) {
    final p = image.getPixel(sx, sy);
    if (p.a.toInt() > 0) {
      bgR = p.r.toInt();
      bgG = p.g.toInt();
      bgB = p.b.toInt();
      print('  Seed color: rgb($bgR, $bgG, $bgB)');
      break;
    }
  }

  void enqueue(int x, int y) {
    final idx = y * w + x;
    if (!visited[idx]) {
      visited[idx] = true;
      queue.add(idx);
    }
  }

  for (final (sx, sy) in seeds) {
    enqueue(sx, sy);
  }

  int count = 0;
  while (queue.isNotEmpty) {
    final idx = queue.removeFirst();
    final x = idx % w;
    final y = idx ~/ w;
    final p = image.getPixel(x, y);

    if (p.a.toInt() == 0) {
      // already transparent — keep spreading through it
      if (x > 0) enqueue(x - 1, y);
      if (x < w - 1) enqueue(x + 1, y);
      if (y > 0) enqueue(x, y - 1);
      if (y < h - 1) enqueue(x, y + 1);
      continue;
    }

    final dr = (p.r.toInt() - bgR).abs();
    final dg = (p.g.toInt() - bgG).abs();
    final db = (p.b.toInt() - bgB).abs();

    if (dr + dg + db < threshold) {
      image.setPixelRgba(x, y, 0, 0, 0, 0);
      count++;
      if (x > 0) enqueue(x - 1, y);
      if (x < w - 1) enqueue(x + 1, y);
      if (y > 0) enqueue(x, y - 1);
      if (y < h - 1) enqueue(x, y + 1);
    }
  }
  print('  Removed $count pixels');
}

void main() {
  final bytes = File('assets/images/rawayie_app_icon.png').readAsBytesSync();
  final src = img.decodePng(bytes)!;

  // Create RGBA copy
  final out = img.Image(width: src.width, height: src.height, numChannels: 4);
  for (int y = 0; y < src.height; y++) {
    for (int x = 0; x < src.width; x++) {
      final p = src.getPixel(x, y);
      out.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), 255);
    }
  }

  final w = out.width;
  final h = out.height;

  // Pass 1: remove outer white background + anti-aliased halo edge
  // threshold=400 catches all gradient pixels between white and dark navy
  print('Pass 1: removing outer white + anti-aliased halo...');
  floodFill(out, [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)], 500);

  // Pass 2: remove inner dark background + dark anti-aliased border pixels
  final offset = (w * 0.10).toInt();
  print('Pass 2: removing inner dark background...');
  floodFill(
    out,
    [
      (offset, offset),
      (w - 1 - offset, offset),
      (offset, h - 1 - offset),
      (w - 1 - offset, h - 1 - offset),
    ],
    200,
  );

  File('assets/images/rawayie_logo_transparent.png')
      .writeAsBytesSync(img.encodePng(out));
  print('Done! Saved: assets/images/rawayie_logo_transparent.png');
}
