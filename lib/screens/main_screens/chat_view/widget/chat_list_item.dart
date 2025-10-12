import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/models/local_chat_model.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'image_view.dart';
import 'images_list.dart';

class ChatListItem extends StatelessWidget {
  final LocalChatModel mChatModel;
  final Function onTap;

  const ChatListItem({Key? key, required this.mChatModel, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget mWidget = Container();
    switch (mChatModel.mMsgType) {
      case MsgType.left:
        mWidget = Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                child: Container(
              margin: const EdgeInsets.only(right: 80),
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
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30),
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
      case MsgType.right:
        mWidget = Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                child: Container(
              margin: const EdgeInsets.only(left: 80),
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
                        color: AppColors.primaryColor.withOpacity(0.3),
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
      margin: const EdgeInsets.all(5),
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
                child: CachedNetworkImage(
                  imageUrl: mChatModel.files.first,
                  fit: BoxFit.cover,
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
                      itemCount: mChatModel.files.length > 4
                          ? 4
                          : mChatModel.files.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
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
