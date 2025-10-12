import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/container_properties.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/screens/profile/edit_details.dart';
import 'package:back_packers/screens/profile/jobs/applied_jobs.dart';
import 'package:back_packers/screens/profile/my_cv.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/appbars.dart';
import 'package:back_packers/widgets/primary_button.dart';

import 'change_password.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Profile'),
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: wd(25), vertical: ht(30)),
          children: [
            SizedBox(
              height: ht(20),
            ),
            top_box(),
            SizedBox(
              height: ht(40),
            ),
            setting_container(),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0),
              decoration: ContainerProperties.simpleDecoration(
                  color: AppColors.bgGrey, radius: 15),
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      Get.to(() => const AppliedJobs());
                    },
                    // leading: CircleAvatar(
                    //   backgroundColor: Colors.transparent,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(4.0),
                    //     child:
                    //         Icon(Icons.help_outline, color: AppColors.txtGrey),
                    //   ),
                    // ),
                    title: Text(
                      'My Applied Jobs',
                      style: regularText(
                        color: AppColors.txtGrey,
                      ),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right,
                        color: AppColors.borderColor),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0),
              decoration: ContainerProperties.simpleDecoration(
                  color: AppColors.bgGrey, radius: 15),
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      Get.to(() => const MyCVs());
                    },
                    // leading: CircleAvatar(
                    //   backgroundColor: Colors.transparent,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(4.0),
                    //     child:
                    //         Icon(Icons.help_outline, color: AppColors.txtGrey),
                    //   ),
                    // ),
                    title: Text(
                      'My CVs',
                      style: regularText(
                        color: AppColors.txtGrey,
                      ),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right,
                        color: AppColors.borderColor),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: ContainerProperties.simpleDecoration(
                  color: AppColors.bgGrey, radius: 15),
              child: Column(
                children: [
                  // ListTile(
                  //   leading: CircleAvatar(
                  //     backgroundColor: Colors.transparent,
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(4.0),
                  //       child:
                  //           Icon(Icons.help_outline, color: AppColors.txtGrey),
                  //     ),
                  //   ),
                  //   title: Text(
                  //     'Help & Support',
                  //     style: regularText(
                  //       color: AppColors.txtGrey,
                  //     ),
                  //   ),
                  // ),
                  // ListTile(
                  //   leading: CircleAvatar(
                  //     backgroundColor: Colors.transparent,
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(4.0),
                  //       child: Icon(Icons.policy_outlined,
                  //           color: AppColors.txtGrey),
                  //     ),
                  //   ),
                  //   title: Text(
                  //     'Terms & Policies',
                  //     style: regularText(
                  //       color: AppColors.txtGrey,
                  //     ),
                  //   ),
                  // ),
                  // ListTile(
                  //   leading: CircleAvatar(
                  //     backgroundColor: Colors.transparent,
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(4.0),
                  //       child: Icon(Icons.policy_outlined,
                  //           color: AppColors.txtGrey),
                  //     ),
                  //   ),
                  //   title: Text(
                  //     'Report a problem',
                  //     style: regularText(
                  //       color: AppColors.txtGrey,
                  //     ),
                  //   ),
                  // ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: Icon(Icons.account_circle_rounded,
                            color: AppColors.txtGrey),
                      ),
                    ),
                    title: Text(
                      'Delete Account',
                      style: regularText(
                        color: AppColors.txtGrey,
                      ),
                    ),
                    onTap: () {
                      showDeleteAccountDialog(
                        context,
                        () {},
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            PrimaryButton(
                label: 'Logout',
                onPress: () {
                  Get.find<UserDetail>().logout();
                })
          ],
        ),
      ),
    );
  }

  Container setting_container() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: ContainerProperties.simpleDecoration(
          color: AppColors.bgGrey, radius: 15),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              Get.to(() => const EditDetails());
            },
            leading: CircleAvatar(
              backgroundColor: AppColors.colorWhite.withOpacity(0.09),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.person_outlined, color: AppColors.colorWhite),
              ),
            ),
            title: Text(
              'My Account',
              style: subHeadingText(color: AppColors.colorWhite, size: 13),
            ),
            subtitle: Text(
              'Make changes to your account',
              style: regularText(color: AppColors.borderColor, size: 11),
            ),
            trailing:
                Icon(Icons.keyboard_arrow_right, color: AppColors.borderColor),
          ),
          ListTile(
            onTap: () {
              Get.to(() => NewPassword());
            },
            leading: CircleAvatar(
              backgroundColor: AppColors.colorWhite.withOpacity(0.09),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.lock_outlined, color: AppColors.colorWhite),
              ),
            ),
            title: Text(
              'Change Password',
              style: subHeadingText(color: AppColors.colorWhite, size: 13),
            ),
            subtitle: Text(
              'Manage your account security',
              style: regularText(color: AppColors.borderColor, size: 11),
            ),
            trailing:
                Icon(Icons.keyboard_arrow_right, color: AppColors.borderColor),
          ),
          const SizedBox(
            height: 11,
          ),
        ],
      ),
    );
  }

  Container top_box() {
    return Container(
      decoration: ContainerProperties.simpleDecoration(
          color: AppColors.primaryColor, radius: 15),
      padding: EdgeInsets.symmetric(horizontal: ht(25), vertical: ht(18)),
      child: GetBuilder<UserDetail>(builder: (value) {
        return Row(children: [
          Center(
            child: CircleAvatar(
              backgroundColor: AppColors.scaffoldGrey,
              radius: 27,
              child: value.image == ''
                  ? const Icon(Icons.image)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        value.image,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                    ),
            ),
          ),
          SizedBox(
            width: wd(5),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${value.fname} ${value.lname}",
                    style: subHeadingText(color: Colors.white, size: 14),
                  ),
                  Text(
                    "${value.email}",
                    style: regularText(color: AppColors.colorWhite, size: 12),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                Get.to(() => EditDetails());
              },
              child: const Icon(
                Icons.edit,
                size: 30,
                color: Colors.white,
              ),
            ),
          )
        ]);
      }),
    );
  }

  Future<void> showDeleteAccountDialog(
      BuildContext context, VoidCallback onConfirm) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.bgGrey,
          title: const Text(
            'Delete Account',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone, and all your data will be permanently removed.',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without any action
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: AppColors.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteAccount() async {
    EasyLoading.show();
    User? user = FirebaseAuth.instance.currentUser;
    debugPrint("user is : $user");
    if (user != null) {
      try {
        await user.delete();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
        EasyLoading.dismiss();
        EasyLoading.showToast("Account deleted Successfully");
        await Future.delayed(
          const Duration(seconds: 2),
        );
        Get.find<UserDetail>().logout();
      } on FirebaseException catch (exception) {
        EasyLoading.dismiss();
        print("Error deleting user: ${exception.code}");
        if (exception.message != null) {
          EasyLoading.showToast(exception.message!);
        } else {
          EasyLoading.showToast("Something bad Happened Try Again");
        }
        if (exception.code == "requires-recent-login") {
          await Future.delayed(
            const Duration(seconds: 2),
          );
          Get.find<UserDetail>().logout();
        }
      }
    } else {
      EasyLoading.showToast('No user is currently signed in');
      EasyLoading.dismiss();
    }
  }
}
