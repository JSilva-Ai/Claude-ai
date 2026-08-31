import 'package:flutter/material.dart';

/// Every colour in the product, named for what it means rather than for what
/// it looks like.
///
/// Nothing outside this file may write a `Color(0x…)` literal. The point is not
/// tidiness: LOOP communicates state through colour, so the day a semantic
/// accent is judged too loud it has to change in one place and be right
/// everywhere, including in the two places that are easy to forget — the icon
/// ring and the count.
@immutable
class LoopColors {
  const LoopColors._();

  // --- Ground ------------------------------------------------------------
  // Not pure black. Absolute black flattens the elevation of the cards, and on
  // OLED it makes every scroll edge visible as a hard seam.
  static const Color backgroundTop = Color(0xFF070B16);
  static const Color backgroundBottom = Color(0xFF03050C);

  /// The card ground, sitting a little above the page.
  static const Color surface = Color(0xFF0C1120);
  static const Color surfaceMuted = Color(0xFF121829);
  static const Color surfaceRaised = Color(0xFF161D31);

  // --- Text --------------------------------------------------------------
  static const Color textPrimary = Color(0xFFF3F5FB);
  static const Color textSecondary = Color(0xFF98A2B8);
  static const Color textTertiary = Color(0xFF6B7488);

  // --- Lines -------------------------------------------------------------
  static const Color border = Color(0x14FFFFFF);
  static const Color borderStrong = Color(0x24FFFFFF);

  // --- Semantic accents --------------------------------------------------
  // One accent per loop state. These are the only saturated colours on the
  // screen, which is what makes a glance enough to read it.
  static const Color atRisk = Color(0xFFFF4D62);
  static const Color waiting = Color(0xFFFFA51F);
  static const Color today = Color(0xFF3B9BFF);
  static const Color done = Color(0xFF3BD683);

  /// Intelligence. Used for the ring, the AI surface and the create button —
  /// never for a loop state, so "purple" always means "LOOP itself is
  /// speaking" and never "this is urgent".
  static const Color ai = Color(0xFF7C5CFF);
  static const Color aiAlt = Color(0xFF22D3EE);

  /// The brand sweep: violet into cyan, the ring's own gradient.
  static const List<Color> loopGradient = <Color>[ai, Color(0xFF4C6FFF), aiAlt];

  static const Color online = Color(0xFF3BD683);
}
