import 'package:flutter/material.dart';

class AppColors {
  // Modern Food-Friendly Primary Colors
  static const Color primary = Color(0xFFFF6B35); // Vibrant Coral Red
  static const Color primaryLight = Color(0xFFFF8C61); // Lighter variant
  static const Color primaryDark = Color(0xFFE85A2A); // Darker variant
  
  // Secondary Accent Colors
  static const Color secondary = Color(0xFFFFA500); // Golden Orange for rewards
  static const Color accent = Color(0xFF00D4AA); // Teal for CTAs and highlights
  static const Color accentLight = Color(0xFF5DFFDB); // Light teal
  
  // Rich Dark Backgrounds
  static const Color background = Color(0xFF0F0F0F); // Deep dark background
  static const Color backgroundElevated = Color(0xFF151515); // Slightly elevated
  static const Color surface = Color(0xFF1A1A1A); // Card surfaces
  static const Color surfaceLight = Color(0xFF242424); // Input fields
  static const Color surfaceHighlight = Color(0xFF2A2A2A); // Hover states
  
  // Text Hierarchy
  static const Color textPrimary = Color(0xFFFAFAFA); // High emphasis text
  static const Color textSecondary = Color(0xFFB8B8B8); // Medium emphasis
  static const Color textTertiary = Color(0xFF6E6E6E); // Low emphasis
  static const Color textInverse = Color(0xFF0F0F0F); // On colored backgrounds
  
  // Semantic Colors
  static const Color success = Color(0xFF00C48C); // Delivered, confirmed
  static const Color successLight = Color(0xFF8FFFD4); // Success highlights
  static const Color warning = Color(0xFFFFB020); // Pending, caution
  static const Color error = Color(0xFFFF5757); // Error, cancelled
  static const Color info = Color(0xFF4A90E2); // Info, tips
  
  // Food Category Colors
  static const Color foodRed = Color(0xFFFF4757); // Spicy, meat
  static const Color foodGreen = Color(0xFF26DE81); // Vegan, healthy
  static const Color foodYellow = Color(0xFFFFC837); // Desserts
  static const Color foodPurple = Color(0xFF9B59B6); // Premium items
  
  // Overlay and Effects
  static const Color overlay = Color(0x99000000); // 60% Black
  static const Color overlayLight = Color(0x33FFFFFF); // 20% White
  static const Color shimmer = Color(0xFF2A2A2A); // Shimmer effect
  static const Color divider = Color(0xFF2D2D2D); // Dividers
  
  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C61)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF5DFFDB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Shadow Colors
  static Color primaryShadow = const Color(0xFFFF6B35).withOpacity(0.3);
  static Color cardShadow = Colors.black.withOpacity(0.4);
}
