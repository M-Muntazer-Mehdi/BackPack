import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:back_packers/globals/container_properties.dart';
import 'package:back_packers/utils/app_colors.dart';

import '../utils/text_styles.dart';

customTextFiled(TextEditingController controller, FocusNode focusNode,
    List<TextInputFormatter>? textInputFormatter, dynamic icon,
    {bool obscure = false,
    bool dropdown = false,
    dynamic suffixIcon,
    Color? color,
    Function(String? val)? onchange,
    Function? ontap,
    int? lines,
    TextInputType textInputType = TextInputType.text,
    String hint = ''}) {
  return Container(
    decoration: ContainerProperties.simpleDecoration(
        radius: 15, color: color ?? Colors.transparent),
    child: TextField(
      // cursorHeight: 20,
      keyboardType: textInputType,
      inputFormatters: textInputFormatter ?? [],
      focusNode: focusNode,
      textAlign: TextAlign.start,
      obscureText: obscure,
      controller: controller,
      onChanged: onchange,
      cursorColor: Colors.white,
      style: regularText(size: 15).copyWith(color: Colors.white),
      readOnly: ontap != null,
      onTap: () {
        if (ontap != null) {
          ontap();
        }
      },
      decoration: InputDecoration(
          labelText: hint,
          labelStyle: normalText().copyWith(color: Colors.white),
          prefixIcon: icon == null
              ? null
              : SizedBox(
                  height: 60,
                  width: 40,
                  child: icon,
                ),
          suffixIcon: dropdown ? Icon(Icons.keyboard_arrow_down) : suffixIcon,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.colorWhite),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.colorWhite),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          contentPadding: EdgeInsets.symmetric(
              horizontal: 10, vertical: lines == null ? 0 : 5),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.colorWhite),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15))),
    ),
  );
}

simplecustomTextFiled(TextEditingController controller, FocusNode focusNode,
    List<TextInputFormatter>? textInputFormatter, dynamic icon,
    {bool obscure = false,
    bool dropdown = false,
    dynamic suffixIcon,
    Color? color,
    dynamic onchange,
    Function? ontap,
    int? lines,
    TextInputType textInputType = TextInputType.text,
    String hint = ''}) {
  return Container(
    decoration: ContainerProperties.simpleDecoration(
        radius: 15, color: color ?? Colors.transparent),
    child: TextField(
      // cursorHeight: 20,
      keyboardType: textInputType,
      inputFormatters: textInputFormatter ?? [],
      focusNode: focusNode,
      textAlign: TextAlign.start,
      obscureText: obscure,
      controller: controller,
      onChanged: onchange,
      cursorColor: Colors.black,
      style: regularText(size: 15).copyWith(color: Colors.black),
      readOnly: ontap != null,
      onTap: ontap == null ? () {} : ontap(),
      decoration: InputDecoration(
          labelText: hint,
          labelStyle:
              normalText().copyWith(color: Colors.grey.withOpacity(0.9)),
          suffixIcon: dropdown ? Icon(Icons.keyboard_arrow_down) : suffixIcon,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightBorder),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightBorder),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          contentPadding: EdgeInsets.symmetric(
              horizontal: 10, vertical: lines == null ? 0 : 5),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightBorder),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15))),
    ),
  );
}

customTextFiledMulti(TextEditingController controller, FocusNode focusNode,
    List<TextInputFormatter>? textInputFormatter, dynamic icon,
    {bool obscure = false,
    bool dropdown = false,
    dynamic suffixIcon,
    Color? color,
    dynamic onchange,
    Function? ontap,
    int? lines,
    TextInputType textInputType = TextInputType.text,
    String hint = ''}) {
  return Container(
    decoration: ContainerProperties.simpleDecoration(
        radius: 15, color: color ?? Colors.transparent),
    child: TextField(
      // cursorHeight: 20,
      keyboardType: textInputType,
      inputFormatters: textInputFormatter ?? [],
      focusNode: focusNode,
      textAlign: TextAlign.start,
      obscureText: obscure,
      controller: controller,
      onChanged: onchange,
      maxLines: lines,
      cursorColor: Colors.black,
      style: regularText(size: 15).copyWith(color: Colors.black),
      readOnly: ontap != null,
      onTap: ontap == null ? () {} : ontap(),
      decoration: InputDecoration(
          labelText: hint,
          labelStyle:
              normalText().copyWith(color: Colors.grey.withOpacity(0.9)),
          suffixIcon: dropdown ? Icon(Icons.keyboard_arrow_down) : suffixIcon,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightBorder),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightBorder),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          contentPadding: EdgeInsets.symmetric(
              horizontal: 10, vertical: lines == null ? 0 : 5),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightBorder),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15))),
    ),
  );
}

