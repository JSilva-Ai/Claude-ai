import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/intelligence/commitment_candidate.dart';
import 'package:loop/domain/intelligence/commitment_signal_rules.dart';

void main() {
  const CommitmentSignalRules rules = CommitmentSignalRules();

  group('positive corpus — explicit, high-signal phrasing', () {
    test('a direct request: "please send X by Friday"', () {
      final CommitmentSignalMatch? m =
          rules.match('Please send the invoice by Friday.');
      expect(m, isNotNull);
      expect(m!.reasons, contains(CommitmentSignalReason.explicitRequestVerb));
      expect(m.reasons, contains(CommitmentSignalReason.actionVerbPresent));
    });

    test('an interrogative request: "can you send X"', () {
      final CommitmentSignalMatch? m = rules.match('Can you send it over?');
      expect(m, isNotNull);
      expect(m!.reasons, contains(CommitmentSignalReason.explicitRequestVerb));
      expect(m.reasons, contains(CommitmentSignalReason.directRecipient));
    });

    test('a first-person promise: "I\'ll send X tomorrow"', () {
      final CommitmentSignalMatch? m = rules.match("I'll send it tomorrow.");
      expect(m, isNotNull);
      expect(m!.reasons, contains(CommitmentSignalReason.firstPersonPromise));
    });

    test('a first-person promise: "I will call you"', () {
      final CommitmentSignalMatch? m = rules.match('I will call you.');
      expect(m, isNotNull);
      expect(m!.reasons, contains(CommitmentSignalReason.firstPersonPromise));
    });

    test('an explicit promise phrase distinct from the first-person pattern',
        () {
      final CommitmentSignalMatch? m =
          rules.match('I promise to have this done.');
      expect(m, isNotNull);
      expect(
        m!.reasons,
        contains(CommitmentSignalReason.explicitPromisePhrase),
      );
    });

    test('waiting language: "waiting for X"', () {
      final CommitmentSignalMatch? m =
          rules.match('Still waiting for your reply.');
      expect(m, isNotNull);
      expect(m!.reasons, contains(CommitmentSignalReason.waitingLanguage));
    });

    test('an explicit action plus a named recipient', () {
      final CommitmentSignalMatch? m =
          rules.match('Would you review the draft?');
      expect(m, isNotNull);
      expect(m!.reasons, contains(CommitmentSignalReason.explicitRequestVerb));
      expect(m.reasons, contains(CommitmentSignalReason.directRecipient));
      expect(m.reasons, contains(CommitmentSignalReason.actionVerbPresent));
    });
  });

  group('negative corpus — should not casually become a candidate', () {
    test('speculation: "I might send it"', () {
      expect(rules.match('I might send it.'), isNull);
    });

    test('aspiration: "Maybe we should..."', () {
      expect(rules.match('Maybe we should meet next week.'), isNull);
    });

    test('hope, not a promise: "I hope to..."', () {
      expect(rules.match('I hope to finish this soon.'), isNull);
    });

    test('a request aimed at no one in particular: "Can someone send..."', () {
      expect(rules.match('Can someone send the report?'), isNull);
    });

    test('a purely informational marker: "FYI ..."', () {
      expect(
        rules.match('FYI, I sent the report yesterday.'),
        isNull,
      );
    });

    test('quoted historical content, by its plain-text prefix', () {
      expect(
        rules.match('> I will send it Friday'),
        isNull,
      );
    });

    test(
        'an informational statement with an action verb but no trigger '
        'phrase', () {
      expect(rules.match('The report was sent yesterday.'), isNull);
    });

    test('a bare action verb alone is never sufficient', () {
      expect(rules.match('Sending the invoice now.'), isNull);
    });

    test('empty or blank text', () {
      expect(rules.match(''), isNull);
      expect(rules.match('   '), isNull);
    });
  });

  group('boundary and ambiguous cases', () {
    test(
        'both a promise and a request in the same text is flagged '
        'ambiguous, not silently resolved either way', () {
      final CommitmentSignalMatch? m = rules.match(
        "I'll send it, but can you confirm the address first?",
      );
      expect(m, isNotNull);
      expect(m!.reasons, contains(CommitmentSignalReason.firstPersonPromise));
      expect(m.reasons, contains(CommitmentSignalReason.explicitRequestVerb));
      expect(m.reasons, contains(CommitmentSignalReason.ambiguousActor));
    });

    test(
        'the same input, matched repeatedly, always produces the same '
        'reasons — no hidden state', () {
      const String text = 'Please send it by Friday.';
      final CommitmentSignalMatch a = rules.match(text)!;
      final CommitmentSignalMatch b = rules.match(text)!;
      expect(a.reasons, b.reasons);
      expect(a.sourceQuote, b.sourceQuote);
    });

    test('the source quote is verbatim and trimmed, never generated', () {
      final CommitmentSignalMatch? m = rules.match('   I will call you.   ');
      expect(m!.sourceQuote, 'I will call you.');
    });
  });
}
