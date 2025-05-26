// lib/core/config/app_themes.dart

import 'package:flutter/material.dart';

class AppThemes {
  // Palet Warna Utama (Contoh - Sesuaikan dengan branding Universitas Pertamina)
  // Anda bisa mendapatkan kode hex warna resmi dari Universitas Pertamina jika ada.
  static const Color _primaryColor = Color(0xFF003366); // Biru tua khas UP (Contoh)
  static const Color _primaryVariantColor = Color(0xFF002244); // Varian biru lebih tua
  static const Color _secondaryColor = Color(0xFFD4A017); // Emas/Kuning sebagai aksen (Contoh)
  static const Color _secondaryVariantColor = Color(0xFFB8860B); // Varian emas lebih tua
  static const Color _backgroundColor = Color(0xFFF5F5F5); // Latar belakang netral (putih keabuan)
  static const Color _surfaceColor = Colors.white; // Warna permukaan seperti card
  static const Color _errorColor = Color(0xFFB00020); // Merah untuk error

  static const Color _onPrimaryColor = Colors.white;
  static const Color _onSecondaryColor = Colors.black;
  static const Color _onBackgroundColor = Color(0xFF212121); // Teks di atas background
  static const Color _onSurfaceColor = Color(0xFF212121); // Teks di atas surface
  static const Color _onErrorColor = Colors.white;

  // Tema Terang
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: _backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: _primaryColor,
      primaryContainer: _primaryVariantColor, // Dulu primaryVariant
      secondary: _secondaryColor,
      secondaryContainer: _secondaryVariantColor, // Dulu secondaryVariant
      surface: _surfaceColor,
      background: _backgroundColor,
      error: _errorColor,
      onPrimary: _onPrimaryColor,
      onSecondary: _onSecondaryColor,
      onSurface: _onSurfaceColor,
      onBackground: _onBackgroundColor,
      onError: _onErrorColor,
    ),
    appBarTheme: const AppBarTheme(
      color: _primaryColor,
      elevation: 1.0,
      iconTheme: IconThemeData(color: _onPrimaryColor),
      titleTextStyle: TextStyle(
        color: _onPrimaryColor,
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter', // Ganti dengan font pilihan Anda
      ),
    ),
    textTheme: _lightTextTheme,
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      buttonColor: _primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: _onPrimaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: _primaryColor, width: 2.0),
      ),
      labelStyle: const TextStyle(color: Colors.grey, fontFamily: 'Inter'),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontFamily: 'Inter'),
    ),
    cardTheme: CardTheme(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: _surfaceColor,
      surfaceTintColor: Colors.transparent, // Menghilangkan tint default pada card
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey,
      backgroundColor: _surfaceColor,
      elevation: 8.0,
      type: BottomNavigationBarType.fixed, // Atau shifting jika diinginkan
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'),
      unselectedLabelStyle: TextStyle(fontFamily: 'Inter'),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _secondaryColor,
      foregroundColor: _onSecondaryColor,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _primaryColor.withOpacity(0.1),
      disabledColor: Colors.grey.withOpacity(0.1),
      selectedColor: _primaryColor,
      secondarySelectedColor: _primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      labelStyle: const TextStyle(color: _primaryColor, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
      secondaryLabelStyle: const TextStyle(color: _onPrimaryColor, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      side: const BorderSide(color: _primaryColor, width: 1.0),
    ),
    useMaterial3: true, // Aktifkan Material 3 jika diinginkan
    fontFamily: 'Inter', // Font default untuk aplikasi
  );

  // Text Theme untuk Tema Terang
  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: _onBackgroundColor, fontFamily: 'Inter'),
    displayMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700, color: _onBackgroundColor, fontFamily: 'Inter'),
    displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700, color: _onBackgroundColor, fontFamily: 'Inter'),
    headlineMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: _onBackgroundColor, fontFamily: 'Inter'), // Dulu headline5
    headlineSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: _onBackgroundColor, fontFamily: 'Inter'), // Dulu headline6
    titleLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: _onBackgroundColor, fontFamily: 'Inter'), // Dulu subtitle1
    bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: _onSurfaceColor, fontFamily: 'Inter'), // Dulu bodyText1
    bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: _onSurfaceColor, fontFamily: 'Inter'), // Dulu bodyText2
    labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: _onPrimaryColor, fontFamily: 'Inter'), // Untuk teks di atas tombol
    bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.grey, fontFamily: 'Inter'), // Dulu caption
    labelSmall: TextStyle(fontSize: 10.0, fontWeight: FontWeight.normal, color: Colors.grey, fontFamily: 'Inter'), // Dulu overline
  );

  // (Opsional) Tema Gelap
  // static final ThemeData darkTheme = ThemeData(
  //   brightness: Brightness.dark,
  //   primaryColor: _primaryColor, // Atau warna primer yang cocok untuk gelap
  //   scaffoldBackgroundColor: const Color(0xFF121212),
  //   colorScheme: ColorScheme.dark(
  //     primary: _primaryColor, // Sesuaikan
  //     secondary: _secondaryColor, // Sesuaikan
  //     surface: const Color(0xFF1E1E1E),
  //     background: const Color(0xFF121212),
  //     error: Colors.redAccent,
  //     onPrimary: _onPrimaryColor,
  //     onSecondary: _onSecondaryColor, // Sesuaikan
  //     onSurface: Colors.white,
  //     onBackground: Colors.white,
  //     onError: Colors.black,
  //   ),
  //   // ... sesuaikan appBarTheme, textTheme, dll untuk tema gelap
  //   useMaterial3: true,
  //   fontFamily: 'Inter',
  // );
}
