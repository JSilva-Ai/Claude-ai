import 'package:flutter/material.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/loop_dimens.dart';
import '../../../../core/theme/loop_theme.dart';
import '../../../../core/widgets/loop_logo.dart';
import '../../../../core/widgets/primary_button.dart';

/// Where a later phase's screen will be.
///
/// Every tap target on the Home leads somewhere, even now. A card that does
/// nothing when pressed reads as broken, and the fix — a sheet that names the
/// section — is also the seam a real route slots into later.
Future<void> showComingSoonSheet(BuildContext context, String section) {
  return showModalBottomSheet<void>(
    context: context,
    // The gradient behind it is part of the page; a barrier this dark keeps
    // the sheet from looking like it is floating on grey.
    barrierColor: const Color(0xB3000000),
    builder: (BuildContext context) => _ComingSoonSheet(section: section),
  );
}

class _ComingSoonSheet extends StatelessWidget {
  const _ComingSoonSheet({required this.section});

  final String section;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          LoopSpacing.xl,
          LoopSpacing.xs,
          LoopSpacing.xl,
          LoopSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const LoopMark(size: 34, strokeWidth: 3, progress: 0.7),
            const SizedBox(height: LoopSpacing.md),
            Text(
              l10n.comingSoonTitle(section),
              style: context.text.titleLarge,
            ),
            const SizedBox(height: LoopSpacing.xs),
            Text(l10n.comingSoonBody, style: context.text.bodyMedium),
            const SizedBox(height: LoopSpacing.lg),
            // A named way out, not just the drag handle. A sheet whose only
            // dismissal is a gesture is a sheet a screen-reader user is stuck
            // in, and the handle carries no label of its own.
            Align(
              alignment: Alignment.centerRight,
              child: PrimaryButton(
                label: l10n.close,
                variant: PrimaryButtonVariant.quiet,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
