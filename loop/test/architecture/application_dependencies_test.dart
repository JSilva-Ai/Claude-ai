import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The dependency audit for 2C-B's new `lib/application`.
///
/// `application/home/home_projector.dart` deliberately imports
/// `features/home/models/*` — [HomeSnapshot] itself lives there, and the
/// architecture the Director's own brief describes has application produce
/// one. That single, named exception is what this file exists to keep
/// bounded: everything else about application stays isolated the same way
/// domain already is.
void main() {
  final List<File> applicationFiles = Directory('lib/application')
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))
      .toList();

  List<String> importsIn(File file) => file
      .readAsLinesSync()
      .where((String line) => line.trimLeft().startsWith('import '))
      .toList();

  test('the application layer exists and is not empty', () {
    expect(applicationFiles, isNotEmpty);
  });

  test('no Flutter, no dart:ui, no Drift, no sqlite3', () {
    const List<String> forbidden = <String>[
      'package:flutter',
      'dart:ui',
      'package:drift',
      'package:sqlite3',
    ];
    final List<String> offenders = <String>[];
    for (final File file in applicationFiles) {
      for (final String line in importsIn(file)) {
        for (final String needle in forbidden) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test(
      'no data-layer import — not the generated database, not the '
      'concrete repository', () {
    const List<String> forbidden = <String>[
      'data/local/',
      'package:loop/data',
    ];
    final List<String> offenders = <String>[];
    for (final File file in applicationFiles) {
      for (final String line in importsIn(file)) {
        for (final String needle in forbidden) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('no localization and no design-system widget import', () {
    const List<String> forbidden = <String>[
      'core/localization/',
      'core/widgets/',
      'core/animations/',
    ];
    final List<String> offenders = <String>[];
    for (final File file in applicationFiles) {
      for (final String line in importsIn(file)) {
        for (final String needle in forbidden) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test(
      'the one sanctioned exception — features/home/models — is not used '
      'as a door to the rest of features', () {
    const List<String> forbiddenFeatureAreas = <String>[
      'features/home/data/',
      'features/home/presentation/',
      'features/home/state/',
    ];
    final List<String> offenders = <String>[];
    for (final File file in applicationFiles) {
      for (final String line in importsIn(file)) {
        for (final String needle in forbiddenFeatureAreas) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('no AI vendor SDK and nothing that could reach a network', () {
    // The same discipline test/architecture/intelligence_dependencies_test
    // holds the domain to: a Home projection built on top of the
    // zero-model-baseline policies has to stay zero-model itself.
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
      'dart:io',
      'dart:isolate',
    ];
    final List<String> offenders = <String>[];
    for (final File file in applicationFiles) {
      for (final String line in importsIn(file)) {
        for (final String needle in forbidden) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
