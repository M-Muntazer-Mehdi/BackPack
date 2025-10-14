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
        backgroundColor: AppColors.scaffoldBackgroundColor,
        body: SafeArea(
            child: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                      10.wp,
                      Expanded(
                        child: StreamBuilder<DocumentSnapshot<UserModel>>(
                            stream: Database.getSingleUser(
                                widget.chat.user1.id ==
                                        Get.find<UserDetail>().userId
                                    ? widget.chat.user2.id
                                    : widget.chat.user1.id),
                            builder: (context, snap) {
                              GroupChatUser user = widget.chat.user1.id ==
                                      Get.find<UserDetail>().userId
                                  ? widget.chat.user2
                                  : widget.chat.user1;
                              String name = snap.hasData
                                  ? '${snap.data?.data()?.fname ?? ""} ${snap.data?.data()?.lname ?? ''}'
                                  : user.name;
                              String image = snap.hasData
                                  ? (snap.data?.data()?.image ?? '')
                                  : '';
                              return Container(
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.white10))),
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        right: 10,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: NetworkImageCustom(
                                            image: image,
                                            fit: BoxFit.cover,
                                            height: 40,
                                            width: 40),
                                      ),
                                    ),
                                    10.wp,
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                  name,
                                                  style: subHeadingText(
                                                      size: 16,
                                                      color: Colors.white),
                                                )),
                                              ],
                                            )),
                                      ],
                                    )),
                                  ],
                                ),
                              );
                            }),
                      ),
                      PopupMenuButton<String>(
                        color: Colors.white,
                        iconColor: Colors.white,
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              child: const Text('Block'),
                              onTap: () {
                                final user = widget.chat.user1.id ==
                                        Get.find<UserDetail>().userId
                                    ? widget.chat.user2
                                    : widget.chat.user1;
                                Database.reportUser(
                                  user.id,
                                  docId: widget.chat.roomId,
                                  myId: Get.find<UserDetail>().userId,
                                ).then(
                                  (value) {
                                    if (value) {
                                      EasyLoading.showToast(
                                          'User has been blocked, you will not receive any message from it');
                                      Get.back();
                                    }
                                  },
                                );
                              },
                            ),
                          ];
                        },
                      )
                    ],
                  ),
                ),
                Expanded(child: messagesV2(context)),
              ],
            ),
            if (widget.chat.status == 'pending' &&
                widget.chat.createdBy != Get.find<UserDetail>().userId)
              Positioned(
                top: 100,
                left: 15,
                right: 15,
                child: Row(
                  children: [
                    Expanded(
                        child: PrimaryButton(
                      label: 'Accept',
                      whiteButton: true,
                      onPress: () {
                        FirebaseFirestore.instance
                            .collection('chats')
                            .doc(widget.chat.roomId)
                            .update({'status': 'accepted'});
                        widget.chat.status = 'accepted';
                        setState(() {});
                      },
                      color: const Color(0xff83FF49),
                    )),
                    20.wp,
                    Expanded(
                        child: PrimaryButton(
                      label: 'Decline',
                      whiteButton: true,
                      onPress: () {
                        FirebaseFirestore.instance
                            .collection('chats')
                            .doc(widget.chat.roomId)
                            .update({'status': 'rejected'});
                        widget.chat.status = 'rejected';
                        setState(() {});
                      },
                      color: const Color(0xffFF4949),
                    )),
                  ],
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
        GetBuilder<ChatDetailController>(builder: (value) {
          return Visibility(
            visible: value.loading || value.isUploadingVoice,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: value.isUploadingVoice ? value.uploadProgress : null,
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
          );
        }),
        Row(
          children: [
            // Attachment button (like WhatsApp) - for documents
            Container(
              margin: const EdgeInsets.only(left: 5),
              child: IconButton(
                icon: Icon(
                  Icons.attach_file,
                  color: Colors.white70,
                  size: 26,
                ),
                onPressed: () {
                  controller.showAttachmentPicker(context);
                },
              ),
            ),
            // Text input field
            Expanded(
              child: Container(
                height: ht(45),
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: const Color(0xff383838).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(100)),
                child: TextField(
                  onTap: () => controller.disableEmoji(),
                  onChanged: controller.changeText,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  style: normalText(color: Colors.white),
                  controller: controller.controllerMessage,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    prefixIconConstraints: const BoxConstraints(minWidth: 35),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Camera icon inside text field
                        IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            controller.showCameraOptions(context);
                          },
                        ),
                      ],
                    ),
                    contentPadding: const EdgeInsets.only(top: 7, left: 15),
                    focusedBorder: AppViews.textFieldRoundBorder(),
                    border: AppViews.textFieldRoundBorder(),
                    disabledBorder: AppViews.textFieldRoundBorder(),
                    focusedErrorBorder: AppViews.textFieldRoundBorder(),
                    hintText: "Type your message...",
                    hintStyle: regularText(color: Colors.grey),
                  ),
                ),
              ),
            ),
            // Send or Mic button
            GetBuilder<ChatDetailController>(builder: (value) {
              // Show send button if there's text, otherwise show mic button
              if (value.showSendButton) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: AppColors.primaryColor, shape: BoxShape.circle),
                  child: InkWell(
                    onTap: () {
                      controller.sendMessage();
                    },
                    child: SizedBox(
                      width: ht(45),
                      height: ht(45),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Icon(
                          Icons.send,
                          color: AppColors.colorWhite,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                // Voice recording button
                return VoiceRecordingButton(
                  controller: controller.voiceRecordingController,
                  onSendVoiceMessage: controller.sendVoiceMessage,
                );
              }
            }),
          ],
        ),
      ],
    );
  }

  Stack messagesV2(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: stream,
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
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
        if (widget.chat.status != 'accepted' &&
            widget.chat.createdBy == Get.find<UserDetail>().userId) ...[
          Column(
            children: [
              Flexible(
                flex: 1,
                child: Container(),
              ),
              Text(
                'You will be able to message when your request is accepted',
                textAlign: TextAlign.center,
                style: regularText(color: Colors.white),
              ),
              20.hp,
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
