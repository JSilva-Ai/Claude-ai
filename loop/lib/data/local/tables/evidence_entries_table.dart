import 'package:drift/drift.dart';

/// Every [Evidence] the domain has ever recorded, one row per id.
///
/// Named `EvidenceEntries` rather than `Evidence` on purpose: the generated
/// row type would otherwise be called `Evidence`, colliding with the sealed
/// domain class of the same name the moment both are imported together —
/// which the mapping layer, in 2C-B, always will.
///
/// The three subtypes ([ObservedFact], [Inference], [UserAssertion]) share one
/// table rather than three, with [type] as the discriminator and the
/// subtype-only columns left nullable. A read that does not yet know which
/// subtype it is looking at — resolving a [ProvenanceChain], for instance —
/// is the common case, and it is a single indexed lookup here instead of a
/// join across three tables to find out which one applies.
///
/// What is a value object rather than a reference stays flattened as columns
/// on this table: `Claim` has no id of its own in the domain, so it is not
/// given one here either — a `claim_*` column set, nullable because
/// [ObservedFact] carries no claim at all.
///
/// What is a list of references — [Inference.derivedFrom] — cannot be
/// flattened, and is not: see [InferenceDerivations].
@DataClassName('EvidenceEntry')
class EvidenceEntries extends Table {
  /// The `EvidenceId.value` this row was written for.
  TextColumn get id => text()();

  /// One of 'observedFact' | 'inference' | 'userAssertion'. Never an ordinal:
  /// see `lib/data/local/mapping/enum_codec.dart`.
  TextColumn get type => text()();

  /// Epoch milliseconds, UTC. See `lib/data/local/mapping/persisted_time.dart`.
  IntColumn get capturedAtMillis => integer()();

  /// `DataSensitivity`, by name.
  TextColumn get sensitivity => text()();

  // --- ObservedFact only ---------------------------------------------------

  /// `SourceRef.source` (`EvidenceSource`), by name.
  TextColumn get sourceKind => text().nullable()();
  TextColumn get sourceLocator => text().nullable()();
  TextColumn get sourceAccountRef => text().nullable()();

  /// `CaptureIntegrity`, by name.
  TextColumn get integrity => text().nullable()();
  TextColumn get excerpt => text().nullable()();

  // --- Inference and UserAssertion: the embedded Claim ----------------------

  /// `ClaimKind`, by name.
  TextColumn get claimKind => text().nullable()();
  TextColumn get claimCounterparty => text().nullable()();
  IntColumn get claimByMillis => integer().nullable()();
  TextColumn get claimSourceQuote => text().nullable()();

  // --- Inference only --------------------------------------------------------

  /// `Inference.producedBy` (a `ProducerRef`) — distinct from
  /// [confidenceMethodId]/[confidenceMethodVersion], which is the producer of
  /// the *confidence number*, not of the inference itself. The two usually
  /// agree; the domain keeps them as two fields, so this does too.
  TextColumn get producedById => text().nullable()();
  TextColumn get producedByVersion => text().nullable()();

  RealColumn get confidenceValue => real().nullable()();

  /// `ConfidenceBasis`, by name.
  TextColumn get confidenceBasis => text().nullable()();
  TextColumn get confidenceMethodId => text().nullable()();
  TextColumn get confidenceMethodVersion => text().nullable()();

  /// `CalibrationVersion.value`.
  TextColumn get confidenceUnder => text().nullable()();
  IntColumn get confidenceComputedAtMillis => integer().nullable()();

  // --- UserAssertion only ------------------------------------------------

  /// `AssertionKind`, by name.
  TextColumn get assertionKind => text().nullable()();

  /// The inference being judged. Self-referencing: [UserAssertion.about]
  /// points at another row in this same table. Restrictive by default (no
  /// `ON DELETE CASCADE`) — deletion semantics are not designed yet, and a
  /// judged inference disappearing out from under its judgement silently is
  /// exactly the kind of convenience this phase was told not to add.
  TextColumn get aboutEvidenceId =>
      text().nullable().references(EvidenceEntries, #id)();

  @override
  Set<Column> get primaryKey => <Column>{id};
}
