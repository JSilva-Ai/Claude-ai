/// The one canonical representation of a moment in this schema.
///
/// Every `DateTime` column in `lib/data/local/tables/` is epoch milliseconds,
/// UTC, stored as an `IntColumn` rather than through drift's own
/// `dateTime()` column builder — deliberately: that builder's own on-disk
/// representation has changed across drift versions and is a database-level
/// configuration option, not a fact this schema wants to depend on staying
/// whatever it defaults to today. An explicit, fully-owned, fully-tested pair
/// of functions removes the question.
///
/// The domain never calls `DateTime.now()` — every `DateTime` it holds was
/// supplied by a caller — so nothing here needs to either. [toPersistedMillis]
/// and [fromPersistedMillis] only convert a value that already exists; they
/// do not manufacture one.
library;

/// Domain → storage. Normalises to UTC first: a `DateTime` built from local
/// wall-clock time and one built as UTC for the same instant must persist to
/// the same integer, or "reopen the app in a different timezone" becomes a
/// data bug.
int toPersistedMillis(DateTime value) => value.toUtc().millisecondsSinceEpoch;

/// Storage → domain. Reconstructed as UTC, matching [toPersistedMillis].
/// `DateTime`'s own equality compares the instant, not the UTC/local flag, so
/// this round-trips correctly against a domain value that was originally
/// local — see `persisted_time_test.dart`.
DateTime fromPersistedMillis(int millis) =>
    DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
