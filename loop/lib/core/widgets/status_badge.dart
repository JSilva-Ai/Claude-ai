import 'package:flutter/material.dart';

import '../models/loop_category.dart';
import '../theme/category_presentation.dart';
import '../theme/loop_colors.dart';
import '../theme/loop_dimens.dart';
import '../theme/loop_elevation.dart';
import '../theme/loop_theme.dart';

/// How a state is shown.
enum StatusBadgeVariant {
  /// The glyph alone, ringed and lit — what a summary card leads with.
  icon,

  /// The glyph and the word together, as a pill.
  pill,
}

/// One of the four states of a loop, drawn.
///
/// This is the single place that answers "what does AT RISK look like", for
/// both shapes it is drawn in. It matters more than it looks: the states are
/// what the product communicates, and the day a fifth one is added, or the
/// amber is judged too loud, this is the file.
///
/// **It never relies on colour alone.** Every variant carries the category's
/// icon, the pill carries its word as well, and both announce the localized
/// name to a screen reader. Someone who cannot separate the red from the amber
/// still reads the state — which is also true of anyone glancing at the screen
/// in sunlight.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.category,
    this.variant = StatusBadgeVariant.pill,
    this.size = LoopSizes.summaryIcon,
    super.key,
  });

  final LoopCategory category;
  final StatusBadgeVariant variant;

  /// The diameter of the [StatusBadgeVariant.icon] form. Ignored by the pill,
  /// which is sized by its own text.
  final double size;

  @override
  Widget build(BuildContext context) {
    final CategoryPresentation style = CategoryPresentation.of(
      context,
      category,
    );

    return Semantics(
      label: style.title,
      container: true,
      excludeSemantics: true,
      child: switch (variant) {
        StatusBadgeVariant.icon => _Icon(style: style, size: size),
        StatusBadgeVariant.pill => _Pill(style: style),
      },
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon({required this.style, required this.size});

  final CategoryPresentation style;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: LoopColors.surface,
        border: Border.all(
          color: style.color.withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: LoopElevation.glowSmall(style.color),
      ),
      child: Icon(style.icon, size: size * 0.5, color: style.color),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.style});

  final CategoryPresentation style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LoopSpacing.sm,
        vertical: LoopSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          style.color.withValues(alpha: 0.16),
          LoopColors.surface,
        ),
        borderRadius: const BorderRadius.all(LoopRadius.sm),
        border: Border.all(color: style.color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(style.icon, size: 13, color: style.color),
          const SizedBox(width: LoopSpacing.xxs + 2),
          Text(
            style.title,
            style: context.text.labelMedium?.copyWith(color: style.color),
          ),
        ],
      ),
    );
  }
}
