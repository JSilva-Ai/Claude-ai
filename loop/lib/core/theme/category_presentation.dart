import 'package:flutter/material.dart';

import '../localization/l10n/app_localizations.dart';
import 'loop_theme.dart';
import '../models/loop_category.dart';

/// Everything the presentation layer needs to know about a category: its
/// words, its colour and its icon.
///
/// One table, resolved from the model, so a category cannot pick up a red
/// label in one place and an amber one in another — and so the accessibility
/// rule holds by construction: every card gets colour *and* an icon *and*
/// text, never colour alone.
@immutable
class CategoryPresentation {
  const CategoryPresentation({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });

  final String title;
  final String description;
  final Color color;
  final IconData icon;

  static CategoryPresentation of(BuildContext context, LoopCategory category) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LoopAccents accents = context.accents;

    return switch (category) {
      LoopCategory.atRisk => CategoryPresentation(
          title: l10n.atRisk,
          description: l10n.atRiskDescription,
          color: accents.atRisk,
          icon: Icons.priority_high_rounded,
        ),
      LoopCategory.waiting => CategoryPresentation(
          title: l10n.waiting,
          description: l10n.waitingDescription,
          color: accents.waiting,
          icon: Icons.schedule_rounded,
        ),
      LoopCategory.today => CategoryPresentation(
          title: l10n.today,
          description: l10n.todayDescription,
          color: accents.today,
          icon: Icons.calendar_today_rounded,
        ),
      LoopCategory.done => CategoryPresentation(
          title: l10n.done,
          description: l10n.doneDescription,
          color: accents.done,
          icon: Icons.check_rounded,
        ),
    };
  }
}
