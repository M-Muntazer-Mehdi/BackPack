import 'dart:io';
import 'package:path/path.dart' as path;

class AudioUtils {
  /// Format duration to mm:ss format
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  /// Format file size to human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Generate unique filename for audio recording
  static String generateAudioFileName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'voice_$timestamp.m4a';
  }

  /// Get file size in bytes
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Check if file exists
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Delete audio file
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get file extension
  static String getFileExtension(String filePath) {
    return path.extension(filePath);
  }

  /// Validate audio file
  static bool isValidAudioFile(String filePath) {
    final validExtensions = ['.m4a', '.mp3', '.wav', '.aac', '.ogg'];
    final ext = getFileExtension(filePath).toLowerCase();
    return validExtensions.contains(ext);
  }

  /// Convert seconds to Duration
  static Duration secondsToDuration(int seconds) {
    return Duration(seconds: seconds);
  }

  /// Convert Duration to seconds
  static int durationToSeconds(Duration duration) {
    return duration.inSeconds;
  }
}


