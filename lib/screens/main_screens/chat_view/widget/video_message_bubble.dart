import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:back_packers/screens/main_screens/chat_view/widget/video_player_widget.dart';
import 'package:back_packers/screens/main_screens/chat_view/widget/fullscreen_video_player.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/audio_utils.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/globals/enum.dart';

class VideoMessageBubble extends StatelessWidget {
  final Map<String, dynamic> videoData;
  final MsgType msgType;
  final Timestamp time;

  const VideoMessageBubble({
    Key? key,
    required this.videoData,
    required this.msgType,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSender = msgType == MsgType.right;
    final videoUrl = videoData['url'] as String? ?? '';
    final duration = videoData['duration'] as int? ?? 0;
    final fileSize = videoData['fileSize'] as int? ?? 0;

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          // Open full screen video player
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FullScreenVideoPlayer(videoUrl: videoUrl),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.only(
            top: 5,
            bottom: 5,
            left: isSender ? 60 : 10,
            right: isSender ? 10 : 60,
          ),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSender ? AppColors.primaryColor.withOpacity(0.3) : const Color(0xff383838),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15),
              topRight: const Radius.circular(15),
              bottomLeft: Radius.circular(isSender ? 15 : 0),
              bottomRight: Radius.circular(isSender ? 0 : 15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Video preview with tap to open indicator
              Stack(
                children: [
                  VideoPlayerWidget(
                    videoUrl: videoUrl,
                    durationInSeconds: duration,
                    isSender: isSender,
                  ),
                  // Tap to fullscreen indicator
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Tap to expand',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Video info and time
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.videocam,
                        size: 14,
                        color: isSender ? Colors.white70 : Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AudioUtils.formatFileSize(fileSize),
                        style: TextStyle(
                          fontSize: 11,
                          color: isSender ? Colors.white70 : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatTime(time),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSender ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
