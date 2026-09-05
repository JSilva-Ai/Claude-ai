import '../../domain/intelligence/ai/model_inference_metadata.dart';
import '../../domain/intelligence/ai/model_inference_request.dart';
import '../../domain/intelligence/ai/raw_model_commitment_output.dart';

/// Why a model call produced nothing usable — transport/provider-level
/// failures, before validation ever runs. Deliberately not a
/// provider-specific hierarchy: whichever adapter eventually talks to a real
/// vendor translates that vendor's own exceptions into one of these at the
/// adapter boundary, so nothing above [ModelGateway] ever has to know a
/// vendor's error shape.
enum ModelInferenceFailureReason {
  timeout,
  unavailable,
  rateLimited,
  invalidStructuredOutput,
  providerFailure,
  unsupportedModel,
}

/// What calling [ModelGateway.infer] produced.
sealed class ModelGatewayResponse {
  const ModelGatewayResponse();
}

/// A structured answer came back — not yet validated against the request;
/// see `ModelOutputValidator`.
final class ModelGatewaySuccess extends ModelGatewayResponse {
  const ModelGatewaySuccess({required this.output, required this.metadata});

  final RawModelCommitmentOutput output;
  final ModelInferenceMetadata metadata;
}

/// The call itself did not produce a usable structured answer.
final class ModelGatewayFailure extends ModelGatewayResponse {
  const ModelGatewayFailure(this.reason);

  final ModelInferenceFailureReason reason;
}

/// The one provider-neutral seam this application ever calls to reach a
/// model.
///
/// Nothing above this interface — `AICommitmentDetector`, the evaluation
/// harness, any future caller — may know whether an implementation is a
/// deterministic fake, a local model, or a real vendor's API: the contract
/// is exactly [ModelInferenceRequest] in, [ModelGatewayResponse] out, both
/// already provider-neutral types. No provider SDK type, no HTTP response
/// type, and no vendor exception may appear in this file or in this
/// interface's signature — a real adapter translates all of that at its own
/// boundary before it ever reaches here. No implementation of this
/// interface exists yet beyond the test double this phase ships; a real one
/// requires its own, separately authorised gate — see the Phase 3D report.
abstract interface class ModelGateway {
  Future<ModelGatewayResponse> infer(ModelInferenceRequest request);
}
