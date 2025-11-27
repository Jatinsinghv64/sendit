import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Professional "Quick Commerce" Palette
  static const Color qcGreen = Color(0xFF0C831F);
  static const Color qcGreenDark = Color(0xFF096316);
  static const Color qcGreenLight = Color(0xFFF0FFF4);
  static const Color qcAccentBlue = Color(0xFF256FEF);
  static const Color qcDiscountRed = Color(0xFFD32F2F);

  static const Color background = Color(0xFFF4F6FB);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE5E7EB);

  // Typography Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Fixed: Define primaryColor alias so HomeScreen can access 'AppTheme.primaryColor'
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
        displayLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 24),
        titleLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
        titleMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: const TextStyle(color: textPrimary, fontSize: 14),
        bodyMedium: const TextStyle(color: textSecondary, fontSize: 12, height: 1.4),
        labelSmall: const TextStyle(color: textTertiary, fontSize: 10, fontWeight: FontWeight.w600),
      ),

      // FIXED: Changed 'CardTheme' to 'CardThemeData'
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: qcGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }
}