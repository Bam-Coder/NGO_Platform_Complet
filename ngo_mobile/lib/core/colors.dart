import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF009639);
  static const Color primaryDark = Color(0xFF006B2B);
  
  // Secondary
  static const Color accent = Color(0xFFE30613);
  
  // Utilities
  static Color primaryWithOpacity(double opacity) => primary.withValues(alpha: opacity);
  static Color primaryDarkWithOpacity(double opacity) => primaryDark.withValues(alpha: opacity);
  static Color accentWithOpacity(double opacity) => accent.withValues(alpha: opacity);
  static Color whiteWithOpacity(double opacity) => Colors.white.withValues(alpha: opacity);
  static Color blackWithOpacity(double opacity) => Colors.black.withValues(alpha: opacity);
  static Color greyWithOpacity(double opacity) => Colors.grey.withValues(alpha: opacity);
}
