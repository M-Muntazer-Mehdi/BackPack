import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/chat/voice_recording_controller.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';

class RecordingOverlayWidget extends StatelessWidget {
  final VoiceRecordingController controller;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  const RecordingOverlayWidget({
    Key? key,
    required this.controller,
    required this.onSend,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VoiceRecordingController>(
      init: controller,
      builder: (controller) {
        if (!controller.isRecording && !controller.isRecordingLocked) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {}, // Prevent touches from going through
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.isRecordingLocked)
                  _buildLockedRecordingUI(context)
                else
                  _buildRecordingUI(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordingUI() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              GetBuilder<VoiceRecordingController>(
                builder: (controller) {
                  return Text(
                    controller.getFormattedDuration(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.arrow_back, color: Colors.grey, size: 20),
                  const SizedBox(width: 5),
                  Text(
                    'Slide to cancel',
                    style: regularText(color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.arrow_upward, color: Colors.grey, size: 20),
                  const SizedBox(width: 5),
                  Text(
                    'Lock',
                    style: regularText(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLockedRecordingUI(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, color: Colors.green, size: 20),
              const SizedBox(width: 10),
              Text(
                'Recording locked',
                style: subHeadingText(color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tap buttons below to control',
            style: regularText(size: 12, color: Colors.grey),
          ),
          const SizedBox(height: 15),
          GetBuilder<VoiceRecordingController>(
            builder: (controller) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pulsing dot
                    if (!controller.isPaused)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      controller.getFormattedDuration(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cancel button
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onCancel,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Delete',
                    style: regularText(size: 12, color: Colors.red).copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              // Pause/Resume button
              GetBuilder<VoiceRecordingController>(
                builder: (controller) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          if (controller.isPaused) {
                            controller.resumeRecording();
                          } else if (controller.isRecording) {
                            controller.pauseRecording();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
                          ),
                          child: Icon(
                            controller.isPaused ? Icons.play_arrow : Icons.pause,
                            color: Colors.orange,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        controller.isPaused ? 'Resume' : 'Pause',
                        style: regularText(size: 12, color: Colors.orange).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                },
              ),
              // Send button
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onSend,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.green,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Send',
                    style: regularText(size: 12, color: Colors.green).copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


