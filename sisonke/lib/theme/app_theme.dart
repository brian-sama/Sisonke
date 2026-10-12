import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

class AppTheme {
  static const Color primary = SisonkeColors.primary; // Serevo Bright Magenta (0xFFCA0174)
  static const Color secondary = SisonkeColors.secondary; // Deep Purple (0xFF6F206F)
  static const Color tertiary = SisonkeColors.accent; // Sunrise Glow Amber (0xFFFDA737)
  static const Color calmSurface = SisonkeColors.cream; // Warm paper cream (0xFFFAF7F5)
  static const Color ink = SisonkeColors.charcoal; // Deep plum charcoal (0xFF24141E)
  static const Color darkSurface = Color(0xFF140D12);
  static const Color darkSurfaceHigh = Color(0xFF1F141C);
  static const Color darkSurfaceHighest = Color(0xFF2B1B27);
  static const Color darkInk = Color(0xFFFAF5F8);

  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      surface: Colors.white,
      surfaceContainer: const Color(0xFFFDF8F9),
      surfaceContainerHigh: const Color(0xFFFAF0F3),
      surfaceContainerHighest: SisonkeColors.primaryDim,
      onSurface: ink,
      onSurfaceVariant: ink.withValues(alpha: 0.75),
      outline: const Color(0xFFE5D5DD),
      outlineVariant: const Color(0xFFF3E7EC),
      error: const Color(0xFFF43F5E),
    ),
    scaffoldBackgroundColor: calmSurface,
    textTheme: GoogleFonts.nunitoSansTextTheme().apply(
      bodyColor: ink,
      displayColor: ink,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: primary,
      selectionColor: SisonkeColors.primaryMid,
      selectionHandleColor: primary,
    ),
    useMaterial3: true,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 10,
      height: 74,
      shadowColor: ink.withValues(alpha: 0.08),
      indicatorColor: primary.withValues(alpha: 0.14),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 25,
          color: states.contains(WidgetState.selected)
              ? primary
              : ink.withValues(alpha: 0.65),
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => GoogleFonts.nunitoSans(
          fontSize: 12.5,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? primary
              : ink.withValues(alpha: 0.70),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.nunitoSans(fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: ink,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: ink,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: ink, fontWeight: FontWeight.w600),
      floatingLabelStyle: const TextStyle(color: primary, fontWeight: FontWeight.w700),
      hintStyle: TextStyle(color: ink.withValues(alpha: 0.50), fontWeight: FontWeight.w500),
      prefixIconColor: ink.withValues(alpha: 0.75),
      suffixIconColor: ink.withValues(alpha: 0.75),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFFF3E7EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFEE2B5E), // Glowing hot pink
      secondary: const Color(0xFFA855F7), // Glowing purple
      tertiary: const Color(0xFFFDA737), // Sunrise amber
      surface: darkSurfaceHigh,
      surfaceContainer: const Color(0xFF1A1117),
      surfaceContainerHigh: darkSurfaceHigh,
      surfaceContainerHighest: darkSurfaceHighest,
      onSurface: darkInk,
      onSurfaceVariant: darkInk.withValues(alpha: 0.75),
      outline: const Color(0xFF5A3D4E),
      outlineVariant: const Color(0xFF382330),
      error: const Color(0xFFFFB4AB),
    ),
    scaffoldBackgroundColor: darkSurface,
    textTheme: GoogleFonts.nunitoSansTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: darkInk, displayColor: darkInk),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFFEE2B5E),
      selectionColor: Color(0xFF3B1D2C),
      selectionHandleColor: Color(0xFFEE2B5E),
    ),
    useMaterial3: true,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkSurfaceHigh,
      elevation: 0,
      height: 74,
      indicatorColor: const Color(0xFFEE2B5E).withValues(alpha: 0.20),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 25,
          color: states.contains(WidgetState.selected)
              ? const Color(0xFFEE2B5E)
              : darkInk.withValues(alpha: 0.7),
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => GoogleFonts.nunitoSans(
          fontSize: 12.5,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? const Color(0xFFEE2B5E)
              : darkInk.withValues(alpha: 0.72),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: darkSurfaceHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFEE2B5E),
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.nunitoSans(fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkInk,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: darkInk,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceHighest,
      labelStyle: const TextStyle(color: darkInk, fontWeight: FontWeight.w600),
      floatingLabelStyle: const TextStyle(color: Color(0xFFEE2B5E), fontWeight: FontWeight.w700),
      hintStyle: TextStyle(color: darkInk.withValues(alpha: 0.50), fontWeight: FontWeight.w500),
      prefixIconColor: darkInk.withValues(alpha: 0.75),
      suffixIconColor: darkInk.withValues(alpha: 0.75),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFF382330)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFFEE2B5E), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    ),
  );
}
