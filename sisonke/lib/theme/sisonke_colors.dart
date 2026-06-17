import 'package:flutter/material.dart';

class SisonkeColors {
  // ── Brand palette ────────────────────────────────────────────────────────────
  static const primary      = Color(0xFF2E6F60); // sage teal — matches dashboard --color-primary
  static const primaryDim   = Color(0xFFE8F2EF); // teal 8%   — matches --color-primary-dim
  static const primaryMid   = Color(0xFFD0E8E3); // teal 15%  — matches --color-primary-mid
  static const primaryDark  = Color(0xFF1A3D36); // dark teal  — matches --color-primary-dark

  static const secondary    = Color(0xFF7361A9); // lavender   — matches --color-secondary
  static const secondaryDim = Color(0xFFF0EDF8); // lavender 6%

  static const accent       = Color(0xFFD68A7F); // terracotta

  // ── Surfaces ─────────────────────────────────────────────────────────────────
  static const cream        = Color(0xFFFFFBF2); // page background — matches --color-cream
  static const muted        = Color(0xFFF5F0E8); // warm gray inputs — matches --color-muted
  static const card         = Color(0xFFFFFFFF); // card surface

  // ── Text ─────────────────────────────────────────────────────────────────────
  static const charcoal     = Color(0xFF2F3433); // primary text — matches --color-charcoal

  // ── Semantic / risk (exact cross-platform values) ────────────────────────────
  // These hex values MUST stay in sync with index.css --color-risk-* tokens
  static const riskHigh     = Color(0xFFF43F5E); // rose-500
  static const riskMedium   = Color(0xFFF59E0B); // amber-500
  static const riskLow      = Color(0xFF10B981); // emerald-500

  static const success      = Color(0xFF10B981);
  static const warning      = Color(0xFFF59E0B);
  static const danger       = Color(0xFFF43F5E);
  static const info         = Color(0xFF3B82F6);

  // ── Ambient tones (kept for gradient system) ─────────────────────────────────
  static const sage         = Color(0xFFCFE6D2);
  static const mint         = Color(0xFFDDF3EA);
  static const sky          = Color(0xFFD8EEF8);
  static const blush        = Color(0xFFEBCBD0);
  static const lemon        = Color(0xFFF7E8B5);
  static const lavender     = Color(0xFFE4DDF6);
  static const forest       = Color(0xFF315F46);
  static const clay         = Color(0xFFE8B9A2);

  // ── Named gradients ───────────────────────────────────────────────────────────
  static const Gradient pastelSunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blush, lavender],
  );

  static const Gradient morningMist = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [sky, mint],
  );

  static const Gradient forestBreeze = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sage, cream],
  );
}
