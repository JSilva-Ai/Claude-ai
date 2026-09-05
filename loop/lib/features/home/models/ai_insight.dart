import 'package:flutter/foundation.dart';

/// How much attention an insight is allowed to ask for.
///
/// The engine that will eventually write these has to be able to say "this is
/// worth interrupting for" without the card guessing from the wording.
enum InsightTone { positive, neutral, attention }

/// One sentence from the context engine, plus its supporting line.
///
/// Two fields rather than one paragraph, because the card renders them at
/// different weights and a single blob could not be laid out that way.
@immutable
class AIInsight {
  const AIInsight({
    required this.id,
    required this.headline,
    this.detail,
    this.tone = InsightTone.neutral,
    this.generatedAt,
  });

  final String id;
  final String headline;
  final String? detail;
  final InsightTone tone;
  final DateTime? generatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIInsight &&
          other.id == id &&
          other.headline == headline &&
          other.detail == detail &&
          other.tone == tone;

  @override
  int get hashCode => Object.hash(id, headline, detail, tone);
}
