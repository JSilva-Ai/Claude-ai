import 'package:flutter/material.dart';

import '../../../../core/animations/entrance.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/loop_colors.dart';
import '../../../../core/theme/loop_dimens.dart';
import '../../../../core/utils/clock.dart';
import '../../models/ai_insight.dart';
import '../../models/home_snapshot.dart';
import '../../models/loop_category.dart';
import '../../models/upcoming_item.dart';
import '../../models/user_profile.dart';
import '../../state/home_controller.dart';
import '../../state/home_state.dart';
import '../widgets/active_loops_indicator.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/category_presentation.dart';
import '../widgets/coming_soon_sheet.dart';
import '../widgets/greeting_section.dart';
import '../widgets/home_background.dart';
import '../widgets/home_header.dart';
import '../widgets/home_status_views.dart';
import '../widgets/language_sheet.dart';
import '../widgets/loop_bottom_navigation.dart';
import '../widgets/loop_summary_card.dart';
import '../widgets/up_next_card.dart';

/// The Home.
///
/// It answers one question — what needs me today — and it is built so the
/// answer survives a phone, a Pro Max and a tablet: one column, capped at a
/// readable width and centred, scrolling when it has to. There is no fixed
/// height anywhere in this file, which is what stops the layout from being a
/// copy of a single screen size.
class HomeScreen extends StatefulWidget {
  const HomeScreen({this.clock = const Clock(), super.key});

  final Clock clock;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LoopDestination _destination = LoopDestination.home;

  @override
  Widget build(BuildContext context) {
    final HomeController controller = HomeScope.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      body: HomeBackground(
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: LoopSizes.maxContentWidth,
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      LoopSpacing.pagePadding,
                      LoopSpacing.xs,
                      LoopSpacing.pagePadding,
                      LoopSpacing.xs,
                    ),
                    child: _Header(controller: controller),
                  ),
                  Expanded(
                    child: switch (controller.state) {
                      HomeLoading() => const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: LoopSpacing.pagePadding,
                          ),
                          child: HomeLoadingView(),
                        ),
                      HomeFailure() => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: LoopSpacing.pagePadding,
                          ),
                          child: HomeErrorView(onRetry: controller.load),
                        ),
                      HomeReady(snapshot: final HomeSnapshot snapshot) =>
                        snapshot.isEmpty
                            ? const HomeEmptyView()
                            : _HomeContent(
                                snapshot: snapshot,
                                clock: widget.clock,
                                onRefresh: controller.refresh,
                              ),
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: LoopBottomNavigation(
        current: _destination,
        onSelected: (LoopDestination destination) {
          // Create is an action, not a tab: it must not leave the bar showing
          // a selected state for a page that was never opened.
          if (destination != LoopDestination.create) {
            setState(() => _destination = destination);
          }
          showComingSoonSheet(context, _labelFor(l10n, destination));
        },
      ),
    );
  }

  static String _labelFor(AppLocalizations l10n, LoopDestination destination) =>
      switch (destination) {
        LoopDestination.home => l10n.navHome,
        LoopDestination.loops => l10n.navLoops,
        LoopDestination.create => l10n.navCreate,
        LoopDestination.focus => l10n.navFocus,
        LoopDestination.more => l10n.navMore,
      };
}

/// The header needs the profile, which only exists once the snapshot has
/// loaded. Rather than hiding it while loading — which would make the page
/// jump the moment data arrived — it renders with the anonymous profile.
class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final HomeState state = controller.state;

    return HomeHeader(
      profile:
          state is HomeReady ? state.snapshot.profile : UserProfile.anonymous,
      onMenuPressed: () => showLanguageSheet(context),
      onProfilePressed: () => showComingSoonSheet(
        context,
        AppLocalizations.of(context).profileButton,
      ),
    );
  }
}

/// The scrolling part of the page.
class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.snapshot,
    required this.clock,
    required this.onRefresh,
  });

  final HomeSnapshot snapshot;
  final Clock clock;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AIInsight? insight = snapshot.insight;
    final UpcomingItem? upNext = snapshot.upNext;

    // Entrance order is reading order, so the eye is led down the page once
    // rather than everything appearing at the same instant.
    int step = 0;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: LoopColors.aiAlt,
      backgroundColor: LoopColors.surface,
      child: ListView(
        // Always scrollable: on a small phone the page overflows and on a
        // tablet it does not, and pull-to-refresh has to work in both.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          LoopSpacing.pagePadding,
          LoopSpacing.md,
          LoopSpacing.pagePadding,
          LoopSpacing.lg,
        ),
        children: <Widget>[
          Entrance(
            index: step++,
            child: _GreetingRow(snapshot: snapshot, clock: clock),
          ),
          const SizedBox(height: LoopSpacing.lg),
          for (final LoopCategory category in LoopCategory.values) ...<Widget>[
            Entrance(
              index: step++,
              child: LoopSummaryCard(
                summary: LoopSummary(
                  category: category,
                  count: snapshot.countOf(category),
                ),
                onPressed: () => showComingSoonSheet(
                  context,
                  CategoryPresentation.of(context, category).title,
                ),
              ),
            ),
            const SizedBox(height: LoopSpacing.xs + 2),
          ],
          if (insight != null) ...<Widget>[
            const SizedBox(height: LoopSpacing.xs),
            Entrance(
              index: step++,
              child: AIInsightCard(
                insight: insight,
                onPressed: () => showComingSoonSheet(context, l10n.aiInsight),
              ),
            ),
            const SizedBox(height: LoopSpacing.sm),
          ],
          if (upNext != null)
            Entrance(
              index: step++,
              child: UpNextCard(
                item: upNext,
                clock: clock,
                onPressed: () => showComingSoonSheet(context, l10n.upNext),
                onAddToCalendar: upNext.isOnCalendar
                    ? null
                    : () => showComingSoonSheet(context, l10n.addToCalendar),
              ),
            ),
        ],
      ),
    );
  }
}

/// The greeting and the ring.
///
/// Side by side where there is room; stacked where there is not. The threshold
/// is measured against the actual constraint rather than against a device
/// list, so it holds on a split-screen Android window as well as on a small
/// iPhone.
class _GreetingRow extends StatelessWidget {
  const _GreetingRow({required this.snapshot, required this.clock});

  final HomeSnapshot snapshot;
  final Clock clock;

  static const double _stackBelow = 340;

  @override
  Widget build(BuildContext context) {
    final Widget greeting = GreetingSection(
      profile: snapshot.profile,
      now: clock.now(),
    );
    final Widget ring = ActiveLoopsIndicator(
      activeLoops: snapshot.activeLoops,
      ratio: snapshot.openRatio,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < _stackBelow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              greeting,
              const SizedBox(height: LoopSpacing.lg),
              Center(child: ring),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: greeting),
            const SizedBox(width: LoopSpacing.md),
            ring,
          ],
        );
      },
    );
  }
}
