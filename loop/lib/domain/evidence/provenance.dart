import '../ids.dart';
import 'evidence.dart';

/// How the domain reads evidence it does not hold.
///
/// A function rather than a repository: walking a chain needs nothing but
/// lookup, and asking for less is what keeps this layer free of storage.
typedef EvidenceResolver = Evidence? Function(EvidenceId id);

/// One step of the answer to "why does LOOP think this?".
class ProvenanceNode {
  const ProvenanceNode({required this.evidence, required this.depth});

  final Evidence evidence;

  /// 0 for the evidence asked about; one more for each step toward the source.
  final int depth;

  @override
  String toString() => 'ProvenanceNode(depth $depth, ${evidence.id})';
}

/// The chain from a conclusion back to what was observed.
///
/// This is the product's explanation, as data. Rendering it is the entire
/// implementation of "why is this here?" — no prose is generated, which is
/// exactly why the answer can be trusted: a model can write a plausible
/// explanation for a decision it did not make, and this cannot.
class ProvenanceChain {
  const ProvenanceChain({
    required this.nodes,
    required this.roots,
    required this.missing,
  });

  /// Breadth-first from the starting evidence toward its sources.
  final List<ProvenanceNode> nodes;

  /// The ends of the chain: what was observed, or what the person asserted.
  final List<Evidence> roots;

  /// Referenced evidence the resolver could not produce. Empty is the healthy
  /// case; a non-empty list is a broken store, and the chain reports it rather
  /// than pretending the lineage is complete.
  final List<EvidenceId> missing;

  /// True when the chain reaches something the world said or the person said.
  bool get isGrounded => roots.isNotEmpty && missing.isEmpty;

  int get depth {
    int deepest = 0;
    for (final ProvenanceNode node in nodes) {
      if (node.depth > deepest) deepest = node.depth;
    }
    return deepest;
  }

  @override
  String toString() =>
      'ProvenanceChain(${nodes.length} nodes, ${roots.length} roots'
      '${missing.isEmpty ? '' : ', ${missing.length} missing'})';
}

/// Walks evidence lineage.
class Provenance {
  const Provenance._();

  /// Builds the chain behind [start].
  ///
  /// Cycles are tolerated rather than fatal: evidence is append-only so a cycle
  /// should be impossible, but "should be impossible" is not a thing to rely on
  /// when the alternative is a stack overflow in front of a user. Each node is
  /// visited once.
  static ProvenanceChain of(EvidenceId start, EvidenceResolver resolve) {
    final List<ProvenanceNode> nodes = <ProvenanceNode>[];
    final List<Evidence> roots = <Evidence>[];
    final List<EvidenceId> missing = <EvidenceId>[];
    final Set<String> seen = <String>{};
    final List<(EvidenceId, int)> queue = <(EvidenceId, int)>[(start, 0)];

    while (queue.isNotEmpty) {
      final (EvidenceId id, int depth) = queue.removeAt(0);
      if (!seen.add(id.value)) continue;

      final Evidence? evidence = resolve(id);
      if (evidence == null) {
        missing.add(id);
        continue;
      }

      nodes.add(ProvenanceNode(evidence: evidence, depth: depth));

      switch (evidence) {
        case Inference(:final List<EvidenceId> derivedFrom):
          for (final EvidenceId parent in derivedFrom) {
            queue.add((parent, depth + 1));
          }
        case ObservedFact():
        case UserAssertion():
          roots.add(evidence);
      }
    }

    return ProvenanceChain(nodes: nodes, roots: roots, missing: missing);
  }
}
