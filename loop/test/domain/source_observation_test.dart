import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/evidence/capture_integrity.dart';
import 'package:loop/domain/evidence/data_sensitivity.dart';
import 'package:loop/domain/evidence/source_ref.dart';
import 'package:loop/domain/source/source_observation.dart';

import 'fixtures.dart';
import 'source_fixtures.dart';

void main() {
  group('SourceObservation', () {
    test('carries exactly what an ObservedFact needs, nothing more', () {
      final SourceObservation o = messageObservation();

      expect(o.source.source, EvidenceSource.email);
      expect(o.source.locator, 'email:message/1');
      expect(o.capturedAt, t0);
      expect(o.integrity, CaptureIntegrity.verbatim);
      expect(o.excerpt, "I'll send it Friday");
      expect(o.sensitivity, DataSensitivity.ordinary);
    });

    test('an excerpt is optional — a bare observation is legitimate', () {
      final SourceObservation o = SourceObservation(
        source: const SourceRef(source: EvidenceSource.manual, locator: 'x'),
        capturedAt: t0,
        integrity: CaptureIntegrity.userReported,
      );
      expect(o.excerpt, isNull);
    });

    test(
        'three source kinds, one shape — nothing provider-specific lives '
        'in the type itself', () {
      expect(messageObservation().source.source, EvidenceSource.email);
      expect(calendarObservation().source.source, EvidenceSource.calendar);
      expect(manualObservation().source.source, EvidenceSource.manual);
    });

    test('the account reference stays optional, like SourceRef\'s own', () {
      final SourceObservation withAccount =
          messageObservation(accountRef: 'work@example.com');
      final SourceObservation withoutAccount = messageObservation();

      expect(withAccount.source.accountRef, 'work@example.com');
      expect(withoutAccount.source.accountRef, isNull);
    });
  });
}
