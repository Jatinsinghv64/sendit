import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Swiggy Instamart-inspired Palette
  static const Color qcGreen = Color(0xFF0C831F); // The core brand color
  static const Color qcGreenDark = Color(0xFF096316);
  static const Color qcGreenLight = Color(0xFFF0FFF4); // Very light green for backgrounds
  static const Color qcAccentBlue = Color(0xFF256FEF);
  static const Color qcDiscountRed = Color(0xFFD32F2F);

  // Backgrounds
  static const Color background = Color(0xFFF5F7FD); // Slightly blue-ish grey
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE0E0E0);

  // Typography
  static const Color textPrimary = Color(0xFF1F1F1F); // Softer black
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9E9E9E);

  static const Color primaryColor = qcGreen;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primaryColor,

      colorScheme: ColorScheme.fromSeed(
        seedColor: qcGreen,
        surface: surface,
        background: background,
        primary: qcGreen,
        secondary: qcAccentBlue,
        error: qcDiscountRed,
      ),

      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 22),
        titleLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
        titleMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
        bodyLarge: const TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        bodyMedium: const TextStyle(color: textSecondary, fontSize: 12, height: 1.4, fontWeight: FontWeight.w500),
        labelSmall: const TextStyle(color: textTertiary, fontSize: 10, fontWeight: FontWeight.w700),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 0.5),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: qcGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: qcGreen,
          side: const BorderSide(color: qcGreen),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }
}