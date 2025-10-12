import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/globals/container_properties.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/network_image.dart';
import 'package:back_packers/models/group_chat_model.dart';
import 'package:back_packers/models/user.dart';
import 'package:back_packers/screens/main_screens/chat_view/chat_room.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/appbars.dart';
import 'package:back_packers/widgets/text_fields.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  TextEditingController search = TextEditingController();
  CollectionReference collection =
      FirebaseFirestore.instance.collection('chats');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        appBar: customAppBar(title: 'Chats', backButton: false),
        body: chatList());
  }

  Padding chatList() {
    var stream;
    if (selectedCat == 0) {
      stream = collection.where('users',
          arrayContainsAny: [Get.find<UserDetail>().userId]).snapshots();
    } else if (selectedCat == 1) {
      stream = collection
          .where('users', arrayContainsAny: [Get.find<UserDetail>().userId])
          .where('status', isEqualTo: 'accepted')
          .snapshots();
    } else if (selectedCat == 2) {
      stream = collection
          .where('users', arrayContains: Get.find<UserDetail>().userId)
          .where('status', isEqualTo: 'pending')
          .where('createdBy', isEqualTo: Get.find<UserDetail>().userId)
          .snapshots();
    } else if (selectedCat == 3) {
      stream = collection
          .where('users', arrayContains: Get.find<UserDetail>().userId)
          .where('status', isEqualTo: 'rejected')
          .snapshots();
    } else {
      stream = collection
          .where('users', arrayContains: Get.find<UserDetail>().userId)
          .where('status', isEqualTo: 'pending')
          .where('createdBy', isNotEqualTo: Get.find<UserDetail>().userId)
          .snapshots();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          10.hp,
          customTextFiled(
              search,
              FocusNode(),
              [],
              const Icon(
                Icons.search,
                color: Colors.white,
              ),
              hint: 'Search Chats', onchange: (a) {
            setState(() {});
          }),
          categories(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: stream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'No chats',
                        style: normalText(color: Colors.white),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No chats',
                        style: subHeadingText(color: Colors.white),
                      ),
                    );
                  } else {
                    return chats(snapshot);
                  }
                }),
          )
        ],
      ),
    );
  }

  ListView chats(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: snapshot.data!.docs.length,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      itemBuilder: (BuildContext contextM, index) {
        ChatGroupModel chat =
            ChatGroupModel.fromMap(snapshot.data!.docs[index]);
        GroupChatUser user = chat.user1.id == Get.find<UserDetail>().userId
            ? chat.user2
            : chat.user1;
        if (chat.reportedBy.trim().isNotEmpty) {
          return const SizedBox.shrink();
        }
        return ChatListItem(
          user: user,
          chat: chat,
          search: search.text,
        );
      },
    );
  }

  int selectedCat = 0;

  SizedBox categories() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
          separatorBuilder: (ctx, i) => const SizedBox(
                width: 15,
              ),
          scrollDirection: Axis.horizontal,
          itemCount: status.length,
          itemBuilder: (ctx, index) {
            return GestureDetector(
              onTap: () {
                selectedCat = index;
                setState(() {});
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                alignment: Alignment.center,
                decoration: selectedCat == index
                    ? ContainerProperties.shadowDecoration(
                        radius: 10,
                        blurRadius: 5,
                        spreadRadius: 3,
                        color: AppColors.colorWhite)
                    : const BoxDecoration(
                        border:
                            Border(bottom: BorderSide(color: Colors.white))),
                child: Text(status[index],
                    style: headingText(
                        color:
                            index == selectedCat ? Colors.black : Colors.white,
                        size: 12)),
              ),
            );
          }),
    );
  }

  List<String> status = [
    '  All  ',
    'Accepted',
    'Pending',
    'Rejected',
    'Requests'
  ];
}

class ChatListItem extends StatefulWidget {
  const ChatListItem({
    super.key,
    required this.user,
    required this.chat,
    required this.search,
  });

  final GroupChatUser user;
  final ChatGroupModel chat;
  final String search;

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: StreamBuilder<DocumentSnapshot<UserModel>>(
          stream: Database.getSingleUser(widget.user.id),
          builder: (context, snap) {
            String name = snap.hasData
                ? '${snap.data?.data()?.fname ?? ""} ${snap.data?.data()?.lname ?? ''}'
                : widget.user.name;
            String image = snap.hasData ? (snap.data?.data()?.image ?? '') : '';
            if (widget.search.isNotEmpty) {
              if (!name.toLowerCase().contains(widget.search.toLowerCase())) {
                return Container();
              }
            }
            return Container(
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white10))),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 13),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                name,
                                style: subHeadingText(
                                    size: 16, color: Colors.white),
                              )),
                              Text(
                                timeago.format(widget.chat.timestamp.toDate(),
                                    locale: 'en_short'),
                                style: normalText(size: 13, color: Colors.grey),
                              ),

                              // readTimestamp(chat.timestamp)
                            ],
                          )),
                      if (widget.chat.lastMessage != '')
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    widget.chat.lastMessage,
                                    style: normalText(color: Colors.white),
                                  )),
                            ),
                            if (widget.chat.unreadCount != 0 &&
                                widget.chat.lastMessageBy !=
                                    Get.find<UserDetail>().userId)
                              CircleAvatar(
                                radius: 8,
                                backgroundColor: AppColors.primaryColor,
                                child: Text(
                                  widget.chat.unreadCount.toString(),
                                  style: regularText(size: 12)
                                      .copyWith(color: Colors.white),
                                ),
                              )
                          ],
                        ),
                    ],
                  )),
                ],
              ),
            );
          }),
      onTap: () {
        Get.to(() => ChatDetailScreen(
              chat: widget.chat,
            ));
        if (widget.chat.unreadCount != 0 &&
            widget.chat.lastMessageBy != Get.find<UserDetail>().userId) {
          FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.chat.roomId)
              .update({'unreadCount': 0});
        }
      },
    );
  }
}
