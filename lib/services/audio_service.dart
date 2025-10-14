import 'dart:io';
import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:back_packers/utils/audio_utils.dart';

class AudioService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload audio file to Firebase Storage
  /// Returns the download URL of uploaded file
  static Future<Map<String, dynamic>> uploadAudioToFirebase({
    required File audioFile,
    required String chatRoomId,
    Function(double)? onProgress,
  }) async {
    try {
      // Generate unique filename
      final fileName = AudioUtils.generateAudioFileName();
      final filePath = 'chats/$chatRoomId/voice_messages/$fileName';

      // Get file size
      final fileSize = await AudioUtils.getFileSize(audioFile.path);

      // Create reference
      final Reference ref = _storage.ref().child(filePath);

      // Upload file
      final UploadTask uploadTask = ref.putFile(audioFile);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            snapshot.bytesTransferred / snapshot.totalBytes;
        if (onProgress != null) {
          onProgress(progress);
        }
      });

      // Wait for completion
      final TaskSnapshot taskSnapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      log('Audio uploaded successfully: $downloadUrl');

      return {
        'url': downloadUrl,
        'fileName': fileName,
        'fileSize': fileSize,
        'success': true,
      };
    } catch (e) {
      log('Error uploading audio: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Delete audio file from Firebase Storage
  static Future<bool> deleteAudioFromFirebase(String audioUrl) async {
    try {
      final Reference ref = _storage.refFromURL(audioUrl);
      await ref.delete();
      log('Audio deleted successfully: $audioUrl');
      return true;
    } catch (e) {
      log('Error deleting audio: $e');
      return false;
    }
  }

  /// Get audio metadata from Firebase Storage
  static Future<Map<String, dynamic>?> getAudioMetadata(
      String audioUrl) async {
    try {
      final Reference ref = _storage.refFromURL(audioUrl);
      final FullMetadata metadata = await ref.getMetadata();

      return {
        'name': metadata.name,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated,
        'updated': metadata.updated,
      };
    } catch (e) {
      log('Error getting audio metadata: $e');
      return null;
    }
  }

  /// Check if audio file exists in Firebase Storage
  static Future<bool> audioExists(String audioUrl) async {
    try {
      final Reference ref = _storage.refFromURL(audioUrl);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Upload audio with retry mechanism
  static Future<Map<String, dynamic>> uploadAudioWithRetry({
    required File audioFile,
    required String chatRoomId,
    int maxRetries = 3,
    Function(double)? onProgress,
  }) async {
    int attempts = 0;
    Map<String, dynamic> result = {};

    while (attempts < maxRetries) {
      result = await uploadAudioToFirebase(
        audioFile: audioFile,
        chatRoomId: chatRoomId,
        onProgress: onProgress,
      );

      if (result['success'] == true) {
        return result;
      }

      attempts++;
      if (attempts < maxRetries) {
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: attempts * 2));
        log('Retrying upload... Attempt $attempts');
      }
    }

    return result;
  }
}


