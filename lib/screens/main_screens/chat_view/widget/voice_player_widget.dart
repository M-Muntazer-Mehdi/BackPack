import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/chat/audio_player_controller.dart';
import 'package:back_packers/utils/audio_utils.dart';
import 'package:back_packers/utils/app_colors.dart';

class VoicePlayerWidget extends StatelessWidget {
  final String audioUrl;
  final int durationInSeconds;
  final bool isSender;
  final AudioPlayerController playerController;

  const VoicePlayerWidget({
    Key? key,
    required this.audioUrl,
    required this.durationInSeconds,
    required this.isSender,
    required this.playerController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GetBuilder<AudioPlayerController>(
        // Don't use init here - the controller is already initialized in ChatDetailController
        // This prevents conflicts when multiple messages use the same controller
        builder: (controller) {
          // Use the builder's controller to ensure we're listening to updates
          final actualController = controller ?? playerController;
          
          final isPlaying = actualController.isPlaying(audioUrl);
          final isPaused = actualController.isPaused(audioUrl);
          final isLoading = actualController.isLoading(audioUrl);
          final isError = actualController.isError(audioUrl);
          final progress = actualController.getProgress(audioUrl);
          final currentPos = actualController.getCurrentPosition(audioUrl);
          final totalDur = actualController.getTotalDuration(audioUrl);

          // Use stored duration if not playing/loaded yet
          final displayDuration = totalDur.inSeconds > 0
              ? totalDur
              : Duration(seconds: durationInSeconds);

          final displayPosition = currentPos.inSeconds > 0
              ? currentPos
              : Duration.zero;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Play/Pause button
              GestureDetector(
                onTap: () {
                  // Don't allow clicks while loading
                  if (!isLoading) {
                    actualController.togglePlayPause(audioUrl);
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSender
                        ? Colors.white.withOpacity(0.2)
                        : AppColors.primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isSender ? Colors.white : AppColors.primaryColor,
                              ),
                            ),
                          )
                        : isError
                            ? Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 24,
                              )
                            : Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: isSender ? Colors.white : AppColors.primaryColor,
                                size: 24,
                              ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Waveform/Progress section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress bar with waveform effect
                    GestureDetector(
                      onTapDown: (details) {
                        _handleSeek(details);
                      },
                      child: Container(
                        height: 30,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background waveform bars
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(
                                30,
                                (index) {
                                  // Create random-looking heights for waveform effect
                                  final heights = [12.0, 18.0, 25.0, 15.0, 20.0, 10.0, 22.0, 16.0];
                                  final height = heights[index % heights.length];
                                  final isActive = (index / 30) <= progress;
                                  
                                  return Container(
                                    width: 2,
                                    height: height,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? (isSender ? Colors.white : AppColors.primaryColor)
                                          : (isSender 
                                              ? Colors.white.withOpacity(0.3)
                                              : Colors.grey.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Duration text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AudioUtils.formatDuration(displayPosition),
                          style: TextStyle(
                            fontSize: 11,
                            color: isSender ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        Text(
                          AudioUtils.formatDuration(displayDuration),
                          style: TextStyle(
                            fontSize: 11,
                            color: isSender ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Speed control (optional - tap to cycle through speeds)
              if (isPlaying || isPaused)
                GestureDetector(
                  onTap: () => _cyclePlaybackSpeed(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      '${actualController.playbackSpeed}x',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSender ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _handleSeek(TapDownDetails details) {
    // Only allow seeking if this audio is currently playing or paused
    if (playerController.currentlyPlayingUrl != audioUrl) {
      return;
    }
    
    // Don't allow seeking while loading
    if (playerController.isLoading(audioUrl)) {
      return;
    }

    final totalDur = playerController.getTotalDuration(audioUrl);
    
    if (totalDur.inMilliseconds > 0) {
      // Calculate the percentage based on tap position
      // localPosition is already relative to the GestureDetector widget
      final percentage = (details.localPosition.dx / 250).clamp(0.0, 1.0);
      final seekPosition = Duration(
        milliseconds: (totalDur.inMilliseconds * percentage).toInt(),
      );
      playerController.seek(seekPosition);
    }
  }

  void _cyclePlaybackSpeed() {
    final speeds = [1.0, 1.5, 2.0, 0.5];
    final currentIndex = speeds.indexOf(playerController.playbackSpeed);
    final nextSpeed = speeds[(currentIndex + 1) % speeds.length];
    playerController.setPlaybackSpeed(nextSpeed);
  }
}

