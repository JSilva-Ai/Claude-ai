import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import '../data/local/database/loop_database.dart';
import '../data/local/repository/drift_loop_repository.dart';
import '../features/home/data/loop_home_repository.dart';

/// Where the persisted, Drift-backed Home path actually gets built.
///
/// This is the one file in the app allowed to see both `lib/data` and
/// `lib/features` at once — everywhere else, `test/architecture/` enforces
/// that they stay apart. A composition root is supposed to be exactly that
/// single seam, not a rule the rest of the app also has to know.
///
/// Ownership is explicit rather than a global: whoever calls [open] owns
/// the [LoopDatabase] it opens, and is responsible for [dispose]. `main.dart`
/// opens one for the life of the process and never disposes it — there is
/// no natural shutdown hook in a running Flutter app to call it from, which
/// is the same reason most top-level app resources are never explicitly
/// closed. Tests call [dispose] themselves, every time, because a test
/// process outlives no database.
class LoopAppComposition {
  const LoopAppComposition._({
    required this.database,
    required this.repository,
    required this.homeRepository,
  });

  final LoopDatabase database;
  final DriftLoopRepository repository;
  final LoopHomeRepository homeRepository;

  /// The real, on-device path: the app's own documents directory, a fixed
  /// filename. The only thing this adds over [withExecutor] is deciding
  /// *where* the file lives — everything about what gets built from it is
  /// identical, and identically tested, either way.
  static Future<LoopAppComposition> open() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/loop.sqlite');
    return LoopAppComposition.withExecutor(NativeDatabase(file));
  }

  /// The composition itself, independent of where the database lives — what
  /// a test exercises directly, against `NativeDatabase.memory()` or a temp
  /// file, without a real device path.
  factory LoopAppComposition.withExecutor(QueryExecutor executor) {
    final LoopDatabase database = LoopDatabase(executor);
    final DriftLoopRepository repository = DriftLoopRepository(database);
    final LoopHomeRepository homeRepository = LoopHomeRepository(
      repository: repository,
    );
    return LoopAppComposition._(
      database: database,
      repository: repository,
      homeRepository: homeRepository,
    );
  }

  Future<void> dispose() => database.close();
}
