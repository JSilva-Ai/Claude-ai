import 'package:loop/application/intelligence/model_gateway.dart';
import 'package:loop/domain/intelligence/ai/model_inference_metadata.dart';
import 'package:loop/domain/intelligence/ai/model_inference_request.dart';
import 'package:loop/domain/intelligence/ai/raw_model_commitment_output.dart';

/// A deterministic [ModelGateway] test double — the same relationship
/// `InMemoryLoopRepository` already has to `DriftLoopRepository`.
///
/// No network, no API key, no real provider anywhere behind it: [respond]
/// is a plain function the test supplies, so every test in this codebase
/// that exercises AI-shaped behaviour — success, timeout, malformed output,
/// a hallucinated evidence id, a prompt-injection attempt — runs fully
/// offline and free of any billable call. [delay], when set, lets a test
/// exercise [AICommitmentDetector]'s own timeout handling without an actual
/// network being slow.
class FakeModelGateway implements ModelGateway {
  FakeModelGateway({required this.respond, this.delay = Duration.zero});

  final ModelGatewayResponse Function(ModelInferenceRequest request) respond;
  final Duration delay;

  int callCount = 0;

  @override
  Future<ModelGatewayResponse> infer(ModelInferenceRequest request) async {
    callCount++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return respond(request);
  }

  /// A convenience for the common case: a fixed structured output, wrapped
  /// with an honest, fake provider identity — nothing here could be
  /// mistaken for a real vendor's response shape.
  static ModelGatewaySuccess success(
    RawModelCommitmentOutput output, {
    String modelId = 'fake-model-1',
    String promptVersion = 'commitment-detection-prompt-v1',
    Duration latency = const Duration(milliseconds: 5),
  }) =>
      ModelGatewaySuccess(
        output: output,
        metadata: ModelInferenceMetadata(
          providerFamily: 'fake',
          modelId: modelId,
          adapterVersion: 'fake-adapter-v1',
          promptVersion: promptVersion,
          latency: latency,
        ),
      );
}
