import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/evidence/capture_integrity.dart';
import 'package:loop/domain/evidence/claim.dart';
import 'package:loop/domain/evidence/confidence.dart';
import 'package:loop/domain/evidence/evidence.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/intelligence/loop_signals.dart';
import 'package:loop/domain/loop/loop.dart';
import 'package:loop/domain/loop/loop_event.dart';
import 'package:loop/domain/loop/loop_state.dart';

import 'fixtures.dart';

void main() {
  const SignalExtractor extractor = SignalExtractor();

  Loop loopOf({
    LoopState state = LoopState.open,
    EvidenceId basis = basisId,
    List<EvidenceId>? evidence,
    DateTime? stateChangedAt,
  }) =>
      Loop(
        id: loopId,
        title: 'Send the signed lease',
        state: state,
        basis: basis,
        evidence: evidence ?? <EvidenceId>[basis],
        createdAt: t0,
        updatedAt: t0,
        stateChangedAt: stateChangedAt ?? t0,
        waitingOn: state == LoopState.waiting ? marina : null,
        waitingSince: state == LoopState.waiting ? t0 : null,
      );

  group('a deadline is read from the claim on the loop\'s own inference', () {
    test('the inference names a deadline, and the signal carries it', () {
      final DateTime due = t0.add(const Duration(days: 2));
      final ObservedFact f = fact();
      final Inference i = inference(id: 'ev-basis');

      // Rebuild the inference with a claim that names a deadline: the shared
      // fixture's claim does not, and this is the one field this test cares
      // about.
      final Inference withDeadline = Inference(
        id: i.id,
        capturedAt: i.capturedAt,
        derivedFrom: i.derivedFrom,
        claim: Claim(kind: ClaimKind.deadlineExists, by: due),
        confidence: i.confidence,
        producedBy: i.producedBy,
      );

      final LoopSignals s = extractor.extract(
        loopOf(),
        evidence: resolverOf(<Evidence>[f, withDeadline]),
        now: t0,
      );

      expect(s.deadline, due);
      expect(s.timeUntilDeadline, due.difference(t0));
    });

    test('no claim names a deadline — the signal has none, not a guess', () {
      final ObservedFact f = fact();
      final Inference i = inference(id: 'ev-basis');
      final LoopSignals s = extractor.extract(
        loopOf(),
        evidence: resolverOf(<Evidence>[f, i]),
        now: t0,
      );
      expect(s.deadline, isNull);
      expect(s.isOverdue, isFalse);
    });
  });

  group('overdue is derived, never stored', () {
    test('a past deadline on an active loop is overdue', () {
      final Inference i = Inference(
        id: const EvidenceId('ev-basis'),
        capturedAt: t0,
        derivedFrom: const <EvidenceId>[EvidenceId('ev-fact')],
        claim: Claim(
          kind: ClaimKind.deadlineExists,
          by: t0.subtract(const Duration(hours: 1)),
        ),
        confidence: confidence(0.8),
        producedBy: const ProducerRef.rule('x', 'v1'),
      );
      final LoopSignals s = extractor.extract(
        loopOf(),
        evidence: resolverOf(<Evidence>[fact(), i]),
        now: t0,
      );
      expect(s.isOverdue, isTrue);
    });

    test(
        'a past deadline on a resolved loop is not overdue — nothing active to miss',
        () {
      final Inference i = Inference(
        id: const EvidenceId('ev-basis'),
        capturedAt: t0,
        derivedFrom: const <EvidenceId>[EvidenceId('ev-fact')],
        claim: Claim(
          kind: ClaimKind.deadlineExists,
          by: t0.subtract(const Duration(hours: 1)),
        ),
        confidence: confidence(0.8),
        producedBy: const ProducerRef.rule('x', 'v1'),
      );
      final Loop resolved = Loop(
        id: loopId,
        title: 'x',
        state: LoopState.resolved,
        basis: const EvidenceId('ev-basis'),
        evidence: const <EvidenceId>[EvidenceId('ev-basis')],
        createdAt: t0,
        updatedAt: t0,
        stateChangedAt: t0,
        resolvedAt: t0,
      );
      final LoopSignals s = extractor.extract(
        resolved,
        evidence: resolverOf(<Evidence>[fact(), i]),
        now: t0,
      );
      expect(s.isOverdue, isFalse);
    });
  });

  group('waiting and proposal age come straight from the loop', () {
    test('waitingFor is now minus waitingSince', () {
      final LoopSignals s = extractor.extract(
        loopOf(state: LoopState.waiting, stateChangedAt: t0),
        evidence: resolverOf(<Evidence>[fact(), inference(id: 'ev-basis')]),
        now: t0.add(const Duration(days: 2)),
      );
      expect(s.waitingFor, const Duration(days: 2));
    });

    test('proposalAge only applies to a detected proposal', () {
      final LoopSignals waiting = extractor.extract(
        loopOf(state: LoopState.waiting, stateChangedAt: t0),
        evidence: resolverOf(<Evidence>[fact(), inference(id: 'ev-basis')]),
        now: t0.add(const Duration(days: 1)),
      );
      expect(waiting.proposalAge, isNull);

      final LoopSignals detected = extractor.extract(
        loopOf(state: LoopState.detected, stateChangedAt: t0),
        evidence: resolverOf(<Evidence>[fact(), inference(id: 'ev-basis')]),
        now: t0.add(const Duration(days: 1)),
      );
      expect(detected.proposalAge, const Duration(days: 1));
    });
  });

  group(
      'capture integrity and semantic confidence are read from different places',
      () {
    test('the weakest integrity across the whole lineage is reported', () {
      final ObservedFact strong =
          fact(id: 'ev-a', integrity: CaptureIntegrity.verbatim);
      final ObservedFact weak =
          fact(id: 'ev-b', integrity: CaptureIntegrity.transcribed);
      final Inference i =
          inference(id: 'ev-basis', from: <String>['ev-a', 'ev-b']);

      final LoopSignals s = extractor.extract(
        loopOf(),
        evidence: resolverOf(<Evidence>[strong, weak, i]),
        now: t0,
      );
      expect(s.weakestIntegrity, CaptureIntegrity.transcribed);
    });

    test(
        'the basis inference\'s own semantic confidence is reported separately',
        () {
      final Inference i = inference(id: 'ev-basis', value: 0.63);
      final LoopSignals s = extractor.extract(
        loopOf(),
        evidence: resolverOf(<Evidence>[fact(), i]),
        now: t0,
      );
      expect(s.basisConfidence?.value, 0.63);
    });

    test('a loop with no inference in its lineage has neither, honestly', () {
      final UserAssertion a = assertion(
        id: 'ev-basis',
        kind: AssertionKind.states,
        about: null,
      );
      final LoopSignals s = extractor.extract(
        loopOf(
          basis: const EvidenceId('ev-basis'),
          evidence: const <EvidenceId>[EvidenceId('ev-basis')],
        ),
        evidence: resolverOf(<Evidence>[a]),
        now: t0,
      );
      expect(s.basisConfidence, isNull);
      expect(s.weakestIntegrity, isNull);
    });
  });

  group(
      'contradiction is read from an assertion beside the inference, never a mutation of it',
      () {
    test('a rejection of the basis is detected', () {
      final Inference i = inference(id: 'ev-basis');
      final UserAssertion rejection = assertion(
        id: 'ev-rejection',
        kind: AssertionKind.rejects,
        about: 'ev-basis',
      );
      final LoopSignals s = extractor.extract(
        loopOf(
          evidence: const <EvidenceId>[
            EvidenceId('ev-fact'),
            EvidenceId('ev-basis'),
            EvidenceId('ev-rejection'),
          ],
        ),
        evidence: resolverOf(<Evidence>[fact(), i, rejection]),
        now: t0,
      );
      expect(s.contradictedByUser, isTrue);
      // And the inference itself is untouched — 2A's own guarantee, restated
      // at the point 2B relies on it.
      expect(i.confidence.value, 0.72);
    });

    test(
        'a rejection of something else is not read as a contradiction of this loop',
        () {
      final Inference i = inference(id: 'ev-basis');
      final UserAssertion rejectsOther = assertion(
        id: 'ev-rejection',
        kind: AssertionKind.rejects,
        about: 'ev-other-inference',
      );
      final LoopSignals s = extractor.extract(
        loopOf(
          evidence: const <EvidenceId>[
            EvidenceId('ev-fact'),
            EvidenceId('ev-basis'),
            EvidenceId('ev-rejection'),
          ],
        ),
        evidence: resolverOf(<Evidence>[fact(), i, rejectsOther]),
        now: t0,
      );
      expect(s.contradictedByUser, isFalse);
    });
  });

  group('an incomplete or invalid evidence graph is reported, not hidden', () {
    test('a missing link marks the signals ungrounded', () {
      final Inference i = inference(id: 'ev-basis');
      final LoopSignals s = extractor.extract(
        loopOf(),
        evidence: resolverOf(<Evidence>[i]), // 'ev-fact' is not resolvable
        now: t0,
      );
      expect(s.evidenceUngrounded, isTrue);
    });

    test('a fully grounded chain is not flagged', () {
      final LoopSignals s = extractor.extract(
        loopOf(),
        evidence: resolverOf(<Evidence>[fact(), inference(id: 'ev-basis')]),
        now: t0,
      );
      expect(s.evidenceUngrounded, isFalse);
    });
  });

  group('failed verifications are counted from history, not guessed', () {
    test('a verifying → open transition in the log counts as one failure', () {
      final LoopSignals s = extractor.extract(
        loopOf(),
        evidence: resolverOf(<Evidence>[fact(), inference(id: 'ev-basis')]),
        now: t0,
        history: <LoopEvent>[
          LoopEvent(
            loop: loopId,
            sequence: 2,
            kind: LoopEventKind.stateChanged,
            actor: TransitionActor.user,
            at: t0,
            from: LoopState.verifying,
            to: LoopState.open,
          ),
        ],
      );
      expect(s.failedVerifications, 1);
    });

    test('an unrelated transition in the log does not count', () {
      final LoopSignals s = extractor.extract(
        loopOf(),
        evidence: resolverOf(<Evidence>[fact(), inference(id: 'ev-basis')]),
        now: t0,
        history: <LoopEvent>[
          LoopEvent(
            loop: loopId,
            sequence: 2,
            kind: LoopEventKind.stateChanged,
            actor: TransitionActor.user,
            at: t0,
            from: LoopState.open,
            to: LoopState.inProgress,
          ),
        ],
      );
      expect(s.failedVerifications, 0);
    });
  });
}
