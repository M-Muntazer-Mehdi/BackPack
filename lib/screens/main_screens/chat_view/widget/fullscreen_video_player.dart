import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:back_packers/utils/audio_utils.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/global.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPlayer({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });

      // Auto play
      _controller.play();
      _isPlaying = true;

      _controller.addListener(() {
        if (_controller.value.isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = _controller.value.isPlaying;
          });
        }

        // Auto close when video ends
        if (_controller.value.position >= _controller.value.duration) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isInitialized = false;
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  Future<void> _saveVideo() async {
    try {
      EasyLoading.show(status: 'Downloading video...');
      log('Starting video download from: ${widget.videoUrl}');
      
      // Download video bytes
      final response = await http.get(Uri.parse(widget.videoUrl));
      final videoBytes = response.bodyBytes;
      log('Video downloaded, size: ${(videoBytes.length / (1024 * 1024)).toStringAsFixed(2)} MB');
      
      EasyLoading.show(status: 'Saving to gallery...');
      
      // Create temp file with .mp4 extension
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFilePath = '${tempDir.path}/video_$timestamp.mp4';
      
      // Write video bytes to temp file
      final tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(videoBytes);
      log('Temp video file created: $tempFilePath');
      
      // Save file to gallery with proper extension
      final result = await ImageGallerySaverPlus.saveFile(
        tempFilePath,
        name: 'backpackers_video_$timestamp',
        isReturnPathOfIOS: true,
      );
      
      log('Save result type: ${result.runtimeType}, value: $result');
      
      EasyLoading.dismiss();
      
      // Clean up temp file
      try {
        if (await tempFile.exists()) {
          await tempFile.delete();
          log('Temp file deleted');
        }
      } catch (e) {
        log('Failed to delete temp file: $e');
      }
      
      // Check result - can be Map, String, or bool
      bool saveSuccess = false;
      
      if (result is Map) {
        saveSuccess = result['isSuccess'] == true;
        log('Map result - isSuccess: ${result['isSuccess']}, filePath: ${result['filePath']}');
      } else if (result is String && result.isNotEmpty) {
        saveSuccess = true;
        log('String result (file path): $result');
      } else if (result is bool) {
        saveSuccess = result;
        log('Bool result: $result');
      } else if (result != null) {
        saveSuccess = true;
        log('Result is not null, assuming success');
      }
      
      if (saveSuccess) {
        EasyLoading.showSuccess('Video saved to gallery!');
        log('✅ Video saved successfully to device gallery');
      } else {
        log('❌ Save result indicates failure: $result');
        throw Exception('Failed to save - check storage permissions in device settings');
      }
    } catch (e, stackTrace) {
      log('❌ Error saving video: $e');
      log('Stack trace: $stackTrace');
      EasyLoading.dismiss();
      Global.showToastAlert(
        context: Get.overlayContext!,
        strTitle: "Error",
        strMsg: "Failed to save video. Please check storage permissions in settings.",
        toastType: TOAST_TYPE.toastError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video player
          Center(
            child: _isInitialized
                ? GestureDetector(
                    onTap: _toggleControls,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const CircularProgressIndicator(
                    color: Colors.white,
                  ),
          ),

          // Controls overlay
          if (_showControls)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

          // Top bar (close button and save button)
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      if (_isInitialized)
                        Text(
                          AudioUtils.formatDuration(_controller.value.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.white, size: 28),
                        onPressed: _saveVideo,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Center play/pause button
          if (_showControls)
            Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),

          // Bottom controls (progress bar and time)
          if (_showControls && _isInitialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress bar
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.white,
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white24,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      // Time display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AudioUtils.formatDuration(_controller.value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            AudioUtils.formatDuration(_controller.value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

