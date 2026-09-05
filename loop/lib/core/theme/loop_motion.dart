import 'package:flutter/widgets.dart';

/// Durations and curves.
///
/// The house style is short and slightly under-damped: the interface should
/// feel quick first and animated second. Anything above [slow] is a transition
/// the user waits for, and there are none of those on the Home.
@immutable
class LoopMotion {
  const LoopMotion._();

  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 520);

  /// The ring is the one element allowed to take its time; it is the brand.
  static const Duration ring = Duration(milliseconds: 1100);

  /// A loop closing: the circle shuts, the check strokes through, the word
  /// lands. Shorter than the ring's entrance because this one will play
  /// several times a day.
  static const Duration completion = Duration(milliseconds: 720);

  /// Gap between one entrance element and the next.
  static const Duration stagger = Duration(milliseconds: 55);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuint;
  static const Curve press = Curves.easeOut;

  /// Distance an entering element travels. Deliberately small — a long slide
  /// reads as a page transition, not as content settling.
  static const double enterOffset = 18;

  /// Honours the platform "reduce motion" setting.
  ///
  /// Every animated widget on the Home asks this rather than checking the flag
  /// itself, so a new one cannot forget: with motion reduced the widget still
  /// reaches its final state, it simply arrives there without travelling.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static Duration scale(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
