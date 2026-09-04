import 'commitment_candidate.dart';

/// What the pattern rules found in one piece of text, before any temporal
/// resolution or direction judgement is layered on top.
///
/// Deliberately does not carry a [Claim] itself: assigning `ClaimKind`
/// needs to know whether this evidence is the user's own words or someone
/// else's, which this class — reading only text — cannot know. That
/// judgement belongs to whichever caller does know, kept in
/// `CommitmentCandidateDetector`.
class CommitmentSignalMatch {
  const CommitmentSignalMatch({
    required this.reasons,
    required this.sourceQuote,
  });

  /// Never empty — [CommitmentSignalRules.match] returns null rather than an
  /// instance with nothing in it.
  final List<CommitmentSignalReason> reasons;

  /// The observed text, verbatim, trimmed — never generated, never
  /// paraphrased.
  final String sourceQuote;
}

/// Deterministic, English-only pattern matching for commitment-shaped
/// language over already-redacted text.
///
/// Covers only explicit, high-signal phrasing — a first-person future
/// promise, an explicit promise phrase, a direct request, or naming
/// something still outstanding. A false negative is preferred throughout: a
/// bare action verb with none of those patterns present is never, by
/// itself, enough to return a match (see the false-positive corpus in
/// `commitment_candidate_detector_test.dart`), and speculative or aspirational
/// phrasing ("might", "may", "hope to", "'d like to") is excluded simply by
/// not being one of the phrases matched — nothing here suppresses it, it was
/// never a candidate for a match in the first place.
///
/// Two inputs are treated as never expressing a *fresh* commitment at all,
/// and short-circuit to no match before any pattern is even tried: text
/// beginning with "FYI" (an explicit informational marker), and text
/// beginning with `>` (a common plain-text quoting prefix). Neither is a
/// complete answer to "is this quoted or historical content" — an inline
/// quote or an HTML blockquote would not be caught by either check, and
/// that is a known, documented limitation of what 3B's Evidence model can
/// currently distinguish, not something this class works around by
/// inventing metadata the source never supplied.
///
/// English only, deliberately: the phrases matched are English idioms, and
/// running them against Portuguese or Spanish text is not attempted —
/// nothing here detects language, so non-English text simply matches none
/// of these patterns and produces no candidate, which is the same safe,
/// correct outcome as unsupported input, without a separate
/// "unsupportedLanguage" result to maintain.
class CommitmentSignalRules {
  const CommitmentSignalRules();

  static final RegExp _firstPersonPromise = RegExp(
    r"\bI(?:'ll|\s+will)\s+[a-z]",
    caseSensitive: false,
  );
  static final RegExp _explicitPromisePhrase = RegExp(
    r'\bI\s+promise\b',
    caseSensitive: false,
  );
  static final RegExp _pleaseRequest = RegExp(
    r'\bplease\s+[a-z]+',
    caseSensitive: false,
  );
  static final RegExp _youRequest = RegExp(
    r'\b(?:can|could|would)\s+you\s+[a-z]+',
    caseSensitive: false,
  );
  static final RegExp _waiting = RegExp(
    r'\bwaiting\s+for\b',
    caseSensitive: false,
  );
  static final RegExp _you = RegExp(r'\byou\b', caseSensitive: false);

  static const List<String> _actionVerbs = <String>[
    'send',
    'call',
    'review',
    'sign',
    'pay',
    'deliver',
    'meet',
    'reply',
    'respond',
    'finish',
    'complete',
    'submit',
    'share',
  ];

  CommitmentSignalMatch? match(String text) {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final String lower = trimmed.toLowerCase();
    if (lower.startsWith('fyi')) return null;
    if (trimmed.startsWith('>')) return null;

    final List<CommitmentSignalReason> reasons = <CommitmentSignalReason>[];
    final bool hasFirstPersonPromise = _firstPersonPromise.hasMatch(text);
    final bool hasExplicitPromisePhrase = _explicitPromisePhrase.hasMatch(
      text,
    );
    final bool hasRequest =
        _pleaseRequest.hasMatch(text) || _youRequest.hasMatch(text);
    final bool hasWaiting = _waiting.hasMatch(text);

    if (hasFirstPersonPromise) {
      reasons.add(CommitmentSignalReason.firstPersonPromise);
    }
    if (hasExplicitPromisePhrase) {
      reasons.add(CommitmentSignalReason.explicitPromisePhrase);
    }
    if (hasRequest) {
      reasons.add(CommitmentSignalReason.explicitRequestVerb);
    }
    if (hasWaiting) {
      reasons.add(CommitmentSignalReason.waitingLanguage);
    }

    final bool hasPromise = hasFirstPersonPromise || hasExplicitPromisePhrase;
    if (!hasPromise && !hasRequest && !hasWaiting) {
      // Nothing that on its own justifies a candidate. A bare action verb —
      // checked below only for the reasons list of a match that already
      // exists — is never sufficient by itself.
      return null;
    }

    if (hasRequest && _you.hasMatch(text)) {
      reasons.add(CommitmentSignalReason.directRecipient);
    }
    if (hasPromise && hasRequest) {
      // Both directions present in the same text — which one is the point
      // is genuinely unclear from pattern matching alone.
      reasons.add(CommitmentSignalReason.ambiguousActor);
    }
    if (_actionVerbs.any(lower.contains)) {
      reasons.add(CommitmentSignalReason.actionVerbPresent);
    }

    return CommitmentSignalMatch(reasons: reasons, sourceQuote: trimmed);
  }
}
