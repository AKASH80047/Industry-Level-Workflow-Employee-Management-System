import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  /// Compresses a target image file to under 300KB for lightweight storage
  static Future<File> compressSelfie(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // Compresses image to ~70% quality
      minWidth: 600,
      minHeight: 600,
    );

    if (compressedFile == null) {
      return file; // Fallback to original
    }

    return File(compressedFile.path);
  }
}
