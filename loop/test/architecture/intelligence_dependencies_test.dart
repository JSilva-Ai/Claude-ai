import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The dependency audit scoped to `lib/domain/intelligence`, named
/// separately from `domain_dependencies_test.dart` because 2B's own brief
/// asks for it by name: proof, specific to the intelligence layer, that it
/// imports none of Flutter, an HTTP client, a vendor AI SDK, localization, UI,
/// or the data layer.
///
/// `domain_dependencies_test.dart` already covers this file tree — it scans
/// all of `lib/domain` recursively — so this file is deliberately narrower and
/// redundant with it rather than a replacement for it: a failure here points
/// straight at the intelligence layer instead of requiring someone to work out
/// which subtree a broader failure came from.
void main() {
  final List<File> files = Directory('lib/domain/intelligence')
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))
      .toList();

  List<String> importsIn(File file) => file
      .readAsLinesSync()
      .where((String line) => line.trimLeft().startsWith('import '))
      .toList();

  test('the intelligence layer exists and is not empty', () {
    expect(files, isNotEmpty);
  });

  test('no Flutter, no dart:ui', () {
    final List<String> offenders = <String>[];
    for (final File file in files) {
      for (final String line in importsIn(file)) {
        if (line.contains('package:flutter') || line.contains('dart:ui')) {
          offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('no HTTP client, no vendor AI SDK, no networking', () {
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
    for (final File file in files) {
      for (final String line in importsIn(file)) {
        for (final String needle in forbidden) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('no localization and no UI', () {
    final List<String> offenders = <String>[];
    for (final File file in files) {
      final String source = file.readAsStringSync();
      if (source.contains('AppLocalizations') ||
          source.contains('package:intl') ||
          source.contains('Localizations.') ||
          source.contains('Widget ')) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty);
  });

  test('no data layer', () {
    const List<String> above = <String>[
      'features/',
      'core/',
      'data/',
      'package:loop/features',
      'package:loop/core',
      'package:loop/data',
    ];
    final List<String> offenders = <String>[];
    for (final File file in files) {
      for (final String line in importsIn(file)) {
        for (final String needle in above) {
          if (line.contains(needle)) offenders.add('${file.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('no prompt text hardcoded anywhere in the layer', () {
    // A crude but honest check: none of these words, which a prompt to a
    // model would be built from, appear anywhere in the intelligence layer's
    // source.
    const List<String> promptMarkers = <String>[
      'You are a',
      'system prompt',
      'You are an AI',
      '"""You',
    ];
    final List<String> offenders = <String>[];
    for (final File file in files) {
      final String source = file.readAsStringSync();
      for (final String marker in promptMarkers) {
        if (source.contains(marker)) offenders.add('${file.path}: $marker');
      }
    }
    expect(offenders, isEmpty);
  });

  test('imports nothing outside the domain layer itself', () {
    final List<String> external = <String>[];
    for (final File file in files) {
      for (final String line in importsIn(file)) {
        if (line.contains('package:') || line.contains('dart:')) {
          external.add('${file.path}: ${line.trim()}');
        }
      }
    }
    expect(external, isEmpty);
  });
}
