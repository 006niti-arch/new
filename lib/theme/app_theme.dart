// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- COLORS ---
  static const Color primaryColor = Color(0xFF005B41);
  static const Color accentColor = Color(0xFF25D366);
  static const Color errorColor = Color(0xFFD32F2F); // THIS LINE WAS MISSING

  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkTextColor = Color(0xFFE0E0E0);
  static const Color darkSubtleTextColor = Color(0xFFB0B0B0);

  // --- TEXT THEME ---
  static TextTheme _buildTextTheme(Color textColor, Color subtleColor, Color primaryColor) {
    return GoogleFonts.interTextTheme(TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 28),
      headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 24),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, color: textColor, fontSize: 20),
      titleMedium: TextStyle(fontWeight: FontWeight.w500, color: subtleColor, fontSize: 16),
      bodyLarge: TextStyle(fontWeight: FontWeight.normal, color: textColor, fontSize: 16),
      bodyMedium: TextStyle(fontWeight: FontWeight.normal, color: subtleColor, fontSize: 14),
      labelLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
    ));
  }

  // --- DARK THEME DATA ---
  static ThemeData get darkTheme {
    final textTheme = _buildTextTheme(darkTextColor, darkSubtleTextColor, accentColor);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: primaryColor,
        background: darkBackgroundColor,
        surface: darkCardColor,
        error: errorColor, // Added here as well for theme consistency
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onBackground: darkTextColor,
        onSurface: darkTextColor,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: accentColor),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: darkTextColor),
      ),
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.black),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: const BorderSide(color: accentColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: textTheme.labelLarge?.copyWith(color: accentColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: accentColor, width: 2.0),
        ),
      ),
    );
  }
}