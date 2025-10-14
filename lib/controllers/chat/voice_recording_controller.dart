import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:back_packers/utils/audio_utils.dart';

enum RecordingState {
  idle,
  recording,
  paused,
  stopped,
}

class VoiceRecordingController extends GetxController {
  // Audio recorder instance
  final AudioRecorder _audioRecorder = AudioRecorder();

  // Recording state
  RecordingState recordingState = RecordingState.idle;

  // Recording properties
  Duration recordingDuration = Duration.zero;
  String? recordedFilePath;
  bool isRecordingLocked = false;
  Timer? _recordingTimer;

  // Max recording duration (5 minutes)
  static const Duration maxRecordingDuration = Duration(minutes: 5);

  // Min recording duration (1 second)
  static const Duration minRecordingDuration = Duration(seconds: 1);

  // Permission status
  bool hasPermission = false;

  @override
  void onInit() {
    super.onInit();
    checkMicrophonePermission();
  }

  @override
  void onClose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.onClose();
  }

  /// Check if microphone permission is granted
  Future<bool> checkMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      hasPermission = status.isGranted;
      update();
      return hasPermission;
    } catch (e) {
      log('Error checking microphone permission: $e');
      return false;
    }
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      hasPermission = status.isGranted;
      update();

      if (status.isPermanentlyDenied) {
        // Show dialog to open settings
        _showPermissionDialog();
      }

      return hasPermission;
    } catch (e) {
      log('Error requesting microphone permission: $e');
      return false;
    }
  }

  /// Show permission dialog
  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'Please enable microphone permission from settings to record voice messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Start recording
  Future<bool> startRecording() async {
    try {
      // Check permission
      if (!hasPermission) {
        final granted = await requestMicrophonePermission();
        if (!granted) {
          return false;
        }
      }

      // Check if recording is supported
      if (!await _audioRecorder.hasPermission()) {
        log('Recording permission not granted');
        return false;
      }

      // Generate file path
      final directory = await getApplicationDocumentsDirectory();
      final fileName = AudioUtils.generateAudioFileName();
      recordedFilePath = '${directory.path}/$fileName';

      // Configure recording
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );

      // Start recording
      await _audioRecorder.start(config, path: recordedFilePath!);

      // Update state
      recordingState = RecordingState.recording;
      recordingDuration = Duration.zero;
      isRecordingLocked = false;

      // Start timer
      _startRecordingTimer();

      update();
      log('Recording started: $recordedFilePath');
      return true;
    } catch (e) {
      log('Error starting recording: $e');
      recordingState = RecordingState.idle;
      update();
      return false;
    }
  }

  /// Stop recording
  Future<String?> stopRecording() async {
    try {
      if (recordingState != RecordingState.recording &&
          recordingState != RecordingState.paused) {
        return null;
      }

      // Stop recording
      final path = await _audioRecorder.stop();

      // Stop timer
      _stopRecordingTimer();

      // Check minimum duration
      if (recordingDuration < minRecordingDuration) {
        log('Recording too short, deleting file');
        await _deleteRecordingFile();
        recordingState = RecordingState.idle;
        recordedFilePath = null;
        update();
        return null;
      }

      // Update state
      recordingState = RecordingState.stopped;
      update();

      log('Recording stopped: $path, Duration: ${AudioUtils.formatDuration(recordingDuration)}');
      return path;
    } catch (e) {
      log('Error stopping recording: $e');
      recordingState = RecordingState.idle;
      update();
      return null;
    }
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    try {
      if (recordingState != RecordingState.recording) {
        return;
      }

      await _audioRecorder.pause();
      _stopRecordingTimer();
      recordingState = RecordingState.paused;
      update();
      log('Recording paused');
    } catch (e) {
      log('Error pausing recording: $e');
    }
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    try {
      if (recordingState != RecordingState.paused) {
        return;
      }

      await _audioRecorder.resume();
      _startRecordingTimer();
      recordingState = RecordingState.recording;
      update();
      log('Recording resumed');
    } catch (e) {
      log('Error resuming recording: $e');
    }
  }

  /// Cancel recording
  Future<void> cancelRecording() async {
    try {
      if (recordingState == RecordingState.recording ||
          recordingState == RecordingState.paused) {
        await _audioRecorder.stop();
      }

      _stopRecordingTimer();
      await _deleteRecordingFile();

      recordingState = RecordingState.idle;
      recordingDuration = Duration.zero;
      recordedFilePath = null;
      isRecordingLocked = false;
      update();

      log('Recording cancelled');
    } catch (e) {
      log('Error cancelling recording: $e');
    }
  }

  /// Lock recording
  void lockRecording() {
    if (recordingState == RecordingState.recording) {
      isRecordingLocked = true;
      update();
      log('Recording locked');
    }
  }

  /// Unlock recording
  void unlockRecording() {
    isRecordingLocked = false;
    update();
    log('Recording unlocked');
  }

  /// Start recording timer
  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingDuration += const Duration(seconds: 1);

      // Check max duration
      if (recordingDuration >= maxRecordingDuration) {
        stopRecording();
      }

      update();
    });
  }

  /// Stop recording timer
  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  /// Delete recording file
  Future<void> _deleteRecordingFile() async {
    if (recordedFilePath != null) {
      await AudioUtils.deleteFile(recordedFilePath!);
    }
  }

  /// Get formatted recording duration
  String getFormattedDuration() {
    return AudioUtils.formatDuration(recordingDuration);
  }

  /// Check if recording is in progress
  bool get isRecording => recordingState == RecordingState.recording;

  /// Check if recording is paused
  bool get isPaused => recordingState == RecordingState.paused;

  /// Check if recording is stopped
  bool get isStopped => recordingState == RecordingState.stopped;

  /// Check if can send recording
  bool get canSendRecording =>
      recordingState == RecordingState.stopped &&
      recordedFilePath != null &&
      recordingDuration >= minRecordingDuration;

  /// Get recording file
  File? getRecordingFile() {
    if (recordedFilePath != null) {
      return File(recordedFilePath!);
    }
    return null;
  }

  /// Reset controller
  Future<void> reset() async {
    await cancelRecording();
  }
}

