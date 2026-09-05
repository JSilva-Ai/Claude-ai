/// The five seams the architecture names, and nothing behind any of them.
///
/// **Every one of these is an interface. None has a vendor implementation in
/// this codebase.** That is not a placeholder statement — it is the thing 2B
/// is required to prove, and `zero_model_baseline_test.dart` proves it by
/// listing the implementations that exist and asserting each is a rule, never
/// a client for Claude, OpenAI, Gemini or anything else that makes a network
/// call. A provider arrives later by implementing one of these; the domain
/// that calls through them does not change on that day, because it never knew
/// which kind of implementation it had.
///
/// The shared contract, per the architecture: every port takes redacted,
/// already-structured input and returns typed output carrying its own
/// `PolicyRef` or producer — never a client, a key, or a prompt. A prompt
/// belongs to whichever adapter eventually implements one of these; it cannot
/// appear here without the layering test failing.
library;

import '../../evidence/claim.dart';
import '../../ids.dart';
import '../action_suggestion.dart';
import '../loop_signals.dart';
import '../risk_assessment.dart';
import 'source_signal.dart';

/// Text and structured signals in, named entities out — dates, parties,
/// amounts. No implementation in 2B: `SignalExtractor` already does the one
/// piece of "extraction" 2B's evidence model supports (reading a claim's own
/// structured fields), so a port whose job is free-text extraction has
/// nothing yet to extract from.
abstract interface class EntityExtractor {
  List<ExtractedEntity> extractFrom(SourceSignal signal);
}

class ExtractedEntity {
  const ExtractedEntity({required this.kind, required this.text});

  final EntityKind kind;

  /// The source's own words, kept verbatim — never generated.
  final String text;
}

enum EntityKind { person, date, amount, place }

/// Evidence in, a judgement of whether it describes a commitment out.
///
/// Unimplemented in 2B for the same reason as [EntityExtractor]: the rule that
/// would drive it — recognising a promise in free text — is exactly the kind
/// of pattern-matching the architecture asks not to fabricate ahead of real
/// data. The port exists so a rule-based implementation, and later a model,
/// have somewhere to plug in without the caller changing.
abstract interface class CommitmentDetector {
  CommitmentDetection detect(SourceSignal signal);
}

class CommitmentDetection {
  const CommitmentDetection({required this.looksLikeCommitment, this.claim});

  final bool looksLikeCommitment;
  final Claim? claim;
}

/// Signals in, a [RiskAssessment] out. **Implemented** — by `RiskPolicy`,
/// which is the zero-model baseline this port exists to eventually be
/// compared against. Any future model-backed implementation has to beat it,
/// not merely exist.
abstract interface class RiskPredictor {
  RiskAssessment assess(LoopSignals signals);
}

/// Signals in, the ranked candidates out. **Implemented** — by
/// `NextActionPolicy` and its rule table, the other half of the zero-model
/// baseline.
abstract interface class NextActionRecommender {
  List<ActionSuggestion> recommend(LoopId loop, LoopSignals signals);
}

/// Summarising, grouping, similarity across loops. No signal in 2B spans more
/// than one loop at a time — `LoopSignals` is deliberately single-loop, per its
/// own doc — so a port whose job is cross-loop reasoning has nothing to read
/// yet. Deferred to whichever phase gives loops to each other to compare.
abstract interface class ContextIntelligence {
  ContextSummary summarize(List<LoopSignals> signals);
}

class ContextSummary {
  const ContextSummary({required this.headline});

  /// A reason code today; free text is a presentation concern once this port
  /// has an implementation to write one from.
  final String headline;
}
