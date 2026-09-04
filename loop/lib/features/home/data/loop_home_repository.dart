import '../../../application/home/home_projector.dart';
import '../../../application/loop_repository.dart';
import '../../../application/persistence_failure.dart';
import '../../../core/utils/clock.dart';
import '../models/home_snapshot.dart';
import '../models/user_profile.dart';
import 'home_repository.dart';

/// [HomeRepository], answered from real, persisted [Loop] data.
///
/// The runtime adapter the architecture names: [LoopRepository] and
/// [loadHomeSnapshot] are application-layer and know nothing of Home; this
/// class is the one place that turns their output into what
/// [HomeController] already knows how to consume, and it is the only file
/// on the Home side of the boundary allowed to import `application/`.
///
/// [profile] defaults to [UserProfile.anonymous] rather than a fabricated
/// name — there is no account system yet, and pretending Loop data could
/// produce a display name would be exactly the invention 2C-B was told not
/// to do. The same honesty is why [loadHomeSnapshot] is called with no
/// `insight` or `upNext`: neither an AI engine nor a calendar integration
/// exists to supply them, so the Home simply shows those cards absent —
/// the same state `MockHomeRepository(empty: true)` already renders.
class LoopHomeRepository implements HomeRepository {
  LoopHomeRepository({
    required LoopRepository repository,
    this.profile = UserProfile.anonymous,
    this.clock = const Clock(),
  }) : _repository = repository;

  final LoopRepository _repository;
  final UserProfile profile;
  final Clock clock;

  @override
  Future<HomeSnapshot> fetchHome() async {
    try {
      return await loadHomeSnapshot(
        repository: _repository,
        profile: profile,
        now: clock.now(),
      );
    } on PersistenceFailure catch (failure) {
      // Never a raw SqliteException or Drift type past this point — see
      // PersistenceFailure's own doc for why the boundary stops here.
      throw HomeLoadFailure(failure.message);
    }
  }

  /// [LoopRepository.watchLoops] already is the one reactive primitive
  /// 2C-B exposes; this only drops the payload; HomeController's own
  /// listener always re-fetches through [fetchHome] rather than trusting a
  /// stream payload to already be a valid [HomeSnapshot].
  @override
  Stream<void> get changes => _repository.watchLoops().map((_) {});
}
