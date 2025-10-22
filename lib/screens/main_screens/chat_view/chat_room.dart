import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/chat/chat_detail_controller.dart';
import 'package:back_packers/controllers/chat/voice_recording_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/app_views.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/global.dart';
import 'package:back_packers/globals/network_image.dart';
import 'package:back_packers/models/chat_model.dart';
import 'package:back_packers/models/group_chat_model.dart';
import 'package:back_packers/models/local_chat_model.dart';
import 'package:back_packers/models/user.dart';
import 'package:back_packers/screens/main_screens/chat_view/widget/chat_list_item.dart';
import 'package:back_packers/screens/main_screens/chat_view/widget/voice_recording_button.dart';
import 'package:back_packers/screens/main_screens/chat_view/widget/recording_overlay_widget.dart';
import 'package:back_packers/screens/main_screens/chat_view/widget/recording_indicator_widget.dart';
import 'package:back_packers/services/local_notifications_helper.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/primary_button.dart';

class ChatDetailScreen extends StatefulWidget {
  ChatGroupModel chat;

  ChatDetailScreen({Key? key, required this.chat}) : super(key: key);

  @override
  ChatDetailScreenState createState() => ChatDetailScreenState();
}

class ChatDetailScreenState extends State<ChatDetailScreen> {
  var controller = Get.put(ChatDetailController());

  late Stream<QuerySnapshot> stream;

