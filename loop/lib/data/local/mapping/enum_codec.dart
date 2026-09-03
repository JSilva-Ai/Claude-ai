/// The one canonical representation of an enum in this schema.
///
/// Every enum column in `lib/data/local/tables/` stores [Enum.name], never
/// `Enum.index`: an ordinal is a position in a list, and it silently means a
/// different value the day someone reorders or inserts a case. A name only
/// breaks if the case is renamed, which is a compile error at every call site
/// that referenced the old name — loud, not silent.
library;

/// Domain enum → storage.
String encodeEnum(Enum value) => value.name;

/// Storage → domain enum.
///
/// Fails loudly on a name [values] does not recognise, via `Iterable.byName`.
/// A future migration that removes or renames a case must carry its own
/// step to rewrite affected rows; this function does not attempt to guess
/// what an unrecognised value used to mean, because a guess here would be
/// exactly the silent reinterpretation this schema was told not to do.
T decodeEnum<T extends Enum>(List<T> values, String stored) =>
    values.byName(stored);
