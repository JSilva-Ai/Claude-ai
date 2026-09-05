import '../../core/models/loop_category.dart';
import '../../domain/evidence/evidence.dart';
import '../../domain/evidence/provenance.dart';
import '../../domain/ids.dart';
import '../../domain/intelligence/loop_signals.dart';
import '../../domain/intelligence/risk_policy.dart';
import '../../features/home/models/ai_insight.dart';
import '../../features/home/models/home_snapshot.dart';
import '../../features/home/models/upcoming_item.dart';
import '../../features/home/models/user_profile.dart';
import '../loop_repository.dart';
import 'loop_category_policy.dart';

/// Turns persisted loops into the one thing the Home actually draws.
///
/// Pure: no repository, no database, no clock read internally — every input
/// arrives as an argument, [now] included, so a test can build the whole
/// scenario by hand the way `test/domain/fixtures.dart` already does for the
/// domain. Runs entirely on [RiskPolicy] and [categoriesFor], both rule
/// tables with zero model calls — that stays true structurally, since
/// nothing in this file's own imports can reach a network or a vendor SDK;
/// see `test/architecture/` for the guard.
///
/// [profile], [insight] and [upNext] are accepted, not produced: nothing a
/// `Loop` records can honestly become a [UserProfile], and neither an AI
/// insight nor an upcoming calendar item is in scope for this phase (or, for
/// the insight, for any phase yet authorised). Passing `null` for either
/// is what `MockHomeRepository` already does for the same reason.
HomeSnapshot projectHome({
  required List<LoopContext> contexts,
  required EvidenceResolver resolveEvidence,
  required UserProfile profile,
  required DateTime now,
  RiskPolicy riskPolicy = RiskPolicy.v1,
  AIInsight? insight,
  UpcomingItem? upNext,
}) {
  const SignalExtractor extractor = SignalExtractor();

  final Map<LoopCategory, int> counts = <LoopCategory, int>{
    for (final LoopCategory category in LoopCategory.values) category: 0,
  };
  int activeLoops = 0;

  for (final LoopContext context in contexts) {
    if (!context.loop.state.isTerminal) activeLoops++;

    final LoopSignals signals = extractor.extract(
      context.loop,
      evidence: resolveEvidence,
      now: now,
      history: context.events,
    );
    final risk = riskPolicy.evaluate(signals);

    for (final LoopCategory category in categoriesFor(
      loop: context.loop,
      risk: risk,
      signals: signals,
      now: now,
    )) {
      counts[category] = counts[category]! + 1;
    }
  }

  return HomeSnapshot(
    profile: profile,
    summaries: counts,
    // Always the distinct count, never left null to fall back to the sum of
    // overlapping categories — see HomeSnapshot.activeLoops' own doc for why
    // that fallback exists, and why a source that *can* tell loops apart,
    // as this one can, should not use it.
    activeLoops: activeLoops,
    insight: insight,
    upNext: upNext,
  );
}

/// Reads every loop through [repository] and projects them, in the bounded
/// number of queries [LoopRepository.readAllLoopContexts] promises — not one
/// per loop. The [EvidenceResolver] this builds is pooled across every
/// loop's evidence at once, because an [Inference]'s provenance chain is not
/// guaranteed to stay inside the evidence attached to the one loop asking
/// for it.
///
/// Not wired to anything yet: 2C-B stops at proving this function produces a
/// correct [HomeSnapshot] from real, persisted data. Connecting it to
/// [HomeController] is 2C-C's work.
Future<HomeSnapshot> loadHomeSnapshot({
  required LoopRepository repository,
  required UserProfile profile,
  required DateTime now,
  RiskPolicy riskPolicy = RiskPolicy.v1,
  AIInsight? insight,
  UpcomingItem? upNext,
}) async {
  final List<LoopContext> contexts = await repository.readAllLoopContexts();

  final Map<String, Evidence> pooledEvidence = <String, Evidence>{
    for (final LoopContext context in contexts)
      for (final Evidence evidence in context.evidence)
        evidence.id.value: evidence,
  };
  Evidence? resolve(EvidenceId id) => pooledEvidence[id.value];

  return projectHome(
    contexts: contexts,
    resolveEvidence: resolve,
    profile: profile,
    now: now,
    riskPolicy: riskPolicy,
    insight: insight,
    upNext: upNext,
  );
}
