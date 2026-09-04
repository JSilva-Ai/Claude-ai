import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'composition/loop_app_composition.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge to edge: the Home's gradient runs under the status bar and behind the
  // gesture indicator, which is what makes the device frame disappear. Every
  // inset is then handled by SafeArea inside the page. Fire-and-forget, same
  // as before main() had anything to await — the first frame does not wait
  // on the platform channel round trip this call makes.
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));

  // No orientation lock. The page is one scrolling column that reflows, and a
  // tablet held in landscape is a supported way to use it — locking portrait
  // would be a layout shortcut sold as a product decision.

  // Opening the database is the only awaited step before the first frame —
  // a file open, not a query, and bounded regardless of how much the file
  // already holds. HomeController's own loading state, unchanged from Phase
  // 1, is what covers the Home projection query that follows.
  final LoopAppComposition composition = await LoopAppComposition.open();

  // No fresh-database seeding here: a new install opens to zero loops, and
  // that empty Home is the honest answer, not a placeholder for one built
  // from demo data. MockHomeRepository — with its own realistic content —
  // stays exactly what screenshots and widget tests inject instead.
  runApp(LoopApp(repository: composition.homeRepository));
}
