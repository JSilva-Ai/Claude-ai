import 'package:flutter_test/flutter_test.dart';
import 'package:loop/application/ingestion/source_ingestion_service.dart';
import 'package:loop/domain/evidence/evidence.dart';
import 'package:loop/domain/evidence/source_ref.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/source/ingestion_result.dart';

import '../../domain/fixtures.dart';
import '../../domain/source_fixtures.dart';

/// A fake lookup, standing in for a future Drift-backed query — the same
/// relationship `InMemoryLoopRepository` already has to `DriftLoopRepository`.
/// Keyed on the full [SourceRef] triple (source kind, locator, account ref)
/// exactly like schema v1's own `sourceKind`/`sourceLocator`/
/// `sourceAccountRef` columns already are.
class _FakeSourceLedger {
  final Map<SourceRef, ObservedFact> _known = <SourceRef, ObservedFact>{};

  Future<ObservedFact?> call(SourceRef source) async => _known[source];

  void remember(ObservedFact fact) => _known[fact.source] = fact;
}

void main() {
  group('SourceIngestionService', () {
    test('a source seen for the first time is accepted', () async {
      final _FakeSourceLedger ledger = _FakeSourceLedger();
      final SourceIngestionService service =
          SourceIngestionService(lookup: ledger.call);

      final IngestionResult result = await service.ingest(
        observation: messageObservation(),
        assignId: basisId,
      );

      expect(result, isA<IngestionAccepted>());
    });

    test(
        'the lookup result is what decides duplicate vs. accepted — the '
        'service performs no comparison of its own', () async {
      final _FakeSourceLedger ledger = _FakeSourceLedger();
      final SourceIngestionService service =
          SourceIngestionService(lookup: ledger.call);

      final IngestionResult first = await service.ingest(
        observation: messageObservation(),
        assignId: basisId,
      );
      ledger.remember((first as IngestionAccepted).evidence);

      final IngestionResult second = await service.ingest(
        observation: messageObservation(),
        assignId: const EvidenceId('would-be-wasted'),
      );

      expect(second, isA<IngestionDuplicate>());
      expect((second as IngestionDuplicate).existing, basisId);
    });

    test('repeat delivery through the full async path stays idempotent',
        () async {
      final _FakeSourceLedger ledger = _FakeSourceLedger();
      final SourceIngestionService service =
          SourceIngestionService(lookup: ledger.call);

      final IngestionResult first = await service.ingest(
        observation: messageObservation(),
        assignId: basisId,
      );
      ledger.remember((first as IngestionAccepted).evidence);

      for (int i = 0; i < 3; i++) {
        final IngestionResult repeat = await service.ingest(
          observation: messageObservation(),
          assignId: const EvidenceId('unused'),
        );
        expect(repeat, isA<IngestionDuplicate>());
      }
    });

    test('an update reaches the caller through the same async path', () async {
      final _FakeSourceLedger ledger = _FakeSourceLedger();
      final SourceIngestionService service =
          SourceIngestionService(lookup: ledger.call);

      final IngestionResult first = await service.ingest(
        observation: messageObservation(excerpt: "I'll send it Friday"),
        assignId: basisId,
      );
      ledger.remember((first as IngestionAccepted).evidence);

      final IngestionResult second = await service.ingest(
        observation: messageObservation(excerpt: 'Actually Monday is fine'),
        assignId: const EvidenceId('ev-monday'),
      );

      expect(second, isA<IngestionUpdated>());
      expect((second as IngestionUpdated).previous, basisId);
    });

    test('rejection does not require a lookup to have found anything',
        () async {
      final _FakeSourceLedger ledger = _FakeSourceLedger();
      final SourceIngestionService service =
          SourceIngestionService(lookup: ledger.call);

      final IngestionResult result = await service.ingest(
        observation: messageObservation(locator: ''),
        assignId: basisId,
      );

      expect(result, isA<IngestionRejected>());
    });
  });
}
