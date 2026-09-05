import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The dependency audit for 2C-A's new `lib/data/local` layer.
///
/// `domain_dependencies_test.dart` already forbids anything under
/// `lib/domain` from importing `data/` — that check needed no change to
/// cover this phase, since it already treats `data/` as a layer above the
/// domain. What that file does not check, and this one exists to, is the
/// other direction the brief asks for by name: a Drift row is a persistence
/// representation, not a domain entity or a public application model, and no
/// widget may see one.
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

  final List<File> dataFiles = dartFilesIn('lib/data');
  final List<File> featureFiles = dartFilesIn('lib/features');
  final List<File> coreFiles = dartFilesIn('lib/core');

  test('the data layer exists and is not empty', () {
    expect(dataFiles, isNotEmpty);
  });

  test('no feature imports Drift, sqlite3, or the data layer directly', () {
    // 2C-A intentionally builds no repository and wires nothing to the Home —
    // this test is what keeps that true after 2C-B exists too. A feature is
    // allowed to depend on a repository *interface* the application layer
    // defines; it is never allowed to see `package:drift`, `package:sqlite3`,
    // or a generated row type, which is what importing this package directly
    // would hand it.
    //
    // The needle is `data/local`, not a bare `data/`: Phase 1's own
    // `features/home/data/home_repository.dart` is a legitimate, unrelated
    // directory that happens to share the word, and a bare substring match
    // flagged it the first time this test ran — a false positive is exactly
    // the kind of failure that trains someone to stop trusting this suite.
    const List<String> forbidden = <String>[
      'package:drift',
      'package:sqlite3',
      'data/local/',
      'package:loop/data',
    ];
    final List<String> offenders = <String>[];
    for (final File file in featureFiles) {
      for (final String line in importsIn(file)) {
        for (final String needle in forbidden) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('no design-system or shared core widget imports the data layer', () {
    const List<String> forbidden = <String>[
      'package:drift',
      'package:sqlite3',
      'data/local/',
      'package:loop/data',
    ];
    final List<String> offenders = <String>[];
    for (final File file in coreFiles) {
      for (final String line in importsIn(file)) {
        for (final String needle in forbidden) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('the data layer imports nothing from features or core', () {
    // The layering the architecture names is DOMAIN ↑ APPLICATION ↑
    // DATA/ADAPTERS, with presentation consuming projections — never the
    // reverse. A data-layer file reaching up into `features/` or `core/`
    // would be that arrow pointing backwards.
    const List<String> above = <String>[
      "'../../features/",
      "'../../../features/",
      "'../../core/",
      "'../../../core/",
      'package:loop/features',
      'package:loop/core',
    ];
    final List<String> offenders = <String>[];
    for (final File file in dataFiles) {
      for (final String line in importsIn(file)) {
        for (final String needle in above) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test(
      'the data layer never imports the domain\'s intelligence policies '
      'directly into a table or migration file', () {
    // Not a layering violation by itself — the mapping helpers legitimately
    // import domain types to convert them — but a *table* or *database*
    // definition file has no reason to know about domain policies, and one
    // that did would be schema shaped around behaviour rather than durable
    // state.
    final List<File> schemaFiles = <File>[
      ...dartFilesIn('lib/data/local/tables'),
      ...dartFilesIn('lib/data/local/database'),
    ].where((File f) => !f.path.endsWith('.g.dart')).toList();
    final List<String> offenders = <String>[];
    for (final File file in schemaFiles) {
      for (final String line in importsIn(file)) {
        if (line.contains('domain/intelligence') ||
            line.contains('domain/policies')) {
          offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
