import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/commitment/commitment.dart';
import 'package:loop/domain/commitment/commitment_status.dart';
import 'package:loop/domain/evidence/claim.dart';
import 'package:loop/domain/failures.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/loop/loop.dart';
import 'package:loop/domain/loop/loop_state.dart';
import 'package:loop/domain/result.dart';

import 'fixtures.dart';

const CommitmentId commitmentId = CommitmentId('commitment-1');
const CommitmentId otherCommitmentId = CommitmentId('commitment-2');
const EvidenceId secondEvidenceId = EvidenceId('ev-monday');

/// A commitment parked in [status], with exactly the fields that status
/// requires — the same shape `fixtures.dart`'s own `loopIn` uses for [Loop].
Commitment commitmentIn(
  CommitmentStatus status, {
  DateTime? updatedAt,
  CommitmentId? supersededBy,
}) {
  final DateTime when = updatedAt ?? t0;
  return Commitment(
    id: commitmentId,
    claim: const Claim(kind: ClaimKind.oweDeliverable, counterparty: marina),
    basis: basisId,
    evidence: const <EvidenceId>[basisId],
    createdAt: t0,
    updatedAt: when,
    status: status,
    resolvedAt: status == CommitmentStatus.active ? null : when,
    supersededBy: status == CommitmentStatus.superseded
        ? (supersededBy ?? otherCommitmentId)
        : null,
  );
}

