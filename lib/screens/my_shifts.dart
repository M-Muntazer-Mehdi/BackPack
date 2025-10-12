import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/globals/adaptive_helper.dart';
import 'package:back_packers/globals/container_properties.dart';
import 'package:back_packers/screens/shifts.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';
import 'package:back_packers/widgets/primary_button.dart';

class MyShiftsScreen extends StatefulWidget {
  const MyShiftsScreen({super.key});

  @override
  State<MyShiftsScreen> createState() => _MyShiftsScreenState();
}

class _MyShiftsScreenState extends State<MyShiftsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: wd(25)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: ht(35),
              ),
              searchBar(),
              const SizedBox(
                height: 25,
              ),
              Text(
                'My Jobs',
                style: headingText(size: 24, color: AppColors.primaryColor),
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
                        myJob: true,
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
                    child: TextField(
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search by job...',
                      hintStyle: regularText(color: AppColors.primaryColor)),
                )),
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
          color: Colors.white),
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
                style: headingText(size: 17, color: Colors.black),
              ),
              Spacer()
            ],
          ),
          SizedBox(
            height: ht(40),
          ),
          Text(
            'Registered Nurse Surgical Ward',
            style: subHeadingText(color: AppColors.primaryColor, size: 18),
          ),
          SizedBox(
            height: ht(20),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor),
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryColor.withOpacity(0.00),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset('assets/images/ic_clock.png'),
                ),
              ),
              title: Text(
                '07-Aug-2023',
                style: regularText(color: AppColors.lightText, size: 15),
              ),
              subtitle: Text(
                '7:00 AM to 3:00 AM',
                style: regularText(color: AppColors.borderColor, size: 13),
              ),
              trailing: const Icon(Icons.keyboard_arrow_right),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor),
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryColor.withOpacity(0.00),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset('assets/images/ic_dollor.png'),
                ),
              ),
              title: Text(
                '35\$ per hour',
                style: regularText(color: AppColors.lightText, size: 15),
              ),
              subtitle: Text(
                '280.0 total paid pre-tax',
                style: regularText(color: AppColors.borderColor, size: 13),
              ),
              trailing: const Icon(Icons.keyboard_arrow_right),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          PrimaryButton(label: 'Grab', onPress: () {})
        ],
      ),
    );
  }
}
