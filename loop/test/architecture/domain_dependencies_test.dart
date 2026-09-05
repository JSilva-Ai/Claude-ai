import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The dependency audit for the domain layer.
///
/// Twenty lines that replace a review rule nobody remembers. The architecture
/// says the domain is pure Dart with no framework, no vendor and no knowledge
/// of the layers above it; that is a claim, and a claim in a document decays.
/// Here it is a claim the suite refuses to let decay.
void main() {
  final List<File> domainFiles = Directory('lib/domain')
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))
      .toList();

  List<String> importsIn(File file) => file
      .readAsLinesSync()
      .where((String line) => line.trimLeft().startsWith('import '))
      .toList();

  test('the domain layer exists and is not empty', () {
    expect(domainFiles, isNotEmpty);
  });

  group('what the domain may not import', () {
    test('no Flutter, and no dart:ui', () {
      // A domain that imports the framework cannot be tested without a widget
      // binding, cannot move to a server, and drifts toward holding widgets.
      final List<String> offenders = <String>[];
      for (final File file in domainFiles) {
        for (final String line in importsIn(file)) {
          if (line.contains('package:flutter') || line.contains('dart:ui')) {
            offenders.add('${file.path}: $line');
          }
        }
      }
      expect(offenders, isEmpty);
    });

    test('no AI vendor, and nothing that could reach a network', () {
      // Principle 10 of the approved architecture, enforced rather than
      // promised: the ports for intelligence arrive in 2B, and even then the
      // vendor lives in the adapter.
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
      for (final File file in domainFiles) {
        for (final String line in importsIn(file)) {
          for (final String needle in forbidden) {
            if (line.contains(needle)) offenders.add('${file.path}: $line');
          }
        }
      }
      expect(offenders, isEmpty);
    });

    test('nothing from the layers above it', () {
      // The dependency arrow points inward. The domain knowing about a screen
      // is how a domain stops being one.
      const List<String> above = <String>[
        'features/',
        'core/',
        'data/',
        'package:loop/features',
        'package:loop/core',
        'package:loop/data',
      ];
      final List<String> offenders = <String>[];
      for (final File file in domainFiles) {
        for (final String line in importsIn(file)) {
          for (final String needle in above) {
            if (line.contains(needle)) offenders.add('${file.path}: $line');
          }
        }
      }
      expect(offenders, isEmpty);
    });

    test('no localization, because the domain has no words', () {
      // Behaviour must be identical in the three languages, which is only
      // guaranteed if the domain never sees one. Enums travel; sentences do not.
      final List<String> offenders = <String>[];
      for (final File file in domainFiles) {
        final String source = file.readAsStringSync();
        if (source.contains('AppLocalizations') ||
            source.contains('package:intl') ||
            source.contains('Localizations.')) {
          offenders.add(file.path);
        }
      }
      expect(offenders, isEmpty);
    });
  });

  test('the domain imports nothing but itself', () {
    // The strongest form of the rule, and currently true: every import in
    // lib/domain is relative. If that ever has to change, the exception should
    // be argued for here rather than discovered later.
    final List<String> external = <String>[];
    for (final File file in domainFiles) {
      for (final String line in importsIn(file)) {
        if (line.contains('package:') || line.contains('dart:')) {
          external.add('${file.path}: ${line.trim()}');
        }
      }
    }
    expect(external, isEmpty);
  });
}
