import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/failures.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/loop/loop.dart';
import 'package:loop/domain/loop/loop_state.dart';
import 'package:loop/domain/loop/loop_state_machine.dart';
import 'package:loop/domain/loop/loop_transition.dart';
import 'package:loop/domain/policies/staleness_policy.dart';
import 'package:loop/domain/result.dart';

import 'fixtures.dart';

void main() {
  const LoopStateMachine machine = LoopStateMachine();
  const StalenessPolicy staleness = StalenessPolicy();

  group('time alone changes nothing', () {
    test('a proposal goes stale as a reading, not as a mutation', () {
      final Loop proposal = loopIn(LoopState.detected);
      final DateTime muchLater = t0.add(const Duration(days: 30));

      expect(staleness.isStale(proposal, now: t0), isFalse);
      expect(staleness.isStale(proposal, now: muchLater), isTrue);

      // The answer changed because the moment changed. The loop did not: same
      // state, same revision, same timestamps. There is no code path in this
      // layer that a clock can trigger.
      expect(proposal.state, LoopState.detected);
      expect(proposal.revision, 1);
      expect(proposal.updatedAt, t0);
      expect(proposal.stateChangedAt, t0);
    });

    test('staleness is meaningless for anything but a proposal', () {
      final DateTime muchLater = t0.add(const Duration(days: 90));
      for (final LoopState state in LoopState.values) {
        if (state == LoopState.detected) continue;
        expect(
          staleness.isStale(loopIn(state), now: muchLater),
          isFalse,
          reason: '${state.name} is not a proposal',
        );
      }
    });

    test('suppression is a question about now, not a stored state', () {
      final Loop suppressed = loopIn(
        LoopState.open,
      ).copyWith(suppressedUntil: t0.add(const Duration(days: 2)));

      expect(suppressed.isSuppressedAt(t0), isTrue);
      final DateTime afterWindow = t0.add(const Duration(days: 3));
      expect(suppressed.isSuppressedAt(afterWindow), isFalse);
      expect(
        suppressed.state,
        LoopState.open,
        reason: 'never a state of its own',
      );
    });
  });

  group('expiring a proposal is an act with an author', () {
    test('it requires a reconciliation pass, not a person and not a timer', () {
      final Loop proposal = loopIn(LoopState.detected);
      final DateTime now = t0.add(const Duration(days: 30));

      final Result<LoopOutcome> byUser = machine.apply(
        proposal,
        const ExpireProposal(actor: TransitionActor.user),
        now: now,
      );

      expect(byUser.isErr, isTrue);
      expect(byUser.failureOrNull, isA<TransitionPreconditionUnmet>());
      expect(proposal.state, LoopState.detected, reason: 'nothing changed');
    });

    test('the reconciliation pass records itself as the actor', () {
      final DateTime now = t0.add(const Duration(days: 30));
      final LoopOutcome out = machine
          .apply(loopIn(LoopState.detected), const ExpireProposal(), now: now)
          .unwrap;

      expect(out.loop.state, LoopState.abandoned);
      expect(out.loop.abandonReason, AbandonReason.expired);
      expect(out.event.actor, TransitionActor.systemReconciliation);
      expect(out.event.at, now);
      // Expiry is distinguishable from every other way a loop ends, which is
      // what lets it mean "nobody answered" rather than "the detector erred".
      expect(out.event.reason, AbandonReason.expired);
    });
  });

  group('the clock cannot run backwards over a loop', () {
    test('a transition dated before the loop is refused', () {
      final Loop loop = loopIn(
        LoopState.open,
        updatedAt: t0.add(const Duration(hours: 5)),
      );

      final Result<LoopOutcome> result = machine.apply(
        loop,
        const Start(),
        now: t0,
      );

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<TransitionPreconditionUnmet>());
    });

    test('attaching evidence dated before the loop is refused', () {
      final Loop loop = loopIn(
        LoopState.open,
        updatedAt: t0.add(const Duration(hours: 5)),
      );

      final Result<LoopOutcome> result = machine.attachEvidence(
        loop,
        const EvidenceId('ev-late'),
        now: t0,
      );

      expect(result.isErr, isTrue);
      expect(loop.evidence, hasLength(1));
    });
  });

  group('the domain reads no clock', () {
    test('DateTime.now() appears nowhere in lib/domain', () {
      // The rule that makes every one of the assertions above meaningful: if a
      // single function could ask what time it is, none of this would be
      // deterministic and "the passage of time changed nothing" would be
      // unprovable.
      final List<String> offenders = <String>[];
      for (final FileSystemEntity entity
          in Directory('lib/domain').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final String source = entity.readAsStringSync();
        if (source.contains('DateTime.now(') ||
            source.contains('Stopwatch(') ||
            source.contains('Timer(')) {
          offenders.add(entity.path);
        }
      }
      expect(offenders, isEmpty);
    });
  });
}
