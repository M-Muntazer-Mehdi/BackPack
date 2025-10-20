import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/mainScreen_controllers/store_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/chat_database.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/globals/network_image.dart';
import 'package:back_packers/models/group_chat_model.dart';
import 'package:back_packers/models/user.dart';
import 'package:back_packers/screens/main_screens/chat_view/chat_room.dart';
import 'package:back_packers/screens/main_screens/store.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';

class Buddies extends StatefulWidget {
  const Buddies({super.key});

  @override
  State<Buddies> createState() => _BuddiesState();
}

class _BuddiesState extends State<Buddies> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: SafeArea(
        child: GetBuilder<StoreController>(
          builder: (logic) {
            return Column(
              children: [
                // Modern header
                _buildHeader(),
                
                // Location controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: radiusNLocation(context),
                ),
                
                const SizedBox(height: 20),
                
                // Buddies list
                Expanded(
                  child: StreamBuilder<List<DocumentSnapshot<UserModel>>>(
                    stream: Database.getNearByBuddies(
                      logic.latLng,
                      '',
                      radius: logic.radius,
                    ),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return _buildEmptyState('No Buddies Available');
                      }
                      if (!snap.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        );
                      }
                      if (snap.data!.isEmpty) {
                        return _buildEmptyState('No Buddies Nearby');
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: snap.data?.length,
                        itemBuilder: (context, index) {
                          UserModel? userModel = snap.data?[index].data();
                          
                          // Filter out self and reported users
                          if (userModel?.id == Get.find<UserDetail>().userId ||
                              Get.find<UserDetail>().reportedUsers.contains(userModel?.id)) {
                            return const SizedBox.shrink();
                          }
                          
                          return _buildBuddieCard(
                            userModel,
                            myId: Get.find<UserDetail>().userId,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.people_rounded,
            color: AppColors.primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find Buddies',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                'Connect with travelers nearby',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.txtGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 60,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.txtDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search radius',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.txtGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuddieCard(UserModel? userModel, {String? myId}) {
    final isBlocked = userModel?.reportedUsers.contains(myId) ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: NetworkImageCustom(
                      image: userModel?.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${userModel?.fname ?? ''} ${userModel?.lname ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.txtGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Nearby',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.txtGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Profile image
          Container(
            height: 280,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.bgGrey,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: NetworkImageCustom(
                image: userModel?.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: isBlocked
              ? _buildBlockedButton()
              : _buildConnectionButton(userModel),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.errorRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block_rounded,
              size: 18,
              color: AppColors.errorRed,
            ),
            const SizedBox(width: 8),
            Text(
              'Blocked',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.errorRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionButton(UserModel? userModel) {
    return StreamBuilder<QuerySnapshot<ChatGroupModel>>(
      stream: Database.getChatRoomStatus(userModel?.id ?? ""),
      builder: (context, snap) {
        if (snap.hasError) return const SizedBox.shrink();
        if (!snap.hasData) {
          return Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            ),
          );
        }

        final querySnapshot = snap.data;
        
        if (querySnapshot?.docs.isNotEmpty ?? false) {
          String status = querySnapshot?.docs.first.data().status ?? "accepted";
          return _buildStatusButton(status, querySnapshot!.docs.first.data());
        }
        
        return _buildConnectButton(userModel);
      },
    );
  }

  Widget _buildStatusButton(String status, ChatGroupModel chat) {
    String label;
    Color bgColor;
    Color textColor;
    IconData icon;
    bool isDisabled = false;
    
    switch (status) {
      case 'rejected':
        label = 'Request Rejected';
        bgColor = AppColors.errorRed.withOpacity(0.1);
        textColor = AppColors.errorRed;
        icon = Icons.cancel_rounded;
        isDisabled = true;
        break;
      case 'accepted':
        label = 'Chat Now';
        bgColor = AppColors.successGreen;
        textColor = Colors.white;
        icon = Icons.chat_bubble_rounded;
        break;
      case 'pending':
        label = 'Request Sent';
        bgColor = AppColors.warningYellow.withOpacity(0.1);
        textColor = AppColors.warningYellow;
        icon = Icons.schedule_rounded;
        isDisabled = true;
        break;
      default:
        label = 'Connect';
        bgColor = AppColors.primaryColor;
        textColor = Colors.white;
        icon = Icons.person_add_rounded;
    }
    
    return GestureDetector(
      onTap: isDisabled ? null : () {
        Get.to(() => ChatDetailScreen(chat: chat));
      },
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: !isDisabled
            ? [
                BoxShadow(
                  color: bgColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectButton(UserModel? userModel) {
    return GestureDetector(
      onTap: () async {
        EasyLoading.show();
        await FireDatabase.createChatRoom(userModel!).then((id) async {
          if (id != 'null') {
            var chatGroupModel = await Database.getSingleChat(id);
            if (chatGroupModel.exists) {
              Get.to(() => ChatDetailScreen(chat: chatGroupModel.data()!));
            }
          }
        });
        EasyLoading.dismiss();
      },
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.person_add_rounded, size: 20, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Connect',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
