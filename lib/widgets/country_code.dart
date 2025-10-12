// import 'dart:collection';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:talentogram/globals/app_views.dart';
// import 'package:talentogram/globals/enum.dart';
// import 'package:talentogram/globals/global.dart';
// import 'package:talentogram/models/user.dart';
// import 'package:talentogram/utils/text_styles.dart';
 

// /// This is the stateful widget that the main application instantiates.
// class ChooseCountry extends StatefulWidget {
//   final Function onTap;
//   final String type;
//   ChooseCountry(this.onTap, {required this.type});
//   @override
//   State<ChooseCountry> createState() => _ChooseCountryState();
// }

// /// This is the private State class that goes with MyStatefulWidget.
// class _ChooseCountryState extends State<ChooseCountry> {
//   List<SheetData> sheetDataa = [];
//   List<SheetData> searchSheet = [];
//   TextEditingController searchController = TextEditingController();
//   var isLoading = false;
//   getData() async {
//     isLoading = true;
//     setState(() {});
//     HashMap<String, Object> requestParams = HashMap();
//     var data;
//     if (widget.type == SheetValue.nationality) {
//       data = await AuthRepo().getNationality(requestParams);
//     } else if (widget.type == SheetValue.gender) {
//       data = await AuthRepo().gender(requestParams);
//     } else if (widget.type == SheetValue.profession) {
//       data = await AuthRepo().getProfession(requestParams);
//     } else {
//       data = await AuthRepo().getPermit(requestParams);
//     }
//     data.fold((failure) {
//       Global.showToastAlert(
//           context: Get.overlayContext!,
//           strTitle: "",
//           strMsg: 'Something went wrong!',
//           toastType: TOAST_TYPE.toastError);
//       isLoading = false;
//       setState(() {});
//     }, (mResult) async {
//       isLoading = false;
//       sheetDataa = mResult.responseData as List<SheetData>;
//       setState(() {});
//     });
//   }

//   @override
//   void initState() {
//     getData();

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: Container(
//         decoration: const BoxDecoration(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
//         child: Column(
//           children: [
//             SizedBox(
//               height: 60,
//               child: Row(
//                 children: [
//                   const Spacer(),
//                   GestureDetector(
//                     onTap: () {
//                       Get.back();
//                     },
//                     child: const Icon(
//                       Icons.close,
//                       color: Colors.red,
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 15,
//                   )
//                 ],
//               ),
//             ),
//             // Container(
//             //   margin: const EdgeInsets.all(10),
//             //   child: TextField(
//             //     controller: searchController,
//             //     // style: TextStyle(height: 1, fontSize: 15),
//             //     onChanged: (val) {
//             //       setState(() {
//             //         searchSheet = sheetDataa
//             //             .where((city) =>
//             //                 city.name.toLowerCase().contains(val.toLowerCase()))
//             //             .toList();
//             //       });
//             //     },
//             //     decoration: const InputDecoration(
//             //         hintText: 'Search...',
//             //         isDense: true,
//             //         contentPadding: EdgeInsets.all(15)),
//             //   ),
//             // ),
//             isLoading
//                 ? AppViews.showLoading()
//                 : Expanded(
//                     child: ListView.builder(
//                         itemCount: searchController.text.isEmpty
//                             ? sheetDataa.length
//                             : searchSheet.length,
//                         itemBuilder: (context, index) {
//                           SheetData city = searchController.text.isEmpty
//                               ? sheetDataa[index]
//                               : searchSheet[index];
//                           return ListTile(
//                               title: Text(
//                                 city.name,
//                                 style: regularText(),
//                               ),
//                               onTap: () async {
//                                 widget.onTap(city.id, city.name);
//                                 Get.back();
//                               });
//                         }),
//                   )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SheetValue {
//   static String profession = 'profession';
//   static String nationality = 'nationality';
//   static String gender = 'gender';
//   static String permit = 'permit';
// }