customTextFiledMenu(TextEditingController controller, FocusNode focusNode,
    List<TextInputFormatter> textInputFormatter, dynamic icon,
    {bool obscure = false,
    dynamic ontap,
    TextInputType textInputType = TextInputType.text,
    String hint = ''}) {
  return GestureDetector(
    onTap: ontap,
    child: Container(
      decoration: ContainerProperties.simpleDecoration(
          radius: 15, color: Colors.transparent),
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        cursorColor: Colors.white,
        style: regularText(size: 15).copyWith(color: Colors.white),
        readOnly: true,
        enabled: false,
        decoration: InputDecoration(
          labelText: hint,
          hintStyle: regularText().copyWith(color: Colors.white),
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.colorWhite),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.colorWhite),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.colorWhite),
              borderRadius: BorderRadius.circular(icon == null ? 8 : 15)),
        ),
      ),
    ),
  );
}

customTextFiledSimple(TextEditingController controller, FocusNode focusNode,
    {bool obscure = false,
    int? maxChar,
    List<TextInputFormatter> textInputFormatter = const [],
    double height = 35,
    double textSize = 15,
    Color? textColor,
    Color? cursorColor,
    Color? borderColor,
    dynamic icon,
    TextStyle? hintStyle,
    TextInputType textInputType = TextInputType.text,
    String hint = '',
    String lable = ''}) {
  return SizedBox(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lable,
          style: regularText(size: 12, color: Color(0xFFFFF5E1)),
        ),
        TextField(
          keyboardType: textInputType,
          inputFormatters: textInputFormatter,
          focusNode: focusNode,
          obscureText: obscure,
          maxLength: maxChar,
          controller: controller,
          cursorColor: cursorColor ?? Colors.black,
          style: regularText(size: textSize)
              .copyWith(color: textColor ?? Colors.white),
          decoration: InputDecoration(
              hintText: hint,
              suffixIcon: Container(
                  alignment: Alignment.center,
                  width: 30,
                  height: 30,
                  child: icon),
              hintStyle: regularText(color: AppColors.borderColor),
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(width: 1.5, color: AppColors.borderColor)),
              focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(width: 1.5, color: AppColors.borderColor)),
              border: UnderlineInputBorder(
                  borderSide:
                      BorderSide(width: 1.5, color: AppColors.borderColor))),
        ),
      ],
    ),
  );
}

multiLinesTextfield(TextEditingController controller, FocusNode focusNode,
    List<TextInputFormatter> textInputFormatter,
    {bool obscure = false,
    int? maxChar,
    double textSize = 15,
    Color? textColor,
    Color? cursorColor,
    Color? borderColor,
    TextStyle? hintStyle,
    TextInputType textInputType = TextInputType.text,
    String hint = ''}) {
  return SizedBox(
    child: TextField(
      keyboardType: textInputType,
      inputFormatters: textInputFormatter,
      focusNode: focusNode,
      obscureText: obscure,
      maxLength: maxChar,
      maxLines: 8,
      controller: controller,
      cursorColor: cursorColor ?? Colors.black,
      style: regularText(size: textSize)
          .copyWith(color: textColor ?? Colors.black),
      decoration: InputDecoration(
          hintText: hint,
          helperStyle: hintStyle,
          focusedBorder: _outlineBorder(borderColor),
          enabledBorder: _outlineBorder(borderColor),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          border: _outlineBorder(borderColor)),
    ),
  );
}

OutlineInputBorder _outlineBorder(Color? borderColor) {
  return OutlineInputBorder(
      borderSide: BorderSide(color: borderColor ?? const Color(0xFF000000)),
      borderRadius: BorderRadius.circular(5));
}
