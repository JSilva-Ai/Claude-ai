import 'package:flutter/material.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/loop_colors.dart';
import '../../../../core/theme/loop_dimens.dart';
import '../../../../core/theme/loop_theme.dart';
import '../../../../core/theme/loop_typography.dart';
import '../../../../core/widgets/loop_surface.dart';
import '../../../../core/widgets/pressable.dart';
import '../../models/loop_category.dart';
import 'category_presentation.dart';

/// One state of the user's life, as a row: icon, name, what it means, count.
///
/// Reused for all four categories. The count is the only number on the card
/// and it is set in tabular figures, so 2 becoming 3 does not nudge the
/// chevron — a small thing that separates a product from a prototype.
class LoopSummaryCard extends StatelessWidget {
  const LoopSummaryCard({required this.summary, this.onPressed, super.key});

  final LoopSummary summary;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final CategoryPresentation style =
        CategoryPresentation.of(context, summary.category);

    return Pressable(
      onPressed: onPressed,
      semanticLabel: l10n.summaryCardSemantics(
        style.title,
        style.description,
        summary.count,
      ),
      child: ExcludeSemantics(
        child: LoopSurface(
          accent: style.color,
          // Tight enough that the four states plus both cards below them are
          // one screen on a 390pt phone — the reference's whole premise is
          // that the answer is visible without scrolling.
          padding: const EdgeInsets.symmetric(
            horizontal: LoopSpacing.md,
            vertical: LoopSpacing.sm + 1,
          ),
          child: Row(
            children: <Widget>[
              _CategoryIcon(color: style.color, icon: style.icon),
              const SizedBox(width: LoopSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      style.title,
                      style: context.text.labelLarge?.copyWith(
                        color: style.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Portuguese and Spanish run longer than English here
                    // ("Esperando otras personas" against "Waiting for
                    // others"), so the description is allowed two lines
                    // rather than being clipped to one.
                    Text(
                      style.description,
                      style: context.text.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: LoopSpacing.sm),
              Text(
                '${summary.count}',
                style: LoopTypography.counter.copyWith(color: style.color),
              ),
              const SizedBox(width: LoopSpacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: context.accents.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: LoopSizes.summaryIcon,
      height: LoopSizes.summaryIcon,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: LoopColors.surface,
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1.5),
        // A single soft shadow in the accent colour. This is the "glow" from
        // the reference; it is one shadow, not a blur filter, so it costs the
        // rasteriser almost nothing.
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 14,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Icon(icon, size: 21, color: color),
    );
  }
}
