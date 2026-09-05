import 'commitment_candidate.dart';

/// What a temporal cue in text resolved to, if anything.
///
/// [resolved] is null for a cue this phase deliberately refuses to turn into
/// a date — "soon", "later" — rather than guessing: fabricating certainty
/// for an ambiguous date would be exactly the thing the brief prohibits.
/// [matchedText] is kept verbatim so the explanation can show what was
/// actually read, the same discipline `Claim.sourceQuote` already applies.
class TemporalMatch {
  const TemporalMatch({
    required this.matchedText,
    required this.reason,
    this.resolved,
  });

  final String matchedText;
  final CommitmentSignalReason reason;
  final DateTime? resolved;
}

/// Deterministic date-cue recognition and resolution over already-redacted
/// text.
///
/// Two capabilities, kept apart because they need different inputs. Finding
/// a date-shaped cue needs only the text — [findMentions] is what
/// `RuleBasedEntityExtractor` calls, since `EntityExtractor.extractFrom`
/// takes no reference time and cannot resolve one anyway. *Resolving* one
/// into a concrete moment needs an explicit reference time this phase never
/// reads from a clock — [resolveDeadline] is what `CommitmentCandidateDetector`
/// calls, which does have one to give.
///
/// English only, and deliberately small: an explicit ISO date, "today",
/// "tomorrow", a bare weekday name (resolved to its next occurrence
/// on-or-after the reference date), and the two vague cues this phase
/// recognises without resolving. No recurrence, no timezone inference, no
/// general natural-language date parser.
class CommitmentTemporalSignals {
  const CommitmentTemporalSignals();

  static final RegExp _isoDate = RegExp(r'\b(\d{4})-(\d{2})-(\d{2})\b');

  static const Map<String, int> _weekdays = <String, int>{
    'monday': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'friday': DateTime.friday,
    'saturday': DateTime.saturday,
    'sunday': DateTime.sunday,
  };

  /// Every date-shaped cue this phase recognises in [text], verbatim and in
  /// no particular order. Used for mention extraction only — nothing here
  /// is resolved to a moment.
  List<String> findMentions(String text) {
    final String lower = text.toLowerCase();
    final List<String> found = <String>[];

    for (final Match m in _isoDate.allMatches(text)) {
      found.add(m.group(0)!);
    }
    if (lower.contains('tomorrow')) found.add('tomorrow');
    if (lower.contains('today')) found.add('today');
    for (final String day in _weekdays.keys) {
      if (lower.contains(day)) found.add(day);
    }
    if (lower.contains('soon')) found.add('soon');
    if (lower.contains('later')) found.add('later');

    return found;
  }

  /// The single strongest temporal cue in [text], resolved against
  /// [referenceTime] where it can honestly be. Returns null when nothing
  /// recognisable is present at all.
  TemporalMatch? resolveDeadline(String text, DateTime referenceTime) {
    final RegExpMatch? iso = _isoDate.firstMatch(text);
    if (iso != null) {
      return TemporalMatch(
        matchedText: iso.group(0)!,
        reason: CommitmentSignalReason.explicitDeadline,
        resolved: DateTime.utc(
          int.parse(iso.group(1)!),
          int.parse(iso.group(2)!),
          int.parse(iso.group(3)!),
        ),
      );
    }

    final String lower = text.toLowerCase();
    final DateTime today = DateTime.utc(
      referenceTime.year,
      referenceTime.month,
      referenceTime.day,
    );

    if (lower.contains('tomorrow')) {
      return TemporalMatch(
        matchedText: 'tomorrow',
        reason: CommitmentSignalReason.explicitDeadline,
        resolved: today.add(const Duration(days: 1)),
      );
    }

    if (lower.contains('today')) {
      return TemporalMatch(
        matchedText: 'today',
        reason: CommitmentSignalReason.explicitDeadline,
        resolved: today,
      );
    }

    for (final MapEntry<String, int> weekday in _weekdays.entries) {
      if (!lower.contains(weekday.key)) continue;
      final int diff = (weekday.value - today.weekday) % 7;
      final bool hasBy = lower.contains('by ${weekday.key}');
      return TemporalMatch(
        matchedText: weekday.key,
        reason: hasBy
            ? CommitmentSignalReason.explicitDeadline
            : CommitmentSignalReason.weakTemporalSignal,
        resolved: today.add(Duration(days: diff)),
      );
    }

    if (lower.contains('soon') || lower.contains('later')) {
      return TemporalMatch(
        matchedText: lower.contains('soon') ? 'soon' : 'later',
        reason: CommitmentSignalReason.weakTemporalSignal,
      );
    }

    return null;
  }
}
