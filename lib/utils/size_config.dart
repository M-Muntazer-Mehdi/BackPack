import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData mediaQueryData;
  static double screenWidth = 0;
  static double screenHeight = 0;
  static late Orientation orientation;

  void init(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;
    orientation = mediaQueryData.orientation;
  }
}

// Get the proportionate height as per screen size
double ht(double inputHeight) {
  double screenHeight = SizeConfig.screenHeight;
  // 812 is the layout height that designer use
  if (SizeConfig.orientation == Orientation.portrait) {
    // screenHeight = screenHeight < 500 ? 550 : screenHeight;
    return (inputHeight / 812.0) * screenHeight;
  } else {
    return (inputHeight / 812.0) * SizeConfig.screenWidth;
  }
}

// Get the proportionate height as per screen size
double wd(double inputWidth) {
  double screenWidth = SizeConfig.screenWidth;
  // 375 is the layout width that designer use
  if (SizeConfig.orientation == Orientation.portrait) {
    return (inputWidth / 375.0) * screenWidth;
  } else {
    return (inputWidth / 375.0) * SizeConfig.screenHeight;
  }
}

double tx(double inputWidth) {
  double screenWidth = SizeConfig.screenWidth;
  // 375 is the layout width that designer use
  if (SizeConfig.orientation == Orientation.portrait) {
    screenWidth = screenWidth > 400 ? 400 : screenWidth;
    return (inputWidth / 375.0) * screenWidth;
  } else {
    double h = SizeConfig.screenHeight > 400 ? 400 : SizeConfig.screenHeight;
    return (inputWidth / 375.0) * h;
  }
}
