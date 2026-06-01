import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class DisplayBoardImageHelper {
  static const int _maxSizeBytes = 2 * 1024 * 1024; // 2 MB

  static Future<String> copyImageToPrivateStorage(XFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final destDir = Directory('${appDir.path}/display_board_images');
    if (!destDir.existsSync()) {
      destDir.createSync(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = file.path.split('.').last.toLowerCase();
    final destPath = '${destDir.path}/$timestamp.$ext';

    final sourceBytes = await file.readAsBytes();

    if (sourceBytes.length <= _maxSizeBytes) {
      await File(destPath).writeAsBytes(sourceBytes);
      return destPath;
    }

    // Compress until under 2 MB
    final quality = _estimateQuality(sourceBytes.length);
    final compressed = await FlutterImageCompress.compressWithList(
      sourceBytes,
      quality: quality,
      format: CompressFormat.jpeg,
    );

    final finalBytes =
        compressed.length <= _maxSizeBytes ? compressed : sourceBytes;
    final finalPath = compressed.length <= _maxSizeBytes
        ? '${destDir.path}/$timestamp.jpg'
        : destPath;

    await File(finalPath).writeAsBytes(finalBytes);
    return finalPath;
  }

  static Future<void> deleteImageFile(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  static int _estimateQuality(int bytes) {
    // Scale quality inversely with file size: larger files get lower quality
    if (bytes < 4 * 1024 * 1024) return 75;
    if (bytes < 8 * 1024 * 1024) return 55;
    return 40;
  }
}
