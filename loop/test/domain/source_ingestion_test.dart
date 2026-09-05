import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/evidence/capture_integrity.dart';
import 'package:loop/domain/evidence/evidence.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/loop/loop.dart';
import 'package:loop/domain/loop/loop_state.dart';
import 'package:loop/domain/source/ingestion_result.dart';
import 'package:loop/domain/source/source_ingestion.dart';
import 'package:loop/domain/source/source_observation.dart';

import 'fixtures.dart';
import 'source_fixtures.dart';

void main() {
  const SourceIngestion ingestion = SourceIngestion();

  group('a new source item', () {
    test('is accepted as a fresh ObservedFact', () {
      final IngestionResult result = ingestion.ingest(
        observation: messageObservation(),
        assignId: basisId,
      );

      expect(result, isA<IngestionAccepted>());
      final ObservedFact fact = (result as IngestionAccepted).evidence;
      expect(fact.id, basisId);
      expect(fact.source.locator, 'email:message/1');
      expect(fact.integrity, CaptureIntegrity.verbatim);
      expect(fact.excerpt, "I'll send it Friday");
    });
  });

  group('the same item, unchanged, delivered again', () {
    test('is reported as a duplicate — no new Evidence is described', () {
      final SourceObservation observation = messageObservation();
      final IngestionAccepted first = ingestion.ingest(
        observation: observation,
        assignId: basisId,
      ) as IngestionAccepted;

      final IngestionResult result = ingestion.ingest(
        observation: observation,
        assignId: const EvidenceId('would-be-wasted'),
        existingForSource: first.evidence,
      );

      expect(result, isA<IngestionDuplicate>());
      expect((result as IngestionDuplicate).existing, basisId);
    });

    test('is idempotent across repeated calls with the same inputs', () {
      final SourceObservation observation = messageObservation();
      final IngestionAccepted first = ingestion.ingest(
        observation: observation,
        assignId: basisId,
      ) as IngestionAccepted;

      final List<IngestionResult> repeats = List<IngestionResult>.generate(
        3,
        (_) => ingestion.ingest(
          observation: observation,
          assignId: const EvidenceId('unused'),
          existingForSource: first.evidence,
        ),
      );

      for (final IngestionResult r in repeats) {
        expect(r, isA<IngestionDuplicate>());
        expect((r as IngestionDuplicate).existing, basisId);
      }
    });
  });

  group('the same item, changed since it was captured', () {
    test(
        'is reported as an update, producing a new ObservedFact and '
        'leaving the previous one named, not touched', () {
      final ObservedFact previous = (ingestion.ingest(
        observation: messageObservation(excerpt: "I'll send it Friday"),
        assignId: basisId,
      ) as IngestionAccepted)
          .evidence;

      final IngestionResult result = ingestion.ingest(
        observation: messageObservation(excerpt: 'Actually Monday is fine'),
        assignId: const EvidenceId('ev-monday'),
        existingForSource: previous,
      );

      expect(result, isA<IngestionUpdated>());
      final IngestionUpdated updated = result as IngestionUpdated;
      expect(updated.previous, basisId);
      expect(updated.evidence.id, const EvidenceId('ev-monday'));
      expect(updated.evidence.excerpt, 'Actually Monday is fine');
      // The previous fact is a separate object, never mutated — Evidence's
      // own immutability, unaffected by ingestion.
      expect(previous.excerpt, "I'll send it Friday");
    });

    test('any changed field triggers an update, not just the excerpt', () {
      final IngestionAccepted first = ingestion.ingest(
        observation: messageObservation(),
        assignId: basisId,
      ) as IngestionAccepted;

      final IngestionResult result = ingestion.ingest(
        observation:
            messageObservation(integrity: CaptureIntegrity.transcribed),
        assignId: const EvidenceId('ev-2'),
        existingForSource: first.evidence,
      );

      expect(result, isA<IngestionUpdated>());
    });
  });

  group('a different item — including one in the same conversation', () {
    test(
        'a different locator is always a different item, never a '
        'duplicate or an update of another', () {
      final IngestionResult first = ingestion.ingest(
        observation: messageObservation(locator: 'email:message/1'),
        assignId: basisId,
      );
      final IngestionResult second = ingestion.ingest(
        observation: messageObservation(locator: 'email:message/2'),
        assignId: const EvidenceId('ev-2'),
      );

      expect(first, isA<IngestionAccepted>());
      expect(second, isA<IngestionAccepted>());
      expect(
        (first as IngestionAccepted).evidence.id,
        isNot((second as IngestionAccepted).evidence.id),
      );
    });
  });

  group('invalid input', () {
    test('a blank locator is rejected, not silently ingested', () {
      final IngestionResult result = ingestion.ingest(
        observation: messageObservation(locator: '   '),
        assignId: basisId,
      );

      expect(result, isA<IngestionRejected>());
      expect((result as IngestionRejected).reason, contains('locator'));
    });
  });

  group('determinism', () {
    test('the same inputs always produce the same decision', () {
      final SourceObservation observation = messageObservation();
      final IngestionResult a =
          ingestion.ingest(observation: observation, assignId: basisId);
      final IngestionResult b =
          ingestion.ingest(observation: observation, assignId: basisId);

      expect(a.runtimeType, b.runtimeType);
      expect(
        (a as IngestionAccepted).evidence.id,
        (b as IngestionAccepted).evidence.id,
      );
    });

    test(
        'ingestion can only ever produce an ObservedFact — '
        'IngestionAccepted/IngestionUpdated are typed to it, not to the '
        'broader Evidence, so an Inference/UserAssertion/Commitment/Loop '
        'is not a possible result by construction, not by convention', () {
      final IngestionResult result = ingestion.ingest(
        observation: messageObservation(),
        assignId: basisId,
      );
      final ObservedFact evidence = (result as IngestionAccepted).evidence;
      expect(evidence, isA<ObservedFact>());
    });
  });

  group('offline interoperability', () {
    test(
        'an ingested ObservedFact is an ordinary piece of Evidence — it '
        'needs no special casing to found a Loop, exactly like any other '
        'basis would', () {
      final IngestionAccepted accepted = ingestion.ingest(
        observation: manualObservation(),
        assignId: basisId,
      ) as IngestionAccepted;
      final ObservedFact fact = accepted.evidence;

      final Loop loop = Loop(
        id: loopId,
        title: 'Call the dentist',
        state: LoopState.open,
        basis: fact.id,
        evidence: <EvidenceId>[fact.id],
        createdAt: t0,
        updatedAt: t0,
        stateChangedAt: t0,
      );

      expect(loop.basis, fact.id);
    });
  });
}
