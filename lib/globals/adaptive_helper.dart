class Responsive {
  static double screenWidth = 0.0;
  static double screenHeight = 0.0;
  static double defaultSize = 0.0;

  static void init(height, width) {
    screenWidth = width;
    screenHeight = height;
  }
}

// Get the proportionate height as per screen size
double ht(double inputHeight) {
  double screenHeight = Responsive.screenHeight;
  // 812 is the layout height that designer use
  return (inputHeight / 812.0) * screenHeight;
}

// Get the proportionate height as per screen size
double wd(double inputWidth) {
  double screenWidth = Responsive.screenWidth;
  // 375 is the layout width that designer use
  return (inputWidth / 375.0) * screenWidth;
}
