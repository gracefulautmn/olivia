import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF005AAB); // Contoh warna biru UP
  static const Color secondaryColor = Color(0xFFF5A623); // Contoh warna aksen
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF333333);
  static const Color subtleTextColor = Color(0xFF757575);

  static MaterialColor get primaryMaterialColor {
    final Map<int, Color> shades = {
      50: primaryColor.withOpacity(0.1),
      100: primaryColor.withOpacity(0.2),
      200: primaryColor.withOpacity(0.3),
      300: primaryColor.withOpacity(0.4),
      400: primaryColor.withOpacity(0.5),
      500: primaryColor.withOpacity(0.6),
      600: primaryColor.withOpacity(0.7),
      700: primaryColor.withOpacity(0.8),
      800: primaryColor.withOpacity(0.9),
      900: primaryColor,
    };
    return MaterialColor(primaryColor.value, shades);
  }
}