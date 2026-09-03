import 'package:loop/domain/evidence/capture_integrity.dart';
import 'package:loop/domain/evidence/claim.dart';
import 'package:loop/domain/evidence/confidence.dart';
import 'package:loop/domain/evidence/confidence_calibration.dart';
import 'package:loop/domain/evidence/evidence.dart';
import 'package:loop/domain/evidence/source_ref.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/loop/loop.dart';
import 'package:loop/domain/loop/loop_state.dart';

/// A fixed moment, so every assertion about time is about a time we chose.
final DateTime t0 = DateTime.utc(2026, 9, 1, 9, 41);

const EvidenceId basisId = EvidenceId('ev-basis');
const LoopId loopId = LoopId('loop-1');
const PartyId marina = PartyId('party-marina');

ObservedFact fact({
  String id = 'ev-fact',
  CaptureIntegrity integrity = CaptureIntegrity.verbatim,
  String? excerpt = "I'll send it Friday",
  DateTime? at,
}) =>
    ObservedFact(
      id: EvidenceId(id),
      capturedAt: at ?? t0,
      source: const SourceRef(
        source: EvidenceSource.email,
        locator: 'email:thread/9f2',
      ),
      integrity: integrity,
      excerpt: excerpt,
    );

Confidence confidence(
  double value, {
  ConfidenceBasis basis = ConfidenceBasis.modelInference,
  ConfidenceCalibration calibration = ConfidenceCalibration.v1,
  DateTime? at,
}) =>
    Confidence(
      value: value,
      basis: basis,
      method: const ProducerRef.rule('promise-verb', 'v3'),
      under: calibration.version,
      computedAt: at ?? t0,
    );

Inference inference({
  String id = 'ev-inference',
  List<String> from = const <String>['ev-fact'],
  double value = 0.72,
  DateTime? at,
}) =>
    Inference(
      id: EvidenceId(id),
      capturedAt: at ?? t0,
      derivedFrom: <EvidenceId>[for (final String f in from) EvidenceId(f)],
      claim:
          const Claim(kind: ClaimKind.awaitingResponse, counterparty: marina),
      confidence: confidence(value, at: at),
      producedBy: const ProducerRef.rule('promise-verb', 'v3'),
    );

UserAssertion assertion({
  String id = 'ev-assertion',
  AssertionKind kind = AssertionKind.confirms,
  String? about = 'ev-inference',
  DateTime? at,
}) =>
    UserAssertion(
      id: EvidenceId(id),
      capturedAt: at ?? t0,
      kind: kind,
      claim: const Claim(kind: ClaimKind.awaitingResponse),
      about: about == null ? null : EvidenceId(about),
    );

/// A loop parked in [state], with exactly the fields that state requires.
///
/// Built through the constructor rather than by driving the machine, so the
/// matrix can start from every state without the test asserting the very thing
/// it is trying to exercise.
Loop loopIn(
  LoopState state, {
  DateTime? updatedAt,
  DateTime? stateChangedAt,
  int revision = 1,
}) {
  final DateTime when = updatedAt ?? t0;
  return Loop(
    id: loopId,
    title: 'Send the signed lease',
    state: state,
    basis: basisId,
    evidence: const <EvidenceId>[basisId],
    createdAt: t0,
    updatedAt: when,
    stateChangedAt: stateChangedAt ?? when,
    revision: revision,
    waitingOn: state == LoopState.waiting ? marina : null,
    waitingSince: state == LoopState.waiting ? when : null,
    resolvedAt: state == LoopState.resolved ? when : null,
    abandonReason:
        state == LoopState.abandoned ? AbandonReason.decidedNotTo : null,
  );
}
