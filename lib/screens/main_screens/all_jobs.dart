import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/cv_controller.dart';
import 'package:back_packers/controllers/mainScreen_controllers/navbar_controller.dart';
import 'package:back_packers/controllers/mainScreen_controllers/store_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/models/item_model.dart';
import 'package:back_packers/screens/main_screens/store.dart';
import 'package:back_packers/screens/profile/jobs/job_details.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/appbars.dart';
import 'package:back_packers/widgets/primary_button.dart';

class AllJobs extends StatefulWidget {
  const AllJobs({super.key});

  @override
  State<AllJobs> createState() => _AllJobsState();
}

class _AllJobsState extends State<AllJobs> {
  var storeController = Get.put(CvController());
  var controller = Get.put(NavBarController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (value) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        appBar: customAppBar(backButton: false, title: 'All Jobs'),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: wd(15), vertical: ht(15)),
            child: Column(
              children: [
                radiusNLocation(context),
                20.hp,
                Expanded(
                  child: StreamBuilder<List<DocumentSnapshot<ItemModel>>>(
                      stream: Database.getNearByJobs(value.latLng,
                          radius: value.radius),
                      builder: (context, snap) {
                        if (snap.hasError) {
                          return Center(
                              child: Text(
                            snap.error.toString(),
                            // "No Jobs Available",
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
                            "No Jobs Available",
                            style: subHeadingText(color: Colors.white),
                          ));
                        }
                        return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: snap.data!.length,
                            itemBuilder: (context, index) {
                              ItemModel? jobModel = snap.data?[index].data();
                              final isReported = jobModel?.reports
                                  .where((report) =>
                                      report['userId'] ==
                                      Get.find<UserDetail>().userId)
                                  .isNotEmpty;
                              return isReported != true
                                  ? Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color:
                                                      AppColors.primaryColor),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10))),
                                          padding: const EdgeInsets.only(
                                              right: 10, left: 10),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                title: Text(
                                                  jobModel!.title,
                                                  style: regularText(
                                                    color: AppColors.colorWhite,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  jobModel.description,
                                                  style: regularText(
                                                      color: AppColors.txtGrey,
                                                      size: 10),
                                                ),
                                              ),
                                              Divider(
                                                height: 1,
                                                color: AppColors.borderColor,
                                              ),
                                              16.hp,
                                              PrimaryButton(
                                                label: 'View',
                                                onPress: () {
                                                  Get.to(() =>
                                                      AppliedJobDetails(
                                                        itemModel: jobModel,
                                                        showApplyButton: true,
                                                        isReported:
                                                            isReported == true,
                                                      ))?.then(
                                                    (value) => setState(() {}),
                                                  );
                                                },
                                                radius: 4,
                                                buttonHight: 45,
                                              ),
                                              16.hp,
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 3.0),
                                            decoration: BoxDecoration(
                                              color: isReported == true
                                                  ? Colors.red
                                                  : Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: const Offset(2, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.flag,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 6.0),
                                                Text(
                                                  isReported == true
                                                      ? "Reported"
                                                      : "Report",
                                                  style: regularText(
                                                      size: 12,
                                                      color:
                                                          AppColors.colorWhite),
                                                ),
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            if (isReported == true) return;
                                            final jobId = jobModel.id;
                                            final userId =
                                                Get.find<UserDetail>().userId;
                                            reportJob(jobId, userId);
                                          },
                                        )
                                      ],
                                    )
                                  : const SizedBox.shrink();
                            });
                      }),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<bool> hasUserReported(String jobId, String userId) async {
    DocumentSnapshot reportSnapshot =
        await FirebaseFirestore.instance.collection('items').doc(jobId).get();
    final data = reportSnapshot.data() as Map;
    final reports = data['reportedBy'] ?? [];
    if (reports.isNotEmpty) {
      final isExist = reports.where((report) => report['userId'] == userId);
      return isExist.isNotEmpty;
    } else {
      return false;
    }
  }

  Future<void> reportJob(String jobId, String userId) async {
    EasyLoading.show();
    debugPrint("job id is : $jobId, and user Id is : $userId");
    bool alreadyReported = await hasUserReported(jobId, userId);
    // debugPrint("job posted status : ------------------> $alreadyReported");
    if (!alreadyReported) {
      await FirebaseFirestore.instance.collection('items').doc(jobId).update({
        'reportedBy': FieldValue.arrayUnion([
          {
            'userId': userId,
            'reportedAt': DateTime.now(),
            'reason': 'reason',
          }
        ])
      });
      EasyLoading.dismiss();
      EasyLoading.showToast('Your report has been sent');
      await checkAndDeleteJobIfReportedMultipleTimes(jobId);
      setState(() {});
    } else {
      print('User has already reported this job.');
      EasyLoading.showToast('You have sent the report already');
      EasyLoading.dismiss();
    }
  }

  Future<void> checkAndDeleteJobIfReportedMultipleTimes(String jobId) async {
    try {
      DocumentSnapshot reportSnapshot =
          await FirebaseFirestore.instance.collection('items').doc(jobId).get();
      // final data = reportSnapshot.data() as Map;
      // debugPrint("report snapshot is : ${data['reports'].length}");
      final data = reportSnapshot.data() as Map;
      final reports = data['reportedBy'] ?? [];
      debugPrint("report snapshot is : ${reports.length}");
      if (reports.length >= 15) {
        await FirebaseFirestore.instance
            .collection('items')
            .doc(jobId)
            .delete();
        print('Job deleted due to multiple reports.');
        EasyLoading.showToast('Job deleted due to multiple reports.');
      }
    } catch (err) {
      debugPrint("error while checking reports : $err");
    }
  }
}
