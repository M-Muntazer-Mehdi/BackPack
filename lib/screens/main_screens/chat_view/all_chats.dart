import 'dart:math' as math;
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

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  TextEditingController search = TextEditingController();
  CollectionReference collection =
      FirebaseFirestore.instance.collection('chats');
  
  late AnimationController _headerAnimController;
  late AnimationController _floatController;
  int selectedCat = 0;

  @override
  void initState() {
    super.initState();
    
    // Header gradient animation
    _headerAnimController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    // Floating animation
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _floatController.dispose();
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Premium header
            _buildHeader(),
            
            // Search bar
            _buildSearchBar(),
            
            // Categories
            _buildCategories(),
            
            // Chat list
            Expanded(
              child: chatList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimController,
      builder: (context, child) {
        return Container(
          clipBehavior: Clip.none,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.85),
                AppColors.primaryColor.withOpacity(0.7),
              ],
              stops: [
                0.0,
                0.5 + (0.2 * math.sin(_headerAnimController.value * 2 * math.pi)),
                1.0,
              ],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Animated floating circles
              Positioned(
                right: -40 + (30 * math.sin(_headerAnimController.value * 2 * math.pi)),
                top: -20 + (20 * math.cos(_headerAnimController.value * 2 * math.pi)),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                    border: Border.all(color: Colors.white.withOpacity(0.12), width: 2),
                  ),
                ),
              ),
              
              Positioned(
                left: -20 + (20 * math.cos(_headerAnimController.value * 2 * math.pi + 1)),
                bottom: -15 + (15 * math.sin(_headerAnimController.value * 2 * math.pi + 1)),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                  ),
                ),
              ),
              
              // Main content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Animated icon badge
                        AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -2 + (4 * _floatController.value)),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.chat_bubble_rounded,
                                  color: AppColors.primaryColor,
                                  size: 26,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        // Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Messages',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Your Chats',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // New message icon
                        AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.95 + (0.05 * _floatController.value),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_rounded, color: Colors.white, size: 11),
                          SizedBox(width: 4),
                          Text(
                            'Stay connected with your buddies',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: search,
          onChanged: (value) => setState(() {}),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.txtDark,
          ),
          decoration: InputDecoration(
            hintText: 'Search chats...',
            hintStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.txtGrey,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.primaryColor,
              size: 22,
            ),
            suffixIcon: search.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: AppColors.txtGrey, size: 20),
                  onPressed: () {
                    search.clear();
                    setState(() {});
                  },
                )
              : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _statusList.length,
        itemBuilder: (context, index) {
          final isSelected = selectedCat == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCat = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withOpacity(0.85),
                        ],
                      )
                    : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                    ? null
                    : Border.all(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                  boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
                ),
                child: Center(
                  child: Text(
                    _statusList[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.primaryColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget chatList() {
    var stream;
    print('🔍 Building chat list for category: ${_statusList[selectedCat]}');
    
    if (selectedCat == 0) {
      stream = collection.where('users',
          arrayContainsAny: [Get.find<UserDetail>().userId])
          .orderBy('timestamp', descending: true)
          .snapshots();
      print('📱 Query: All chats for user: ${Get.find<UserDetail>().userId}');
    } else if (selectedCat == 1) {
      stream = collection
          .where('users', arrayContainsAny: [Get.find<UserDetail>().userId])
          .where('status', isEqualTo: 'accepted')
          .orderBy('timestamp', descending: true)
          .snapshots();
      print('✅ Query: Accepted chats for user: ${Get.find<UserDetail>().userId}');
    } else if (selectedCat == 2) {
      stream = collection
          .where('users', arrayContains: Get.find<UserDetail>().userId)
          .where('status', isEqualTo: 'pending')
          .where('createdBy', isEqualTo: Get.find<UserDetail>().userId)
          .orderBy('timestamp', descending: true)
          .snapshots();
      print('⏳ Query: Pending chats created by user: ${Get.find<UserDetail>().userId}');
    } else if (selectedCat == 3) {
      stream = collection
          .where('users', arrayContains: Get.find<UserDetail>().userId)
          .where('status', isEqualTo: 'rejected')
          .orderBy('timestamp', descending: true)
          .snapshots();
      print('❌ Query: Rejected chats for user: ${Get.find<UserDetail>().userId}');
    } else {
      stream = collection
          .where('users', arrayContains: Get.find<UserDetail>().userId)
          .where('status', isEqualTo: 'pending')
          .where('createdBy', isNotEqualTo: Get.find<UserDetail>().userId)
          .orderBy('timestamp', descending: true)
          .snapshots();
      print('📨 Query: Pending requests for user: ${Get.find<UserDetail>().userId}');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
            child: StreamBuilder<QuerySnapshot>(
                stream: stream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
            print('❌ Chat List Error: ${snapshot.error}');
            return _buildEmptyState('Error loading chats: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
                      ),
                    );
                  }
          if (snapshot.data!.docs.isEmpty) {
            print('📱 No chats found for category: ${_statusList[selectedCat]}');
            return _buildEmptyState('No ${_statusList[selectedCat].toLowerCase()} chats');
          }
          return chats(snapshot);
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 50,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.txtDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start connecting with buddies',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.txtGrey,
            ),
          ),
        ],
      ),
    );
  }

  ListView chats(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 100),
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (BuildContext contextM, index) {
        ChatGroupModel chat =
            ChatGroupModel.fromMap(snapshot.data!.docs[index]);
        GroupChatUser user = chat.user1.id == Get.find<UserDetail>().userId
            ? chat.user2
            : chat.user1;
        if (chat.reportedBy.trim().isNotEmpty) {
          return const SizedBox.shrink();
        }
        return _buildAnimatedChatItem(
          user: user,
          chat: chat,
          search: search.text,
          index: index,
        );
      },
    );
  }

  Widget _buildAnimatedChatItem({
    required GroupChatUser user,
    required ChatGroupModel chat,
    required String search,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 80)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: ChatListItem(
        user: user,
        chat: chat,
        search: search,
      ),
    );
  }

  final List<String> _statusList = [
    'All',
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
    return StreamBuilder<DocumentSnapshot<UserModel>>(
          stream: Database.getSingleUser(widget.user.id),
          builder: (context, snap) {
            String name = snap.hasData
                ? '${snap.data?.data()?.fname ?? ""} ${snap.data?.data()?.lname ?? ''}'
                : widget.user.name;
            String image = snap.hasData ? (snap.data?.data()?.image ?? '') : '';
        
            if (widget.search.isNotEmpty) {
              if (!name.toLowerCase().contains(widget.search.toLowerCase())) {
            return const SizedBox.shrink();
          }
        }
        
        final hasUnread = widget.chat.unreadCount != 0 &&
            widget.chat.lastMessageBy != Get.find<UserDetail>().userId;
        
        return GestureDetector(
          onTap: () {
            Get.to(() => ChatDetailScreen(chat: widget.chat));
            if (hasUnread) {
              FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chat.roomId)
                  .update({'unreadCount': 0});
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: hasUnread
                ? Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    width: 2,
                  )
                : null,
              boxShadow: [
                BoxShadow(
                  color: hasUnread
                    ? AppColors.primaryColor.withOpacity(0.12)
                    : Colors.black.withOpacity(0.04),
                  blurRadius: hasUnread ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
              child: Row(
              children: [
                // Avatar with status indicator
                Stack(
                children: [
                  Container(
                      width: 56,
                      height: 56,
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
                        borderRadius: BorderRadius.circular(28),
                      child: NetworkImageCustom(
                          image: image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Online status indicator
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Chat info
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                            children: [
                              Expanded(
                                  child: Text(
                                name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w700,
                                color: AppColors.txtDark,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                              Text(
                            timeago.format(
                              widget.chat.timestamp.toDate(),
                              locale: 'en_short',
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: hasUnread 
                                ? AppColors.primaryColor 
                                : AppColors.txtGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                                  child: Text(
                              widget.chat.lastMessage.isEmpty 
                                ? 'Tap to start chatting' 
                                : widget.chat.lastMessage,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
                                color: hasUnread 
                                  ? AppColors.txtDark 
                                  : AppColors.txtGrey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryColor,
                                    AppColors.primaryColor.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                                child: Text(
                                  widget.chat.unreadCount.toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                          ],
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



