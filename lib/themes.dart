import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // You might need to add google_fonts to pubspec

class AppTheme {
  // Professional Color Palette
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color accentOrange = Color(0xFFFF6D00); // For CTAs
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF757575);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundOffWhite = Color(0xFFF4F5F7);
  static const Color errorRed = Color(0xFFD32F2F);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentOrange,
        surface: backgroundWhite,
        error: errorRed,
        background: backgroundOffWhite,
      ),
      scaffoldBackgroundColor: backgroundOffWhite,

      // Typography
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: const TextStyle(color: textDark, fontWeight: FontWeight.bold),
        titleLarge: const TextStyle(color: textDark, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: textDark),
        bodyMedium: const TextStyle(color: textGrey),
      ),

      // Component Themes
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundWhite,
        foregroundColor: textDark,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
      ),
    );
  }
}