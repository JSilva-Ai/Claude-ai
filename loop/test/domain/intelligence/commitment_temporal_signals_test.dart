import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/intelligence/commitment_candidate.dart';
import 'package:loop/domain/intelligence/commitment_temporal_signals.dart';

import 'fixtures.dart';

void main() {
  const CommitmentTemporalSignals temporal = CommitmentTemporalSignals();

  group('resolveDeadline', () {
    test('an explicit ISO date resolves exactly, with high confidence', () {
      final TemporalMatch? m = temporal.resolveDeadline(
        'Let\'s target 2026-09-11 for this.',
        t0,
      );
      expect(m, isNotNull);
      expect(m!.resolved, DateTime.utc(2026, 9, 11));
      expect(m.reason, CommitmentSignalReason.explicitDeadline);
    });

    test('"today" resolves to the reference date', () {
      final TemporalMatch? m = temporal.resolveDeadline('Due today.', t0);
      expect(m!.resolved, DateTime.utc(t0.year, t0.month, t0.day));
      expect(m.reason, CommitmentSignalReason.explicitDeadline);
    });

    test('"tomorrow" resolves to the reference date plus one day', () {
      final TemporalMatch? m = temporal.resolveDeadline(
        'I will send it tomorrow.',
        t0,
      );
      expect(
        m!.resolved,
        DateTime.utc(t0.year, t0.month, t0.day).add(const Duration(days: 1)),
      );
    });

    test(
        '"by Friday" resolves to the next Friday on or after the reference '
        'date, with explicitDeadline', () {
      // t0 is 2026-09-01, a Tuesday.
      final TemporalMatch? m = temporal.resolveDeadline(
        'Please send it by Friday.',
        t0,
      );
      expect(m!.resolved!.weekday, DateTime.friday);
      expect(m.resolved, DateTime.utc(2026, 9, 4));
      expect(m.reason, CommitmentSignalReason.explicitDeadline);
    });

    test(
        'a bare weekday with no "by" still resolves, but only as a weak '
        'signal', () {
      final TemporalMatch? m = temporal.resolveDeadline(
        'Friday works for me.',
        t0,
      );
      expect(m!.resolved, DateTime.utc(2026, 9, 4));
      expect(m.reason, CommitmentSignalReason.weakTemporalSignal);
    });

    test(
        'a reference date that already is the named weekday resolves to '
        'that same day, not a week later', () {
      final DateTime friday = DateTime.utc(2026, 9, 4, 8);
      final TemporalMatch? m = temporal.resolveDeadline(
        'by Friday',
        friday,
      );
      expect(m!.resolved, DateTime.utc(2026, 9, 4));
    });

    test(
        '"soon" is recognised but never resolved to a date — ambiguity is '
        'not fabricated into certainty', () {
      final TemporalMatch? m = temporal.resolveDeadline(
        'I will get to it soon.',
        t0,
      );
      expect(m, isNotNull);
      expect(m!.resolved, isNull);
      expect(m.reason, CommitmentSignalReason.weakTemporalSignal);
    });

    test('"later" behaves the same as "soon"', () {
      final TemporalMatch? m = temporal.resolveDeadline(
        'We can deal with that later.',
        t0,
      );
      expect(m!.resolved, isNull);
      expect(m.reason, CommitmentSignalReason.weakTemporalSignal);
    });

    test('no temporal cue at all returns null', () {
      final TemporalMatch? m = temporal.resolveDeadline(
        'Thanks for the update.',
        t0,
      );
      expect(m, isNull);
    });

    test(
        'resolution never reads a clock — the same text and reference time '
        'always resolve identically', () {
      final TemporalMatch a = temporal.resolveDeadline('by Friday', t0)!;
      final TemporalMatch b = temporal.resolveDeadline('by Friday', t0)!;
      expect(a.resolved, b.resolved);
    });
  });

  group('findMentions', () {
    test(
        'reports every recognised date cue verbatim, without resolving any '
        'of them', () {
      final List<String> mentions = temporal.findMentions(
        'Send it by Friday, or 2026-09-11 at the latest — tomorrow works '
        'too.',
      );
      expect(mentions, contains('friday'));
      expect(mentions, contains('2026-09-11'));
      expect(mentions, contains('tomorrow'));
    });

    test('an empty result for text with no date-shaped cue', () {
      expect(temporal.findMentions('Thanks for the update.'), isEmpty);
    });
  });
}
