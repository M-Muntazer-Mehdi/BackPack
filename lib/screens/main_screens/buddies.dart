import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/mainScreen_controllers/store_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/chat_database.dart';
import 'package:back_packers/globals/container_properties.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/network_image.dart';
import 'package:back_packers/models/group_chat_model.dart';
import 'package:back_packers/models/user.dart';
import 'package:back_packers/screens/main_screens/chat_view/chat_room.dart';
import 'package:back_packers/screens/main_screens/store.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/appbars.dart';
import 'package:back_packers/widgets/primary_button.dart';

class Buddies extends StatefulWidget {
  const Buddies({super.key});

  @override
  State<Buddies> createState() => _BuddiesState();
}

class _BuddiesState extends State<Buddies> {
  checkStatus() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: customAppBar(backButton: false, title: 'Buddies'),
      body: GetBuilder<StoreController>(builder: (logic) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: wd(15), vertical: ht(15)),
            child: Column(
              children: [
                radiusNLocation(context),
                20.hp,
                Expanded(
                  child: StreamBuilder<List<DocumentSnapshot<UserModel>>>(
                      stream: Database.getNearByBuddies(logic.latLng, '',
                          radius: logic.radius),
                      builder: (context, snap) {
                        if (snap.hasError) {
                          return Center(
                              child: Text(
                            // snap.error.toString(),
                            "No Buddies Available",
                            style: subHeadingText(color: Colors.white),
                          ));
                        }
                        if (!snap.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snap.data!.isEmpty) {
                          return Center(
                              child: Text(
                            "No Buddies Available",
                            style: subHeadingText(color: Colors.white),
                          ));
                        }

                        return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 70),
                            shrinkWrap: true,
                            itemCount: snap.data?.length,
                            itemBuilder: (context, index) {
                              Get.find<UserDetail>().getData();
                              UserModel? userModel = snap.data?[index].data();
                              if (userModel?.id ==
                                      Get.find<UserDetail>().userId ||
                                  (Get.find<UserDetail>()
                                      .reportedUsers
                                      .contains(userModel?.id))) {
                                return Container();
                              }
                              return buddieContainer(
                                userModel,
                                myId: Get.find<UserDetail>().userId,
                              );
                            });
                      }),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}

Container buddieContainer(
  UserModel? userModel, {
  String? myId,
}) {
  debugPrint("reported users are : ${userModel?.reportedUsers}, and my id is : $myId");
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: ContainerProperties.simpleDecoration(
        color: AppColors.bgGrey, radius: 8),
    child: Column(
      children: [
        6.hp,
        ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: NetworkImageCustom(
                      image: userModel?.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                10.wp,
                Expanded(
                  child: Text(
                    (userModel?.fname ?? '') + " " + (userModel?.lname ?? ''),
                    style: regularText(
                      color: AppColors.colorWhite,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: ContainerProperties.simpleDecoration(
                  color: Colors.white,
                ),
                height: 300,
                child: NetworkImageCustom(
                  image: userModel?.image,
                  fit: BoxFit.cover,
                ))),
        Divider(
          height: 1,
          color: AppColors.borderColor,
        ),
        16.hp,
        // StreamBuilder<
        //         QuerySnapshot<ChatGroupModel>>(
        //     stream: Database.getChatRoomStatus([
        //       userModel?.id,
        //       Get.find<UserDetail>().userId
        //     ]),
        //     builder: (context, snap) {
        //       final querySnapshot = snap.data;
        //       final List<ChatGroupModel>
        //           chatGroups = querySnapshot!.docs
        //               .map((doc) =>
        //                   ChatGroupModel.fromMap(
        //                       doc))
        //               .toList();

        //       if (snap.hasError) {
        //         return Center(
        //             child: Text(
        //           // snap.error.toString(),
        //           "",
        //           style: subHeadingText(
        //               color: Colors.white),
        //         ));
        //       }
        //       if (!snap.hasData) {
        //         return const Center(
        //             child:
        //                 CircularProgressIndicator());
        //       }
        //       if (snap.hasData) {
        //         return Center(
        //             child: Text(
        //           // "has data",
        //           chatGroups.
        //           style: subHeadingText(
        //               color: Colors.white),
        //         ));
        //       }
        //       return Center(
        //           child: Text(
        //         "",
        //         style: subHeadingText(
        //             color: Colors.white),
        //       ));
        //     }),
        // fff
        userModel?.reportedUsers.contains(myId) ?? false
            ? const Text(
                'Blocked',
                style: TextStyle(color: Colors.white, fontSize: 20),
              )
            : StreamBuilder<QuerySnapshot<ChatGroupModel>>(
                stream: Database.getChatRoomStatus(userModel?.id ?? ""),
                builder: (context, snap) {
                  // print(chatGroups);
                  if (snap.hasError) {
                    return Center(child: Container());
                  }
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final querySnapshot = snap.data;
                  if (querySnapshot?.docs.isNotEmpty ?? false) {
                    String label = 'Connect';
                    String status =
                        querySnapshot?.docs.first.data().status ?? "Accepted";
                    if (status == 'rejected') {
                      label = 'Request Rejected';
                    } else if (status == 'accepted') {
                      label = 'Chat Now';
                    } else if (status == 'pending') {
                      label = 'Request Sent';
                    }
                    return PrimaryButton(
                      label: label,
                      onPress: () async {
                        if (status == 'rejected') {
                          return;
                        } else {
                          Get.to(ChatDetailScreen(
                              chat: querySnapshot!.docs.first.data()));
                        }
                      },
                      radius: 8,
                      buttonHight: 40,
                    );
                  }
                  return PrimaryButton(
                    label: 'Connect',
                    onPress: () async {
                      EasyLoading.show();
                      await FireDatabase.createChatRoom(userModel!)
                          .then((id) async {
                        if (id != 'null') {
                          var chatGroupModel = await Database.getSingleChat(id);
                          if (chatGroupModel.exists) {
                            Get.to(() => ChatDetailScreen(
                                  chat: chatGroupModel.data()!,
                                ));
                          }
                        }
                      });

                      EasyLoading.dismiss();
                    },
                    radius: 8,
                    buttonHight: 40,
                  );
                }),

        16.hp,
      ],
    ),
  );
}
