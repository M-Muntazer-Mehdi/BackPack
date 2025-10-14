import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/chat/voice_recording_controller.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';

class RecordingIndicatorWidget extends StatelessWidget {
  final VoiceRecordingController controller;

  const RecordingIndicatorWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VoiceRecordingController>(
      init: controller,
      builder: (controller) {
        if (!controller.isRecording || controller.isRecordingLocked) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: 0,
          right: 0,
          bottom: 70,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xff383838),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                // Cancel indicator (left)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Slide to cancel',
                        style: regularText(size: 12, color: Colors.red),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Recording indicator with timer (center)
                  Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pulsing red dot
                    _PulsingDot(),
                    const SizedBox(width: 8),
                    // Timer
                    Text(
                      controller.getFormattedDuration(),
                      style: subHeadingText(size: 16, color: Colors.white),
                    ),
                  ],
                ),
                const Spacer(),
                // Lock indicator (right)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_open,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      const Icon(
                        Icons.arrow_upward,
                        color: Colors.white70,
                        size: 14,
                      ),
                      Text(
                        'Lock',
                        style: regularText(size: 10, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

