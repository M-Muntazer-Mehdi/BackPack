import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/applyJobs_controller.dart';
import 'package:back_packers/controllers/cv_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/globals/enum.dart';
import 'package:back_packers/globals/global.dart';
import 'package:back_packers/models/application_model.dart';
import 'package:back_packers/models/doc_model.dart';
import 'package:back_packers/models/item_model.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/login_details.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/appbars.dart';
import 'package:back_packers/widgets/custom_bottom_option_sheet.dart';
import 'package:back_packers/widgets/primary_button.dart';

class SelectCvs extends StatefulWidget {
  final ItemModel itemModel;

  const SelectCvs({super.key, required this.itemModel});

  @override
  State<SelectCvs> createState() => _SelectCvsState();
}

class _SelectCvsState extends State<SelectCvs> {
  var controller = Get.put(ApplyjobsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        appBar: customAppBar(backButton: true, title: "Job Title"),
        body: GetBuilder<ApplyjobsController>(builder: (value) {
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: wd(15), vertical: ht(15)),
            children: [
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          style: BorderStyle.solid,
                          color: AppColors.colorWhite),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (controller.selectedCV.url == "")
                        Container(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: Column(
                            children: [
                              20.hp,
                              GestureDetector(
                                onTap: () {
                                  controller.uploadDocs(DocType.cv);
                                },
                                child: Text("Upload CV",
                                    style: regularText(
                                      color: AppColors.colorWhite,
                                    ).copyWith(
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white)),
                              ),
                              10.hp,
                              Text("OR",
                                  style: normalText(
                                    color: AppColors.colorWhite,
                                  )),
                              10.hp,
                              GestureDetector(
                                onTap: () async {
                                  QuerySnapshot<DocModel> response =
                                      await Database.getMyDocsFuture(
                                          DocType.cv);
                                  List<QueryDocumentSnapshot<DocModel>> cvs =
                                      response.docs;
                                  if (cvs.isEmpty) {
                                    Global.showToastAlert(
                                        context: Get.overlayContext!,
                                        strTitle: "",
                                        strMsg: 'No saved CV available',
                                        toastType: TOAST_TYPE.toastInfo);
                                    return;
                                  }
                                  // ignore: use_build_context_synchronously
                                  customBottomSheet(
                                      cvs.map((e) => e.data().name).toList(),
                                      -1, (i) {
                                    controller.selectedCV = cvs[i].data();
                                    controller.update();
                                  });
                                },
                                child: Text("Choose saved CV",
                                    style: subHeadingText(
                                      color: AppColors.colorWhite,
                                    ).copyWith(
                                        decoration: TextDecoration.underline,
                                        color: Colors.white,
                                        decorationColor: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      if (controller.selectedCV.url != "")
                        Container(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: Column(
                            children: [
                              20.hp,
                              Text(controller.selectedCV.name,
                                  style: regularText(
                                    color: AppColors.colorWhite,
                                  ).copyWith(
                                      decoration: TextDecoration.underline)),
                              10.hp,
                              Text("OR",
                                  style: normalText(
                                    color: AppColors.colorWhite,
                                  )),
                              10.hp,
                              GestureDetector(
                                  onTap: () async {
                                    controller.selectedCV = DocModel(
                                        id: "", type: "", name: "", url: "");
                                    controller.update();
                                  },
                                  child: Text("Change CV",
                                      style: regularText(
                                        color: AppColors.colorWhite,
                                      ).copyWith(
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white))),
                            ],
                          ),
                        ),
                      20.hp,
                    ],
                  )),
              const SizedBox(
                height: 10,
              ),
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          style: BorderStyle.solid,
                          color: AppColors.colorWhite),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          if (controller.selectedCoverLetter.url == "")
                            Container(
                              padding: EdgeInsets.only(right: 10, left: 10),
                              child: Column(
                                children: [
                                  20.hp,
                                  GestureDetector(
                                    onTap: () {
                                      controller.uploadDocs(DocType.letter);
                                    },
                                    child: Text("Upload Cover letter",
                                        style: regularText(
                                          color: AppColors.colorWhite,
                                        ).copyWith(
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.white)),
                                  ),
                                  10.hp,
                                  Text("OR",
                                      style: normalText(
                                        color: AppColors.colorWhite,
                                      )),
                                  10.hp,
                                  GestureDetector(
                                    onTap: () async {
                                      QuerySnapshot<DocModel> response =
                                          await Database.getMyDocsFuture(
                                              DocType.letter);

                                      List<QueryDocumentSnapshot<DocModel>>
                                          covverLetters = response.docs;
                                      if (covverLetters.isEmpty) {
                                        Global.showToastAlert(
                                            context: Get.overlayContext!,
                                            strTitle: "",
                                            strMsg:
                                                'No saved cover letter available',
                                            toastType: TOAST_TYPE.toastInfo);
                                        return;
                                      }
                                      // ignore: use_build_context_synchronously
                                      customBottomSheet(
                                          covverLetters
                                              .map((e) => e.data().name)
                                              .toList(),
                                          -1, (i) {
                                        controller.selectedCoverLetter =
                                            covverLetters[i].data();
                                        controller.update();
                                      });
                                    },
                                    child: Text("Choose Cover Letter",
                                        style: subHeadingText(
                                          color: AppColors.colorWhite,
                                        ).copyWith(
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.white,
                                            decorationColor: Colors.white)),
                                  ),
                                  20.hp,
                                ],
                              ),
                            ),
                          if (controller.selectedCoverLetter.url != "")
                            Container(
                              padding:
                                  const EdgeInsets.only(right: 10, left: 10),
                              child: Column(
                                children: [
                                  20.hp,
                                  Text(controller.selectedCoverLetter.name,
                                      style: regularText(
                                        color: AppColors.colorWhite,
                                      ).copyWith(
                                          decoration:
                                              TextDecoration.underline)),
                                  10.hp,
                                  Text("OR",
                                      style: normalText(
                                        color: AppColors.colorWhite,
                                      )),
                                  10.hp,
                                  GestureDetector(
                                      onTap: () async {
                                        controller.selectedCoverLetter =
                                            DocModel(
                                                id: "",
                                                type: "",
                                                name: "",
                                                url: "");
                                        controller.update();
                                      },
                                      child: Text("Change Cover Letter",
                                          style: regularText(
                                            color: AppColors.colorWhite,
                                          ).copyWith(
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Colors.white))),
                                  20.hp,
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  )),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Please select one",
                style: subHeadingText(color: AppColors.colorWhite, size: 18),
              ),
              const SizedBox(
                height: 20,
              ),
              GetBuilder<ApplyjobsController>(builder: (value) {
                return Column(
                  children: [
                    CheckboxListTile(
                      side: const BorderSide(color: Colors.white),
                      value: controller.visaStatus,
                      onChanged: (b) {
                        controller.handleVisaStatusChange();
                        controller.update();
                      },
                      title: Text(
                        'I have Visa assistance',
                        style: normalText(color: Colors.white),
                      ),
                    ),
                    CheckboxListTile(
                      value: controller.workingRights,
                      side: const BorderSide(color: Colors.white),
                      onChanged: (b) {
                        controller.handleWorkingRightsChange();
                        controller.update();
                      },
                      title: Text(
                        'I have working right',
                        style: normalText(color: Colors.white),
                      ),
                    )
                  ],
                );
              }),
              30.hp,
              PrimaryButton(
                  label: 'Submit',
                  onPress: () {
                    ApplicantModel applicantModel = ApplicantModel(
                        id: "",
                        coverLetter: controller.selectedCoverLetter.url,
                        jobId: widget.itemModel.id,
                        cv: controller.selectedCV.url,
                        visaStatus: controller.visaStatus,
                        workingRights: controller.workingRights,
                        userId: Get.find<UserDetail>().userId);

                    controller.handleApplyJob(applicantModel);
                  })
            ],
          );
        }));
  }
}
