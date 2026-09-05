import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The dependency audit for 3D's AI intelligence boundary.
///
/// `domain_dependencies_test.dart`, `intelligence_dependencies_test.dart`
/// and `application_dependencies_test.dart` already cover both trees
/// recursively for Flutter/Drift/data-layer imports. What this file exists
/// to prove specifically is what 3D's own brief names by number: no
/// provider SDK or network library anywhere in the AI boundary, no path
/// from it to the durable `Commitment` or to `Loop`, and no hardcoded
/// secret — the same "grep the source, not the reader's trust" discipline
/// `zero_model_baseline_test.dart` already applies to the deterministic
/// ports.
void main() {
  List<File> dartFilesIn(String path) {
    final Directory dir = Directory(path);
    if (!dir.existsSync()) return const <File>[];
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .toList();
  }

  List<String> importsIn(File file) => file
      .readAsLinesSync()
      .where((String line) => line.trimLeft().startsWith('import '))
      .toList();

  final List<File> aiDomainFiles = dartFilesIn('lib/domain/intelligence/ai');
  final List<File> aiApplicationFiles = <File>[
    ...dartFilesIn('lib/application/intelligence'),
  ].where((File f) => !f.path.contains('/evaluation/')).toList()
    ..addAll(dartFilesIn('lib/application/intelligence/evaluation'));

  test('the AI domain and application layers exist and are not empty', () {
    expect(aiDomainFiles, isNotEmpty);
    expect(aiApplicationFiles, isNotEmpty);
  });

  test(
      'no provider SDK, no HTTP client, no network library anywhere in '
      'the AI boundary', () {
    const List<String> forbidden = <String>[
      'anthropic',
      'openai',
      'google_generative_ai',
      'genai',
      'mistral',
      'cohere',
      'ollama',
      'langchain',
      'package:http',
      'package:dio',
      'package:googleapis',
      'dart:io',
      'dart:isolate',
      'package:flutter',
      'dart:ui',
    ];
    final List<String> offenders = <String>[];
    for (final File file in <File>[...aiDomainFiles, ...aiApplicationFiles]) {
      for (final String line in importsIn(file)) {
        for (final String needle in forbidden) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test(
      'lib/domain/intelligence/ai imports nothing outside the domain '
      'layer itself', () {
    final List<String> external = <String>[];
    for (final File file in aiDomainFiles) {
      for (final String line in importsIn(file)) {
        if (line.contains('package:') || line.contains('dart:')) {
          external.add('${file.path}: ${line.trim()}');
        }
      }
    }
    expect(external, isEmpty);
  });

  test(
      'lib/application/intelligence does not import Drift, sqlite3, or '
      'the data layer directly', () {
    const List<String> forbidden = <String>[
      'package:drift',
      'package:sqlite3',
      'data/local/',
      'package:loop/data',
    ];
    final List<String> offenders = <String>[];
    for (final File file in aiApplicationFiles) {
      for (final String line in importsIn(file)) {
        for (final String needle in forbidden) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test(
      'no file in the AI boundary imports the durable Commitment type or '
      'Loop — model output cannot reach either', () {
    final List<String> offenders = <String>[];
    for (final File file in <File>[...aiDomainFiles, ...aiApplicationFiles]) {
      for (final String line in importsIn(file)) {
        if (line.contains('commitment/commitment.dart') ||
            line.contains('commitment/commitment_status.dart') ||
            line.contains('loop/loop.dart') ||
            line.contains('loop/loop_state_machine.dart') ||
            line.contains('loop/loop_transition.dart')) {
          offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('no file in the AI boundary constructs a UserAssertion', () {
    final List<String> offenders = <String>[];
    for (final File file in <File>[...aiDomainFiles, ...aiApplicationFiles]) {
      if (file.readAsStringSync().contains('UserAssertion(')) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty);
  });

  test(
      'no hardcoded API key, token, or secret anywhere in the AI '
      'boundary', () {
    const List<String> markers = <String>[
      'sk-',
      'Bearer ',
      'apiKey:',
      'api_key',
      'ApiKey(',
      '.env',
    ];
    final List<String> offenders = <String>[];
    for (final File file in <File>[...aiDomainFiles, ...aiApplicationFiles]) {
      final String source = file.readAsStringSync();
      for (final String marker in markers) {
        if (source.contains(marker)) offenders.add('${file.path}: $marker');
      }
    }
    expect(offenders, isEmpty);
  });

  test(
      'no ModelGateway implementation exists in lib/ yet — the real '
      'provider adapter is a separately authorised, later gate', () {
    // Mirrors zero_model_baseline_test.dart's own "honestly unimplemented"
    // check: grepping lib/ directly is the honest proof that no real
    // provider adapter was added under this authorisation, rather than
    // trusting that nothing changed.
    final List<String> implementations = <String>[];
    for (final File file
        in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      if (file.readAsStringSync().contains('implements ModelGateway')) {
        implementations.add(file.path);
      }
    }
    expect(implementations, isEmpty);
  });
}
