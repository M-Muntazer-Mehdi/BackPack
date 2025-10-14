import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/chat/voice_recording_controller.dart';
import 'package:back_packers/utils/app_colors.dart';

class VoiceRecordingButton extends StatefulWidget {
  final VoidCallback onSendVoiceMessage;
  final VoiceRecordingController controller;

  const VoiceRecordingButton({
    Key? key,
    required this.onSendVoiceMessage,
    required this.controller,
  }) : super(key: key);

  @override
  State<VoiceRecordingButton> createState() => _VoiceRecordingButtonState();
}

class _VoiceRecordingButtonState extends State<VoiceRecordingButton>
    with SingleTickerProviderStateMixin {
  double _offset = 0.0;
  bool _isCancelled = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VoiceRecordingController>(
      init: widget.controller,
      builder: (controller) {
        return GestureDetector(
          onLongPressStart: _onLongPressStart,
          onLongPressMoveUpdate: _onLongPressMoveUpdate,
          onLongPressEnd: _onLongPressEnd,
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: controller.isRecording
                  ? Colors.red
                  : AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: controller.isRecording
                ? AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 24,
                        ),
                      );
                    },
                  )
                : const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 24,
                  ),
          ),
        );
      },
    );
  }

  void _onLongPressStart(LongPressStartDetails details) async {
    final success = await widget.controller.startRecording();
    if (success) {
      setState(() {
        _offset = 0.0;
        _isCancelled = false;
      });
    }
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!widget.controller.isRecording) return;

    setState(() {
      _offset = details.localOffsetFromOrigin.dx;
    });

    // Slide to cancel (left)
    if (_offset < -100 && !_isCancelled) {
      _isCancelled = true;
      widget.controller.cancelRecording();
      _showCancelFeedback();
    }
    // Slide up to lock
    else if (details.localOffsetFromOrigin.dy < -100 &&
        !widget.controller.isRecordingLocked) {
      widget.controller.lockRecording();
      _showLockFeedback();
    }
  }

  void _onLongPressEnd(LongPressEndDetails details) async {
    if (!widget.controller.isRecording &&
        !widget.controller.isRecordingLocked) {
      return;
    }

    if (_isCancelled) {
      return;
    }

    // If locked, don't send on release
    if (widget.controller.isRecordingLocked) {
      return;
    }

    // Stop and send
    final path = await widget.controller.stopRecording();
    if (path != null) {
      widget.onSendVoiceMessage();
    }

    setState(() {
      _offset = 0.0;
      _isCancelled = false;
    });
  }

  void _showCancelFeedback() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording cancelled'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _showLockFeedback() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording locked - tap send when done'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}


