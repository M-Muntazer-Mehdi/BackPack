// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class AppColors {
  // Color Start
  static Color scaffoldGrey = HexColor('#DFDFDF');
  static Color scaffoldBackgroundColor = Color(0xff141414);
  static Color bgGrey = HexColor("#303030");
  static Color txtGrey = HexColor("#8C8C8C");

  static Color colorWhite = HexColor('#FFFFFF');
  static Color primaryColor = HexColor('#8C1FF3');
  static Color purple = HexColor('#5754FC');
  static Color orangeColor = HexColor('#e04a29');
  static Color lightOrangeColor = HexColor('#EFAC99');
  static Color borderColor = Color(0xFF999999);
  static Color lightBorder = HexColor('#BCBCBC');
  static Color iconColor = HexColor('#787878');
  static Color lightText = HexColor('#181D27');
  static Color lightColorBlue = HexColor('#4272EF').withOpacity(0.51);

  static Color getMainBgColor() {
    // return AppColors.colorAccent.withOpacity(0.05);
    return AppColors.colorWhite;
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }

    final hexNum = int.parse(hexColor, radix: 16);

    if (hexNum == 0) {
      return 0xff000000;
    }

    return hexNum;
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class ColorToHex extends Color {
  ///convert material colors to hexcolor
  static int _convertColorTHex(Color color) {
    var hex = '${color.value}';
    return int.parse(
      hex,
    );
  }

  ColorToHex(final Color color) : super(_convertColorTHex(color));
}
