import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/data/local/database/loop_database.dart';
import 'package:loop/data/local/mapping/evidence_mapping.dart';
import 'package:loop/domain/evidence/capture_integrity.dart';
import 'package:loop/domain/evidence/evidence.dart';
import 'package:loop/domain/ids.dart';

import '../../../domain/fixtures.dart';

void main() {
  late LoopDatabase db;

  setUp(() {
    db = LoopDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('ObservedFact round trip', () {
    test(
        'captures source, integrity and excerpt without becoming an '
        'Inference', () async {
      final ObservedFact original = fact(
        id: 'ev-fact-1',
        integrity: CaptureIntegrity.transcribed,
        excerpt: "I'll send it Friday",
      );
      await db.into(db.evidenceEntries).insert(evidenceToCompanion(original));

      final EvidenceEntry row = await db.select(db.evidenceEntries).getSingle();
      final Evidence restored = evidenceFromEntry(row);

      expect(restored, isA<ObservedFact>());
      final ObservedFact restoredFact = restored as ObservedFact;
      expect(restoredFact.id, original.id);
      expect(restoredFact.capturedAt, original.capturedAt);
      expect(restoredFact.sensitivity, original.sensitivity);
      expect(restoredFact.source, original.source);
      expect(restoredFact.integrity, CaptureIntegrity.transcribed);
      expect(restoredFact.excerpt, original.excerpt);
    });

    test(
        'CaptureIntegrity round-trips as its own enum, distinct from '
        'Confidence', () async {
      for (final CaptureIntegrity integrity in CaptureIntegrity.values) {
        final ObservedFact original = fact(
          id: 'ev-${integrity.name}',
          integrity: integrity,
        );
        await db.into(db.evidenceEntries).insert(evidenceToCompanion(original));
      }

      final List<EvidenceEntry> rows =
          await db.select(db.evidenceEntries).get();
      final Set<CaptureIntegrity> restoredIntegrities = rows
          .map((EvidenceEntry r) => evidenceFromEntry(r))
          .whereType<ObservedFact>()
          .map((ObservedFact f) => f.integrity)
          .toSet();
      expect(restoredIntegrities, CaptureIntegrity.values.toSet());
    });

    test('an ObservedFact carries no confidence column values', () async {
      final ObservedFact original = fact();
      await db.into(db.evidenceEntries).insert(evidenceToCompanion(original));
      final EvidenceEntry row = await db.select(db.evidenceEntries).getSingle();
      expect(row.confidenceValue, isNull);
      expect(row.claimKind, isNull);
    });
  });

  group('Inference round trip', () {
    test(
        'claim, confidence and producedBy all survive, as two distinct '
        'ProducerRef values', () async {
      final Inference original = inference(id: 'ev-inf-1', value: 0.68);
      await db.into(db.evidenceEntries).insert(evidenceToCompanion(original));

      final EvidenceEntry row = await db.select(db.evidenceEntries).getSingle();
      final Evidence restored = evidenceFromEntry(
        row,
        derivedFrom: original.derivedFrom,
      );

      expect(restored, isA<Inference>());
      final Inference restoredInference = restored as Inference;
      expect(restoredInference.id, original.id);
      expect(restoredInference.claim, original.claim);
      expect(restoredInference.confidence.value, original.confidence.value);
      expect(restoredInference.confidence.basis, original.confidence.basis);
      expect(restoredInference.confidence.method, original.confidence.method);
      expect(restoredInference.confidence.under, original.confidence.under);
      expect(
        restoredInference.confidence.computedAt,
        original.confidence.computedAt,
      );
      expect(restoredInference.producedBy, original.producedBy);
    });

    test(
        'Confidence semantic value is independent of CaptureIntegrity — '
        'both round-trip without capping each other', () async {
      final Inference original = inference(id: 'ev-inf-2', value: 0.91);
      await db.into(db.evidenceEntries).insert(evidenceToCompanion(original));
      final EvidenceEntry row = await db.select(db.evidenceEntries).getSingle();
      final Inference restored = evidenceFromEntry(
        row,
        derivedFrom: original.derivedFrom,
      ) as Inference;
      expect(restored.confidence.value, 0.91);
    });

    test(
        'provenance: derivedFrom is reconstructable via '
        'InferenceDerivations, in the order it was written', () async {
      final ObservedFact source1 = fact(id: 'ev-source-1');
      final ObservedFact source2 = fact(id: 'ev-source-2');
      final Inference original = inference(
        id: 'ev-inf-3',
        from: <String>['ev-source-1', 'ev-source-2'],
      );

      await db.into(db.evidenceEntries).insert(evidenceToCompanion(source1));
      await db.into(db.evidenceEntries).insert(evidenceToCompanion(source2));
      await db.into(db.evidenceEntries).insert(evidenceToCompanion(original));
      for (final (int i, EvidenceId sourceId) in original.derivedFrom.indexed) {
        await db.into(db.inferenceDerivations).insert(
              InferenceDerivationsCompanion.insert(
                inferenceId: original.id.value,
                sourceEvidenceId: sourceId.value,
                position: i,
              ),
            );
      }

      final List<InferenceDerivation> links = await (db.select(
        db.inferenceDerivations,
      )..where((t) => t.inferenceId.equals(original.id.value)))
          .get();
      links.sort(
        (InferenceDerivation a, InferenceDerivation b) =>
            a.position.compareTo(b.position),
      );
      final List<EvidenceId> reconstructedDerivedFrom = links
          .map((InferenceDerivation l) => EvidenceId(l.sourceEvidenceId))
          .toList();

      expect(reconstructedDerivedFrom, original.derivedFrom);

      final EvidenceEntry row = await (db.select(
        db.evidenceEntries,
      )..where((t) => t.id.equals(original.id.value)))
          .getSingle();
      final Inference restored = evidenceFromEntry(
        row,
        derivedFrom: reconstructedDerivedFrom,
      ) as Inference;
      expect(restored.derivedFrom, original.derivedFrom);
    });

    test('a duplicate (inferenceId, sourceEvidenceId) derivation is refused',
        () async {
      final ObservedFact source = fact(id: 'ev-source-dup');
      final Inference original =
          inference(id: 'ev-inf-dup', from: <String>['ev-source-dup']);
      await db.into(db.evidenceEntries).insert(evidenceToCompanion(source));
      await db.into(db.evidenceEntries).insert(evidenceToCompanion(original));
      await db.into(db.inferenceDerivations).insert(
            InferenceDerivationsCompanion.insert(
              inferenceId: original.id.value,
              sourceEvidenceId: source.id.value,
              position: 0,
            ),
          );

      expect(
        () => db.into(db.inferenceDerivations).insert(
              InferenceDerivationsCompanion.insert(
                inferenceId: original.id.value,
                sourceEvidenceId: source.id.value,
                position: 1,
              ),
            ),
        throwsA(anything),
      );
    });
  });

  group('UserAssertion round trip', () {
    test('confirms/rejects carry the inference they judge; states does not',
        () async {
      final Inference judged = inference(id: 'ev-judged');
      await db.into(db.evidenceEntries).insert(evidenceToCompanion(judged));

      final UserAssertion confirmation = assertion(
        id: 'ev-confirm',
        kind: AssertionKind.confirms,
        about: 'ev-judged',
      );
      await db
          .into(db.evidenceEntries)
          .insert(evidenceToCompanion(confirmation));

      final UserAssertion stated = assertion(
        id: 'ev-stated',
        kind: AssertionKind.states,
        about: null,
      );
      await db.into(db.evidenceEntries).insert(evidenceToCompanion(stated));

      final List<EvidenceEntry> rows =
          await db.select(db.evidenceEntries).get();
      final Map<String, Evidence> byId = <String, Evidence>{
        for (final EvidenceEntry r in rows)
          r.id: evidenceFromEntry(
            r,
            // Only the judged Inference row needs its provenance supplied;
            // this test is not exercising InferenceDerivations itself (see
            // the dedicated 'provenance' test for that), so the known
            // fixture value is enough to satisfy the domain's own
            // non-empty-derivedFrom invariant.
            derivedFrom: r.id == judged.id.value
                ? judged.derivedFrom
                : const <EvidenceId>[],
          ),
      };

      final UserAssertion restoredConfirm =
          byId['ev-confirm']! as UserAssertion;
      expect(restoredConfirm.kind, AssertionKind.confirms);
      expect(restoredConfirm.about, const EvidenceId('ev-judged'));

      final UserAssertion restoredStated = byId['ev-stated']! as UserAssertion;
      expect(restoredStated.kind, AssertionKind.states);
      expect(restoredStated.about, isNull);
    });

    test(
        'a confirmation does not overwrite the inference it judges — both '
        'rows survive independently', () async {
      final Inference judged = inference(id: 'ev-judged-2');
      final UserAssertion confirmation = assertion(
        id: 'ev-confirm-2',
        about: 'ev-judged-2',
      );
      await db.into(db.evidenceEntries).insert(evidenceToCompanion(judged));
      await db
          .into(db.evidenceEntries)
          .insert(evidenceToCompanion(confirmation));

      final List<EvidenceEntry> rows =
          await db.select(db.evidenceEntries).get();
      expect(rows, hasLength(2));
      expect(
        rows
            .map(
              (EvidenceEntry r) => evidenceFromEntry(
                r,
                derivedFrom: r.id == judged.id.value
                    ? judged.derivedFrom
                    : const <EvidenceId>[],
              ),
            )
            .whereType<Inference>(),
        hasLength(1),
      );
    });
  });

  group('corrupt / invalid persisted values fail safely', () {
    test(
        'an unrecognised type discriminator throws rather than silently '
        'guessing a subtype', () async {
      await db.into(db.evidenceEntries).insert(
            EvidenceEntriesCompanion.insert(
              id: 'ev-corrupt',
              type: 'somethingFutureVersionInvented',
              capturedAtMillis: t0.millisecondsSinceEpoch,
              sensitivity: 'ordinary',
            ),
          );
      final EvidenceEntry row = await db.select(db.evidenceEntries).getSingle();
      expect(() => evidenceFromEntry(row), throwsArgumentError);
    });

    test(
        'a required subtype field left null throws rather than producing '
        'a half-built Evidence', () async {
      // An ObservedFact row with `integrity` missing — the schema allows it
      // (the column is nullable, since it does not apply to the other two
      // subtypes), but reconstructing an ObservedFact without it is not
      // recoverable data, and evidenceFromEntry says so with a null-check
      // failure rather than inventing a default integrity.
      await db.into(db.evidenceEntries).insert(
            EvidenceEntriesCompanion.insert(
              id: 'ev-incomplete',
              type: 'observedFact',
              capturedAtMillis: t0.millisecondsSinceEpoch,
              sensitivity: 'ordinary',
            ),
          );
      final EvidenceEntry row = await db.select(db.evidenceEntries).getSingle();
      expect(() => evidenceFromEntry(row), throwsA(anything));
    });
  });
}
