import 'package:flutter/material.dart';
import 'package:back_packers/globals/container_properties.dart';
import 'package:back_packers/utils/app_colors.dart';
import 'package:back_packers/utils/text_styles.dart';

// All rights reserved by Healer

class PrimaryButton extends StatelessWidget {
  final String label;
  final Color? color;
  final GestureTapCallback onPress;
  final dynamic icon;
  final dynamic keys;
  final bool bordered;
  final bool whiteButton;
  final double buttonHight;
  double radius;

  PrimaryButton(
      {super.key,
      required this.label,
      required this.onPress,
      this.color,
      this.whiteButton = false,
      this.bordered = false,
      this.radius = 10,
      this.icon,
      this.keys,
      this.buttonHight = 55.0});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color ?? AppColors.primaryColor,
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 7),
                blurRadius: 10,
                spreadRadius: 2),
          ],
          borderRadius: BorderRadius.circular(whiteButton ? 15 : radius),
        ),
        height: buttonHight,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPress,
          style: ButtonStyle(
              shadowColor: MaterialStatePropertyAll(Colors.transparent),
              // elevation: MaterialStateProperty.all(3),
              backgroundColor: MaterialStateProperty.all(
                  whiteButton ? Colors.transparent : Colors.transparent),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(whiteButton ? 15 : radius),
                ),
              )),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label.toUpperCase(),
              style: regularText(size: 18)
                  .copyWith(color: whiteButton ? Colors.black : Colors.white),
            ),
          ),
        ),
      );
}

// CupertinoButton(child: Text(
// label,
// style: Theme.of(context)
// .textTheme
//     .button
//     .copyWith(color: textColor ?? Theme.of(context).primaryColor),
// ), onPressed: onPress,):
