import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/theme/loop_colors.dart';

/// WCAG 2.1 contrast, on the backgrounds the colours are actually painted on.
///
/// This exists because the audit found two failures nobody could see by eye —
/// the violet label at 3.68:1 on its own tinted card, and the tertiary grey at
/// 2.96:1 on the DONE card — and because the fix is one hex value that a later
/// "let's warm the palette up" would silently undo. A ratio is a number; a
/// number can be asserted.
double contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double hi = la > lb ? la : lb;
  final double lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// The ground a [LoopSurface] actually paints under its own label: the accent
/// washed over the surface at the same alpha the card uses.
Color tintedCard(Color accent) =>
    Color.alphaBlend(accent.withValues(alpha: 0.16), LoopColors.surface);

void main() {
  // AA for text below 18pt. Everything here is body copy, a label or an icon
  // that carries meaning, so this is the bar for all of it.
  const double aa = 4.5;

  group('text on its own card', () {
    test('each category title reads on the card it tints', () {
      for (final (String name, Color color) in <(String, Color)>[
        ('atRisk', LoopColors.atRisk),
        ('waiting', LoopColors.waiting),
        ('today', LoopColors.today),
        ('done', LoopColors.done),
      ]) {
        expect(
          contrast(color, tintedCard(color)),
          greaterThanOrEqualTo(aa),
          reason: '$name title on its own card',
        );
      }
    });

    test('the AI label reads on the violet card', () {
      // The fill would not: it measures 3.68:1 here, which is why aiText
      // exists as a separate token.
      expect(
        contrast(LoopColors.aiText, tintedCard(LoopColors.ai)),
        greaterThanOrEqualTo(aa),
      );
    });
  });

  group('the grey ladder', () {
    /// Every ground text is ever placed on.
    final List<(String, Color)> grounds = <(String, Color)>[
      ('page top', LoopColors.backgroundTop),
      ('page bottom', LoopColors.backgroundBottom),
      ('surface', LoopColors.surface),
      ('surface muted', LoopColors.surfaceMuted),
      ('surface raised', LoopColors.surfaceRaised),
      for (final Color accent in <Color>[
        LoopColors.atRisk,
        LoopColors.waiting,
        LoopColors.today,
        LoopColors.done,
        LoopColors.ai,
      ])
        ('tinted card', tintedCard(accent)),
    ];

    test('primary, secondary and tertiary all clear AA everywhere', () {
      for (final (String name, Color ground) in grounds) {
        for (final (String level, Color color) in <(String, Color)>[
          ('primary', LoopColors.textPrimary),
          ('secondary', LoopColors.textSecondary),
          // Navigation labels, chevrons and the glyph beside a time. They
          // point at things and they invite taps, so they are held to the
          // text bar and not to the 3:1 one for decoration.
          ('tertiary', LoopColors.textTertiary),
        ]) {
          expect(
            contrast(color, ground),
            greaterThanOrEqualTo(aa),
            reason: '$level text on $name',
          );
        }
      }
    });

    test('the ladder still reads as a ladder', () {
      // Lifting tertiary to meet AA compressed the gap on purpose — hierarchy
      // is carried by size and weight now — but the order must not invert.
      expect(
        LoopColors.textPrimary.computeLuminance(),
        greaterThan(LoopColors.textSecondary.computeLuminance()),
      );
      expect(
        LoopColors.textSecondary.computeLuminance(),
        greaterThan(LoopColors.textTertiary.computeLuminance()),
      );
    });
  });

  group('accents used as text elsewhere', () {
    test('the countdown and UP NEXT read on a plain card', () {
      expect(
        contrast(LoopColors.aiText, LoopColors.surface),
        greaterThanOrEqualTo(aa),
      );
    });

    test('the calendar action reads on the raised surface it sits on', () {
      expect(
        contrast(LoopColors.aiText, LoopColors.surfaceRaised),
        greaterThanOrEqualTo(aa),
      );
    });

    test('the selected navigation label reads on the bar', () {
      expect(
        contrast(LoopColors.aiAlt, LoopColors.surface),
        greaterThanOrEqualTo(aa),
      );
    });
  });
}
