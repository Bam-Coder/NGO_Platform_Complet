import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData burkinaTheme = ThemeData(
    primaryColor: const Color(0xFF009639), // Vert
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF009639),
      secondary: const Color(0xFFE30613), // Rouge
      tertiary: const Color(0xFFFFD700),  // Jaune
    ),
    useMaterial3: true,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF009639),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
