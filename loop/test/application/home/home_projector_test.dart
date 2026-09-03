import 'package:flutter_test/flutter_test.dart';
import 'package:loop/application/home/home_projector.dart';
import 'package:loop/application/loop_repository.dart';
import 'package:loop/core/models/loop_category.dart';
import 'package:loop/domain/evidence/claim.dart';
import 'package:loop/domain/evidence/evidence.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/loop/loop_state_machine.dart';
import 'package:loop/domain/loop/loop_transition.dart';
import 'package:loop/domain/result.dart';
import 'package:loop/features/home/models/user_profile.dart';

import '../../domain/fixtures.dart';
import '../in_memory_loop_repository.dart';

void main() {
  const UserProfile profile = UserProfile(id: 'u1', displayName: 'Jorge Silva');
  const LoopStateMachine machine = LoopStateMachine();

  group('projectHome, pure', () {
    test('an empty store projects an empty, valid snapshot', () {
      final snapshot = projectHome(
        contexts: const <LoopContext>[],
        resolveEvidence: (_) => null,
        profile: profile,
        now: t0,
      );
      expect(snapshot.activeLoops, 0);
      expect(snapshot.closedCount, 0);
      expect(snapshot.isEmpty, isTrue);
    });

    test(
        'activeLoops counts distinct loops, not the sum of overlapping '
        'categories', () {
      // One loop that is both AT RISK and TODAY must add 1 to activeLoops,
      // not 2 — the exact distinction HomeSnapshot.activeLoops' own doc
      // exists to draw.
      final DateTime overdueToday = t0.subtract(const Duration(hours: 2));
      final UserAssertion basis = UserAssertion(
        id: const EvidenceId('ev-overdue'),
        capturedAt: t0,
        kind: AssertionKind.states,
        claim: Claim(kind: ClaimKind.deadlineExists, by: overdueToday),
      );
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'Overdue and today',
        basis: basis.id,
        now: t0,
      );

      final snapshot = projectHome(
        contexts: <LoopContext>[
          LoopContext(
            loop: created.loop,
            evidence: <Evidence>[basis],
            events: const [],
          ),
        ],
        resolveEvidence: (EvidenceId id) => id == basis.id ? basis : null,
        profile: profile,
        now: t0,
      );

      expect(snapshot.activeLoops, 1);
      expect(snapshot.countOf(LoopCategory.atRisk), 1);
      expect(snapshot.countOf(LoopCategory.today), 1);
    });

    test('two loops in different categories both count toward activeLoops', () {
      final ObservedFact basisA = fact(id: 'ev-a');
      final LoopOutcome loopA = machine.create(
        id: const LoopId('loop-a'),
        title: 'Calm loop',
        basis: basisA.id,
        now: t0,
      );
      final ObservedFact basisB = fact(id: 'ev-b');
      final LoopOutcome createdB = machine.create(
        id: const LoopId('loop-b'),
        title: 'Waiting loop',
        basis: basisB.id,
        now: t0,
      );
      final Result<LoopOutcome> delegated = machine.apply(
        createdB.loop,
        const Delegate(waitingOn: marina),
        now: t0,
      );

      final snapshot = projectHome(
        contexts: <LoopContext>[
          LoopContext(
            loop: loopA.loop,
            evidence: <Evidence>[basisA],
            events: const [],
          ),
          LoopContext(
            loop: delegated.unwrap.loop,
            evidence: <Evidence>[basisB],
            events: const [],
          ),
        ],
        resolveEvidence: (EvidenceId id) =>
            id == basisA.id ? basisA : (id == basisB.id ? basisB : null),
        profile: profile,
        now: t0,
      );

      expect(snapshot.activeLoops, 2);
      expect(snapshot.countOf(LoopCategory.waiting), 1);
    });

    test('a resolved loop counts toward closedCount, not activeLoops', () {
      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'x',
        basis: basis.id,
        now: t0,
      );
      final resolved =
          machine.apply(created.loop, const Complete(), now: t0).unwrap;

      final snapshot = projectHome(
        contexts: <LoopContext>[
          LoopContext(
            loop: resolved.loop,
            evidence: <Evidence>[basis],
            events: const [],
          ),
        ],
        resolveEvidence: (EvidenceId id) => id == basis.id ? basis : null,
        profile: profile,
        now: t0,
      );

      expect(snapshot.activeLoops, 0);
      expect(snapshot.closedCount, 1);
    });

    test(
        'produces a HomeSnapshot with zero model calls — nothing here can '
        'reach a network', () {
      // Structural proof lives in test/architecture/; this is the
      // behavioural half: the same deterministic call, run twice with
      // identical input, must produce an identical result — the signature
      // of a rule table, not of anything that could vary by way of a
      // model call.
      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'x',
        basis: basis.id,
        now: t0,
      );
      List<LoopContext> contexts() => <LoopContext>[
            LoopContext(
              loop: created.loop,
              evidence: <Evidence>[basis],
              events: const [],
            ),
          ];
      Evidence? resolve(EvidenceId id) => id == basis.id ? basis : null;

      final first = projectHome(
        contexts: contexts(),
        resolveEvidence: resolve,
        profile: profile,
        now: t0,
      );
      final second = projectHome(
        contexts: contexts(),
        resolveEvidence: resolve,
        profile: profile,
        now: t0,
      );
      expect(first.summaries, second.summaries);
      expect(first.activeLoops, second.activeLoops);
    });
  });

  group('loadHomeSnapshot, against a repository', () {
    test(
        'produces a real HomeSnapshot from loops stored through '
        'InMemoryLoopRepository', () async {
      final InMemoryLoopRepository repo = InMemoryLoopRepository();
      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'Send the signed lease',
        basis: basis.id,
        now: t0,
      );
      await repo.saveOutcome(created, newEvidence: <Evidence>[basis]);

      final snapshot = await loadHomeSnapshot(
        repository: repo,
        profile: profile,
        now: t0,
      );

      expect(snapshot.profile, profile);
      expect(snapshot.activeLoops, 1);
      await repo.close();
    });
  });
}
