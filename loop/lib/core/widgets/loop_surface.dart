import 'package:flutter/material.dart';

import '../theme/loop_colors.dart';
import '../theme/loop_dimens.dart';

/// The card.
///
/// One container, tinted by an accent when it has one. The tint is a very low
/// alpha wash from the leading edge — enough that AT RISK and DONE are
/// different objects at a glance, far short of a coloured panel. The accent
/// never touches the border at more than a sixth of its strength, which is what
/// keeps four of these in a column from reading as a set of alerts.
class LoopSurface extends StatelessWidget {
  const LoopSurface({
    required this.child,
    this.accent,
    this.padding = const EdgeInsets.all(LoopSpacing.md),
    this.borderRadius = LoopRadius.card,
    super.key,
  });

  final Widget child;
  final Color? accent;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final Color? accent = this.accent;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: accent == null
              ? LoopColors.border
              : accent.withValues(alpha: 0.22),
        ),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: accent == null
              ? const <Color>[LoopColors.surface, LoopColors.surface]
              : <Color>[
                  Color.alphaBlend(
                    accent.withValues(alpha: 0.16),
                    LoopColors.surface,
                  ),
                  LoopColors.surface,
                ],
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
