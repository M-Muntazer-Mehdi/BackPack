import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/controllers/cv_controller.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/database.dart';
import 'package:back_packers/models/doc_model.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/appbars.dart';
import 'package:url_launcher/url_launcher.dart';

class MyCVs extends StatefulWidget {
  const MyCVs({super.key});

  @override
  State<MyCVs> createState() => _MyCVsState();
}

class _MyCVsState extends State<MyCVs> {
  var controller = Get.put(CvController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: customAppBar(backButton: true, title: "My CV's"),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: wd(15), vertical: ht(15)),
          children: [
            GestureDetector(
              onTap: () {
                controller.uploadDocs(DocType.cv);
              },
              child: Container(
                  height: 120,
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
                      Icon(
                        Icons.upload_file_outlined,
                        color: AppColors.colorWhite,
                      ),
                      Text("Upload CV",
                          style: subHeadingText(
                            color: AppColors.colorWhite,
                          )),
                    ],
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                controller.uploadDocs(DocType.letter);
              },
              child: Container(
                  height: 120,
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
                      Icon(
                        Icons.upload_file_outlined,
                        color: AppColors.colorWhite,
                      ),
                      Text("Upload Cover Letter",
                          style: subHeadingText(
                            color: AppColors.colorWhite,
                          )),
                    ],
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            Text("Saved CV's",
                style: subHeadingText(
                  color: AppColors.colorWhite,
                )),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder<QuerySnapshot<DocModel>>(
                stream: Database.getMyDocs(DocType.cv),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                        child: Text(
                      // snap.error.toString(),
                      "No Cvs Available",
                      style: subHeadingText(color: Colors.white),
                    ));
                  }
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.data!.docs.isEmpty) {
                    return Center(
                        child: Text(
                      "No Cvs Available",
                      style: subHeadingText(color: Colors.white),
                    ));
                  }

                  return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snap.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocModel? docModel = snap.data?.docs[index].data();
                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: AppColors.bgGrey,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  docModel?.name ?? 'Cv',
                                  style: subHeadingText(
                                      color: AppColors.colorWhite),
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      launchUrl(Uri.parse(docModel?.url ?? ''));
                                    },
                                    child: Icon(
                                      Icons.download_outlined,
                                      color: AppColors.colorWhite,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Database.deleteDoc(docModel?.id ?? '');
                                    },
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: AppColors.colorWhite,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      });
                }),
            const SizedBox(
              height: 20,
            ),
            Text("Saved Cover Letters",
                style: subHeadingText(
                  color: AppColors.colorWhite,
                )),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder<QuerySnapshot<DocModel>>(
                stream: Database.getMyDocs(DocType.letter),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                        child: Text(
                      // snap.error.toString(),
                      "No cover letter available",
                      style: subHeadingText(color: Colors.white),
                    ));
                  }
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.data!.docs.isEmpty) {
                    return Center(
                        child: Text(
                      "No cover letter available",
                      style: subHeadingText(color: Colors.white),
                    ));
                  }

                  return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snap.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocModel? docModel = snap.data?.docs[index].data();
                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: AppColors.bgGrey,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  docModel?.name ?? 'Cv',
                                  style: subHeadingText(
                                      color: AppColors.colorWhite),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.download_outlined,
                                    color: AppColors.colorWhite,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.delete_outline,
                                    color: AppColors.colorWhite,
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      });
                }),
          ],
        ),
      ),
    );
  }
}
