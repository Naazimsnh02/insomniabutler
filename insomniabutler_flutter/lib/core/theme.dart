import 'package:flutter/material.dart';
import 'dart:ui';

/// Comprehensive Design System for Insomnia Butler
/// Glassmorphic Night-Time Companion

class AppColors {
  // Background Gradients
  static const bgPrimary = LinearGradient(
    colors: [Color(0xFF0A0E27), Color(0xFF1A1E3E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const bgSecondary = LinearGradient(
    colors: [Color(0xFF1E2347), Color(0xFF2A1E4F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const bgCard = LinearGradient(
    colors: [Color(0x992A1E4F), Color(0x661E2347)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Accent Colors
  static const accentPrimary = Color(0xFFA78BFA); // Soft Purple
  static const accentSecondary = Color(0xFFC084FC); // Vibrant Purple
  static const accentTertiary = Color(0xFF60A5FA); // Sky Blue
  static const accentSuccess = Color(0xFF34D399); // Mint Green
  static const accentWarning = Color(0xFFFBBF24); // Warm Gold
  static const accentError = Color(0xFFEF4444); // Red

  // Glass Effects
  static const glassBg = Color(0x14FFFFFF); // rgba(255, 255, 255, 0.08)
  static const glassBgElevated = Color(0x1FFFFFFF); // rgba(255, 255, 255, 0.12)
  static const glassBorder = Color(0x1FFFFFFF); // rgba(255, 255, 255, 0.12)

  // Text Colors
  static const textPrimary = Color(0xF2FFFFFF); // rgba(255, 255, 255, 0.95)
  static const textSecondary = Color(0xA6FFFFFF); // rgba(255, 255, 255, 0.65)
  static const textTertiary = Color(0x73FFFFFF); // rgba(255, 255, 255, 0.45)
  static const textDisabled = Color(0x40FFFFFF); // rgba(255, 255, 255, 0.25)

  // Semantic Colors
  static const sleepReadyLow = Color(0xFFEF4444); // Red
  static const sleepReadyMid = Color(0xFFFBBF24); // Gold
  static const sleepReadyHigh = Color(0xFF34D399); // Green

  // Hero Gradients
  static const gradientHero = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFF093FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientThought = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientCalm = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSuccess = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientPrimary = LinearGradient(
    colors: [accentPrimary, accentSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shimmer Effect
  static const gradientShimmer = LinearGradient(
    colors: [
      Color(0x00FFFFFF),
      Color(0x1AFFFFFF),
      Color(0x00FFFFFF),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppTextStyles {
  // Display
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

  // Headings
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

  // Body
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

  // Labels
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
      color: Color(0x4D000000), // rgba(0, 0, 0, 0.3)
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  static const cardShadow = [
    BoxShadow(
      color: Color(0x26000000), // rgba(0, 0, 0, 0.15)
      blurRadius: 24,
      offset: Offset(0, 4),
    ),
  ];

  static const buttonShadow = [
    BoxShadow(
      color: Color(0x66A78BFA), // rgba(167, 139, 250, 0.4)
      blurRadius: 24,
      offset: Offset(0, 4),
    ),
  ];
}