void main() {
  group('CommitmentStatus', () {
    test('exactly four values, and only active is non-terminal', () {
      expect(
        CommitmentStatus.values.length,
        4,
        reason: 'a status was added or removed',
      );
      expect(CommitmentStatus.active.isTerminal, isFalse);
      expect(CommitmentStatus.fulfilled.isTerminal, isTrue);
      expect(CommitmentStatus.cancelled.isTerminal, isTrue);
      expect(CommitmentStatus.superseded.isTerminal, isTrue);
    });
  });

  group('construction invariants', () {
    test('basis must be among the evidence', () {
      expect(
        () => Commitment(
          id: commitmentId,
          claim: const Claim(kind: ClaimKind.oweDeliverable),
          basis: basisId,
          evidence: const <EvidenceId>[],
          createdAt: t0,
          updatedAt: t0,
        ),
        throwsA(isA<LoopInvariantViolation>()),
      );
    });

    test('an active commitment may not carry resolvedAt', () {
      expect(
        () => Commitment(
          id: commitmentId,
          claim: const Claim(kind: ClaimKind.oweDeliverable),
          basis: basisId,
          evidence: const <EvidenceId>[basisId],
          createdAt: t0,
          updatedAt: t0,
          resolvedAt: t0,
        ),
        throwsA(isA<LoopInvariantViolation>()),
      );
    });

    test('a terminal status must record resolvedAt', () {
      expect(
        () => Commitment(
          id: commitmentId,
          claim: const Claim(kind: ClaimKind.oweDeliverable),
          basis: basisId,
          evidence: const <EvidenceId>[basisId],
          createdAt: t0,
          updatedAt: t0,
          status: CommitmentStatus.fulfilled,
        ),
        throwsA(isA<LoopInvariantViolation>()),
      );
    });

    test('superseded must name its replacement', () {
      expect(
        () => Commitment(
          id: commitmentId,
          claim: const Claim(kind: ClaimKind.oweDeliverable),
          basis: basisId,
          evidence: const <EvidenceId>[basisId],
          createdAt: t0,
          updatedAt: t0,
          status: CommitmentStatus.superseded,
          resolvedAt: t0,
        ),
        throwsA(isA<LoopInvariantViolation>()),
      );
    });

    test('only a superseded commitment may carry supersededBy', () {
      expect(
        () => Commitment(
          id: commitmentId,
          claim: const Claim(kind: ClaimKind.oweDeliverable),
          basis: basisId,
          evidence: const <EvidenceId>[basisId],
          createdAt: t0,
          updatedAt: t0,
          status: CommitmentStatus.fulfilled,
          resolvedAt: t0,
          supersededBy: otherCommitmentId,
        ),
        throwsA(isA<LoopInvariantViolation>()),
      );
    });

    test('a commitment may not name itself as its own replacement', () {
      expect(
        () => Commitment(
          id: commitmentId,
          claim: const Claim(kind: ClaimKind.oweDeliverable),
          basis: basisId,
          evidence: const <EvidenceId>[basisId],
          createdAt: t0,
          updatedAt: t0,
          status: CommitmentStatus.superseded,
          resolvedAt: t0,
          supersededBy: commitmentId,
        ),
        throwsA(isA<LoopInvariantViolation>()),
      );
    });
  });

  group('evidence — multiple, even contradictory, references coexist', () {
    test(
        'construction accepts more than one evidence item with no '
        'cross-validation of agreement', () {
      final Commitment c = Commitment(
        id: commitmentId,
        claim:
            const Claim(kind: ClaimKind.oweDeliverable, counterparty: marina),
        basis: basisId,
        evidence: const <EvidenceId>[basisId, secondEvidenceId],
        createdAt: t0,
        updatedAt: t0,
      );

      // Nothing about constructing this commitment inspected what either
      // piece of evidence actually claims — it is free to disagree.
      expect(c.evidence, <EvidenceId>[basisId, secondEvidenceId]);
    });
  });

  group('party and direction — via the reused Claim, no separate role type',
      () {
    test('oweDeliverable: the user owes the counterparty', () {
      final Commitment c = commitmentIn(CommitmentStatus.active);
      expect(c.claim.kind, ClaimKind.oweDeliverable);
      expect(c.claim.counterparty, marina);
    });

    test('awaitingResponse: the counterparty owes the user', () {
      final Commitment c = Commitment(
        id: commitmentId,
        claim: const Claim(
          kind: ClaimKind.awaitingResponse,
          counterparty: marina,
        ),
        basis: basisId,
        evidence: const <EvidenceId>[basisId],
        createdAt: t0,
        updatedAt: t0,
      );
      expect(c.claim.kind, ClaimKind.awaitingResponse);
    });

    test('a counterparty is optional — a commitment need not name one', () {
      final Commitment c = Commitment(
        id: commitmentId,
        claim: const Claim(kind: ClaimKind.oweDeliverable),
        basis: basisId,
        evidence: const <EvidenceId>[basisId],
        createdAt: t0,
        updatedAt: t0,
      );
      expect(c.claim.counterparty, isNull);
    });
  });

  group('temporal representation — carried on the reused Claim', () {
    test('no deadline is a legitimate commitment', () {
      final Commitment c = commitmentIn(CommitmentStatus.active);
      expect(c.claim.by, isNull);
    });

    test(
        'a resolved deadline is carried with its source quote, '
        'distinguishably from the raw text it came from', () {
      final DateTime friday = DateTime.utc(2026, 9, 11);
      final Commitment c = Commitment(
        id: commitmentId,
        claim: Claim(
          kind: ClaimKind.oweDeliverable,
          by: friday,
          sourceQuote: "I'll send it Friday",
        ),
        basis: basisId,
        evidence: const <EvidenceId>[basisId],
        createdAt: t0,
        updatedAt: t0,
      );

      expect(c.claim.by, friday);
      expect(c.claim.sourceQuote, "I'll send it Friday");
    });
  });

  group('status transitions', () {
    test('active starts non-terminal, with no resolvedAt', () {
      final Commitment c = commitmentIn(CommitmentStatus.active);
      expect(c.isTerminal, isFalse);
      expect(c.resolvedAt, isNull);
    });

    test('active → fulfilled', () {
      final Commitment c = commitmentIn(CommitmentStatus.active);
      final DateTime now = t0.add(const Duration(days: 1));

      final Result<Commitment> result = c.fulfil(now: now);

      expect(result.isOk, isTrue);
      expect(result.unwrap.status, CommitmentStatus.fulfilled);
      expect(result.unwrap.resolvedAt, now);
      expect(result.unwrap.isTerminal, isTrue);
      // The claim and evidence trail travel unchanged through the move.
      expect(result.unwrap.claim, c.claim);
      expect(result.unwrap.evidence, c.evidence);
    });

    test('active → cancelled', () {
      final Commitment c = commitmentIn(CommitmentStatus.active);
      final Result<Commitment> result =
          c.cancel(now: t0.add(const Duration(hours: 2)));

      expect(result.isOk, isTrue);
      expect(result.unwrap.status, CommitmentStatus.cancelled);
      expect(result.unwrap.isTerminal, isTrue);
    });

    test('active → superseded, naming its replacement', () {
      final Commitment c = commitmentIn(CommitmentStatus.active);
      final Result<Commitment> result = c.supersede(
        by: otherCommitmentId,
        now: t0.add(const Duration(hours: 3)),
      );

      expect(result.isOk, isTrue);
      expect(result.unwrap.status, CommitmentStatus.superseded);
      expect(result.unwrap.supersededBy, otherCommitmentId);
    });

    test('a commitment cannot supersede itself, and is left untouched', () {
      final Commitment c = commitmentIn(CommitmentStatus.active);

      final Result<Commitment> result = c.supersede(by: commitmentId, now: t0);

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<OperationRefused>());
      expect(c.status, CommitmentStatus.active);
      expect(c.supersededBy, isNull);
    });

    group(
        'a terminal status refuses every further transition — '
        'no return to active', () {
      for (final CommitmentStatus from in <CommitmentStatus>[
        CommitmentStatus.fulfilled,
        CommitmentStatus.cancelled,
        CommitmentStatus.superseded,
      ]) {
        test('$from refuses fulfil, cancel and supersede alike', () {
          final Commitment c = commitmentIn(from);
          final DateTime now = t0.add(const Duration(days: 2));

          final List<Result<Commitment>> attempts = <Result<Commitment>>[
            c.fulfil(now: now),
            c.cancel(now: now),
            c.supersede(by: otherCommitmentId, now: now),
          ];

          for (final Result<Commitment> attempt in attempts) {
            expect(
              attempt.isErr,
              isTrue,
              reason: '$from should refuse every transition',
            );
            expect(attempt.failureOrNull, isA<IllegalCommitmentTransition>());
          }

          // A refused transition changes nothing — same discipline
          // LoopStateMachine already applies.
          expect(c.status, from);
          expect(c.resolvedAt, isNotNull);
        });
      }
    });

    test(
        'a refusal names the status it could not leave and the one it '
        'was asked to reach', () {
      final Commitment c = commitmentIn(CommitmentStatus.fulfilled);

      final IllegalCommitmentTransition failure =
          c.cancel(now: t0).failureOrNull! as IllegalCommitmentTransition;

      expect(failure.from, CommitmentStatus.fulfilled);
      expect(failure.to, CommitmentStatus.cancelled);
      expect(failure.debugMessage, contains('fulfilled'));
      expect(failure.debugMessage, contains('cancelled'));
    });
  });

  group('strong-id type safety and determinism', () {
    test('CommitmentId.parse rejects an empty string, like every other id', () {
      expect(() => CommitmentId.parse(''), throwsArgumentError);
      expect(CommitmentId.parse('commitment-1'), commitmentId);
    });

    test(
        'nothing inside Commitment reads a clock — now always comes from '
        'the caller', () {
      final Commitment c = commitmentIn(CommitmentStatus.active);
      final DateTime chosen = DateTime.utc(2099, 1, 1);

      final Commitment after = c.fulfil(now: chosen).unwrap;

      expect(after.resolvedAt, chosen);
      expect(after.updatedAt, chosen);
    });

    test('two transitions at two different moments never collide', () {
      final Commitment c = commitmentIn(CommitmentStatus.active);
      final Commitment first =
          c.fulfil(now: t0.add(const Duration(seconds: 1))).unwrap;

      // c itself is untouched — fulfil returns a new Commitment, it does not
      // mutate the receiver, so a second call from the same starting point
      // is still legal and independent.
      final Commitment second =
          c.fulfil(now: t0.add(const Duration(seconds: 2))).unwrap;

      expect(first.resolvedAt, isNot(second.resolvedAt));
    });
  });

  group(
      'Loop.commitmentId already references CommitmentId — no Loop '
      'modification required', () {
    test('a Loop can carry this Commitment\'s id with zero changes to Loop',
        () {
      final Loop loop = Loop(
        id: loopId,
        title: 'Send the signed lease',
        state: LoopState.open,
        basis: basisId,
        evidence: const <EvidenceId>[basisId],
        createdAt: t0,
        updatedAt: t0,
        stateChangedAt: t0,
        commitment: commitmentId,
      );

      expect(loop.commitment, commitmentId);
    });

    test('a Loop may equally carry no commitment at all', () {
      final Loop loop = Loop(
        id: loopId,
        title: 'Buy milk',
        state: LoopState.open,
        basis: basisId,
        evidence: const <EvidenceId>[basisId],
        createdAt: t0,
        updatedAt: t0,
        stateChangedAt: t0,
      );

      expect(loop.commitment, isNull);
    });
  });
}
