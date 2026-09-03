/// Which kind of ground a number stands on.
enum ConfidenceBasis {
  /// Straight from an observation. Reserved for facts, which do not carry
  /// semantic confidence of their own — see `CaptureIntegrity`.
  observed,

  /// A rule or a model concluded it.
  modelInference,

  /// The person said so.
  userAsserted,
}

/// Which rule or model produced a conclusion, and which version of it.
///
/// A label, never a dependency: the domain records that `rule:promise-verb@v3`
/// or `model:local-ner@2026-08` was responsible, and knows nothing whatsoever
/// about how either is invoked.
class ProducerRef {
  const ProducerRef({required this.id, required this.version});

  const ProducerRef.rule(String id, String version)
      : this(id: 'rule:$id', version: version);

  final String id;
  final String version;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProducerRef && other.id == id && other.version == version;

  @override
  int get hashCode => Object.hash(id, version);

  @override
  String toString() => '$id@$version';
}

/// The version of the calibration a number was produced under.
extension type const CalibrationVersion(String value) implements Object {}

/// Semantic confidence: is the reading right?
///
/// Carries the calibration it was born under, which is what lets the thresholds
/// be re-tuned later without invalidating the past — a decision made in March
/// stays explainable by March's calibration.
class Confidence {
  Confidence({
    required this.value,
    required this.basis,
    required this.method,
    required this.under,
    required this.computedAt,
  }) {
    if (value.isNaN || value < 0 || value > 1) {
      throw ArgumentError.value(value, 'value', 'Confidence must be in 0..1');
    }
  }

  final double value;
  final ConfidenceBasis basis;
  final ProducerRef method;
  final CalibrationVersion under;

  /// Supplied by the caller; the domain reads no clock.
  final DateTime computedAt;

  Confidence copyWith({double? value, ConfidenceBasis? basis}) => Confidence(
        value: value ?? this.value,
        basis: basis ?? this.basis,
        method: method,
        under: under,
        computedAt: computedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Confidence &&
          other.value == value &&
          other.basis == basis &&
          other.method == method &&
          other.under == under &&
          other.computedAt == computedAt;

  @override
  int get hashCode => Object.hash(value, basis, method, under, computedAt);

  @override
  String toString() =>
      'Confidence(${value.toStringAsFixed(2)} ${basis.name} $method $under)';
}
