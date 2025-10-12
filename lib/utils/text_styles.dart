import 'package:flutter/material.dart';

TextStyle headingText({double size = 15, color}) {
  return TextStyle(
      color: color ?? Colors.black,
      fontSize: size,
      fontWeight: FontWeight.w700);
}

TextStyle subHeadingText({double size = 14, color}) {
  return TextStyle(
      color: color ?? Colors.black,
      fontSize: size,
      fontWeight: FontWeight.w600);
}

TextStyle regularText({double size = 14, color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontSize: size,
    fontWeight: FontWeight.w500,
  );
}

TextStyle normalText({double size = 14, color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontSize: size,
    fontWeight: FontWeight.normal,
  );
}

TextStyle underLineText({double size = 16, color}) {
  return TextStyle(
      // fontFamily: "Roboto",
      color: color ?? Colors.black,
      fontSize: size,
      fontWeight: FontWeight.normal,
      decoration: TextDecoration.underline);
}

TextStyle lightText({double size = 16}) {
  return TextStyle(
    // fontFamily: "Roboto",

    fontSize: size,
    fontWeight: FontWeight.normal,
  );
}
