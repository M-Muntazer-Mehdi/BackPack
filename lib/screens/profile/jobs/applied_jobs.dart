import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/models/application_model.dart';
import 'package:back_packers/models/item_model.dart';
import 'package:back_packers/screens/profile/jobs/job_details.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/appbars.dart';
import 'package:back_packers/widgets/primary_button.dart';

class AppliedJobs extends StatefulWidget {
  const AppliedJobs({super.key});

  @override
  State<AppliedJobs> createState() => _AppliedJobsState();
}

class _AppliedJobsState extends State<AppliedJobs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: customAppBar(backButton: true, title: 'Applied Jobs'),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: wd(15), vertical: ht(15)),
          children: [
            StreamBuilder<QuerySnapshot<ApplicantModel>>(
                stream: Database.getAppliedJobs(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                        child: Text(
                      // snap.error.toString(),
                      "No Jobs Available",
                      style: subHeadingText(color: Colors.white),
                    ));
                  }
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.data!.docs.isEmpty) {
                    return Center(
                        child: Text(
                      "No Jobs Available",
                      style: subHeadingText(color: Colors.white),
                    ));
                  }

                  return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snap.data!.docs.length,
                      itemBuilder: (context, index) {
                        ApplicantModel? applicantModel =
                            snap.data?.docs[index].data();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: AppColors.bgGrey,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15))),
                          child: StreamBuilder<DocumentSnapshot<ItemModel>>(
                              stream: Database.getSingleItemStream(
                                  applicantModel!.jobId),
                              builder: (context, snap) {
                                ItemModel? jobModel = snap.data?.data();
                                if (snap.hasError) {
                                  return Center(
                                      child: Text(
                                    // snap.error.toString(),
                                    "",
                                    style: subHeadingText(color: Colors.white),
                                  ));
                                }
                                if (!snap.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snap.hasData) {
                                  return ListTile(
                                    onTap: () {
                                      Get.to(() => AppliedJobDetails(
                                            itemModel: jobModel!,
                                            showApplyButton: false,
                                          ));
                                    },
                                    title: Text(
                                      jobModel!.title,
                                      style: regularText(
                                        color: AppColors.colorWhite,
                                      ),
                                    ),
                                    subtitle: Text(
                                      jobModel.description,
                                      style: regularText(
                                          color: AppColors.txtGrey, size: 10),
                                    ),
                                    trailing: Icon(Icons.keyboard_arrow_right,
                                        color: AppColors.borderColor),
                                  );
                                }
                                return Center(
                                    child: Text(
                                  "",
                                  style: subHeadingText(color: Colors.white),
                                ));
                              }),
                        );
                      });
                }),
          ],
        ),
      ),
    );
  }
}
