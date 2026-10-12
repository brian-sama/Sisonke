import 'package:flutter/material.dart';

class SisonkeColors {
  // ── Official Serevo Brand Palette ─────────────────────────────────────────
  static const primary      = Color(0xFFCA0174); // Serevo Bright Magenta
  static const primaryDim   = Color(0xFFFDF2F8); // Magenta 8% tint
  static const primaryMid   = Color(0xFFFBCFE8); // Soft Magenta 20%
  static const primaryDark  = Color(0xFF921966); // Dark Serevo Magenta / Plum

  static const secondary    = Color(0xFF6F206F); // Deep Purple Leaf & Base
  static const secondaryDim = Color(0xFFFAF5FF); // Purple 6% tint
  static const secondaryMid = Color(0xFFE9D5FF); // Soft Purple

  static const accent       = Color(0xFFFDA737); // Sunrise Yellow / Forehead Glow

  // ── Exact Logo Colors ─────────────────────────────────────────────────────
  // Figure and Base
  static const figureHead   = Color(0xFFC20677); // Figure's head circle
  static const figureBody   = Color(0xFFCA0174); // Bright magenta of figure's body
  static const figurePlum   = Color(0xFF870E65); // Deep plum shading on body
  static const purpleLeaf   = Color(0xFF6F206F); // Purple of leaf & base
  static const purpleBase   = Color(0xFF5E2366); // Deep purple base

  // Healing Plus Signs
  static const plusTeal     = Color(0xFF1BB9B9); // Teal at the top of each plus
  static const plusBlue     = Color(0xFF1B75B9); // Blue at the bottom of each plus

  // Head Profile Gradient stops
  static const headYellow   = Color(0xFFFDA737); // Yellow glow near forehead
  static const headOrange   = Color(0xFFF76844); // Orange
  static const headCoral    = Color(0xFFF7584B); // Coral
  static const headHotPink  = Color(0xFFEE2B5E); // Hot pink
  static const headDeepPink = Color(0xFFEA1567); // Deep pink at bottom

  // Text Branding
  static const serevoText   = Color(0xFF921966); // Dark magenta ("SEREVO")
  static const healthText   = Color(0xFFD3155F); // Pink ("MENTAL HEALTH")

  // ── Surfaces ─────────────────────────────────────────────────────────────
  static const cream        = Color(0xFFFAF7F5); // Warm paper page background
  static const creamSoft    = Color(0xFFFFFFFF); // Elevated card background
  static const muted        = Color(0xFFF5EFEF); // Warm input background
  static const card         = Color(0xFFFFFFFF); // Card surface

  // ── Text ─────────────────────────────────────────────────────────────────
  static const charcoal     = Color(0xFF24141E); // Deep plum espresso text
  static const charcoalSoft = Color(0xFF5A4452); // Secondary subtle text

  // ── Semantic / risk (exact cross-platform values) ────────────────────────
  static const riskHigh     = Color(0xFFF43F5E); // rose-500
  static const riskMedium   = Color(0xFFF59E0B); // amber-500
  static const riskLow      = Color(0xFF10B981); // emerald-500

  static const success      = Color(0xFF10B981);
  static const warning      = Color(0xFFF59E0B);
  static const danger       = Color(0xFFF43F5E);
  static const info         = Color(0xFF1B75B9);

  // ── Ambient tones (legacy compatible & gradient accents) ─────────────────
  static const sage         = Color(0xFFD1FAE5);
  static const mint         = Color(0xFFCCFBF1);
  static const sky          = Color(0xFFE0F2FE);
  static const blush        = Color(0xFFFCE7F3);
  static const lemon        = Color(0xFFFEF3C7);
  static const lavender     = Color(0xFFF3E8FF);
  static const forest       = Color(0xFF1BB9B9);
  static const clay         = Color(0xFFF7584B);

  // ── Serevo Brand Gradients ────────────────────────────────────────────────
  // Head Profile Gradient
  static const Gradient serevoHeadProfile = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [headYellow, headOrange, headCoral, headHotPink, headDeepPink],
  );

  // Magenta Figure Gradient
  static const Gradient serevoFigureGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [figureBody, figurePlum],
  );

  // Plus Sign Healing Gradient
  static const Gradient serevoPlusCross = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [plusTeal, plusBlue],
  );

  // Purple Leaf & Base
  static const Gradient serevoBaseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purpleBase, purpleLeaf],
  );

  // Soft Ambient Background Gradients
  static const Gradient softPeachGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF7ED), Color(0xFFFDF2F8)],
  );

  static const Gradient pastelSunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFEDD5), Color(0xFFFCE7F3)],
  );

  static const Gradient morningMist = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAF5FF), Color(0xFFFFF7ED)],
  );

  static const Gradient forestBreeze = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF1F2), Color(0xFFFAF7F5)],
  );
}
