import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The dependency audit for 2C-C's real runtime wiring.
///
/// `data_dependencies_test.dart` already forbids any file under
/// `lib/features` from importing `data/local` or Drift — that check needed
/// no change to cover this phase; `LoopHomeRepository` reaches the real
/// store only through `application/loop_repository.dart`, which is not
/// `data/local`. What neither existing suite checks, and this one exists
/// to, is the domain side of the same rule: presentation and state must
/// keep consuming `HomeSnapshot`, never the domain `Loop` the projection is
/// built from. A widget importing `domain/loop/loop.dart` would be exactly
/// the shortcut 2C-C was told not to take — "prefer changing composition
/// wiring... rather than rebuilding presentation code" only holds if
/// presentation never learns the domain exists.
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

  final List<File> presentationFiles = dartFilesIn(
    'lib/features/home/presentation',
  );
  final List<File> stateFiles = dartFilesIn('lib/features/home/state');

  test('presentation and state exist and are not empty', () {
    expect(presentationFiles, isNotEmpty);
    expect(stateFiles, isNotEmpty);
  });

  test(
      'no widget or controller imports the domain, Drift, or sqlite3 '
      'directly', () {
    const List<String> forbidden = <String>[
      'domain/',
      'package:loop/domain',
      'package:drift',
      'package:sqlite3',
      'data/local/',
      'package:loop/data',
    ];
    final List<String> offenders = <String>[];
    for (final File file in <File>[...presentationFiles, ...stateFiles]) {
      for (final String line in importsIn(file)) {
        for (final String needle in forbidden) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test(
      'no widget imports the application layer either — HomeSnapshot, '
      'reached through HomeController, is the entire contract', () {
    final List<String> offenders = <String>[];
    for (final File file in presentationFiles) {
      for (final String line in importsIn(file)) {
        if (line.contains('application/') ||
            line.contains('package:loop/application')) {
          offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
