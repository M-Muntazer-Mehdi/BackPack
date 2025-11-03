import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/models/local_chat_model.dart';
import 'package:back_packers/models/chat_model.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/controllers/chat/audio_player_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'image_view.dart';
import 'images_list.dart';
import 'voice_message_bubble.dart';
import 'video_message_bubble.dart';
import 'document_message_bubble.dart';
import 'location_message_bubble.dart';

class ChatListItem extends StatelessWidget {
  final LocalChatModel mChatModel;
  final Function onTap;
  final AudioPlayerController? audioPlayerController;

  const ChatListItem({
    Key? key, 
    required this.mChatModel, 
    required this.onTap,
    this.audioPlayerController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if this is a voice message
    if (mChatModel.messageType == MessageType.voice && 
        mChatModel.voiceData != null &&
        audioPlayerController != null) {
      return VoiceMessageBubble(
        voiceData: mChatModel.voiceData!,
        msgType: mChatModel.mMsgType,
        time: mChatModel.time,
        playerController: audioPlayerController!,
      );
    }

    // Check if this is a video message
    if (mChatModel.messageType == MessageType.video && 
        mChatModel.voiceData != null) {
      return VideoMessageBubble(
        videoData: mChatModel.voiceData!,
        msgType: mChatModel.mMsgType,
        time: mChatModel.time,
      );
    }

    // Check if this is a document message
    if (mChatModel.messageType == MessageType.document && 
        mChatModel.voiceData != null) {
      return DocumentMessageBubble(
        documentData: mChatModel.voiceData!,
        msgType: mChatModel.mMsgType,
        time: mChatModel.time,
      );
    }

    // Check if this is a location message
    if (mChatModel.messageType == MessageType.location && 
        mChatModel.voiceData != null) {
      return LocationMessageBubble(
        locationData: mChatModel.voiceData!,
        msgType: mChatModel.mMsgType,
        time: mChatModel.time,
      );
    }

    // Otherwise render normal text/image message
    Widget mWidget = Container();
    switch (mChatModel.mMsgType) {
      case MsgType.left:
        mWidget = Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                child: Container(
              margin: const EdgeInsets.only(right: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  mChatModel.status == 'Reported'
                      ? Row(
                          children: [
                            const Icon(Icons.flag, color: Colors.red, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Reported',
                              style: regularText(size: 12)
                                  .copyWith(color: Colors.red),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          showImages(context),
                          if (mChatModel.message.isNotEmpty)
                          Text(
                            mChatModel.message,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.txtDark,
                                height: 1.4,
                              ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            timeago.format(mChatModel.time.toDate(),
                                locale: 'en_short'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.txtGrey,
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            )),
          ],
        );
        break;
      case MsgType.right:
        mWidget = Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                child: Container(
              margin: const EdgeInsets.only(left: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  mChatModel.status == 'Reported'
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.flag, color: Colors.red, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Reported',
                              style: regularText(size: 12)
                                  .copyWith(color: Colors.red),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.9),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          showImages(context),
                          Text(
                            mChatModel.message,
                            style: regularText(size: 16)
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            timeago.format(mChatModel.time.toDate(),
                                locale: 'en_short'),
                            style: regularText(size: 10)
                                .copyWith(color: Colors.grey),
                          )
                        ],
                      )),
                ],
              ),
            )),
          ],
        );
        break;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: mWidget,
    );
  }

  Visibility showImages(BuildContext context) {
    return Visibility(
        visible: mChatModel.files.isNotEmpty ? true : false,
        child: mChatModel.files.length == 1
            ? InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ImageView(mChatModel.files.first)));
                },
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 250,
                    maxHeight: 250,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: mChatModel.files.first,
                  fit: BoxFit.cover,
                      width: 250,
                      height: 250,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                        color: Colors.grey,
                        backgroundColor: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.error,
                      size: 18,
                        ),
                      ),
                    ),
                  ),
                ))
            : InkWell(
                onTap: () {
                  mChatModel.files.length >= 2
                      ? Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ImagesList(
                                images: mChatModel.files,
                              )))
                      : () {};
                },
                child: IgnorePointer(
                  child: GridView.builder(
                      padding: const EdgeInsets.only(bottom: 10),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: mChatModel.files.length > 4
                          ? 4
                          : mChatModel.files.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              childAspectRatio: 3 / 3,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5),
                      itemBuilder: (ctx, index) {
                        return index == 3
                            ? Blur(
                                blur: 0,
                                blurColor: Colors.black87,
                                overlay: Center(
                                    child: Text(
                                  "+${mChatModel.files.length - 3}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                )),
                                child: CachedNetworkImage(
                                  imageUrl: mChatModel.files[index],
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: downloadProgress.progress,
                                        color: Colors.grey,
                                        backgroundColor: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.error,
                                      size: 18,
                                    ),
                                  ),
                                ))
                            : CachedNetworkImage(
                                imageUrl: mChatModel.files[index],
                                fit: BoxFit.cover,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.grey,
                                      value: downloadProgress.progress,
                                      backgroundColor: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.error,
                                    size: 18,
                                  ),
                                ),
                              );
                      }),
                ),
              ));
  }
}
