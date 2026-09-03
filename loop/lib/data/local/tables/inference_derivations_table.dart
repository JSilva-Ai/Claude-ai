import 'package:drift/drift.dart';

import 'evidence_entries_table.dart';

/// `Inference.derivedFrom`, one row per source evidence.
///
/// A `List<EvidenceId>` cannot be a column; it is a list of foreign keys, and
/// this is the normalised shape of exactly that. It is also what makes
/// provenance a query rather than a parse: reconstructing a `ProvenanceChain`
/// is a lookup on [inferenceId], not decoding a serialised list column and
/// hoping every writer encoded it the same way.
///
/// [position] preserves the order `derivedFrom` was constructed with, since
/// nothing else in the schema does — it is not itself meaningful to the
/// domain today, but losing it during a round trip would be a fact invented
/// at read time that the write time never asserted.
@DataClassName('InferenceDerivation')
class InferenceDerivations extends Table {
  /// The `Inference` row this derivation belongs to.
  TextColumn get inferenceId => text().references(EvidenceEntries, #id)();

  /// One piece of evidence the inference above was derived from.
  TextColumn get sourceEvidenceId => text().references(EvidenceEntries, #id)();

  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => <Column>{inferenceId, sourceEvidenceId};
}
