import 'failures.dart';

/// Success or refusal, without exceptions.
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T? get valueOrNull => switch (this) {
        Ok<T>(:final T value) => value,
        Err<T>() => null,
      };

  LoopFailure? get failureOrNull => switch (this) {
        Ok<T>() => null,
        Err<T>(:final LoopFailure failure) => failure,
      };

  /// For call sites that have already established success — a test, or code
  /// after an `isOk` check. Throws rather than returning null, so a mistake
  /// here is loud.
  T get unwrap => switch (this) {
        Ok<T>(:final T value) => value,
        Err<T>(:final LoopFailure failure) => throw StateError(
            'Result was a failure: ${failure.debugMessage}',
          ),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  String toString() => 'Ok($value)';
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final LoopFailure failure;

  @override
  String toString() => 'Err(${failure.debugMessage})';
}
