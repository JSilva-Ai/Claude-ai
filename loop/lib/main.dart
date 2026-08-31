import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge to edge: the Home's gradient runs under the status bar and behind the
  // gesture indicator, which is what makes the device frame disappear. Every
  // inset is then handled by SafeArea inside the page.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // No orientation lock. The page is one scrolling column that reflows, and a
  // tablet held in landscape is a supported way to use it — locking portrait
  // would be a layout shortcut sold as a product decision.
  runApp(const LoopApp());
}
