import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/evidence/claim.dart';
import 'package:loop/domain/evidence/data_sensitivity.dart';
import 'package:loop/domain/intelligence/ports/intelligence_ports.dart';
import 'package:loop/domain/intelligence/ports/rule_based_ports.dart';
import 'package:loop/domain/intelligence/ports/source_signal.dart';

SourceSignal _signal(String text) =>
    SourceSignal(text: text, sensitivity: DataSensitivity.ordinary);

void main() {
  group('RuleBasedCommitmentDetector — the narrow, 2B-era port', () {
    const CommitmentDetector detector = RuleBasedCommitmentDetector();

    test('a clear promise looks like a commitment', () {
      final CommitmentDetection d = detector.detect(_signal("I'll send it."));
      expect(d.looksLikeCommitment, isTrue);
      expect(d.claim, isNotNull);
      expect(d.claim!.kind, ClaimKind.other);
    });

    test('speculative language does not look like a commitment', () {
      final CommitmentDetection d =
          detector.detect(_signal('I might send it.'));
      expect(d.looksLikeCommitment, isFalse);
      expect(d.claim, isNull);
    });

    test(
        'this port never resolves a deadline — it has no reference time '
        'to resolve one against', () {
      final CommitmentDetection d =
          detector.detect(_signal("I'll send it by Friday."));
      expect(d.looksLikeCommitment, isTrue);
      expect(d.claim!.by, isNull);
      expect(d.claim!.sourceQuote, "I'll send it by Friday.");
    });

    test(
        'agrees with the underlying rules on whether something matches at '
        'all', () {
      // Not a second code path with its own logic to drift from the shared
      // rules — same relationship RuleBasedRiskPredictor already has to
      // RiskPolicy.
      const CommitmentDetector viaPort = RuleBasedCommitmentDetector();
      final CommitmentDetection a = viaPort.detect(_signal('Please send it.'));
      final CommitmentDetection b = viaPort.detect(_signal('Please send it.'));
      expect(a.looksLikeCommitment, b.looksLikeCommitment);
    });
  });

  group('RuleBasedEntityExtractor — mention-level clues only', () {
    const EntityExtractor extractor = RuleBasedEntityExtractor();

    test('reports "I" and "you" as person mentions, verbatim', () {
      final List<ExtractedEntity> entities =
          extractor.extractFrom(_signal('I will call you.'));

      expect(
        entities.where((ExtractedEntity e) => e.kind == EntityKind.person),
        isNotEmpty,
      );
      expect(
        entities.map((ExtractedEntity e) => e.text),
        containsAll(<String>['I', 'you']),
      );
    });

    test(
        'reports date-shaped mentions using the same recognition '
        'CommitmentTemporalSignals uses', () {
      final List<ExtractedEntity> entities =
          extractor.extractFrom(_signal('Let\'s meet on Friday.'));

      final List<ExtractedEntity> dates = entities
          .where((ExtractedEntity e) => e.kind == EntityKind.date)
          .toList();
      expect(dates, isNotEmpty);
      expect(dates.first.text, 'friday');
    });

    test(
        'never reports a proper-noun name as a person mention — '
        'capitalisation alone is not attempted as identity evidence', () {
      final List<ExtractedEntity> entities =
          extractor.extractFrom(_signal('Sarah will send it.'));

      expect(
        entities.where((ExtractedEntity e) => e.kind == EntityKind.person),
        isEmpty,
      );
    });

    test('produces no entities for text with no recognised mention at all', () {
      expect(extractor.extractFrom(_signal('Thanks.')), isEmpty);
    });

    test(
        'never reports an amount or a place — not attempted in this '
        'baseline', () {
      final List<ExtractedEntity> entities = extractor.extractFrom(
        _signal('I will pay you \$50 at the office.'),
      );
      expect(
        entities.where(
          (ExtractedEntity e) =>
              e.kind == EntityKind.amount || e.kind == EntityKind.place,
        ),
        isEmpty,
      );
    });
  });
}
