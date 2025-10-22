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
          top: 4,
          bottom: 4,
          left: isSender ? 60 : 10,
          right: isSender ? 10 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSender 
              ? AppColors.primaryColor.withOpacity(0.9)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isSender ? 20 : 0),
            bottomRight: Radius.circular(isSender ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: isSender 
                  ? AppColors.primaryColor.withOpacity(0.25)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSender ? Colors.white.withOpacity(0.85) : AppColors.txtGrey,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSender ? Colors.white.withOpacity(0.85) : AppColors.txtGrey,
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


