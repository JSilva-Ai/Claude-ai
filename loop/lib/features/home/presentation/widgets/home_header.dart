import 'package:flutter/material.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/loop_colors.dart';
import '../../../../core/theme/loop_dimens.dart';
import '../../../../core/theme/loop_theme.dart';
import '../../../../core/widgets/loop_logo.dart';
import '../../../../core/widgets/pressable.dart';
import '../../models/user_profile.dart';

/// Menu, wordmark, avatar.
///
/// The wordmark is centred against the page rather than against the space
/// between the two buttons, so it stays put when the avatar gains a badge or
/// the menu button changes width. That is the whole reason this is a [Stack]
/// and not a [Row].
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.profile,
    this.onMenuPressed,
    this.onProfilePressed,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onProfilePressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SizedBox(
      height: LoopSizes.minTouchTarget,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          const Center(child: LoopWordmark()),
          Align(
            alignment: Alignment.centerLeft,
            child: Pressable(
              onPressed: onMenuPressed,
              semanticLabel: l10n.menuButton,
              minSize: LoopSizes.minTouchTarget,
              child: const _MenuButton(),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Pressable(
              onPressed: onProfilePressed,
              // Composed here rather than left to merge: the avatar's own
              // parts — the initial and the status dot — are decoration, and
              // a screen reader announcing "Your profile J Online" is what
              // merging them produces.
              semanticLabel: profile.isOnline
                  ? '${l10n.profileButton}, ${l10n.statusOnline}'
                  : l10n.profileButton,
              minSize: LoopSizes.minTouchTarget,
              child: ExcludeSemantics(child: _Avatar(profile: profile)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: LoopSizes.headerButton,
      height: LoopSizes.headerButton,
      decoration: BoxDecoration(
        color: LoopColors.surface.withValues(alpha: 0.7),
        borderRadius: const BorderRadius.all(LoopRadius.sm),
        border: Border.all(color: context.accents.border),
      ),
      child: const Icon(
        Icons.menu_rounded,
        size: 20,
        color: LoopColors.textPrimary,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final LoopAccents accents = context.accents;
    final String? url = profile.avatarUrl;

    return SizedBox.square(
      dimension: LoopSizes.avatar + 4,
      child: Stack(
        children: <Widget>[
          Container(
            width: LoopSizes.avatar,
            height: LoopSizes.avatar,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accents.surfaceRaised,
              border: Border.all(color: accents.borderStrong),
              image: url == null
                  ? null
                  : DecorationImage(
                      image: NetworkImage(url),
                      fit: BoxFit.cover,
                    ),
            ),
            // The initial is not a placeholder for a picture that failed to
            // load — most accounts will never have one — so it is styled to
            // be a finished state rather than an apology.
            child: url != null
                ? null
                : Center(
                    child: Text(
                      profile.initial,
                      style: context.text.titleMedium,
                    ),
                  ),
          ),
          if (profile.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Semantics(
                label: AppLocalizations.of(context).statusOnline,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LoopColors.online,
                    border: Border.all(
                      color: LoopColors.backgroundTop,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
