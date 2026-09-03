import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/data/local/database/loop_database.dart';
import 'package:loop/data/local/mapping/evidence_mapping.dart';
import 'package:loop/data/local/mapping/loop_mapping.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/loop/loop.dart';
import 'package:loop/domain/loop/loop_state.dart';

import '../../../domain/fixtures.dart';

void main() {
  late LoopDatabase db;

  setUp(() {
    db = LoopDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  /// Writes the basis evidence and the loop itself, and the join row the
  /// domain's own invariant requires — a repository's job in 2C-B, done by
  /// hand here to prove the schema can hold what the mapping produces.
  Future<void> insertLoopWithBasis(Loop loop) async {
    await db
        .into(db.evidenceEntries)
        .insert(evidenceToCompanion(fact(id: loop.basis.value)));
    await db.into(db.loopRecords).insert(loopToCompanion(loop));
    for (final EvidenceId evidenceId in loop.evidence) {
      await db.into(db.loopEvidenceLinks).insert(
            LoopEvidenceLinksCompanion.insert(
              loopId: loop.id.value,
              evidenceId: evidenceId.value,
            ),
          );
    }
  }

  group('Loop round trip', () {
    test('a loop in a resting state (open) round-trips every field', () async {
      final Loop original = loopIn(LoopState.open);
      await insertLoopWithBasis(original);

      final LoopRecord row = await db.select(db.loopRecords).getSingle();
      final Loop restored = loopFromRecord(row, evidence: original.evidence);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.state, original.state);
      expect(restored.basis, original.basis);
      expect(restored.evidence, original.evidence);
      expect(restored.pinned, original.pinned);
      expect(restored.sensitivity, original.sensitivity);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
      expect(restored.stateChangedAt, original.stateChangedAt);
      expect(restored.schemaVersion, original.schemaVersion);
      expect(restored.revision, original.revision);
      expect(restored.commitment, isNull);
      expect(restored.suggestion, isNull);
      expect(restored.waitingOn, isNull);
      expect(restored.resolvedAt, isNull);
      expect(restored.abandonReason, isNull);
    });

    test('a waiting loop round-trips waitingOn and waitingSince', () async {
      final Loop original = loopIn(LoopState.waiting);
      await insertLoopWithBasis(original);

      final LoopRecord row = await db.select(db.loopRecords).getSingle();
      final Loop restored = loopFromRecord(row, evidence: original.evidence);

      expect(restored.waitingOn, original.waitingOn);
      expect(restored.waitingSince, original.waitingSince);
    });

    test('a resolved loop round-trips resolvedAt', () async {
      final Loop original = loopIn(LoopState.resolved);
      await insertLoopWithBasis(original);

      final LoopRecord row = await db.select(db.loopRecords).getSingle();
      final Loop restored = loopFromRecord(row, evidence: original.evidence);

      expect(restored.resolvedAt, original.resolvedAt);
    });

    test('an abandoned loop round-trips its AbandonReason', () async {
      final Loop original = loopIn(LoopState.abandoned);
      await insertLoopWithBasis(original);

      final LoopRecord row = await db.select(db.loopRecords).getSingle();
      final Loop restored = loopFromRecord(row, evidence: original.evidence);

      expect(restored.abandonReason, original.abandonReason);
    });

    test(
        'a pinned, suppressed loop with a commitment and a suggestion '
        'reference round-trips as opaque ids, no target table required',
        () async {
      final Loop original = loopIn(LoopState.open).copyWith(
        pinned: true,
        suppressedUntil: t0.add(const Duration(days: 3)),
      );
      // commitment/suggestion are set via the constructor directly since
      // copyWith on the approved Loop never assigns them (see the schema v1
      // ADR note on why ActionSuggestion is not persisted).
      final Loop withRefs = Loop(
        id: original.id,
        title: original.title,
        state: original.state,
        basis: original.basis,
        evidence: original.evidence,
        createdAt: original.createdAt,
        updatedAt: original.updatedAt,
        stateChangedAt: original.stateChangedAt,
        pinned: original.pinned,
        suppressedUntil: original.suppressedUntil,
        commitment: const CommitmentId('commitment-1'),
        suggestion: const ActionSuggestionId('loop-1:confirmDetectedProposal'),
      );
      await insertLoopWithBasis(withRefs);

      final LoopRecord row = await db.select(db.loopRecords).getSingle();
      final Loop restored = loopFromRecord(row, evidence: withRefs.evidence);

      expect(restored.commitment, withRefs.commitment);
      expect(restored.suggestion, withRefs.suggestion);
      expect(restored.pinned, isTrue);
      expect(restored.suppressedUntil, withRefs.suppressedUntil);
    });

    test(
        'strong ids survive the round trip losslessly, through the '
        'deserialisation boundary ids.dart itself names', () async {
      final Loop original = loopIn(LoopState.open);
      await insertLoopWithBasis(original);

      final LoopRecord row = await db.select(db.loopRecords).getSingle();
      final Loop restored = loopFromRecord(row, evidence: original.evidence);

      // Equality here is on the wrapped string, which is what an extension
      // type erases to — the real proof that the id is *strong* again after
      // storage is that `restored` type-checks as a `Loop`, whose
      // constructor demands a `LoopId`, not a `String`. A raw string could
      // never have been passed to it.
      expect(restored.id.value, original.id.value);
      expect(restored.basis.value, original.basis.value);
    });

    test(
        'loopFromRecord reconstructs ids through LoopId.parse, which '
        'refuses an empty value the way any deserialisation boundary should',
        () {
      expect(() => LoopId.parse(''), throwsArgumentError);
      expect(() => LoopId.parse('  '), throwsArgumentError);
    });
  });
}
