/// What a [LoopRepository] throws instead of a storage-specific exception.
///
/// A `SqliteException` crossing into application code would mean every
/// caller — eventually the Home, a future Loops screen — has to know SQLite
/// to handle a failure, and the day the data layer changes technology every
/// one of those call sites breaks too. Three shapes cover what this layer
/// can actually distinguish; nothing here guesses *why* beyond that.
sealed class PersistenceFailure implements Exception {
  const PersistenceFailure(this.message);

  /// For a log or a test, never for a screen — same discipline as
  /// `LoopFailure.debugMessage` in the domain.
  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

/// A write was refused by a constraint the schema itself enforces — a
/// foreign key with nothing to point at, a duplicate id, a duplicate
/// `(loop, sequence)` pair. The caller asked for something the stored data
/// does not support, not something the store is broken.
final class PersistenceConstraintViolation extends PersistenceFailure {
  const PersistenceConstraintViolation(super.message);
}

/// A stored value could not be turned back into a domain object — an
/// unrecognised enum name, a required column left null. This is the failure
/// a future schema migration exists to prevent; seeing it today means data
/// on disk does not match what this version of the schema expects.
final class PersistenceCorruptData extends PersistenceFailure {
  const PersistenceCorruptData(super.message);
}

/// Anything else the store refused, wrapped rather than swallowed. Corrupt
/// or unexpected data fails visibly through one of the two types above or
/// this one — never silently, never as a default value standing in for
/// data that was never actually read.
final class PersistenceUnavailable extends PersistenceFailure {
  const PersistenceUnavailable(super.message);
}
