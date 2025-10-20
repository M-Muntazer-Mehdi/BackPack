// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class AppColors {
  // ===== PREMIUM LIGHT THEME WITH PURPLE TONES =====
  
  // Purple Scale - Main Brand Colors
  static Color primaryColor = HexColor('#7C3AED'); // Deep Purple (Violet 600)
  static Color primaryLight = HexColor('#8B5CF6'); // Light Purple (Violet 500)
  static Color primaryLighter = HexColor('#A78BFA'); // Lighter Purple (Violet 400)
  static Color primaryDark = HexColor('#6D28D9'); // Darker Purple (Violet 700)
  static Color primaryDarker = HexColor('#5B21B6'); // Darkest Purple (Violet 800)
  
  // Background Colors - Clean White Theme
  static Color scaffoldBackgroundColor = HexColor('#FFFFFF'); // Pure White
  static Color bgGrey = HexColor("#F9FAFB"); // Gray 50 - Subtle background
  static Color bgLight = HexColor("#F3F4F6"); // Gray 100 - Cards
  static Color bgCard = HexColor("#FFFFFF"); // White cards
  
  // Text Colors - Clear Hierarchy
  static Color colorWhite = HexColor('#FFFFFF');
  static Color txtDark = HexColor("#111827"); // Gray 900 - Primary text
  static Color txtGrey = HexColor("#6B7280"); // Gray 500 - Secondary text
  static Color txtMuted = HexColor("#9CA3AF"); // Gray 400 - Muted text
  static Color lightText = HexColor('#F9FAFB'); // Light text for dark backgrounds
  
  // UI Elements - Modern & Clean
  static Color borderColor = HexColor('#E5E7EB'); // Gray 200
  static Color lightBorder = HexColor('#D1D5DB'); // Gray 300
  static Color iconColor = HexColor('#9CA3AF'); // Gray 400
  static Color scaffoldGrey = HexColor('#F9FAFB'); // Gray 50
  
  // Accent Colors - Supporting Palette
  static Color accentOrange = HexColor('#F59E0B'); // Amber 500
  static Color accentTeal = HexColor('#10B981'); // Emerald 500
  static Color accentPink = HexColor('#EC4899'); // Pink 500
  static Color accentBlue = HexColor('#3B82F6'); // Blue 500
  
  // Status Colors - Standard
  static Color successGreen = HexColor('#10B981'); // Emerald 500
  static Color warningYellow = HexColor('#F59E0B'); // Amber 500
  static Color errorRed = HexColor('#EF4444'); // Red 500
  static Color infoBlue = HexColor('#3B82F6'); // Blue 500
  
  // Legacy Support (keeping old color names for compatibility)
  static Color purple = HexColor('#7C3AED');
  static Color orangeColor = HexColor('#F59E0B');
  static Color lightOrangeColor = HexColor('#FCD34D');
  static Color lightColorBlue = HexColor('#60A5FA');
  
  // Gradient Combinations - Premium Purple
  static LinearGradient primaryGradient = LinearGradient(
    colors: [HexColor('#7C3AED'), HexColor('#6D28D9')],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient lightGradient = LinearGradient(
    colors: [HexColor('#F9FAFB'), HexColor('#FFFFFF')],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static LinearGradient purpleGradient = LinearGradient(
    colors: [
      HexColor('#8B5CF6'), // Light Purple
      HexColor('#7C3AED'), // Main Purple
      HexColor('#6D28D9'), // Deep Purple
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient subtleGradient = LinearGradient(
    colors: [HexColor('#FAFAFA'), HexColor('#F5F5F5')],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient darkGradient = LinearGradient(
    colors: [HexColor('#0F172A'), HexColor('#1E293B'), HexColor('#334155')],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color getMainBgColor() {
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
