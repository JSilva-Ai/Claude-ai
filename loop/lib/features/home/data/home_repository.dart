import '../models/home_snapshot.dart';

/// The one seam between the Home and where its data comes from.
///
/// Phase 1 satisfies it with fixtures. Gmail, Calendar and the commitment graph
/// will satisfy it with a real aggregation later, and the widgets above it do
/// not change when that happens — which is the entire reason this interface
/// exists this early.
abstract interface class HomeRepository {
  Future<HomeSnapshot> fetchHome();
}

/// Thrown by a repository when the snapshot cannot be produced.
///
/// A typed failure rather than a raw exception so the UI can distinguish "no
/// network" from a bug, once there is a network to lose.
class HomeLoadFailure implements Exception {
  const HomeLoadFailure([this.message]);

  final String? message;

  @override
  String toString() => 'HomeLoadFailure(${message ?? 'unknown'})';
}
