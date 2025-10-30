import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class RatingImageHelper {
  /// Maximum file size in bytes (5MB)
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  /// Maximum image dimension (width/height)
  static const int maxImageDimension = 1920;

  /// Compression quality (0-100)
  static const int compressionQuality = 85;

  /// Compress image before upload
  /// Returns compressed file or original if compression fails
  static Future<File> compressImage(File file) async {
    try {
      final fileSize = await file.length();

      // If file is already small enough, return original
      if (fileSize <= maxFileSizeBytes) {
        return file;
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Compress image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: compressionQuality,
        minWidth: maxImageDimension,
        minHeight: maxImageDimension,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        print('Image compression failed, using original file');
        return file;
      }

      // Check if compressed file is smaller
      final compressedSize = await File(compressedFile.path).length();
      if (compressedSize < fileSize) {
        return File(compressedFile.path);
      }

      return file;
    } catch (e) {
      print('Error compressing image: $e');
      return file;
    }
  }

  /// Compress multiple images
  static Future<List<File>> compressImages(List<File> files) async {
    final List<File> compressedFiles = [];

    for (final file in files) {
      final compressed = await compressImage(file);
      compressedFiles.add(compressed);
    }

    return compressedFiles;
  }

  /// Validate image file
  static Future<bool> validateImageFile(File file) async {
    try {
      // Check file exists
      if (!await file.exists()) {
        return false;
      }

      // Check file extension
      final ext = path.extension(file.path).toLowerCase();
      if (!['.jpg', '.jpeg', '.png', '.webp'].contains(ext)) {
        return false;
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize > maxFileSizeBytes * 2) {
        // Allow 2x before compression
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating image file: $e');
      return false;
    }
  }

  /// Validate multiple image files
  static Future<List<File>> validateImageFiles(List<File> files) async {
    final List<File> validFiles = [];

    for (final file in files) {
      if (await validateImageFile(file)) {
        validFiles.add(file);
      }
    }

    return validFiles;
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(File file) async {
    try {
      final bytes = await file.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      print('Error getting file size: $e');
      return 0;
    }
  }
}
