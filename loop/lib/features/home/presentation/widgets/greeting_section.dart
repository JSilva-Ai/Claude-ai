import 'package:flutter/material.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/loop_colors.dart';
import '../../../../core/theme/loop_dimens.dart';
import '../../../../core/theme/loop_theme.dart';
import '../../../../core/utils/greeting.dart';
import '../../models/user_profile.dart';

/// "Good morning, Jorge." and the line under it.
///
/// Both halves are data: the hour picks the greeting, the profile supplies the
/// name. Nothing here is a constant string, which is the point — this is the
/// first thing on the screen and the fastest way to make an app feel generic
/// is to greet everybody the same way at every hour.
class GreetingSection extends StatelessWidget {
  const GreetingSection({
    required this.profile,
    required this.now,
    super.key,
  });

  final UserProfile profile;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DayPart part = dayPartFor(now);

    final String greeting = switch (part) {
      DayPart.morning => l10n.greetingMorning,
      DayPart.afternoon => l10n.greetingAfternoon,
      DayPart.evening => l10n.greetingEvening,
    };

    final (IconData icon, Color color) = switch (part) {
      DayPart.morning => (Icons.wb_sunny_rounded, LoopColors.waiting),
      DayPart.afternoon => (Icons.wb_twilight_rounded, LoopColors.waiting),
      DayPart.evening => (Icons.nightlight_round, LoopColors.ai),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // The icon sits inline with the first line of text rather than in its
        // own column, so at a large accessibility text size the heading wraps
        // under it instead of being squeezed into a narrow strip beside it.
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: LoopSpacing.sm),
                  child: Icon(icon, size: 26, color: color),
                ),
              ),
              TextSpan(
                text: l10n.greetingWithName(greeting, profile.firstName),
              ),
            ],
          ),
          style: context.text.displaySmall,
        ),
        const SizedBox(height: LoopSpacing.xs),
        Text(l10n.heresWhatsImportant, style: context.text.bodyLarge),
      ],
    );
  }
}
