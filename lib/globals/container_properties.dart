import 'package:flutter/material.dart';
import 'package:back_packers/utils/app_colors.dart';

class ContainerProperties {
  static BoxDecoration mainDecoration() {
    return BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 0),
              blurRadius: 4,
              spreadRadius: 1),
        ]);
  }

  static BoxDecoration shadowDecoration({
    double radius = 6.0,
    double blurRadius = 10,
    Color? color,
    double spreadRadius = 6,
    double xd = 0,
    double yd = 0,
  }) {
    return BoxDecoration(
        shape: BoxShape.rectangle,
        color: color ?? AppColors.colorWhite,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              offset: Offset(xd, yd),
              blurRadius: blurRadius,
              spreadRadius: spreadRadius),
        ]);
  }

  static BoxDecoration simpleDecoration({double radius = 5.0, color}) {
    return BoxDecoration(
      shape: BoxShape.rectangle,
      color: color ?? AppColors.colorWhite,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration borderDecoration({double radius = 5.0, borderColor}) {
    return BoxDecoration(
      shape: BoxShape.rectangle,
      border: Border.all(color: borderColor ?? AppColors.primaryColor),
      borderRadius: BorderRadius.circular(radius),
    );
  }
}
