import 'package:loop/domain/evidence/confidence.dart';
import 'package:loop/domain/evidence/evidence.dart';
import 'package:loop/domain/evidence/provenance.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/intelligence/attention_assessment.dart';
import 'package:loop/domain/intelligence/attention_policy.dart';
import 'package:loop/domain/intelligence/loop_signals.dart';
import 'package:loop/domain/intelligence/risk_assessment.dart';
import 'package:loop/domain/intelligence/risk_policy.dart';
import 'package:loop/domain/loop/loop_state.dart';

import '../fixtures.dart' show t0;
export '../fixtures.dart'
    show t0, loopId, marina, basisId, fact, inference, assertion, confidence;

const RiskPolicy risk = RiskPolicy.v1;
const AttentionPolicy attention = AttentionPolicy.v1;

/// Builds [LoopSignals] directly, the way `loopIn` in the 2A fixtures builds a
/// [Loop] directly: through every named field, so a test of the policies is a
/// test of the policies and not, incidentally, a test of extraction.
LoopSignals signals({
  LoopState state = LoopState.open,
  DateTime? now,
  bool isPinned = false,
  bool isSuppressed = false,
  DateTime? deadline,
  Duration? waitingFor,
  Duration? proposalAge,
  double? confidence,
  bool contradictedByUser = false,
  bool evidenceUngrounded = false,
  int failedVerifications = 0,
  bool hasCounterparty = false,
}) {
  final DateTime at = now ?? t0;
  return LoopSignals(
    state: state,
    now: at,
    isPinned: isPinned,
    isSuppressed: isSuppressed,
    deadline: deadline,
    timeUntilDeadline: deadline?.difference(at),
    waitingFor: waitingFor,
    proposalAge: proposalAge,
    basisConfidence: confidence == null
        ? null
        : Confidence(
            value: confidence,
            basis: ConfidenceBasis.modelInference,
            method: const ProducerRef.rule('promise-verb', 'v3'),
            under: const CalibrationVersion('conf-v1'),
            computedAt: at,
          ),
    contradictedByUser: contradictedByUser,
    evidenceUngrounded: evidenceUngrounded,
    failedVerifications: failedVerifications,
    hasCounterparty: hasCounterparty,
  );
}

RiskAssessment riskOf(LoopSignals s) => risk.evaluate(s);
AttentionAssessment attentionOf(LoopSignals s) => attention.evaluate(s);

/// A resolver over a fixed evidence set, the same helper the 2A provenance
/// tests use.
EvidenceResolver resolverOf(List<Evidence> all) {
  final Map<String, Evidence> byId = <String, Evidence>{
    for (final Evidence e in all) e.id.value: e,
  };
  return (EvidenceId id) => byId[id.value];
}
