import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/evidence/evidence.dart';
import 'package:loop/domain/evidence/provenance.dart';
import 'package:loop/domain/ids.dart';

import 'fixtures.dart';

/// A resolver over a fixed set, standing in for whatever stores evidence later.
EvidenceResolver resolverOf(List<Evidence> all) {
  final Map<String, Evidence> byId = <String, Evidence>{
    for (final Evidence e in all) e.id.value: e,
  };
  return (EvidenceId id) => byId[id.value];
}

void main() {
  group('the chain answers "why is this here?"', () {
    test('an inference resolves back to what was observed', () {
      final ObservedFact f = fact();
      final Inference i = inference();
      final ProvenanceChain chain = Provenance.of(
        i.id,
        resolverOf(<Evidence>[f, i]),
      );

      expect(chain.isGrounded, isTrue);
      expect(chain.roots.single.id, f.id);
      expect(chain.nodes.first.evidence.id, i.id);
      expect(chain.nodes.first.depth, 0);
      expect(chain.depth, 1);
      expect(chain.missing, isEmpty);
    });

    test('it walks more than one level', () {
      final ObservedFact f = fact();
      final Inference first = inference(id: 'ev-i1');
      final Inference second = inference(id: 'ev-i2', from: <String>['ev-i1']);

      final ProvenanceChain chain = Provenance.of(
        second.id,
        resolverOf(<Evidence>[f, first, second]),
      );

      expect(chain.depth, 2);
      expect(chain.roots.single.id, f.id);
      expect(chain.nodes, hasLength(3));
    });

    test('a loop the person typed is grounded by their own assertion', () {
      final UserAssertion a = assertion(
        id: 'ev-typed',
        kind: AssertionKind.states,
        about: null,
      );

      final ProvenanceChain chain = Provenance.of(
        a.id,
        resolverOf(<Evidence>[a]),
      );

      // No exception for manual entry: the rule "everything points at
      // evidence" holds because the person's word is evidence.
      expect(chain.isGrounded, isTrue);
      expect(chain.roots.single, isA<UserAssertion>());
    });

    test('two sources both appear as roots', () {
      final ObservedFact email = fact(id: 'ev-fact');
      final ObservedFact calendar = fact(id: 'ev-cal', excerpt: null);
      final Inference i = inference(from: <String>['ev-fact', 'ev-cal']);

      final ProvenanceChain chain = Provenance.of(
        i.id,
        resolverOf(<Evidence>[email, calendar, i]),
      );

      expect(chain.roots.map((Evidence e) => e.id.value), <String>[
        'ev-fact',
        'ev-cal',
      ]);
    });
  });

  group('the chain is honest when it cannot be completed', () {
    test('a missing link is reported rather than glossed over', () {
      final Inference i = inference();
      final ProvenanceChain chain = Provenance.of(
        i.id,
        resolverOf(<Evidence>[i]),
      );

      expect(chain.missing, <EvidenceId>[const EvidenceId('ev-fact')]);
      expect(
        chain.isGrounded,
        isFalse,
        reason: 'a broken store is not grounded',
      );
    });

    test('a cycle terminates instead of hanging', () {
      // Append-only evidence should make this impossible; "should be
      // impossible" is not something to rely on when the alternative is a
      // stack overflow in front of a user.
      final Inference a = inference(id: 'ev-a', from: <String>['ev-b']);
      final Inference b = inference(id: 'ev-b', from: <String>['ev-a']);

      final ProvenanceChain chain = Provenance.of(
        a.id,
        resolverOf(<Evidence>[a, b]),
      );

      expect(chain.nodes, hasLength(2));
      expect(chain.roots, isEmpty);
      expect(chain.isGrounded, isFalse);
    });
  });
}
