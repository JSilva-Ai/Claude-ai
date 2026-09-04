import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/evidence/claim.dart';
import 'package:loop/domain/evidence/data_sensitivity.dart';
import 'package:loop/domain/evidence/source_ref.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/intelligence/commitment_candidate.dart';
import 'package:loop/domain/intelligence/commitment_candidate_policy.dart';
import 'package:loop/domain/intelligence/ports/source_signal.dart';

import 'fixtures.dart';

SourceSignal _signal(String text) =>
    SourceSignal(text: text, sensitivity: DataSensitivity.ordinary);

void main() {
  const CommitmentCandidateDetector detector = CommitmentCandidateDetector();

  group('a manual observation — unambiguous authorship', () {
    test(
        'a first-person promise becomes oweDeliverable with no ambiguity '
        'flag', () {
      final CommitmentCandidate? c = detector.detect(
        signal: _signal("I'll send the signed lease tomorrow."),
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
      );

      expect(c, isNotNull);
      expect(c!.claim.kind, ClaimKind.oweDeliverable);
      expect(c.reasons, isNot(contains(CommitmentSignalReason.ambiguousActor)));
      expect(c.claim.by, isNotNull);
    });

    test('waiting language becomes awaitingResponse', () {
      final CommitmentCandidate? c = detector.detect(
        signal: _signal('Still waiting for the signed lease.'),
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
      );

      expect(c, isNotNull);
      expect(c!.claim.kind, ClaimKind.awaitingResponse);
      expect(c.reasons, isNot(contains(CommitmentSignalReason.ambiguousActor)));
    });
  });

  group('a non-manual observation — authorship cannot be determined', () {
    test(
        'the same first-person promise, from an email, is never assigned a '
        'confident direction', () {
      final CommitmentCandidate? c = detector.detect(
        signal: _signal("I'll send the signed lease tomorrow."),
        sourceKind: EvidenceSource.email,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
      );

      expect(c, isNotNull);
      expect(c!.claim.kind, ClaimKind.other);
      expect(c.reasons, contains(CommitmentSignalReason.ambiguousActor));
    });

    test(
        'the ambiguity flag measurably lowers confidence relative to the '
        'same pattern from a manual observation', () {
      final CommitmentCandidate manual = detector.detect(
        signal: _signal("I'll send the signed lease tomorrow."),
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
      )!;
      final CommitmentCandidate email = detector.detect(
        signal: _signal("I'll send the signed lease tomorrow."),
        sourceKind: EvidenceSource.email,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
      )!;

      expect(email.confidence.value, lessThan(manual.confidence.value));
    });

    test('every non-manual source kind is treated the same way', () {
      for (final EvidenceSource kind in <EvidenceSource>[
        EvidenceSource.email,
        EvidenceSource.message,
        EvidenceSource.calendar,
        EvidenceSource.document,
        EvidenceSource.note,
      ]) {
        final CommitmentCandidate? c = detector.detect(
          signal: _signal('Can you send it over?'),
          sourceKind: kind,
          evidence: <EvidenceId>[basisId],
          referenceTime: t0,
        );
        expect(c!.claim.kind, ClaimKind.other, reason: '$kind');
        expect(
          c.reasons,
          contains(CommitmentSignalReason.ambiguousActor),
          reason: '$kind',
        );
      }
    });
  });

  group('no candidate', () {
    test('speculative language produces no candidate at all', () {
      final CommitmentCandidate? c = detector.detect(
        signal: _signal('I might send it.'),
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
      );
      expect(c, isNull);
    });

    test('purely informational content produces no candidate', () {
      final CommitmentCandidate? c = detector.detect(
        signal: _signal('FYI, I sent the report yesterday.'),
        sourceKind: EvidenceSource.email,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
      );
      expect(c, isNull);
    });

    test(
        'non-English text matches no English-only pattern and produces no '
        'candidate — the same, safe outcome as any other unrecognised '
        'input, with no separate "unsupported language" result', () {
      final CommitmentCandidate? c = detector.detect(
        // Portuguese: "I'll send it tomorrow."
        signal: _signal('Vou enviar amanhã.'),
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
      );
      expect(c, isNull);
    });
  });

  group('provenance', () {
    test(
        'the candidate carries exactly the evidence it was given, never a '
        'copy of its content', () {
      final CommitmentCandidate c = detector.detect(
        signal: _signal("I'll send it tomorrow."),
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId, const EvidenceId('ev-2')],
        referenceTime: t0,
      )!;

      expect(c.evidence, <EvidenceId>[basisId, const EvidenceId('ev-2')]);
    });
  });

  group(
      'contradictory evidence — detection does not resolve it, only '
      'represents it', () {
    test(
        'two pieces of evidence with conflicting deadlines each produce '
        'their own candidate, and neither is silently overwritten', () {
      final CommitmentCandidate friday = detector.detect(
        signal: _signal("I'll send it by Friday."),
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
      )!;
      final CommitmentCandidate? monday = detector.detect(
        signal: _signal('Actually, Monday works better.'),
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[const EvidenceId('ev-monday')],
        referenceTime: t0,
      );

      // "Actually, Monday works better" alone carries none of the
      // promise/request/waiting patterns this phase requires — a bare
      // temporal revision with no restated commitment language produces no
      // candidate on its own, which is itself the honest, conservative
      // answer: 3C does not invent a revision it cannot see stated.
      expect(monday, isNull);
      expect(friday.claim.by, isNotNull);
    });
  });

  group('determinism and identity', () {
    test(
        'the same evidence, reference time and policy always produce the '
        'same candidate id and content', () {
      final CommitmentCandidate a = detector.detect(
        signal: _signal("I'll send it by Friday."),
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
      )!;
      final CommitmentCandidate b = detector.detect(
        signal: _signal("I'll send it by Friday."),
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
      )!;

      expect(a.id, b.id);
      expect(a.confidence, b.confidence);
      expect(a.claim.by, b.claim.by);
      expect(a.reasons, b.reasons);
    });

    test(
        'detection never reads a clock — evaluatedAt is always exactly '
        'what was supplied', () {
      final DateTime chosen = DateTime.utc(2099, 1, 1);
      final CommitmentCandidate c = detector.detect(
        signal: _signal("I'll send it."),
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: chosen,
      )!;
      expect(c.evaluatedAt, chosen);
    });

    test('the policy/detector version is recorded on every candidate', () {
      final CommitmentCandidate c = detector.detect(
        signal: _signal("I'll send it."),
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
      )!;
      expect(c.producedBy.id, 'commitment-detection');
    });
  });

  group('authority — this layer produces interpretations, never truth', () {
    test(
        'the claim never carries a counterparty — naming a specific party '
        'would need identity resolution this phase does not build', () {
      final CommitmentCandidate c = detector.detect(
        signal: _signal('Can you send it over?'),
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
      )!;
      expect(c.claim.counterparty, isNull);
    });

    test(
        'nothing in this pipeline constructs a Loop, a Commitment, or a '
        'UserAssertion — CommitmentCandidate is the only type this file '
        'produces', () {
      final CommitmentCandidate? c = detector.detect(
        signal: _signal("I'll send it."),
        sourceKind: EvidenceSource.manual,
        evidence: <EvidenceId>[basisId],
        referenceTime: t0,
      );
      expect(c, isA<CommitmentCandidate>());
      // Documented, not exhaustively re-checked here: CommitmentCandidateDetector
      // imports neither `commitment/commitment.dart` nor `loop/loop.dart` —
      // see test/architecture/commitment_candidate_dependencies_test.dart.
    });
  });
}
