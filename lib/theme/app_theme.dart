import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NexColors {
  // Core palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42E8);
  static const Color accent = Color(0xFFB388FF);
  static const Color accentSoft = Color(0xFFE8E0FF);

  // Surfaces
  static const Color surface = Color(0xFFF8F7FC);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF0EEF8);
  static const Color background = Color(0xFFFAF9FE);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color textTertiary = Color(0xFF9E9EB0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Mood colors
  static const Color moodStressed = Color(0xFFFF6B6B);
  static const Color moodInspired = Color(0xFFFFB347);
  static const Color moodFocused = Color(0xFF4ECDC4);
  static const Color moodConfused = Color(0xFF95A5A6);

  // Thought mode colors
  static const Color modeIdea = Color(0xFFFFD93D);
  static const Color modeDeepThinking = Color(0xFF6C63FF);
  static const Color modeQuickCapture = Color(0xFF00D2FF);
  static const Color modeReflection = Color(0xFF8B5CF6);
  static const Color modeTaskOriented = Color(0xFF10B981);

  // Memory Space colors
  static const Color spaceWork = Color(0xFF3B82F6);
  static const Color spacePersonal = Color(0xFFEC4899);
  static const Color spaceIdeasLab = Color(0xFFF59E0B);
  static const Color spaceLifeJournal = Color(0xFF10B981);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFFB388FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient logoGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFFAB7AFF), Color(0xFFD4A5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F7FC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF6C63FF).withValues(alpha: 0.04),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
      blurRadius: 40,
      offset: const Offset(0, 12),
    ),
  ];
}

class NexTypography {
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: NexColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: NexColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: NexColors.textPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: NexColors.textPrimary,
  );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: NexColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: NexColors.textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: NexColors.textSecondary,
    height: 1.6,
  );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: NexColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: NexColors.textTertiary,
  );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: NexColors.textPrimary,
  );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: NexColors.textSecondary,
  );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: NexColors.textTertiary,
    letterSpacing: 0.5,
  );

  // Focus writing mode typography
  static TextStyle get focusTitle => GoogleFonts.sourceSerif4(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: NexColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get focusBody => GoogleFonts.sourceSerif4(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: NexColors.textPrimary,
    height: 1.8,
  );

  static TextStyle get logo => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
  );
}

class NexTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: NexColors.background,
      colorScheme: ColorScheme.light(
        primary: NexColors.primary,
        onPrimary: NexColors.textOnPrimary,
        secondary: NexColors.accent,
        surface: NexColors.surface,
        onSurface: NexColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: NexTypography.headlineLarge,
        iconTheme: const IconThemeData(color: NexColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: NexColors.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: NexColors.surfaceSubtle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: NexTypography.bodyMedium.copyWith(color: NexColors.textTertiary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NexColors.primary,
          foregroundColor: NexColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: NexTypography.titleMedium.copyWith(color: NexColors.textOnPrimary),
        ),
      ),
    );
  }
}
