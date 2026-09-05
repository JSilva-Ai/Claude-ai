import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The dependency audit for 3C's commitment-candidate files.
///
/// `domain_dependencies_test.dart` and `intelligence_dependencies_test.dart`
/// already cover `lib/domain/intelligence` recursively — no Flutter, no
/// network, no vendor SDK, no prompt text. What neither checks by name, and
/// this file exists to, is the two guarantees the brief asks for
/// specifically: this layer never imports the durable `Commitment` type it
/// must not construct, and it never imports `Loop`, which it must never
/// mutate.
void main() {
  const List<String> commitmentCandidateFiles = <String>[
    'lib/domain/intelligence/commitment_candidate.dart',
    'lib/domain/intelligence/commitment_signal_rules.dart',
    'lib/domain/intelligence/commitment_temporal_signals.dart',
    'lib/domain/intelligence/commitment_candidate_policy.dart',
    'lib/domain/intelligence/ports/rule_based_ports.dart',
  ];

  List<String> importsIn(File file) => file
      .readAsLinesSync()
      .where((String line) => line.trimLeft().startsWith('import '))
      .toList();

  test('every 3C commitment-candidate file exists', () {
    for (final String path in commitmentCandidateFiles) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });

  test('none of them imports the durable Commitment type', () {
    final List<String> offenders = <String>[];
    for (final String path in commitmentCandidateFiles) {
      for (final String line in importsIn(File(path))) {
        if (line.contains('commitment/commitment.dart') ||
            line.contains('commitment/commitment_status.dart')) {
          offenders.add('$path: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('none of them imports Loop or the Loop state machine', () {
    final List<String> offenders = <String>[];
    for (final String path in commitmentCandidateFiles) {
      for (final String line in importsIn(File(path))) {
        if (line.contains('loop/loop.dart') ||
            line.contains('loop/loop_state_machine.dart') ||
            line.contains('loop/loop_transition.dart')) {
          offenders.add('$path: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test(
      'none of them imports UserAssertion construction — authority stays '
      'outside detection', () {
    // UserAssertion lives in evidence.dart alongside ObservedFact/Inference,
    // so the real guarantee is structural (CommitmentCandidate's fields
    // never reference one) rather than an importable name to forbid
    // outright — evidence.dart is legitimately imported for Claim's own
    // sake. This test instead proves the stronger claim directly: no file
    // here constructs one.
    final List<String> offenders = <String>[];
    for (final String path in commitmentCandidateFiles) {
      final String source = File(path).readAsStringSync();
      if (source.contains('UserAssertion(')) offenders.add(path);
    }
    expect(offenders, isEmpty);
  });
}
