import '../loop/loop.dart';
import '../loop/loop_state.dart';

/// When a proposal nobody answered has gone quiet for too long.
///
/// **This policy never changes anything.** It answers a question about a loop
/// and a moment, and the answer changes as the moment does — which is precisely
/// why it is a predicate and not a state. A `detected` proposal that has gone
/// stale simply stops being surfaced.
///
/// The mutation, when it happens, is a separate and deliberate act: a
/// reconciliation pass at a moment we can name — the app opening, a manual
/// refresh — applying `ExpireProposal`, which writes an event with an actor and
/// a reason like any other transition. Derivation is continuous; mutation is
/// punctual and has an author.
class StalenessPolicy {
  const StalenessPolicy({this.proposalTtl = const Duration(days: 14)});

  /// How long an unanswered proposal stays worth showing. A starting value, in
  /// the same spirit as the confidence calibration: a hypothesis, not a truth.
  final Duration proposalTtl;

  /// True when a proposal has been waiting for an answer longer than its
  /// lifetime. Meaningless for any other state — only `detected` is a proposal.
  bool isStale(Loop loop, {required DateTime now}) {
    if (loop.state != LoopState.detected) return false;
    return now.difference(loop.stateChangedAt) > proposalTtl;
  }
}
