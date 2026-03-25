import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single source of truth for all design tokens in SkyFit Pro.
class AppTheme {
  AppTheme._();

  // ─── Colors ───────────────────────────────────────────────────
  static const Color bgDark        = Color(0xFF08080E);
  static const Color bgLight       = Color(0xFFF8FAFC);
  static const Color surfDark      = Color(0xFF12121E);
  static const Color surfLight     = Color(0xFFFFFFFF);
  static const Color textDark      = Color(0xFF1A1C1E);
  static const Color textLight     = Color(0xFFFFFFFF);

  // Brand gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient sunGradient = LinearGradient(
    colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient rainGradient = LinearGradient(
    colors: [Color(0xFF3A7BD5), Color(0xFF3A6073)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Difficulty palette
  static const Color easyColor     = Color(0xFF2ECC71);
  static const Color moderateColor = Color(0xFFF39C12);
  static const Color hardColor     = Color(0xFFE74C3C);

  // ─── Border Radius ────────────────────────────────────────────
  static const double radiusSm  = 12.0;
  static const double radiusMd  = 20.0;
  static const double radiusLg  = 28.0;
  static const double radiusXl  = 36.0;

  // ─── Spacing ──────────────────────────────────────────────────
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;

  // ─── Text Styles ──────────────────────────────────────────────
  static TextStyle displayLg(bool isDark) => GoogleFonts.plusJakartaSans(
    fontSize: 32, fontWeight: FontWeight.w800,
    color: isDark ? textLight : textDark, letterSpacing: -1,
  );
  static TextStyle titleMd(bool isDark) => GoogleFonts.plusJakartaSans(
    fontSize: 20, fontWeight: FontWeight.bold,
    color: isDark ? textLight : textDark,
  );
  static TextStyle titleSm(bool isDark) => GoogleFonts.plusJakartaSans(
    fontSize: 16, fontWeight: FontWeight.w700,
    color: isDark ? textLight : textDark,
  );
  static TextStyle bodySm(bool isDark) => GoogleFonts.plusJakartaSans(
    fontSize: 13, fontWeight: FontWeight.w500,
    color: isDark ? Colors.white60 : Colors.black54,
  );

  // ─── Glassmorphic Card Decoration ─────────────────────────────
  static BoxDecoration glassCard({required bool isDark, Color? accentColor}) {
    return BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.white.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(radiusLg),
      border: Border.all(
        color: accentColor != null
            ? accentColor.withValues(alpha: 0.25)
            : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
        width: 1.5,
      ),
      boxShadow: isDark
          ? []
          : [BoxShadow(color: (accentColor ?? Colors.black).withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))],
    );
  }

  // ─── Helper: Background Blob ──────────────────────────────────
  static Widget blob(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
    ),
  );
}
