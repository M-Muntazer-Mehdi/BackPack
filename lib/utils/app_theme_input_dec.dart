import 'package:flutter/material.dart';
import 'package:back_packers/utils/app_colors.dart';

// All rights reserved by Healer

class AppTheme {
  static ThemeData data() => ThemeData(
        primaryColor: AppColors.primaryColor,
        // textTheme: _textTheme(),
        // useMaterial3: true,a
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.white, scrolledUnderElevation: 0),
        popupMenuTheme: _popUpMenuThemeData(),
        scaffoldBackgroundColor: AppColors.colorWhite,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
        ),
        cardColor: AppColors.scaffoldBackgroundColor,

        splashColor: Colors.grey.shade400,
        highlightColor: Colors.blueGrey[200]?.withOpacity(.25),
        datePickerTheme:
            DatePickerThemeData(headerBackgroundColor: AppColors.primaryColor),
        textButtonTheme: _textButtonTheme(),
        outlinedButtonTheme: _outlinedButtonThemeData(),
        canvasColor:
            Colors.transparent, //This is necessary for bottomSheet to work.
      );

  static PopupMenuThemeData _popUpMenuThemeData() => PopupMenuThemeData(
        elevation: 15,
        color: Colors.white,
        textStyle: TextStyle(
          color: Colors.grey[800],
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(
            color: Colors.grey.shade300,
            width: 2,
          ),
        ),
      );

  static TextButtonThemeData _textButtonTheme() => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.colorWhite,
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonThemeData() =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.colorWhite,
          side: BorderSide(
            color: AppColors.primaryColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
}
