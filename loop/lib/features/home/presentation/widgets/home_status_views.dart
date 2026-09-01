import 'package:flutter/material.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/loop_colors.dart';
import '../../../../core/theme/loop_dimens.dart';
import '../../../../core/theme/loop_motion.dart';
import '../../../../core/theme/loop_theme.dart';
import '../../../../core/models/loop_category.dart';
import '../../../../core/widgets/loop_completion.dart';
import '../../../../core/widgets/loop_surface.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_badge.dart';

/// Loading, error and empty.
///
/// They exist in phase 1 even though the mock repository barely fails, because
/// a layout that has only ever been drawn with data is a layout that assumes
/// data. These three are what the screen does the first time a network is
/// involved, and finding that out later is finding it out from a user.

/// Skeleton rather than a spinner: it holds the shape of the page, so the
/// content does not jump when it arrives.
class HomeLoadingView extends StatefulWidget {
  const HomeLoadingView({super.key});

  @override
  State<HomeLoadingView> createState() => _HomeLoadingViewState();
}

class _HomeLoadingViewState extends State<HomeLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // A pulse that never stops is exactly the animation "reduce motion"
      // exists to switch off.
      if (!LoopMotion.reduced(context)) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).loading,
      liveRegion: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          final double opacity = 0.35 + 0.25 * _controller.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Bar(width: 220, height: 30, opacity: opacity),
              const SizedBox(height: LoopSpacing.sm),
              _Bar(width: 150, height: 15, opacity: opacity),
              const SizedBox(height: LoopSpacing.xl),
              for (int i = 0; i < 4; i++) ...<Widget>[
                _Bar(height: 76, opacity: opacity),
                const SizedBox(height: LoopSpacing.sm),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.opacity, this.width});

  final double? width;
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: LoopColors.surfaceMuted.withValues(alpha: opacity),
          borderRadius: const BorderRadius.all(LoopRadius.sm),
        ),
      ),
    );
  }
}

class HomeErrorView extends StatelessWidget {
  const HomeErrorView({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Center(
      child: LoopSurface(
        accent: context.accents.atRisk,
        padding: const EdgeInsets.all(LoopSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.wifi_tethering_off_rounded,
              color: context.accents.atRisk,
              size: 28,
            ),
            const SizedBox(height: LoopSpacing.md),
            Text(l10n.errorTitle, style: context.text.titleLarge),
            const SizedBox(height: LoopSpacing.xxs),
            Text(l10n.errorBody, style: context.text.bodyMedium),
            const SizedBox(height: LoopSpacing.lg),
            // The one thing this screen is for, so it carries the brand
            // gradient rather than a quiet border.
            PrimaryButton(
              label: l10n.retry,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

/// Nothing open. The one screen in the product that is allowed to be a
/// celebration rather than a to-do list.
class HomeEmptyView extends StatelessWidget {
  const HomeEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // The only place in phase 1 where a loop actually closes on screen.
          const LoopCompletion(
            footer: StatusBadge(category: LoopCategory.done),
          ),
          const SizedBox(height: LoopSpacing.lg),
          Text(l10n.emptyTitle, style: context.text.titleLarge),
          const SizedBox(height: LoopSpacing.xxs),
          Text(
            l10n.emptyBody,
            style: context.text.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
