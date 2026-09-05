import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/evidence/source_ref.dart';
import 'package:loop/domain/intelligence/ai/model_inference_request.dart';

import '../fixtures.dart';

void main() {
  group('ModelInferenceRequest', () {
    test('cannot be built with zero evidence', () {
      expect(
        () => ModelInferenceRequest(
          kind: ModelInferenceKind.commitmentDetection,
          evidence: const <ModelEvidenceView>[],
          locale: 'en',
          referenceTime: t0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('requestKey is deterministic for identical content', () {
      ModelInferenceRequest build() => ModelInferenceRequest(
            kind: ModelInferenceKind.commitmentDetection,
            evidence: <ModelEvidenceView>[
              const ModelEvidenceView(
                id: basisId,
                text: "I'll send it.",
                sourceKind: EvidenceSource.manual,
              ),
            ],
            locale: 'en',
            referenceTime: t0,
          );

      expect(build().requestKey, build().requestKey);
    });

    test(
        'requestKey changes when the evidence set, locale, or reference '
        'time changes — never a random id standing in for identity', () {
      final ModelInferenceRequest base = ModelInferenceRequest(
        kind: ModelInferenceKind.commitmentDetection,
        evidence: <ModelEvidenceView>[
          const ModelEvidenceView(
            id: basisId,
            text: "I'll send it.",
            sourceKind: EvidenceSource.manual,
          ),
        ],
        locale: 'en',
        referenceTime: t0,
      );
      final ModelInferenceRequest differentLocale = ModelInferenceRequest(
        kind: ModelInferenceKind.commitmentDetection,
        evidence: base.evidence,
        locale: 'pt',
        referenceTime: t0,
      );
      final ModelInferenceRequest differentTime = ModelInferenceRequest(
        kind: ModelInferenceKind.commitmentDetection,
        evidence: base.evidence,
        locale: 'en',
        referenceTime: t0.add(const Duration(days: 1)),
      );

      expect(base.requestKey, isNot(differentLocale.requestKey));
      expect(base.requestKey, isNot(differentTime.requestKey));
    });
  });
}
