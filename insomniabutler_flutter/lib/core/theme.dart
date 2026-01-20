import 'package:flutter/material.dart';
import 'dart:ui';

/// Comprehensive Design System for Insomnia Butler
/// Deep Blue + Warm Copper Glassmorphic UI
/// Optimized for late-night, 2 AM usage

class AppColors {
  // --- Backgrounds ---
  static const Color backgroundDeep = Color(0xFF0B1C2D); // Deep Ink Blue
  static const Color surfaceBlueBlack = Color(0xFF10263A); // Secondary Surface

  // --- Background Gradients (Subtle Night Blues) ---
  static const bgPrimary = LinearGradient(
    colors: [Color(0xFF0B1C2D), Color(0xFF081421)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const bgSecondary = LinearGradient(
    colors: [Color(0xFF10263A), Color(0xFF0B1C2D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const bgCard = LinearGradient(
    colors: [Color(0xCC10263A), Color(0x990B1C2D)], // Translucent blue-black
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Accent Colors ---
  static const accentCopper = Color(0xFFC38E5C); // Primary Accent
  static const accentAmber = Color(0xFFD9A76F); // Warm Lamp Glow
  static const accentSkyBlue = Color(0xFF5FA8D3); // Secondary Accent

  static const accentSuccess = Color(0xFF4A7C59); // Muted Calm Green
  static const accentWarning = Color(0xFFB8860B); // Muted Dark Gold/Amber
  static const accentError = Color(0xFF9B4444); // Softened Red

  // --- Glass Effects (Translucent blue-black, reduced brightness) ---
  static const glassBg = Color(0x1A10263A); // rgba(16, 38, 58, 0.1)
  static const glassBgElevated = Color(0x2610263A); // rgba(16, 38, 58, 0.15)
  static const glassBorder = Color(
    0x265FA8D3,
  ); // Subtle Sky Blue border (15% opacity)

  // --- Text Colors (Warm Off-Whites & Desaturated Calm Tones) ---
  static const textPrimary = Color(0xFFF5F5F0); // Warm off-white
  static const textSecondary = Color(0xFF94A3B8); // Desaturated Blue-Grey
  static const textTertiary = Color(0xFF64748B); // Slate Blue-Grey
  static const textDisabled = Color(0xFF334155); // Dark Slate

  // --- Hero & UI Gradients ---
  static const gradientPrimary = LinearGradient(
    colors: [accentCopper, accentAmber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientHero = LinearGradient(
    colors: [Color(0xFF0B1C2D), Color(0xFF1E3A8A)], // Deep Night Blue to Navy
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientThought = LinearGradient(
    colors: [accentCopper, Color(0xFF8E5C3C)], // Copper to Deep Bronze
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientCalm = LinearGradient(
    colors: [accentSkyBlue, Color(0xFF2E5B75)], // Sky Blue to Deep Teal
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSuccess = LinearGradient(
    colors: [accentSuccess, Color(0xFF2D4C38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Shimmer Effect (Blue-toned) ---
  static const gradientShimmer = LinearGradient(
    colors: [
      Color(0x005FA8D3),
      Color(0x1A5FA8D3),
      Color(0x005FA8D3),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // --- Legacy Mappings (for backward compatibility) ---
  static const accentPrimary = accentCopper;
  static const accentSecondary = accentSkyBlue;
  static const accentTertiary = accentSkyBlue; // Map to secondary accent
  static const sleepReadyLow = accentError;
  static const sleepReadyMid = accentWarning;
  static const sleepReadyHigh = accentSuccess;
}

class AppTextStyles {
  static const displayXl = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.12,
    height: 1.14,
    color: AppColors.textPrimary,
  );

  static const displayLg = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.96,
    height: 1.17,
    color: AppColors.textPrimary,
  );

  static const displayMd = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.40,
    height: 1.20,
    color: AppColors.textPrimary,
  );

  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.32,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static const h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.28,
    height: 1.29,
    color: AppColors.textPrimary,
  );

  static const h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    color: AppColors.textPrimary,
  );

  static const h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.40,
    color: AppColors.textPrimary,
  );

  static const bodyLg = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.56,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const bodySm = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    color: AppColors.textPrimary,
  );

  static const labelLg = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    color: AppColors.textPrimary,
  );

  static const label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    color: AppColors.textPrimary,
  );

  static const caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.textSecondary,
  );
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  static const double containerPadding = 20;
  static const double sectionSpacing = 32;
  static const double cardGap = 16;
}

class AppBorderRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 9999;
}

class AppShadows {
  static const glassShadow = [
    BoxShadow(
      color: Color(0x66040C14), // Deep Navy Shadow
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  static const cardShadow = [
    BoxShadow(
      color: Color(0x40040C14), // Deep Navy Shadow
      blurRadius: 24,
      offset: Offset(0, 4),
    ),
  ];

  static const buttonShadow = [
    BoxShadow(
      color: Color(0x33C38E5C), // Subtle copper glow (20% opacity)
      blurRadius: 24,
      offset: Offset(0, 4),
    ),
  ];
}
