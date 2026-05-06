import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sisonke/theme/sisonke_colors.dart';

class AppTheme {
  static const Color primary = Color(0xFF2E6F60); // Soft comforting sage-teal
  static const Color secondary = Color(0xFF7361A9); // Soft muted lavender
  static const Color tertiary = Color(0xFFD68A7F); // Warm soft terracotta-clay
  static const Color calmSurface = SisonkeColors.cream;
  static const Color ink = SisonkeColors.charcoal;
  static const Color darkSurface = Color(0xFF10131C);
  static const Color darkSurfaceHigh = Color(0xFF1A1D29);
  static const Color darkInk = Color(0xFFEDEBFF);

  static ThemeData lightTheme = ThemeData(
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: primary,
          secondary: secondary,
          tertiary: tertiary,
          surface: Colors.white,
          surfaceContainerHighest: SisonkeColors.mint,
          error: const Color(0xFFBA1A1A),
        ),
    scaffoldBackgroundColor: calmSurface,
    textTheme: GoogleFonts.nunitoSansTextTheme().apply(
      bodyColor: ink,
      displayColor: ink,
    ),
    useMaterial3: true,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 12,
      height: 74,
      shadowColor: ink.withValues(alpha: 0.12),
      indicatorColor: primary.withValues(alpha: 0.18),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 25,
          color: states.contains(WidgetState.selected)
              ? primary
              : ink.withValues(alpha: 0.68),
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => GoogleFonts.nunitoSans(
          fontSize: 12.5,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? ink
              : ink.withValues(alpha: 0.72),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFFF1EEFA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF6DD5F2),
          secondary: const Color(0xFFC6BFFF),
          tertiary: const Color(0xFFFFB1C8),
          surface: darkSurfaceHigh,
          surfaceContainerHighest: const Color(0xFF25293A),
          onSurface: darkInk,
          error: const Color(0xFFFFB4AB),
        ),
    scaffoldBackgroundColor: darkSurface,
    textTheme: GoogleFonts.nunitoSansTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: darkInk, displayColor: darkInk),
    useMaterial3: true,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkSurfaceHigh,
      elevation: 12,
      height: 74,
      shadowColor: Colors.black.withValues(alpha: 0.32),
      indicatorColor: const Color(0xFF6DD5F2).withValues(alpha: 0.20),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 25,
          color: states.contains(WidgetState.selected)
              ? const Color(0xFF6DD5F2)
              : darkInk.withValues(alpha: 0.70),
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => GoogleFonts.nunitoSans(
          fontSize: 12.5,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? darkInk
              : darkInk.withValues(alpha: 0.72),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: darkSurfaceHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        textStyle: GoogleFonts.nunitoSans(fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurfaceHigh,
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
      fillColor: const Color(0xFF1D2130),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFF25293A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFF6DD5F2), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    ),
  );
}
