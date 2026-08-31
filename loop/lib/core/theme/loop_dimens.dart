import 'package:flutter/widgets.dart';

/// Spacing, radii and sizes. A magic number in a widget is a number nobody can
/// change safely, so they live here on a 4pt grid.
@immutable
class LoopSpacing {
  const LoopSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  /// Horizontal page padding.
  static const double pagePadding = 20;
}

@immutable
class LoopRadius {
  const LoopRadius._();

  static const Radius sm = Radius.circular(12);
  static const Radius md = Radius.circular(16);
  static const Radius lg = Radius.circular(20);
  static const Radius xl = Radius.circular(28);

  static const BorderRadius card = BorderRadius.all(lg);
  static const BorderRadius chip = BorderRadius.all(sm);
  static const BorderRadius sheet = BorderRadius.vertical(top: xl);
}

@immutable
class LoopSizes {
  const LoopSizes._();

  /// Apple's minimum is 44pt and Android's is 48dp. Taking the larger of the
  /// two as the floor everywhere means no target has to be argued about again.
  static const double minTouchTarget = 48;

  static const double avatar = 40;
  static const double headerButton = 44;
  static const double summaryIcon = 42;
  static const double activeRing = 104;
  static const double createButton = 56;
  static const double bottomNavHeight = 64;

  /// On a tablet the column stops growing and centres. A 1000pt-wide card of
  /// four words is not a premium layout, it is a stretched phone.
  static const double maxContentWidth = 560;
}
