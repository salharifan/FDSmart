import 'package:flutter/material.dart';

class AppColors {
  // Vibrant Primary Brand Colors
  static const Color primary = Color(0xFFFF5722); // Deep Orange
  static const Color primaryVariant = Color(0xFFE64A19);
  static const Color secondary = Color(
    0xFFFFC107,
  ); // Amber/Gold for tokens/stars

  // Background and Surfaces (Dark Mode Focused)
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF3D3D3D);

  // Text Colors
  static const Color textPrimary = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textInverse = Color(0xFF121212);

  // Status Indicators
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Glassmorphism overlays
  static const Color glassWhite = Color(0x1AFFFFFF); // 10% White
  static const Color glassBlack = Color(0x80000000); // 50% Black
}
