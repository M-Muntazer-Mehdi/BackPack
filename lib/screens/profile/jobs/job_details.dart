import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/cv_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/container_properties.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/models/application_model.dart';
import 'package:back_packers/models/doc_model.dart';
import 'package:back_packers/models/item_model.dart';
import 'package:back_packers/screens/other_screens/select_cv.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/appbars.dart';
import 'package:back_packers/widgets/primary_button.dart';

class AppliedJobDetails extends StatefulWidget {
  final ItemModel itemModel;
  final bool showApplyButton;
  final bool isReported;

  const AppliedJobDetails(
      {super.key,
      required this.itemModel,
      this.showApplyButton = false,
      this.isReported = false});

  @override
  State<AppliedJobDetails> createState() => _AppliedJobDetailsState();
}

class _AppliedJobDetailsState extends State<AppliedJobDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: customAppBar(backButton: true, title: 'Job Details'),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: wd(15), vertical: ht(15)),
          children: [
            Align(
              alignment: Alignment.topRight,
              child: !widget.isReported
                  ? TextButton(
                      onPressed: () async {
                        final jobId = widget.itemModel.id;
                        final userId = Get.find<UserDetail>().userId;
                        reportJob(jobId, userId);
                      },
                      child:
                          Text('Report', style: regularText(color: Colors.green)),
                    )
                  : Text('Reported', style: regularText(color: Colors.red)),
            ),
            const SizedBox(
              height: 20,
            ),

            Text(widget.itemModel.title,
                style: headingText(color: AppColors.colorWhite, size: 18)),
            Text(
              widget.itemModel.description,
              style: regularText(size: 12, color: AppColors.borderColor),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              decoration: ContainerProperties.simpleDecoration(
                  color: AppColors.bgGrey, radius: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Description :",
                      style:
                          headingText(color: AppColors.colorWhite, size: 18)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.itemModel.description,
                    style: regularText(size: 12, color: AppColors.borderColor),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              decoration: ContainerProperties.simpleDecoration(
                  color: AppColors.bgGrey, radius: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Location:",
                        style:
                            headingText(color: AppColors.colorWhite, size: 16),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          widget.itemModel.location,
                          style: regularText(color: AppColors.borderColor),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Hourly Rate:",
                        style:
                            headingText(color: AppColors.colorWhite, size: 16),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "\$ ${widget.itemModel.itemDetails['hourlyRate'] ?? 0}",
                        style: regularText(color: AppColors.borderColor),
                      ),
                    ],
                  ),
                  0.hp,
                ],
              ),
            ),
            40.hp,
            // if (widget.showApplyButton)
            !widget.isReported
                ? StreamBuilder<QuerySnapshot<ApplicantModel>>(
                    stream: Database.checkJobAppliedOrNot(widget.itemModel.id),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(
                            child: Text(
                          // snap.error.toString(),
                          "",
                          style: subHeadingText(color: Colors.white),
                        ));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snap.data!.docs.isEmpty) {
                        return PrimaryButton(
                            label: 'Apply',
                            onPress: () {
                              Get.to(
                                  () => SelectCvs(itemModel: widget.itemModel));
                            });
                      }
                      return PrimaryButton(
                          color: Colors.grey, label: 'Applied', onPress: () {});
                    })
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
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
      Get.back();
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
