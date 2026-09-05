import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/evidence/capture_integrity.dart';
import 'package:loop/domain/evidence/claim.dart';
import 'package:loop/domain/evidence/confidence.dart';
import 'package:loop/domain/evidence/data_sensitivity.dart';
import 'package:loop/domain/evidence/evidence.dart';
import 'package:loop/domain/ids.dart';

import 'fixtures.dart';

void main() {
  group('an inference cannot be orphaned', () {
    test('deriving from nothing is impossible to construct', () {
      // The rule that makes provenance a property of the type rather than of
      // anyone's diligence: a conclusion with no lineage cannot be built, so it
      // can never reach a screen.
      expect(
        () => Inference(
          id: const EvidenceId('ev-orphan'),
          capturedAt: t0,
          derivedFrom: const <EvidenceId>[],
          claim: const Claim(kind: ClaimKind.awaitingResponse),
          confidence: confidence(0.9),
          producedBy: const ProducerRef.rule('x', 'v1'),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('it names every piece of evidence it stands on', () {
      final Inference i = inference(from: <String>['ev-fact', 'ev-cal']);
      expect(i.derivedFrom, hasLength(2));
    });
  });

  group('a user assertion judges something, or asserts on its own ground', () {
    test('confirming without saying what is confirmed is impossible', () {
      expect(
        () => assertion(kind: AssertionKind.confirms, about: null),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejecting without saying what is rejected is impossible', () {
      expect(
        () => assertion(kind: AssertionKind.rejects, about: null),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('stating a commitment of your own needs no subject', () {
      final UserAssertion a = assertion(
        kind: AssertionKind.states,
        about: null,
      );
      expect(a.about, isNull);
    });
  });

  group('confirmation never erases the inference it confirms', () {
    test('the original object is untouched and still readable', () {
      final Inference original = inference(value: 0.72);
      final UserAssertion confirmation = assertion(about: original.id.value);

      // The confirmation points at the inference; it does not replace it. If it
      // did, the record that the producer was right — or wrong — would be gone,
      // and that record is the only training signal this system ever gets.
      expect(confirmation.about, original.id);
      expect(original.confidence.value, 0.72);
      expect(original.producedBy, const ProducerRef.rule('promise-verb', 'v3'));
    });

    test('raising confidence produces a new inference, not a mutation', () {
      final Inference original = inference(value: 0.72);
      final Inference raised = original.withConfidence(
        confidence(0.95, basis: ConfidenceBasis.userAsserted),
      );

      expect(original.confidence.value, 0.72, reason: 'original unchanged');
      expect(raised.confidence.value, 0.95);
      expect(raised.id, original.id);
      expect(raised.derivedFrom, original.derivedFrom);
      expect(identical(original, raised), isFalse);
    });

    test('a rejection is recorded beside the inference, not over it', () {
      final Inference original = inference(value: 0.72);
      final UserAssertion rejection = assertion(
        id: 'ev-rejection',
        kind: AssertionKind.rejects,
        about: original.id.value,
      );

      expect(rejection.kind, AssertionKind.rejects);
      expect(original.confidence.value, 0.72);
    });
  });

  group('facts and inferences carry different things', () {
    test('a fact has integrity and no semantic confidence', () {
      final ObservedFact f = fact(integrity: CaptureIntegrity.transcribed);
      expect(f.integrity, CaptureIntegrity.transcribed);
      // Structurally: there is no `confidence` on a fact, and the language
      // enforces it. What is uncertain about a quotation is its meaning, and
      // meaning lives on the inference.
      expect(f, isA<ObservedFact>());
      expect(f, isNot(isA<Inference>()));
    });

    test('an inference has semantic confidence and no integrity', () {
      final Inference i = inference();
      expect(i.confidence.value, 0.72);
      expect(i, isNot(isA<ObservedFact>()));
    });

    test('every piece of evidence is classified when captured', () {
      expect(fact().sensitivity, DataSensitivity.ordinary);
      expect(
        ObservedFact(
          id: const EvidenceId('ev-med'),
          capturedAt: t0,
          source: fact().source,
          integrity: CaptureIntegrity.verbatim,
          sensitivity: DataSensitivity.health,
        ).sensitivity.isElevated,
        isTrue,
      );
    });
  });
}
