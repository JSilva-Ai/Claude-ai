import 'package:flutter/material.dart';

import 'loop_colors.dart';

/// The type scale.
///
/// No font file is bundled: the system face (SF on iOS, Roboto on Android)
/// is what a premium app on each platform is expected to look like, it is
/// already hinted for that platform's rendering, and it costs nothing to
/// download. A brand face can replace `fontFamily` here alone.
@immutable
class LoopTypography {
  const LoopTypography._();

  static const TextTheme textTheme = TextTheme(
    // The greeting.
    displaySmall: TextStyle(
      fontSize: 27,
      height: 1.16,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.6,
      color: LoopColors.textPrimary,
    ),
    // Card headlines.
    titleLarge: TextStyle(
      fontSize: 17,
      height: 1.25,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: LoopColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: LoopColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 14.5,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: LoopColors.textSecondary,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      height: 1.35,
      fontWeight: FontWeight.w400,
      color: LoopColors.textSecondary,
    ),
    // The eyebrow above a card: AT RISK, AI INSIGHT, UP NEXT.
    labelLarge: TextStyle(
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
      color: LoopColors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.4,
      color: LoopColors.textSecondary,
    ),
    labelSmall: TextStyle(
      fontSize: 10.5,
      height: 1.2,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
      color: LoopColors.textSecondary,
    ),
  );

  /// Counts and the ring's number: tabular so a 3 changing to a 4 does not
  /// shift the layout beside it.
  static const TextStyle counter = TextStyle(
    fontSize: 27,
    height: 1,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  static const TextStyle ringValue = TextStyle(
    fontSize: 28,
    height: 1,
    fontWeight: FontWeight.w600,
    letterSpacing: -1,
    color: LoopColors.textPrimary,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// The wordmark. Wide tracking, light weight — the logo carries the brand,
  /// it does not shout.
  static const TextStyle wordmark = TextStyle(
    fontSize: 19,
    height: 1,
    fontWeight: FontWeight.w300,
    letterSpacing: 5.5,
    color: LoopColors.textPrimary,
  );
}
