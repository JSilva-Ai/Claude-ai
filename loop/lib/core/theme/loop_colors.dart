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

  /// The surface ladder. Depth in LOOP is which of these three a thing sits
  /// on — there is no shadow between them; see [LoopElevation].
  ///
  /// page (backgroundTop/Bottom) → surface → surfaceMuted → surfaceRaised
  static const Color surface = Color(0xFF0C1120);
  static const Color surfaceMuted = Color(0xFF121829);
  static const Color surfaceRaised = Color(0xFF161D31);

  // --- Text --------------------------------------------------------------
  static const Color textPrimary = Color(0xFFF3F5FB);
  static const Color textSecondary = Color(0xFF98A2B8);

  /// The third level of text, used for navigation labels, chevrons and the
  /// small glyphs beside a time — all of which carry meaning or invite a tap.
  ///
  /// It is only one step below [textSecondary] on purpose. At its old value
  /// (#6B7488) it measured 4.01:1 on the plain surface and 2.96:1 on the DONE
  /// card, which fails WCAG AA for text of this size; the hierarchy between
  /// the two is now carried by size and weight rather than by luminance,
  /// which is the trade the guideline forces and the right one to make.
  static const Color textTertiary = Color(0xFF8995AE);

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
  ///
  /// This is the *fill* violet: gradients, strokes, glows, the card tint.
  static const Color ai = Color(0xFF7C5CFF);

  /// The same violet for text and for icons that are read rather than
  /// admired.
  ///
  /// A separate token because the fill and the label have different jobs:
  /// [ai] on its own tinted card measures 3.68:1, which is not readable, and
  /// lifting the fill to fix the label would change the brand colour of the
  /// ring and the create button. This is lighter by just enough — 4.60:1 on
  /// the AI card, 5.41:1 on the plain surface.
  static const Color aiText = Color(0xFF8E73FF);
  static const Color aiAlt = Color(0xFF22D3EE);

  /// The brand sweep: violet into cyan, the ring's own gradient.
  static const List<Color> loopGradient = <Color>[ai, Color(0xFF4C6FFF), aiAlt];

  static const Color online = Color(0xFF3BD683);
}
