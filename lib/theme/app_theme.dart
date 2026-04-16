import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// NexNote Design System — Minimal, calm, premium.
/// Inspired by Linear, Superhuman, Apple Notes.

class Nex {
  Nex._();

  // ── Colors ──────────────────────────────────────
  static const Color primary = Color(0xFF5B5BD6);     // Calm indigo
  static const Color primarySoft = Color(0xFFEEEEFC);  // Tinted background
  static const Color accent = Color(0xFF3E63DD);        // Action blue

  static const Color bg = Color(0xFFF9F9FB);           // App background
  static const Color surface = Color(0xFFFFFFFF);       // Cards
  static const Color surfaceDim = Color(0xFFF2F2F5);    // Input fields, chips
  static const Color border = Color(0xFFE8E8EC);        // Dividers, borders

  static const Color text = Color(0xFF11181C);          // Primary text
  static const Color textSub = Color(0xFF687076);       // Secondary text
  static const Color textMuted = Color(0xFF889096);     // Tertiary / captions
  static const Color textInverse = Color(0xFFFFFFFF);

  // Semantic (minimal palette — only used for mode indicators)
  static const Color blue = Color(0xFF3E63DD);
  static const Color violet = Color(0xFF6E56CF);
  static const Color green = Color(0xFF30A46C);
  static const Color amber = Color(0xFFE5A000);
  static const Color red = Color(0xFFE5484D);
  static const Color cyan = Color(0xFF05A2C2);
  static const Color pink = Color(0xFFD6409F);

  // ── Radius ─────────────────────────────────────
  static const double r8 = 8;
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;

  // ── Shadows ────────────────────────────────────
  static List<BoxShadow> get shadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Spacing (use as reference, not strictly enforced) ──
  // 4, 8, 12, 16, 20, 24, 32, 40, 48

  // ── Typography ─────────────────────────────────
  static TextStyle _base({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = text,
    double height = 1.4,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle get display => _base(size: 28, weight: FontWeight.w700, height: 1.2, letterSpacing: -0.5);
  static TextStyle get h1 => _base(size: 22, weight: FontWeight.w700, height: 1.25, letterSpacing: -0.3);
  static TextStyle get h2 => _base(size: 18, weight: FontWeight.w600, height: 1.3);
  static TextStyle get h3 => _base(size: 15, weight: FontWeight.w600, height: 1.35);
  static TextStyle get body => _base(size: 15, weight: FontWeight.w400, color: text, height: 1.55);
  static TextStyle get bodySub => _base(size: 14, weight: FontWeight.w400, color: textSub, height: 1.5);
  static TextStyle get label => _base(size: 13, weight: FontWeight.w500, color: textSub);
  static TextStyle get caption => _base(size: 12, weight: FontWeight.w500, color: textMuted);
  static TextStyle get small => _base(size: 11, weight: FontWeight.w500, color: textMuted, letterSpacing: 0.3);

  // Focus writing
  static TextStyle get focusTitle => GoogleFonts.sourceSerif4(
    fontSize: 26, fontWeight: FontWeight.w600, color: text, height: 1.3,
  );
  static TextStyle get focusBody => GoogleFonts.sourceSerif4(
    fontSize: 17, fontWeight: FontWeight.w400, color: text, height: 1.85,
  );

  // ── Theme ──────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: textInverse,
      surface: surface,
      onSurface: text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: h2,
      iconTheme: const IconThemeData(color: text, size: 22),
    ),
    dividerColor: border,
    splashFactory: InkSparkle.splashFactory,
  );
}
