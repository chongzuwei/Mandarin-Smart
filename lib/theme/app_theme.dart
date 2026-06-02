import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand Colors ──────────────────────────────────────────────
  static const Color primaryRed = Color(0xFFE53935);
  static const Color primaryRedDark = Color(0xFFC62828);
  static const Color primaryRedLight = Color(0xFFFF6F60);
  static const Color accentGold = Color(0xFFFFB300);
  static const Color accentGoldLight = Color(0xFFFFE082);

  // ── Status Colors ─────────────────────────────────────────────
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color successGreenLight = Color(0xFF81C784);
  static const Color successGreenDark = Color(0xFF388E3C);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color warningOrangeDark = Color(0xFFE65100);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color errorRedLight = Color(0xFFEF5350);
  static const Color infoBlue = Color(0xFF2196F3);
  static const Color infoBlueDark = Color(0xFF1565C0);

  // ── Neutrals ──────────────────────────────────────────────────
  // LIGHT MODE
  static const Color bgLight = Color(0xFFF7FBFD);
  static const Color bgLightAlt = Color(0xFFEEF6FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightAlt = Color(0xFFF4FBFE);

  static const Color textLightPrimary = Color(0xFF111E30);
  static const Color textLightSecondary = Color(0xFF4E657D);
  static const Color textLightTertiary = Color(0xFF8094A9);

// DARK MODE
  static const Color bgDark = Color(0xFF0F1720);
  static const Color bgDarkAlt = Color(0xFF16202B);
  static const Color surfaceDark = Color(0xFF1D2936);
  static const Color surfaceDarkAlt = Color(0xFF263545);

  static const Color textDarkPrimary = Color(0xFFFFFFFF);
  static const Color textDarkSecondary = Color(0xFFB8C7D9);
  static const Color textDarkTertiary = Color(0xFF8A9BB0);

  static const Color dividerColor = Color(0xFFD4E5EE);

  static const Color textPrimary = textLightPrimary;
  static const Color textSecondary = textLightSecondary;
  static const Color textTertiary = textLightTertiary;
  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, Color(0xFFFF6B6B)],
  );

  static const LinearGradient primaryGradientReverse = LinearGradient(
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
    colors: [primaryRed, Color(0xFFFF8A80)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successGreen, successGreenLight],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warningOrange, Color(0xFFFFB74D)],
  );

  static const RadialGradient bgGradient = RadialGradient(
    center: Alignment.center,
    radius: 1.3,
    colors: [
      Color(0xFFF7FDFF), // Soft mist center
      Color(0xFFDCEFF6), // Pale aqua mid-tone
      Color(0xFFB8DFF0), // Cool sky edge
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF4FBFE),
    ],
  );

  static const LinearGradient cardGradientEnhanced = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF5FCFF),
      Color(0xFFE8F3F9),
    ],
  );

  // ── Shadows ───────────────────────────────────────────────────
  static List<BoxShadow> get primaryShadow => [
        BoxShadow(
          color: primaryRed.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: primaryRed.withValues(alpha: 0.15),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get deepShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 48,
          offset: const Offset(0, 16),
        ),
      ];

  static List<BoxShadow> get successShadow => [
        BoxShadow(
          color: successGreen.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get warningShadow => [
        BoxShadow(
          color: warningOrange.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // ── Border Radius ─────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 100.0;

  // ── Spacing ───────────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacingXxl = 32.0;

  // ── Opacity ───────────────────────────────────────────────────
  static const double opacityLight = 0.06;
  static const double opacityMedium = 0.12;
  static const double opacityStrong = 0.2;

  // ── Typography ────────────────────────────────────────────────
  static TextStyle get headingLarge => GoogleFonts.outfit(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.18,
        color: textPrimary,
      );

  static TextStyle get headingMedium => GoogleFonts.outfit(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.25,
        color: textPrimary,
      );

  static TextStyle get headingSmall => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: textPrimary,
      );

  static TextStyle get headingXSmall => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.6,
        color: textSecondary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.7,
        color: textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.7,
        color: textTertiary,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: textSecondary,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: textTertiary,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: Colors.white,
      );

  static TextStyle get captionText => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: textTertiary,
      );

  // ── ThemeData ─────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: bgLight,
        cardColor: surfaceLight,
        dividerColor: dividerColor,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: bgLight,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(
            color: textLightPrimary,
          ),
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textLightPrimary,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        cardTheme: CardThemeData(
          color: surfaceLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF7FBFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide(
              color: dividerColor.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(
              color: primaryRed,
              width: 2,
            ),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: bgDark,
        cardColor: surfaceDark,
        dividerColor: Colors.white12,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: bgDark,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        cardTheme: CardThemeData(
          color: surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceDarkAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(
              color: primaryRedLight,
              width: 2,
            ),
          ),
        ),
      );

  // ── Component Helpers ─────────────────────────────────────────
  /// Enhanced input decoration for text fields
  static InputDecoration buildInputDecoration({
    required String hintText,
    String? label,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool hasError = false,
  }) =>
      InputDecoration(
        hintText: hintText,
        labelText: label,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Color(0xFFF7FBFF).withValues(alpha: 0.95),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(
            color: dividerColor,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(
            color: dividerColor.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(
            color: primaryRed,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(
            color: errorRed,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(
            color: errorRed,
            width: 2.0,
          ),
        ),
        hintStyle: bodyMedium.copyWith(color: textTertiary),
        labelStyle: bodyMedium.copyWith(color: textSecondary),
        errorStyle: bodySmall.copyWith(color: errorRed),
      );

  /// Build elevated button decoration
  static BoxDecoration buildButtonDecoration({
    Color? backgroundColor,
    bool isPressed = false,
    bool isDisabled = false,
  }) {
    if (isDisabled) {
      return BoxDecoration(
        color: Color(0xFFCAEAF5).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(radiusMd),
      );
    }

    return BoxDecoration(
      gradient: backgroundColor == null
          ? primaryGradient
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor,
                backgroundColor.withValues(alpha: 0.8),
              ],
            ),
      borderRadius: BorderRadius.circular(radiusMd),
      boxShadow: isPressed ? softShadow : elevatedShadow,
    );
  }

  /// Build card decoration with glass effect
  static BoxDecoration buildCardDecoration({
    List<BoxShadow>? shadows,
    double borderRadius = radiusLg,
  }) =>
      BoxDecoration(
        gradient: cardGradientEnhanced,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: shadows ?? softShadow,
      );

  /// Build status badge decoration
  static BoxDecoration buildBadgeDecoration({
    required Color backgroundColor,
    required Color borderColor,
  }) =>
      BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.15),
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(radiusSm),
      );
}
