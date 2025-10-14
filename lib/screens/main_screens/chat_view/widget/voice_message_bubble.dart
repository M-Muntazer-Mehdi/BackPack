import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:back_packers/controllers/chat/audio_player_controller.dart';
import 'package:back_packers/screens/main_screens/chat_view/widget/voice_player_widget.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/audio_utils.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/globals/enum.dart';

class VoiceMessageBubble extends StatelessWidget {
  final Map<String, dynamic> voiceData;
  final MsgType msgType;
  final Timestamp time;
  final AudioPlayerController playerController;

  const VoiceMessageBubble({
    Key? key,
    required this.voiceData,
    required this.msgType,
    required this.time,
    required this.playerController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSender = msgType == MsgType.right;
    final audioUrl = voiceData['url'] as String? ?? '';
    final duration = voiceData['duration'] as int? ?? 0;
    final fileSize = voiceData['fileSize'] as int? ?? 0;

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 5,
          bottom: 5,
          left: isSender ? 60 : 10,
          right: isSender ? 10 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSender ? AppColors.primaryColor : const Color(0xff383838),
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
            // Voice player
            VoicePlayerWidget(
              audioUrl: audioUrl,
              durationInSeconds: duration,
              isSender: isSender,
              playerController: playerController,
            ),
            const SizedBox(height: 4),
            // File size and time
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  AudioUtils.formatFileSize(fileSize),
                  style: TextStyle(
                    fontSize: 10,
                    color: isSender ? Colors.white70 : Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 8),
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


