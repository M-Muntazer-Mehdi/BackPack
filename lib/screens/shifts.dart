import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/container_properties.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/primary_button.dart';

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: wd(25)),
          child: Column(
            children: [
              SizedBox(
                height: ht(35),
              ),
              searchBar(),
              const SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Jobs list',
                      style:
                          headingText(size: 24, color: AppColors.primaryColor),
                    ),
                  ),
                  Container(
                    decoration: ContainerProperties.simpleDecoration(
                        radius: 6, color: HexColor('#F3F3F3')),
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          decoration: ContainerProperties.shadowDecoration(),
                          height: ht(50),
                          width: wd(75),
                          child:
                              Text('Oldest', style: subHeadingText(size: 11)),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: ht(50),
                          width: wd(75),
                          child: Text(
                            'Newest',
                            style: subHeadingText(size: 11),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(
                          height: 15,
                        ),
                    shrinkWrap: true,
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      return JobContaner(
                        ontap: () {
                          Get.bottomSheet(BottomSheetDetails(),
                              isScrollControlled: true);
                        },
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Row searchBar() {
    return Row(
      children: [
        Container(
          height: ht(50),
          width: ht(50),
          decoration: ContainerProperties.simpleDecoration(
              radius: 100, color: Colors.green),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: ht(50),
            width: double.infinity,
            decoration: ContainerProperties.borderDecoration(radius: 100)
                .copyWith(color: AppColors.primaryColor.withOpacity(0.09)),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    child: Text(
                  'Search by location...',
                  style: regularText(color: AppColors.primaryColor),
                )),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 30,
                  color: AppColors.primaryColor,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BottomSheetDetails extends StatefulWidget {
  const BottomSheetDetails({
    super.key,
  });

  @override
  State<BottomSheetDetails> createState() => _BottomSheetDetailsState();
}

class _BottomSheetDetailsState extends State<BottomSheetDetails> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ht(600),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          color: Colors.black),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        padding: const EdgeInsets.all(10),
                        child: Icon(Icons.keyboard_arrow_left)),
                  ),
                ),
              ),
              Text(
                'Waikato Hospital',
                style: headingText(size: 22, color: AppColors.primaryColor),
              ),
              Spacer()
            ],
          ),
          SizedBox(
            height: ht(40),
          ),
          Text(
            'Registered Nurse Surgical Ward',
            style: subHeadingText(color: Colors.white, size: 18),
          ),
          SizedBox(
            height: ht(20),
          ),
          JobContaner(
            details: true,
            ontap: () {},
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: ht(140),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor),
                borderRadius: BorderRadius.circular(12)),
            child: Text(
              'Description',
              style: regularText(color: AppColors.primaryColor),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          PrimaryButton(label: 'Grab', onPress: () {})
        ],
      ),
    );
  }
}

class JobContaner extends StatelessWidget {
  final Function ontap;
  final bool myJob;
  final bool details;
  const JobContaner(
      {super.key,
      this.myJob = false,
      required this.ontap,
      this.details = false});

  @override
  Widget build(BuildContext context) {
    Color textColor = myJob || details ? AppColors.colorWhite : Colors.black;
    Color mainColor = myJob ? AppColors.primaryColor : Colors.white;
    Color borderColor = myJob ? Colors.white : AppColors.primaryColor;
    return GestureDetector(
      onTap: () {
        ontap();
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            color: myJob ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: wd(60),
                  height: ht(60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '07',
                        style: headingText(color: textColor),
                      ),
                      Text(
                        'Aug-2023',
                        style: regularText(size: 11, color: textColor),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  height: ht(40),
                  width: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),
                Expanded(
                  child: Text(
                    'Registered Nurse Surgical Ward',
                    style: subHeadingText(size: 12, color: textColor),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12))),
                  height: ht(60),
                  width: wd(70),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '\$30',
                          style: headingText(color: mainColor),
                        ),
                        Text(
                          'per hour',
                          style: regularText(size: 11, color: mainColor),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 7,
            ),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(12))),
              child: Row(
                children: [
                  SizedBox(
                    width: wd(60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '07:00 AM',
                          style: regularText(size: 12, color: textColor),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          '08:00 AM',
                          style: regularText(size: 12, color: textColor),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          '(8 hours)',
                          style: regularText(size: 11, color: textColor),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    height: ht(40),
                    width: 1,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: subHeadingText(size: 12, color: textColor),
                        ),
                        Text(
                          'Sub-Location',
                          style: regularText(size: 12, color: textColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
