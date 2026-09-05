import 'package:drift/drift.dart';

import '../../../domain/evidence/capture_integrity.dart';
import '../../../domain/evidence/claim.dart';
import '../../../domain/evidence/confidence.dart';
import '../../../domain/evidence/data_sensitivity.dart';
import '../../../domain/evidence/evidence.dart';
import '../../../domain/evidence/source_ref.dart';
import '../../../domain/ids.dart';
import '../database/loop_database.dart';
import 'enum_codec.dart';
import 'persisted_time.dart';

/// The [EvidenceEntries.type] discriminator. A closed set matching the three
/// `Evidence` subtypes, checked against by name, never by ordinal.
enum _EvidenceEntryType { observedFact, inference, userAssertion }

/// Domain → storage.
///
/// Does not write [InferenceDerivations]: `Inference.derivedFrom` is a list
/// of foreign keys, not a column, and writing the join rows for it is a
/// multi-statement operation — a repository's job in 2C-B, same as
/// `Loop.evidence` in `loop_mapping.dart`.
EvidenceEntriesCompanion evidenceToCompanion(Evidence evidence) {
  final String sensitivity = encodeEnum(evidence.sensitivity);
  final int capturedAt = toPersistedMillis(evidence.capturedAt);

  return switch (evidence) {
    ObservedFact(:final SourceRef source, :final CaptureIntegrity integrity) =>
      EvidenceEntriesCompanion.insert(
        id: evidence.id.value,
        type: encodeEnum(_EvidenceEntryType.observedFact),
        capturedAtMillis: capturedAt,
        sensitivity: sensitivity,
        sourceKind: Value<String?>(encodeEnum(source.source)),
        sourceLocator: Value<String?>(source.locator),
        sourceAccountRef: Value<String?>(source.accountRef),
        integrity: Value<String?>(encodeEnum(integrity)),
        excerpt: Value<String?>(evidence.excerpt),
      ),
    Inference(
      :final Claim claim,
      :final Confidence confidence,
      :final ProducerRef producedBy,
    ) =>
      EvidenceEntriesCompanion.insert(
        id: evidence.id.value,
        type: encodeEnum(_EvidenceEntryType.inference),
        capturedAtMillis: capturedAt,
        sensitivity: sensitivity,
        claimKind: Value<String?>(encodeEnum(claim.kind)),
        claimCounterparty: Value<String?>(claim.counterparty?.value),
        claimByMillis: Value<int?>(
          claim.by == null ? null : toPersistedMillis(claim.by!),
        ),
        claimSourceQuote: Value<String?>(claim.sourceQuote),
        producedById: Value<String?>(producedBy.id),
        producedByVersion: Value<String?>(producedBy.version),
        confidenceValue: Value<double?>(confidence.value),
        confidenceBasis: Value<String?>(encodeEnum(confidence.basis)),
        confidenceMethodId: Value<String?>(confidence.method.id),
        confidenceMethodVersion: Value<String?>(confidence.method.version),
        confidenceUnder: Value<String?>(confidence.under.value),
        confidenceComputedAtMillis: Value<int?>(
          toPersistedMillis(confidence.computedAt),
        ),
      ),
    UserAssertion(
      :final AssertionKind kind,
      :final Claim claim,
      :final EvidenceId? about,
    ) =>
      EvidenceEntriesCompanion.insert(
        id: evidence.id.value,
        type: encodeEnum(_EvidenceEntryType.userAssertion),
        capturedAtMillis: capturedAt,
        sensitivity: sensitivity,
        claimKind: Value<String?>(encodeEnum(claim.kind)),
        claimCounterparty: Value<String?>(claim.counterparty?.value),
        claimByMillis: Value<int?>(
          claim.by == null ? null : toPersistedMillis(claim.by!),
        ),
        claimSourceQuote: Value<String?>(claim.sourceQuote),
        assertionKind: Value<String?>(encodeEnum(kind)),
        aboutEvidenceId: Value<String?>(about?.value),
      ),
  };
}

/// Storage → domain.
///
/// [derivedFrom] is required only to reconstruct an [Inference] row and is
/// ignored otherwise; supplying it is the caller's job (a join on
/// [InferenceDerivations]) for the same reason [loopFromRecord] takes
/// `evidence` as a parameter rather than querying for it itself.
Evidence evidenceFromEntry(
  EvidenceEntry row, {
  List<EvidenceId> derivedFrom = const <EvidenceId>[],
}) {
  final EvidenceId id = EvidenceId.parse(row.id);
  final DateTime capturedAt = fromPersistedMillis(row.capturedAtMillis);
  final DataSensitivity sensitivity = decodeEnum(
    DataSensitivity.values,
    row.sensitivity,
  );

  return switch (decodeEnum(_EvidenceEntryType.values, row.type)) {
    _EvidenceEntryType.observedFact => ObservedFact(
        id: id,
        capturedAt: capturedAt,
        sensitivity: sensitivity,
        source: SourceRef(
          source: decodeEnum(EvidenceSource.values, row.sourceKind!),
          locator: row.sourceLocator!,
          accountRef: row.sourceAccountRef,
        ),
        integrity: decodeEnum(CaptureIntegrity.values, row.integrity!),
        excerpt: row.excerpt,
      ),
    _EvidenceEntryType.inference => Inference(
        id: id,
        capturedAt: capturedAt,
        sensitivity: sensitivity,
        derivedFrom: derivedFrom,
        claim: Claim(
          kind: decodeEnum(ClaimKind.values, row.claimKind!),
          counterparty: row.claimCounterparty == null
              ? null
              : PartyId.parse(row.claimCounterparty!),
          by: row.claimByMillis == null
              ? null
              : fromPersistedMillis(row.claimByMillis!),
          sourceQuote: row.claimSourceQuote,
        ),
        confidence: Confidence(
          value: row.confidenceValue!,
          basis: decodeEnum(ConfidenceBasis.values, row.confidenceBasis!),
          method: ProducerRef(
            id: row.confidenceMethodId!,
            version: row.confidenceMethodVersion!,
          ),
          under: CalibrationVersion(row.confidenceUnder!),
          computedAt: fromPersistedMillis(row.confidenceComputedAtMillis!),
        ),
        producedBy: ProducerRef(
          id: row.producedById!,
          version: row.producedByVersion!,
        ),
      ),
    _EvidenceEntryType.userAssertion => UserAssertion(
        id: id,
        capturedAt: capturedAt,
        sensitivity: sensitivity,
        kind: decodeEnum(AssertionKind.values, row.assertionKind!),
        claim: Claim(
          kind: decodeEnum(ClaimKind.values, row.claimKind!),
          counterparty: row.claimCounterparty == null
              ? null
              : PartyId.parse(row.claimCounterparty!),
          by: row.claimByMillis == null
              ? null
              : fromPersistedMillis(row.claimByMillis!),
          sourceQuote: row.claimSourceQuote,
        ),
        about: row.aboutEvidenceId == null
            ? null
            : EvidenceId.parse(row.aboutEvidenceId!),
      ),
  };
}