  @override
  void initState() {
    super.initState();
    
    controller.id = widget.chat.roomId;
    
    // Get the other user's ID safely
    try {
      final currentUserId = Get.find<UserDetail>().userId;
      controller.userId = widget.chat.user1?.id == currentUserId
          ? (widget.chat.user2?.id ?? widget.chat.roomId)
          : (widget.chat.user1?.id ?? widget.chat.roomId);
    } catch (e) {
      // Fallback to room ID if there's any issue
      controller.userId = widget.chat.roomId;
    }
    
    stream = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chat.roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.bgGrey,
        body: SafeArea(
            child: Stack(
          children: [
            Column(
              children: [
                // Premium Chat Header
                _buildChatHeader(),
                Expanded(child: messagesV2(context)),
              ],
            ),
            if (widget.chat.status == 'pending' &&
                widget.chat.createdBy != Get.find<UserDetail>().userId)
              Positioned(
                top: 80,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_rounded,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'New Connection Request',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.txtDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                  children: [
                    Expanded(
                            child: GestureDetector(
                              onTap: () {
                        FirebaseFirestore.instance
                            .collection('chats')
                            .doc(widget.chat.roomId)
                            .update({'status': 'accepted'});
                        widget.chat.status = 'accepted';
                        setState(() {});
                      },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.shade400,
                                      Colors.green.shade500,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Accept',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                    Expanded(
                            child: GestureDetector(
                              onTap: () {
                        FirebaseFirestore.instance
                            .collection('chats')
                            .doc(widget.chat.roomId)
                            .update({'status': 'rejected'});
                        widget.chat.status = 'rejected';
                        setState(() {});
                      },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.errorRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.errorRed.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cancel_rounded, color: AppColors.errorRed, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Decline',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.errorRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            // Recording overlay (locked state) - MUST be last to be on top
            GetBuilder<VoiceRecordingController>(
              init: controller.voiceRecordingController,
              builder: (recordController) {
                // Only show when recording is LOCKED
                if (recordController.isRecordingLocked) {
                  return Positioned.fill(
                    child: RecordingOverlayWidget(
                      controller: controller.voiceRecordingController,
                      onSend: controller.handleLockedVoiceSend,
                      onCancel: controller.cancelVoiceRecording,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        )));
  }

  // Stack messages(BuildContext context) {
  //   return Stack(
  //     children: [
  //       Column(
  //         children: [
  //           Expanded(
  //             child: StreamBuilder<QuerySnapshot>(
  //                 stream: stream,
  //                 builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //                   if (snapshot.hasError) {
  //                     return const Text('Something went wrong');
  //                   }
  //                   if (snapshot.connectionState == ConnectionState.waiting) {
  //                     return const SizedBox();
  //                   }
  //
  //                   return ListView.builder(
  //                     padding: const EdgeInsets.all(10),
  //                     reverse: true,
  //                     itemCount: snapshot.data!.docs.length,
  //                     itemBuilder: (BuildContext contextM, index) {
  //                       ChatModel chatModel =
  //                           ChatModel.fromMap(snapshot.data!.docs[index]);
  //
  //                       LocalChatModel chat = LocalChatModel(
  //                           time: chatModel.timeStamp,
  //                           message: chatModel.message,
  //                           files: chatModel.files,
  //                           mMsgType:
  //                               chatModel.from == Get.find<UserDetail>().userId
  //                                   ? MsgType.right
  //                                   : MsgType.left);
  //
  //                       return ChatListItem(
  //                         mChatModel: chat,
  //                         onTap: () {},
  //                       );
  //                     },
  //                   );
  //                 }),
  //           ),
  //           const SizedBox(
  //             height: 20,
  //           ),
  //           GetBuilder<ChatDetailController>(builder: (value) {
  //             return SizedBox(
  //               height: value.isShowEmojis ? 260 : 60,
  //             );
  //           })
  //         ],
  //       ),
  //       if (widget.chat.status != 'accepted' &&
  //           widget.chat.createdBy == Get.find<UserDetail>().userId) ...[
  //         Column(
  //           children: [
  //             Flexible(
  //               flex: 1,
  //               child: Container(),
  //             ),
  //             Text(
  //               'You will be able to message when your request is accepted',
  //               textAlign: TextAlign.center,
  //               style: regularText(color: Colors.white),
  //             ),
  //             20.hp,
  //           ],
  //         ),
  //       ],
  //       if (widget.chat.status == 'accepted')
  //         Column(
  //           children: [
  //             Flexible(
  //               flex: 1,
  //               child: Container(),
  //             ),
  //             _textField(context),
  //             _emojiSection()
  //           ],
  //         ),
  //
  //       // AppViews.showLoadingWithStatus(isShowLoader)
  //     ],
  //   );
  // }

  GetBuilder<ChatDetailController> _emojiSection() {
    return GetBuilder<ChatDetailController>(builder: (value) {
      return Visibility(
          visible: value.isShowEmojis,
          child: SizedBox(
            height: 200,
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Wrap(
                  runAlignment: WrapAlignment.start,
                  alignment: WrapAlignment.center,
                  runSpacing: 10,
                  spacing: 10,
                  children: List.generate(
                      value.emojis.length,
                      (index) => InkWell(
                            onTap: () {
                              value.addEmojis(value.emojis[index]);
                            },
                            child: Text(
                              value.emojis[index],
                              style: const TextStyle(fontSize: 27),
                            ),
                          )),
                )
              ],
            ),
          ));
    });
  }

  Column _textField(BuildContext context) {
    return Column(
      children: [
        // Upload progress indicator
        GetBuilder<ChatDetailController>(builder: (value) {
          return Visibility(
            visible: value.loading || value.isUploadingVoice,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: value.isUploadingVoice ? value.uploadProgress : null,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
                ),
              ),
            ),
          );
        }),
        // Input area
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
          children: [
              // Attachment button
              GestureDetector(
                onTap: () => controller.showAttachmentPicker(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            // Text input field
            Expanded(
              child: Container(
                  constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.bgGrey,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                child: TextField(
                  onTap: () => controller.disableEmoji(),
                  onChanged: controller.changeText,
                  controller: controller.controllerMessage,
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.txtDark,
                            height: 1.4,
                          ),
                  decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type a message...",
                            hintStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.txtGrey,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      // Camera button
                      GestureDetector(
                        onTap: () => controller.showCameraOptions(context),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
            // Send or Mic button
            GetBuilder<ChatDetailController>(builder: (value) {
              if (value.showSendButton) {
                  return GestureDetector(
                    onTap: () => controller.sendMessage(),
                    child: Container(
                      width: 44,
                      height: 44,
                  decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withOpacity(0.85),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                    ),
                  ),
                );
              } else {
                return VoiceRecordingButton(
                  controller: controller.voiceRecordingController,
                  onSendVoiceMessage: controller.sendVoiceMessage,
                );
              }
            }),
          ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.txtDark,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: StreamBuilder<DocumentSnapshot<UserModel>>(
              stream: Database.getSingleUser(
                widget.chat.user1.id == Get.find<UserDetail>().userId
                    ? widget.chat.user2.id
                    : widget.chat.user1.id
              ),
              builder: (context, snap) {
                GroupChatUser user = widget.chat.user1.id == Get.find<UserDetail>().userId
                    ? widget.chat.user2
                    : widget.chat.user1;
                String name = snap.hasData
                    ? '${snap.data?.data()?.fname ?? ""} ${snap.data?.data()?.lname ?? ''}'
                    : user.name;
                String image = snap.hasData ? (snap.data?.data()?.image ?? '') : '';
                
                return Row(
                  children: [
                    // Avatar with gradient ring
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColor.withOpacity(0.3),
                            AppColors.primaryColor.withOpacity(0.1),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: NetworkImageCustom(
                          image: image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name and status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.txtDark,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Online',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Menu button
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                color: AppColors.txtDark,
                size: 20,
              ),
            ),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.block_rounded, color: AppColors.errorRed, size: 20),
                      const SizedBox(width: 12),
                      const Text('Block User'),
                    ],
                  ),
                  onTap: () {
                    final user = widget.chat.user1.id == Get.find<UserDetail>().userId
                        ? widget.chat.user2
                        : widget.chat.user1;
                    Database.reportUser(
                      user.id,
                      docId: widget.chat.roomId,
                      myId: Get.find<UserDetail>().userId,
                    ).then((value) {
                      if (value) {
                        EasyLoading.showToast(
                          'User has been blocked, you will not receive any message from it'
                        );
                        Get.back();
                      }
                    });
                  },
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  Stack messagesV2(BuildContext context) {
    return Stack(
      children: [
        // Chat background with subtle pattern
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgGrey,
            image: DecorationImage(
              image: const AssetImage('assets/images/chat_pattern.png'),
              fit: BoxFit.cover,
              opacity: 0.03,
              onError: (exception, stackTrace) {
                // If pattern image doesn't exist, just use solid color
              },
            ),
          ),
          child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: stream,
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Something went wrong',
                            style: TextStyle(
                              color: AppColors.txtGrey,
                              fontSize: 14,
                            ),
                          ),
                        );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        );
                      }

                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 60,
                                color: AppColors.txtGrey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.txtGrey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start the conversation!',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.txtGrey.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                    }

                    return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext contextM, index) {
                        ChatModel chatModel =
                            ChatModel.fromMap(snapshot.data!.docs[index]);

                        LocalChatModel chat = LocalChatModel(
                            time: chatModel.timeStamp,
                            message: chatModel.message,
                            files: chatModel.files,
                            status: chatModel.status ?? 'Active',
                            messageType: chatModel.messageType,
                            voiceData: chatModel.voiceData,
                            mMsgType:
                                chatModel.from == Get.find<UserDetail>().userId
                                    ? MsgType.right
                                    : MsgType.left);
                        return GestureDetector(
                          onLongPress: () {
                            chatModel.from != Get.find<UserDetail>().userId
                                ? chatModel.status == 'Reported'
                                    ? Global.showToastAlert(
                                        context: Get.overlayContext!,
                                        strTitle: "ok",
                                        strMsg:
                                            'Message has been reported already',
                                        toastType: TOAST_TYPE.toastError)
                                    : showReportDialog(
                                        context,
                                        chatModel,
                                        messageId:
                                            snapshot.data?.docs[index].id ?? '',
                                      )
                                : null;
                          },
                          child: ChatListItem(
                            mChatModel: chat,
                            onTap: () {},
                            audioPlayerController: controller.audioPlayerController,
                          ),
                        );
                      },
                    );
                  }),
            ),
            const SizedBox(
              height: 20,
            ),
            GetBuilder<ChatDetailController>(builder: (value) {
              return SizedBox(
                height: value.isShowEmojis ? 260 : 60,
              );
            })
          ],
          ),
        ),
        if (widget.chat.status != 'accepted' &&
            widget.chat.createdBy == Get.find<UserDetail>().userId) ...[
          Column(
            children: [
              Flexible(
                flex: 1,
                child: Container(),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: AppColors.warningYellow,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Waiting for response...\nYou can message when accepted',
                textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.txtDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
        if (widget.chat.status == 'accepted')
          Column(
            children: [
              Flexible(
                flex: 1,
                child: Container(),
              ),
              _textField(context),
              _emojiSection()
            ],
          ),
        // Recording indicator (unlocked state)
        RecordingIndicatorWidget(
          controller: controller.voiceRecordingController,
        ),
      ],
    );
  }

  void showReportDialog(
    BuildContext context,
    ChatModel chatModel, {
    required String messageId,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Message'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Why are you reporting this message?'),
              ListTile(
                title: const Text('Inappropriate Content'),
                onTap: () => reportMessage(
                  context,
                  chatModel,
                  reason: 'Inappropriate Content',
                  messageId: messageId,
                ),
              ),
              ListTile(
                title: const Text('Harassment'),
                onTap: () => reportMessage(
                  context,
                  chatModel,
                  reason: 'Harassment',
                  messageId: messageId,
                ),
              ),
              ListTile(
                title: const Text('Spam'),
                onTap: () => reportMessage(
                  context,
                  chatModel,
                  reason: 'Spam',
                  messageId: messageId,
                ),
              ),
              ListTile(
                title: const Text('Other'),
                onTap: () => reportMessage(
                  context,
                  chatModel,
                  reason: 'Other',
                  messageId: messageId,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> reportMessage(
    BuildContext context,
    ChatModel chatModel, {
    required String messageId,
    required String reason,
  }) async {
    Navigator.of(context).pop();
    EasyLoading.show();
    String userId = Get.find<UserDetail>().userId;
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chat.roomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'reportedBy': userId,
        'reportReason': reason,
        'status': 'Reported'
      });
      EasyLoading.dismiss();
      EasyLoading.showToast('Message has been reported');
      await Future.delayed(const Duration(seconds: 2));
      LocalNotificationChannel.display(
        const RemoteMessage(
          notification: RemoteNotification(
            title: 'Report Received',
            body:
                'Message Report has been received, we will take necessary actions on the content base',
          ),
        ),
      );
    } catch (err) {
      EasyLoading.dismiss();
      debugPrint("error while reporting message is : $err");
    }
  }
}
