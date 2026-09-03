/// The version of a deterministic policy.
///
/// Kept apart from `CalibrationVersion`, which versions how *confidence* is
/// computed. Conflating the two would mean re-tuning a risk threshold silently
/// restamped every confidence number in the system as if its meaning had
/// changed too.
extension type const PolicyVersion(String value) implements Object {}

/// Which policy produced a judgement, and which version of it.
///
/// Every assessment and every suggestion carries one. It is the difference
/// between "the app thinks this is risky" and "risk-v1 thinks this is risky
/// because of these three things" — and the second is the only one that can be
/// argued with, compared against a later version, or replaced by a model that
/// has to prove it does better.
class PolicyRef {
  const PolicyRef({required this.id, required this.version});

  final String id;
  final PolicyVersion version;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PolicyRef && other.id == id && other.version == version;

  @override
  int get hashCode => Object.hash(id, version);

  @override
  String toString() => '$id@$version';
}
