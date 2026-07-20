// lib/src/core/services/image_storage_service.dart
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageStorageService {
  static const _thumbnailDir = 'thumbnails';

  /// Saves an image file to local storage and returns the file path.
  Future<String> saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final uuid = const Uuid().v4();
    final filePath = '${directory.path}/$_thumbnailDir/$uuid.jpg';

    // Create directory if it doesn't exist
    final file = File(filePath);
    await file.parent.create(recursive: true);

    // Copy the image file to the new path
    await imageFile.copy(filePath);
    return filePath;
  }

  /// Deletes an image file from local storage.
  Future<void> deleteImage(String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
      }
    }on Exception catch (_) {
      // Ignore deletion errors
    }
  }
}
