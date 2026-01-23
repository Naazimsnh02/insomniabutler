import 'package:flutter/material.dart';

/// Insomnia Butler Design System
/// Reference-matched night UI (Ink Blue + Soft Violet + Warm Amber)

class AppColors {
  // ─────────────────────────────────────────────
  // Core Backgrounds
  // ─────────────────────────────────────────────

  static const Color bgPrimary = Color(0xFF0A1125); // Deep Navy
  static const Color bgSecondary = Color(0xFF101730); // Darker Navy
  static const Color bgTertiary = Color(0xFF0D1C3C); // Deep Ocean Blue

  static const LinearGradient bgMainGradient = LinearGradient(
    colors: [bgPrimary, bgTertiary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─────────────────────────────────────────────
  // Surfaces / Cards
  // ─────────────────────────────────────────────

  static const Color surfaceBase = Color(0xFF1E2235);
  static const Color surfaceElevated = Color(0xFF282D42);
  static const Color surfaceSelected = Color(0xFF323954);

  // ─────────────────────────────────────────────
  // Accents
  // ─────────────────────────────────────────────

  /// Primary selection / focus accent - Sky Blue
  static const Color accentPrimary = Color(0xFF6FA8FF);
  static const Color accentPrimarySoft = Color(0xFF8BB9FF);

  /// Cool blue accent (icons, progress, highlights)
  static const Color accentSecondary = Color(0xFF5FA8FF);
  static const Color accentSecondarySoft = Color(0xFF7BB9FF);

  /// Cool Cyan accent (SUCCESS substitute)
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentCyanSoft = Color(0xFF7AEEFF);

  /// Soft Blue / Teal (Replaces lavender/purple)
  static const Color accentLavender = Color(0xFF8BB9FF);
  static const Color accentLavenderSoft = Color(0xFFB3D4FF);

  // ─────────────────────────────────────────────
  // Semantic Colors (Strictly Night Theme)
  // ─────────────────────────────────────────────

  static const Color success = accentPrimary;
  static const Color warning = accentLavender;
  static const Color error = Color(0xFFFF5F5F);

  // ─────────────────────────────────────────────
  // Text Colors
  // ─────────────────────────────────────────────

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8BEDD);
  static const Color textTertiary = Color(0xFF8A90B2);
  static const Color textDisabled = Color(0xFF5E6488);

  // ─────────────────────────────────────────────
  // Glassmorphism
  // ─────────────────────────────────────────────

  static const Color glassBackground = Color(0x33FFFFFF); // 20% white tint
  static const Color glassBorder = Colors.transparent; // Borderless design
  static const Color aiBubbleColor = Color(0xFF1E2640); // Distinct navy for AI

  // ─────────────────────────────────────────────
  // Dividers & Hairlines
  // ─────────────────────────────────────────────

  static const Color divider = Color(0xFF2A3048);

  // ─────────────────────────────────────────────
  // Gradients
  // ─────────────────────────────────────────────

  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [accentPrimary, Color(0xFF4A90E2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientCool = gradientPrimary;

  static const LinearGradient gradientLavender = LinearGradient(
    colors: [accentPrimary, accentLavender],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Compatibility Mappings for Existing Codebase ---
  static const Color backgroundDeep = bgPrimary;
  static const Color surfaceBlueBlack = bgSecondary;
  static const LinearGradient bgPrimaryGradient = bgMainGradient;

  static const Color accentCopper = accentLavender;
  static const Color accentAmber = accentLavender;
  static const Color accentSkyBlue = accentSecondary;
  static const Color accentWarm = accentLavender;

  static const Color accentSuccess = success;
  static const Color accentWarning = warning;
  static const Color accentError = error;

  static const Color glassBg = glassBackground;
  static const Color glassBgElevated = Color(0x261F2538);

  static const LinearGradient bgCard = LinearGradient(
    colors: [Color(0xCC1A1F2E), Color(0x9910162A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientCalm = gradientCool;
  static const LinearGradient gradientSuccess = gradientCool;
  static const LinearGradient gradientThought = gradientPrimary;
  static const LinearGradient gradientWarm = gradientLavender;

  static const Color sleepReadyLow = error;
  static const Color sleepReadyMid = accentLavender;
  static const Color sleepReadyHigh = accentPrimary;
}

/// ─────────────────────────────────────────────
/// Typography
/// ─────────────────────────────────────────────

class AppTextStyles {
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static const h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const h3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 16,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const bodySm = TextStyle(
    fontSize: 14,
    height: 1.45,
    color: AppColors.textTertiary,
  );

  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const caption = TextStyle(
    fontSize: 11,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  // --- Compatibility Mappings ---
  static const TextStyle displayMd = h1;
  static const TextStyle displayLg = h1;
  static const TextStyle displayXl = h1;
  static const TextStyle bodyLg = body;
  static const TextStyle labelLg = label;
  static const TextStyle h4 = h3;
}

/// ─────────────────────────────────────────────
/// Spacing
/// ─────────────────────────────────────────────

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Custom mappings for existing code
  static const double containerPadding = 20;
}

/// ─────────────────────────────────────────────
/// Radius
/// ─────────────────────────────────────────────

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 32;
  static const double pill = 999;
}

// --- Compatibility Class ---
class AppBorderRadius {
  static const double sm = AppRadius.sm;
  static const double md = AppRadius.md;
  static const double lg = AppRadius.lg;
  static const double xl = AppRadius.xl;
  static const double xxl = AppRadius.pill;
  static const double full = AppRadius.pill;
}

/// ─────────────────────────────────────────────
/// Shadows & Glows
/// ─────────────────────────────────────────────

class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 24,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> selectionGlow = [
    BoxShadow(
      color: Color(0x406FA8FF), // sky blue glow
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> cyanGlow = [
    BoxShadow(
      color: Color(0x4000E5FF),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  // --- Compatibility Mappings ---
  static const List<BoxShadow> cardShadow = card;
  static const List<BoxShadow> glassShadow = card;
  static const List<BoxShadow> buttonShadow = selectionGlow;
  static const List<BoxShadow> warmGlow = cyanGlow;
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      primaryColor: AppColors.accentPrimary,
      colorScheme: ColorScheme.dark(
        primary: AppColors.accentPrimary,
        secondary: AppColors.accentSecondary,
        surface: AppColors.surfaceBase,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySm,
        labelLarge: AppTextStyles.label,
      ),
      dividerColor: AppColors.divider,
      cardTheme: const CardThemeData(
        color: AppColors.surfaceBase,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
      ),
    );
  }
}
