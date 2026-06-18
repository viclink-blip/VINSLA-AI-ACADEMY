import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color primary, Color secondary) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge:  GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: primary),
      displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: primary),
      headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: primary),
      headlineMedium:GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: primary),
      titleLarge:    GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      titleMedium:   GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: primary),
      bodyLarge:     GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: primary),
      bodyMedium:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: secondary),
      bodySmall:     GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: secondary),
      labelLarge:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
    );
  }

  // ── DARK THEME ─────────────────────────────────────────
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness:   Brightness.dark,
    colorScheme:  ColorScheme.dark(
      primary:     AppColors.brandPurple,
      secondary:   AppColors.brandCyan,
      surface:     AppColors.darkSurface,
      error:       AppColors.error,
      onPrimary:   Colors.white,
      onSecondary: Colors.white,
      onSurface:   AppColors.darkText,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    textTheme: _textTheme(AppColors.darkText, AppColors.darkTextSub),
    cardTheme: CardTheme(
      color:        AppColors.darkCard,
      elevation:    0,
      shape:        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPurple,
        foregroundColor: Colors.white,
        minimumSize:     const Size(double.infinity, 52),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle:       GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        elevation:       0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brandPurple,
        minimumSize:     const Size(double.infinity, 52),
        side:            const BorderSide(color: AppColors.brandPurple),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle:       GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:          true,
      fillColor:       AppColors.darkCard,
      border:          OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brandPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.inter(color: AppColors.darkTextSub, fontSize: 14),
      labelStyle: GoogleFonts.inter(color: AppColors.darkTextSub),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBg,
      elevation:       0,
      centerTitle:     false,
      titleTextStyle:  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkText),
      iconTheme:       const IconThemeData(color: AppColors.darkText),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:      AppColors.darkSurface,
      selectedItemColor:    AppColors.brandPurple,
      unselectedItemColor:  AppColors.darkTextSub,
      type:                 BottomNavigationBarType.fixed,
      elevation:            0,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.darkBorder, thickness: 1),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkCard,
      labelStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.darkText),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );

  // ── LIGHT THEME ────────────────────────────────────────
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness:   Brightness.light,
    colorScheme:  ColorScheme.light(
      primary:    AppColors.brandPurple,
      secondary:  AppColors.brandCyan,
      surface:    AppColors.lightSurface,
      error:      AppColors.error,
      onPrimary:  Colors.white,
      onSurface:  AppColors.lightText,
    ),
    scaffoldBackgroundColor: AppColors.lightBg,
    textTheme: _textTheme(AppColors.lightText, AppColors.lightTextSub),
    cardTheme: CardTheme(
      color:     AppColors.lightCard,
      elevation: 0,
      shape:     RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPurple,
        foregroundColor: Colors.white,
        minimumSize:     const Size(double.infinity, 52),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle:       GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        elevation:       0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:      true,
      fillColor:   AppColors.lightSurface,
      border:      OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.brandPurple, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      elevation:       0,
      centerTitle:     false,
      titleTextStyle:  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.lightText),
    ),
  );
}
