import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:back_packers/globals/container_properties.dart';
import 'package:back_packers/utils/app_colors.dart';

customBottomSheet(List<String> options, int selected, Function onTap) {
  return Get.bottomSheet(SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(5),
          decoration: ContainerProperties.simpleDecoration(
              radius: 18, color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < options.length; index++)
                GestureDetector(
                  onTap: () {
                    onTap(index);
                    Get.back();
                  },
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    height: 45,
                    child: Text(
                      options[index],
                      style: TextStyle(
                          color: index == selected
                              ? AppColors.primaryColor
                              : AppColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        InkWell(
          onTap: () {
            Get.back();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(5),
            decoration: ContainerProperties.simpleDecoration(
                radius: 12, color: Colors.white),
            alignment: Alignment.center,
            height: 48,
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    ),
  ));
}
// customBottomSheet(context, List<String> options, int selected, Function onTap) {
//   return showCupertinoModalPopup(
//       context: context,
//       builder: (BuildContext context) => Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: CupertinoActionSheet(
//                 actions: List.generate(options.length, (index) {
//                   return CupertinoActionSheetAction(
//                     child: Text(
//                       options[index],
//                       style: TextStyle(
//                           color: index == selected
//                               ? kLinkAccentColor
//                               : availableColor,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400),
//                     ),
//                     onPressed: () {
//                       onTap(index);
//                       Navigator.pop(context);
//                       //_selectItem(item);
//                     },
//                   );
//                 }),
//                 cancelButton: CupertinoActionSheetAction(
//                   child: const Text('Cancel',
//                       style:
//                           TextStyle(color: Colors.white, letterSpacing: 0.3)),
//                   isDefaultAction: true,
//                   onPressed: () {
//                     Navigator.pop(
//                       context,
//                       'Cancel',
//                     );
//                   },
//                 )),
//           ));
// }
