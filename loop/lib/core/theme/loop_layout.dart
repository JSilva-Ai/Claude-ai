import 'package:flutter/foundation.dart';

import 'loop_dimens.dart';

/// The three sizes the Home is designed at.
///
/// Named for the amount of room there is, not for a device: a phone in
/// landscape, a small tablet and an Android app in a split-screen window all
/// land in [medium] and all want the same thing from the layout.
enum LoopWindowClass { compact, medium, expanded }

/// What one window class gives the page.
///
/// Every size that changes between a phone and a tablet is a field here, so
/// the difference between the two layouts can be read in one table instead of
/// being scattered through the widgets as conditionals. The alternative — a
/// phone column centred in a tablet's whitespace — is not a tablet layout, it
/// is a tablet apology.
@immutable
class LoopLayout {
  const LoopLayout({
    required this.windowClass,
    required this.pagePadding,
    required this.maxContentWidth,
    required this.columns,
    required this.ringSize,
    required this.cardGap,
    required this.sectionGap,
  });

  /// Resolved from the width the page actually gets, which is what makes it
  /// right in a split-screen window as well as on the device it was named for.
  factory LoopLayout.of(double width) {
    if (width >= LoopBreakpoints.expanded) {
      return const LoopLayout(
        windowClass: LoopWindowClass.expanded,
        pagePadding: LoopSpacing.xxxl,
        maxContentWidth: 760,
        columns: 2,
        ringSize: 128,
        cardGap: LoopSpacing.md,
        sectionGap: LoopSpacing.xxl,
      );
    }
    if (width >= LoopBreakpoints.medium) {
      return const LoopLayout(
        windowClass: LoopWindowClass.medium,
        pagePadding: LoopSpacing.xxl,
        maxContentWidth: 680,
        columns: 2,
        ringSize: 116,
        cardGap: LoopSpacing.sm + 2,
        sectionGap: LoopSpacing.xl,
      );
    }
    return const LoopLayout(
      windowClass: LoopWindowClass.compact,
      pagePadding: LoopSpacing.pagePadding,
      maxContentWidth: LoopSizes.maxContentWidth,
      columns: 1,
      ringSize: LoopSizes.activeRing,
      cardGap: LoopSpacing.xs + 2,
      sectionGap: LoopSpacing.lg,
    );
  }

  final LoopWindowClass windowClass;

  /// Horizontal breathing room. It grows with the window because a 20pt
  /// gutter that reads as generous on a phone reads as a mistake on a tablet.
  final double pagePadding;

  /// Where the column stops growing. A line of text 900pt wide is unreadable
  /// whatever the device can display.
  final double maxContentWidth;

  /// How many state cards sit side by side. Two on a tablet: the four states
  /// become one block the eye takes in at once, which is the whole premise of
  /// the screen, rather than a list that runs off into empty space.
  final int columns;

  final double ringSize;
  final double cardGap;
  final double sectionGap;

  bool get isCompact => windowClass == LoopWindowClass.compact;
}
