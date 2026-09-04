import '../models/home_snapshot.dart';

/// The one seam between the Home and where its data comes from.
///
/// Phase 1 satisfies it with fixtures. Gmail, Calendar and the commitment graph
/// will satisfy it with a real aggregation later, and the widgets above it do
/// not change when that happens — which is the entire reason this interface
/// exists this early.
abstract interface class HomeRepository {
  Future<HomeSnapshot> fetchHome();

  /// Fires whenever data behind [fetchHome] may have changed — never the
  /// snapshot itself, just a signal. [HomeController] treats every event as
  /// "call [fetchHome] again", the same work its own `refresh()` already
  /// does; this is what lets the real, database-backed repository update the
  /// Home without any widget polling or importing storage directly.
  ///
  /// A source with nothing reactive behind it — [MockHomeRepository], the
  /// fixed demo data every screenshot and widget test still runs against —
  /// answers with a stream that never fires, which is a correct, honest
  /// implementation, not a stub.
  Stream<void> get changes;
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
