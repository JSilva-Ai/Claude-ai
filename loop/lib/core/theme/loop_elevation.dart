import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Depth.
///
/// LOOP has no drop shadows in the ordinary sense — on a near-black ground a
/// grey shadow reads as dirt. Depth here is two things and only two: the
/// surface a thing sits on (the ladder in [LoopColors]: page → surface →
/// raised) and, for the few elements that are meant to look lit, a coloured
/// glow in their own accent.
///
/// Both used to be written inline at three call sites with three different
/// blur radii, which is exactly how a design system stops being one. Every
/// shadow in the app now comes from here.
@immutable
class LoopElevation {
  const LoopElevation._();

  /// Flush with its surface. The default for cards: they are separated by
  /// their border and their ground, not by a shadow.
  static const List<BoxShadow> level0 = <BoxShadow>[];

  /// A small object that reads as lit from within — the accent ring around a
  /// category icon. Tight and close.
  static List<BoxShadow> glowSmall(Color accent) => <BoxShadow>[
        BoxShadow(
          color: accent.withValues(alpha: _glowAlpha),
          blurRadius: 14,
          spreadRadius: -2,
        ),
      ];

  /// The same idea at the size of the insight mark: wider, softer, pulled in
  /// harder so it does not bleed past the card's own edge.
  static List<BoxShadow> glowMedium(Color accent) => <BoxShadow>[
        BoxShadow(
          color: accent.withValues(alpha: _glowAlphaMedium),
          blurRadius: 24,
          spreadRadius: -6,
        ),
      ];

  /// The one element that genuinely floats: the create button. It carries a
  /// downward offset as well as a glow, because it is the only thing on the
  /// screen that sits above the surface rather than on it.
  static List<BoxShadow> floating(Color accent) => <BoxShadow>[
        BoxShadow(
          color: accent.withValues(alpha: _glowAlphaFloating),
          blurRadius: 20,
          spreadRadius: -4,
          offset: const Offset(0, 4),
        ),
      ];

  // Kept as named constants rather than inline numbers so the three levels
  // stay in a deliberate ratio to each other.
  static const double _glowAlpha = 0.22;
  static const double _glowAlphaMedium = 0.28;
  static const double _glowAlphaFloating = 0.40;
}
