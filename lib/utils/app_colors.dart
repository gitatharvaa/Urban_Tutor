// lib/utils/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color darkBlue = Color(0xFF0D47A1);
  
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF66BB6A);
  static const Color accent = Color(0xFF4CAF50);
  
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Colors.white;
  static const Color lightCardBackground = Color(0xFFFAFBFC);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardBackground = Color(0xFF2D2D2D);
  
  // Text Colors
  static const Color lightTextPrimary = Color(0xFF1B2631);
  static const Color lightTextSecondary = Color(0xFF5D6D7E);
  static const Color lightTextLight = Color(0xFF85929E);
  
  static const Color darkTextPrimary = Color(0xFFE8EAED);
  static const Color darkTextSecondary = Color(0xFFBDC1C6);
  static const Color darkTextLight = Color(0xFF9AA0A6);
  
  // Status Colors
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);

  // Backward compatibility getters
  static Color get background => lightBackground;
  static Color get surface => lightSurface;
  static Color get textPrimary => lightTextPrimary;
  static Color get textSecondary => lightTextSecondary;
  static Color get textLight => lightTextLight;

  // Educational Light Theme
  static ColorScheme get educationalLightColorScheme => ColorScheme.fromSeed(
    seedColor: primaryBlue,
    brightness: Brightness.light,
    primary: primaryBlue,
    secondary: primaryGreen,
    background: lightBackground,
    surface: lightSurface,
    error: error,
  );

  // Educational Dark Theme
  static ColorScheme get educationalDarkColorScheme => ColorScheme.fromSeed(
    seedColor: primaryBlue,
    brightness: Brightness.dark,
    primary: lightBlue,
    secondary: lightGreen,
    background: darkBackground,
    surface: darkSurface,
    error: error,
  );

  // Dynamic color getter (backward compatibility)
  static ColorScheme get educationalColorScheme => educationalLightColorScheme;
  
  // Dynamic color scheme based on context
  static ColorScheme educationalColorSchemeForBrightness(bool isDark) =>
      isDark ? educationalDarkColorScheme : educationalLightColorScheme;
}
