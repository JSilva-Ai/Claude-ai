import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/evidence/claim.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/intelligence/commitment_candidate.dart';
import 'package:loop/domain/intelligence/policy_ref.dart';

import 'fixtures.dart';

const PolicyRef _policy = PolicyRef(
  id: 'commitment-detection',
  version: PolicyVersion('commitment-detection-v1'),
);

void main() {
  group('CandidateConfidence', () {
    test('refuses to exist outside 0..1', () {
      expect(() => CandidateConfidence(-0.01), throwsArgumentError);
      expect(() => CandidateConfidence(1.01), throwsArgumentError);
      expect(CandidateConfidence(0), isNotNull);
      expect(CandidateConfidence(1), isNotNull);
    });

    test('two confidences with the same value are equal', () {
      expect(CandidateConfidence(0.5), CandidateConfidence(0.5));
    });
  });

  group('CommitmentCandidate', () {
    test('must be supported by at least one piece of evidence', () {
      expect(
        () => CommitmentCandidate(
          id: const CommitmentCandidateId('x'),
          claim: const Claim(kind: ClaimKind.other),
          evidence: const <EvidenceId>[],
          confidence: CandidateConfidence(0.5),
          reasons: const <CommitmentSignalReason>[],
          producedBy: _policy,
          evaluatedAt: t0,
        ),
        throwsArgumentError,
      );
    });

    group('identifiedBy — composed, not generated', () {
      test(
          'the same evidence, claim kind and policy always produce the '
          'same id', () {
        final CommitmentCandidate a = CommitmentCandidate.identifiedBy(
          evidence: <EvidenceId>[basisId],
          claim: const Claim(kind: ClaimKind.oweDeliverable),
          confidence: CandidateConfidence(0.6),
          reasons: const <CommitmentSignalReason>[
            CommitmentSignalReason.firstPersonPromise,
          ],
          producedBy: _policy,
          evaluatedAt: t0,
        );
        final CommitmentCandidate b = CommitmentCandidate.identifiedBy(
          evidence: <EvidenceId>[basisId],
          claim: const Claim(kind: ClaimKind.oweDeliverable),
          confidence: CandidateConfidence(0.9), // confidence may differ
          reasons: const <CommitmentSignalReason>[],
          producedBy: _policy,
          evaluatedAt: t0.add(const Duration(days: 1)), // and evaluatedAt
        );

        expect(a.id, b.id);
      });

      test(
          'a different claim kind over the same evidence produces a '
          'different id', () {
        final CommitmentCandidate a = CommitmentCandidate.identifiedBy(
          evidence: <EvidenceId>[basisId],
          claim: const Claim(kind: ClaimKind.oweDeliverable),
          confidence: CandidateConfidence(0.5),
          reasons: const <CommitmentSignalReason>[],
          producedBy: _policy,
          evaluatedAt: t0,
        );
        final CommitmentCandidate b = CommitmentCandidate.identifiedBy(
          evidence: <EvidenceId>[basisId],
          claim: const Claim(kind: ClaimKind.awaitingResponse),
          confidence: CandidateConfidence(0.5),
          reasons: const <CommitmentSignalReason>[],
          producedBy: _policy,
          evaluatedAt: t0,
        );

        expect(a.id, isNot(b.id));
      });

      test('different evidence produces a different id', () {
        final CommitmentCandidate a = CommitmentCandidate.identifiedBy(
          evidence: <EvidenceId>[basisId],
          claim: const Claim(kind: ClaimKind.other),
          confidence: CandidateConfidence(0.5),
          reasons: const <CommitmentSignalReason>[],
          producedBy: _policy,
          evaluatedAt: t0,
        );
        final CommitmentCandidate b = CommitmentCandidate.identifiedBy(
          evidence: <EvidenceId>[const EvidenceId('ev-other')],
          claim: const Claim(kind: ClaimKind.other),
          confidence: CandidateConfidence(0.5),
          reasons: const <CommitmentSignalReason>[],
          producedBy: _policy,
          evaluatedAt: t0,
        );

        expect(a.id, isNot(b.id));
      });

      test(
          'no id is ever generated randomly — a bare id is a deterministic '
          'string, not a uuid', () {
        final CommitmentCandidate a = CommitmentCandidate.identifiedBy(
          evidence: <EvidenceId>[basisId],
          claim: const Claim(kind: ClaimKind.other),
          confidence: CandidateConfidence(0.5),
          reasons: const <CommitmentSignalReason>[],
          producedBy: _policy,
          evaluatedAt: t0,
        );
        expect(a.id.value, contains(basisId.value));
        expect(a.id.value, contains('other'));
      });
    });
  });
}
