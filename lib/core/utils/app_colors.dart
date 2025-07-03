import 'package:flutter/material.dart';

class AppColors {
  // Primary colors with better contrast and accessibility
  static const Color primaryColor = Color(0xFF1976D2); // Material Blue 700
  static const Color primaryLight = Color(0xFF42A5F5); // Material Blue 400
  static const Color primaryDark = Color(0xFF0D47A1); // Material Blue 900
  
  // Secondary colors for found/lost items
  static const Color secondaryColor = Color(0xFF4CAF50); // Green for found items (menggantikan secondaryColor lama)
  static const Color warningColor = Color(0xFFF57C00); // Orange for lost items
  static const Color errorColor = Color(0xFFF44336); // Red for urgent items
  
  // Neutral colors
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  // Text colors with proper contrast ratios
  static const Color textColor = Color(0xFF212121); // menggantikan textColor lama
  static const Color subtleTextColor = Color(0xFF757575); // menggantikan subtleTextColor lama
  static const Color textHint = Color(0xFF9E9E9E);
  
  // Untuk kompatibilitas dengan kode lama (aliases)
  static const Color textPrimary = textColor;
  static const Color textSecondary = subtleTextColor;
  
  // Semantic colors
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color shadowColor = Color(0x1A000000);
  
  static MaterialColor get primaryMaterialColor {
    return MaterialColor(primaryColor.value, {
      50: const Color(0xFFE3F2FD),
      100: const Color(0xFFBBDEFB),
      200: const Color(0xFF90CAF9),
      300: const Color(0xFF64B5F6),
      400: const Color(0xFF42A5F5),
      500: primaryColor,
      600: const Color(0xFF1E88E5),
      700: const Color(0xFF1976D2),
      800: const Color(0xFF1565C0),
      900: const Color(0xFF0D47A1),
    });
  }
}