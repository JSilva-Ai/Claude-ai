import 'package:flutter_test/flutter_test.dart';
import 'package:loop/application/intelligence/ai_commitment_detector.dart';
import 'package:loop/application/intelligence/commitment_detection_with_fallback.dart';
import 'package:loop/application/intelligence/model_gateway.dart';
import 'package:loop/domain/evidence/claim.dart';
import 'package:loop/domain/evidence/data_sensitivity.dart';
import 'package:loop/domain/evidence/source_ref.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/intelligence/ai/raw_model_commitment_output.dart';
import 'package:loop/domain/intelligence/commitment_candidate_policy.dart';
import 'package:loop/domain/intelligence/ports/source_signal.dart';

import '../../domain/intelligence/fixtures.dart';
import 'fake_model_gateway.dart';

void main() {
  const SourceSignal signal = SourceSignal(
    text: "I'll send it Friday.",
    sensitivity: DataSensitivity.ordinary,
  );

  group('AI available and confident', () {
    test('the AI candidate is used, and the outcome names AI as the source',
        () async {
      final FakeModelGateway gateway = FakeModelGateway(
        respond: (_) => FakeModelGateway.success(
          const RawModelCommitmentOutput(
            hasCandidate: true,
            claimKind: 'oweDeliverable',
            confidence: 0.9,
            evidenceIds: <String>['ev-basis'],
          ),
        ),
      );
      final CommitmentDetectionWithFallback detection =
          CommitmentDetectionWithFallback(
        ai: AICommitmentDetector(gateway: gateway),
      );

      final CommitmentDetectionOutcome outcome = await detection.detect(
        signal: signal,
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
        locale: 'en',
      );

      expect(outcome.source, CommitmentDetectionSource.ai);
      expect(outcome.candidate, isNotNull);
    });

    test('an honest AI no-candidate is trusted, not overridden by rules',
        () async {
      final FakeModelGateway gateway = FakeModelGateway(
        respond: (_) => FakeModelGateway.success(
          const RawModelCommitmentOutput(hasCandidate: false),
        ),
      );
      final CommitmentDetectionWithFallback detection =
          CommitmentDetectionWithFallback(
        ai: AICommitmentDetector(gateway: gateway),
      );

      final CommitmentDetectionOutcome outcome = await detection.detect(
        signal: signal,
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
        locale: 'en',
      );

      expect(outcome.source, CommitmentDetectionSource.ai);
      expect(outcome.candidate, isNull);
    });
  });

  group('AI unavailable — the deterministic baseline remains available', () {
    test(
        'a gateway failure falls back to the rule-based detector\'s own '
        'answer', () async {
      final FakeModelGateway gateway = FakeModelGateway(
        respond: (_) =>
            const ModelGatewayFailure(ModelInferenceFailureReason.unavailable),
      );
      final CommitmentDetectionWithFallback detection =
          CommitmentDetectionWithFallback(
        ai: AICommitmentDetector(gateway: gateway),
      );

      final CommitmentDetectionOutcome outcome = await detection.detect(
        signal: signal,
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
        locale: 'en',
      );

      expect(outcome.source, CommitmentDetectionSource.rules);
      // The deterministic detector genuinely finds a candidate in this
      // text, so LOOP keeps reasoning correctly even with AI entirely down.
      expect(outcome.candidate, isNotNull);
      expect(outcome.candidate!.claim.kind, ClaimKind.oweDeliverable);
    });

    test('a timeout falls back the same way', () async {
      final FakeModelGateway gateway = FakeModelGateway(
        delay: const Duration(milliseconds: 50),
        respond: (_) => FakeModelGateway.success(
          const RawModelCommitmentOutput(hasCandidate: false),
        ),
      );
      final CommitmentDetectionWithFallback detection =
          CommitmentDetectionWithFallback(
        ai: AICommitmentDetector(
          gateway: gateway,
          timeout: const Duration(milliseconds: 5),
        ),
      );

      final CommitmentDetectionOutcome outcome = await detection.detect(
        signal: signal,
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
        locale: 'en',
      );

      expect(outcome.source, CommitmentDetectionSource.rules);
    });

    test('a validation rejection (hallucinated evidence id) falls back too',
        () async {
      final FakeModelGateway gateway = FakeModelGateway(
        respond: (_) => FakeModelGateway.success(
          const RawModelCommitmentOutput(
            hasCandidate: true,
            claimKind: 'other',
            confidence: 0.9,
            evidenceIds: <String>['ev-invented'],
          ),
        ),
      );
      final CommitmentDetectionWithFallback detection =
          CommitmentDetectionWithFallback(
        ai: AICommitmentDetector(gateway: gateway),
      );

      final CommitmentDetectionOutcome outcome = await detection.detect(
        signal: signal,
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
        locale: 'en',
      );

      expect(outcome.source, CommitmentDetectionSource.rules);
    });

    test(
        'LOOP keeps reasoning end to end without AI: rules alone still '
        'produce the same answer CommitmentCandidateDetector would give '
        'directly', () async {
      final FakeModelGateway gateway = FakeModelGateway(
        respond: (_) =>
            const ModelGatewayFailure(ModelInferenceFailureReason.timeout),
      );
      final CommitmentDetectionWithFallback detection =
          CommitmentDetectionWithFallback(
        ai: AICommitmentDetector(gateway: gateway),
      );

      final CommitmentDetectionOutcome viaFallback = await detection.detect(
        signal: signal,
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
        locale: 'en',
      );
      final direct = const CommitmentCandidateDetector().detect(
        signal: signal,
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
      );

      expect(viaFallback.candidate?.id, direct?.id);
    });
  });
}
