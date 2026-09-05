import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The dependency audit for 3B's `lib/domain/source` and
/// `lib/application/ingestion`.
///
/// `domain_dependencies_test.dart` and `application_dependencies_test.dart`
/// already cover both trees recursively — this file is deliberately
/// narrower and redundant with them, the same relationship
/// `intelligence_dependencies_test.dart` already has to the broader domain
/// guard: a failure here points straight at the ingestion boundary instead
/// of requiring someone to work out which subtree a broader failure came
/// from. It also checks the one thing neither broader test names by
/// intent: that nothing here can reach a network client or a provider SDK,
/// which is what "provider-neutral" and "zero model calls" actually mean at
/// the file level for this specific boundary.
void main() {
  List<File> dartFilesIn(String path) => Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))
      .toList();

  List<String> importsIn(File file) => file
      .readAsLinesSync()
      .where((String line) => line.trimLeft().startsWith('import '))
      .toList();

  final List<File> sourceFiles = dartFilesIn('lib/domain/source');
  final List<File> ingestionFiles = dartFilesIn('lib/application/ingestion');

  test('the source and ingestion layers exist and are not empty', () {
    expect(sourceFiles, isNotEmpty);
    expect(ingestionFiles, isNotEmpty);
  });

  test(
      'no HTTP client, no provider SDK, no AI vendor, no Flutter — the '
      'ingestion boundary reaches no network and no provider by itself', () {
    const List<String> forbidden = <String>[
      'package:http',
      'package:dio',
      'package:googleapis',
      'package:google_sign_in',
      'dart:io',
      'dart:isolate',
      'package:flutter',
      'dart:ui',
      'anthropic',
      'openai',
      'google_generative_ai',
      'genai',
      'mistral',
      'cohere',
      'ollama',
      'langchain',
    ];
    final List<String> offenders = <String>[];
    for (final File file in <File>[...sourceFiles, ...ingestionFiles]) {
      for (final String line in importsIn(file)) {
        for (final String needle in forbidden) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('lib/domain/source imports nothing outside the domain layer itself', () {
    final List<String> external = <String>[];
    for (final File file in sourceFiles) {
      for (final String line in importsIn(file)) {
        if (line.contains('package:') || line.contains('dart:')) {
          external.add('${file.path}: ${line.trim()}');
        }
      }
    }
    expect(external, isEmpty);
  });

  test(
      'lib/application/ingestion does not import Drift, sqlite3, or the '
      'data layer directly', () {
    const List<String> forbidden = <String>[
      'package:drift',
      'package:sqlite3',
      'data/local/',
      'package:loop/data',
    ];
    final List<String> offenders = <String>[];
    for (final File file in ingestionFiles) {
      for (final String line in importsIn(file)) {
        for (final String needle in forbidden) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test(
      'lib/application/ingestion does not detect commitments, extract '
      'entities, or touch Home — single responsibility, mechanically '
      'enforced', () {
    const List<String> forbidden = <String>[
      'commitment_detector',
      'entity_extractor',
      'context_intelligence',
      'features/home',
      'home_projector',
      'home_repository',
    ];
    final List<String> offenders = <String>[];
    for (final File file in ingestionFiles) {
      for (final String line in importsIn(file)) {
        for (final String needle in forbidden) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
