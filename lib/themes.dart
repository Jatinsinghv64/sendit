import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // You might need to add google_fonts to pubspec

class AppTheme {
  // Professional Color Palette
  static const Color primaryGreen = Color(0xFF1B5E20); // Deeper, more premium green
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color accentOrange = Color(0xFFFF6D00); // High contrast for CTAs
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF757575);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundOffWhite = Color(0xFFF9FAFB);
  static const Color errorRed = Color(0xFFD32F2F);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentOrange,
        surface: backgroundWhite,
        error: errorRed,
        background: backgroundOffWhite,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundOffWhite,

      // Typography
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 32),
        titleLarge: const TextStyle(color: textDark, fontWeight: FontWeight.w700, fontSize: 20),
        titleMedium: const TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: const TextStyle(color: textDark, fontSize: 16),
        bodyMedium: const TextStyle(color: textGrey, fontSize: 14),
      ),

      // Component Themes
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundWhite,
        foregroundColor: textDark,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textDark),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIconColor: Colors.grey.shade500,
      ),

      // Fixed: Using CardThemeData to match parameter type
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade100),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}