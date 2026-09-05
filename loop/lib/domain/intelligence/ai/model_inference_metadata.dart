/// Reproducibility metadata for one model call — never carried on
/// [CommitmentCandidate] or on a durable `Commitment`.
///
/// This is the whole answer to "which model produced this, and could it be
/// reproduced": a real provider id (never an alias like `"latest"`), the
/// adapter and prompt versions, and — where the provider reports them —
/// token counts and latency for cost/observability accounting. It lives
/// beside a candidate, not inside its semantics, because a Commitment must
/// stay meaningful regardless of whether a rule or a model ever produced the
/// candidate that led to it — provenance back to *evidence* already answers
/// "why", and provenance back to *which model* is a separate, narrower
/// question this type answers instead.
class ModelInferenceMetadata {
  const ModelInferenceMetadata({
    required this.providerFamily,
    required this.modelId,
    required this.adapterVersion,
    required this.promptVersion,
    required this.latency,
    this.inputTokens,
    this.outputTokens,
  });

  /// `'fake'` for the test double this phase ships; a real provider family
  /// name only once a provider adapter is separately authorised.
  final String providerFamily;

  /// An explicit model identifier. Never `"latest"` or any other alias —
  /// see the class doc: reproducibility depends on knowing exactly which
  /// model actually answered, not which alias was requested.
  final String modelId;

  final String adapterVersion;

  /// Which version of the centralised prompt/task template produced this —
  /// see `CommitmentDetectionPrompt` conceptually. Never the prompt text
  /// itself; domain code has no business reading that.
  final String promptVersion;

  final Duration latency;

  final int? inputTokens;
  final int? outputTokens;

  @override
  String toString() =>
      'ModelInferenceMetadata($providerFamily/$modelId, prompt $promptVersion, '
      '${latency.inMilliseconds}ms)';
}
