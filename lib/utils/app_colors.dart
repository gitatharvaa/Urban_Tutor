import 'package:flutter/material.dart';

class AppColors {
  // Primary Educational Colors - Blues for trust and focus
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color darkBlue = Color(0xFF0D47A1);
  
  // Secondary Colors - Greens for growth and learning
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF66BB6A);
  static const Color accent = Color(0xFF4CAF50);
  
  // Neutral Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color cardBackground = Color(0xFFFAFBFC);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1B2631);
  static const Color textSecondary = Color(0xFF5D6D7E);
  static const Color textLight = Color(0xFF85929E);
  
  // Status Colors
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  
  // Educational Theme
  static ColorScheme get educationalColorScheme => ColorScheme.fromSeed(
    seedColor: primaryBlue,
    primary: primaryBlue,
    secondary: primaryGreen,
    background: background,
    surface: surface,
    brightness: Brightness.light,
  );
}
