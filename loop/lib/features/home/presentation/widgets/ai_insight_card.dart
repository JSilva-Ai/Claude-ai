import 'package:flutter/material.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/loop_colors.dart';
import '../../../../core/theme/loop_dimens.dart';
import '../../../../core/theme/loop_theme.dart';
import '../../../../core/widgets/loop_logo.dart';
import '../../../../core/widgets/loop_surface.dart';
import '../../../../core/widgets/pressable.dart';
import '../../models/ai_insight.dart';

/// What LOOP noticed.
///
/// The card takes an [AIInsight] and renders whatever it holds — it has no
/// opinion about the sentence, which is what will let the context engine write
/// it later without this file changing. The tone only picks the accent; it
/// never rewrites the words.
///
/// Deliberately quiet: one small label, a violet mark, no badge shouting "AI".
class AIInsightCard extends StatelessWidget {
  const AIInsightCard({required this.insight, this.onPressed, super.key});

  final AIInsight insight;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LoopAccents accents = context.accents;

    final Color accent = switch (insight.tone) {
      InsightTone.positive => accents.ai,
      InsightTone.neutral => accents.ai,
      InsightTone.attention => accents.waiting,
    };

    final String? detail = insight.detail;

    return Pressable(
      onPressed: onPressed,
      isButton: onPressed != null,
      child: LoopSurface(
        accent: accent,
        padding: const EdgeInsets.fromLTRB(
          LoopSpacing.md,
          LoopSpacing.sm + 2,
          LoopSpacing.sm,
          LoopSpacing.sm + 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.auto_awesome, size: 15, color: accent),
                      const SizedBox(width: LoopSpacing.xs),
                      Flexible(
                        child: Text(
                          l10n.aiInsight,
                          style:
                              context.text.labelMedium?.copyWith(color: accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: LoopSpacing.sm),
                  Text(insight.headline, style: context.text.titleLarge),
                  if (detail != null) ...<Widget>[
                    const SizedBox(height: LoopSpacing.xxs),
                    Text(detail, style: context.text.bodyMedium),
                  ],
                ],
              ),
            ),
            const SizedBox(width: LoopSpacing.sm),
            _InsightMark(accent: accent),
          ],
        ),
      ),
    );
  }
}

/// The closed loop with a check inside it.
///
/// The reference shows a rendered 3D torus here. This draws the same idea as
/// vector: sharp at any pixel ratio, themeable, a few hundred bytes of code
/// instead of a raster asset that would need an @2x and an @3x and would still
/// be the wrong violet the day the accent changes.
class _InsightMark extends StatelessWidget {
  const _InsightMark({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withValues(alpha: 0.28),
              blurRadius: 24,
              spreadRadius: -6,
            ),
          ],
        ),
        child: const Center(
          child: LoopMark(
            size: 54,
            strokeWidth: 5.5,
            completion: 1,
            colors: <Color>[
              LoopColors.ai,
              Color(0xFF6B8BFF),
              LoopColors.aiAlt,
            ],
          ),
        ),
      ),
    );
  }
}
