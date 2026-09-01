import 'package:flutter/material.dart';

import 'loop_colors.dart';
import 'loop_dimens.dart';
import 'loop_typography.dart';

/// The accents that carry meaning, reachable from any widget through
/// `Theme.of(context).extension<LoopAccents>()`.
///
/// They are a [ThemeExtension] rather than static constants for one reason:
/// the day LOOP gains a light theme, or a high-contrast variant, the widgets
/// that read them do not change at all.
@immutable
class LoopAccents extends ThemeExtension<LoopAccents> {
  const LoopAccents({
    required this.atRisk,
    required this.waiting,
    required this.today,
    required this.done,
    required this.ai,
    required this.aiText,
    required this.aiAlt,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderStrong,
    required this.surfaceMuted,
    required this.surfaceRaised,
  });

  final Color atRisk;
  final Color waiting;
  final Color today;
  final Color done;
  final Color ai;

  /// The violet for text and for icons that carry meaning. See
  /// [LoopColors.aiText] for why it is not the same value as [ai].
  final Color aiText;

  final Color aiAlt;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color borderStrong;
  final Color surfaceMuted;
  final Color surfaceRaised;

  static const LoopAccents dark = LoopAccents(
    atRisk: LoopColors.atRisk,
    waiting: LoopColors.waiting,
    today: LoopColors.today,
    done: LoopColors.done,
    ai: LoopColors.ai,
    aiText: LoopColors.aiText,
    aiAlt: LoopColors.aiAlt,
    textSecondary: LoopColors.textSecondary,
    textTertiary: LoopColors.textTertiary,
    border: LoopColors.border,
    borderStrong: LoopColors.borderStrong,
    surfaceMuted: LoopColors.surfaceMuted,
    surfaceRaised: LoopColors.surfaceRaised,
  );

  @override
  LoopAccents copyWith({
    Color? atRisk,
    Color? waiting,
    Color? today,
    Color? done,
    Color? ai,
    Color? aiText,
    Color? aiAlt,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? borderStrong,
    Color? surfaceMuted,
    Color? surfaceRaised,
  }) {
    return LoopAccents(
      atRisk: atRisk ?? this.atRisk,
      waiting: waiting ?? this.waiting,
      today: today ?? this.today,
      done: done ?? this.done,
      ai: ai ?? this.ai,
      aiText: aiText ?? this.aiText,
      aiAlt: aiAlt ?? this.aiAlt,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
    );
  }

  @override
  LoopAccents lerp(ThemeExtension<LoopAccents>? other, double t) {
    if (other is! LoopAccents) return this;
    return LoopAccents(
      atRisk: Color.lerp(atRisk, other.atRisk, t)!,
      waiting: Color.lerp(waiting, other.waiting, t)!,
      today: Color.lerp(today, other.today, t)!,
      done: Color.lerp(done, other.done, t)!,
      ai: Color.lerp(ai, other.ai, t)!,
      aiText: Color.lerp(aiText, other.aiText, t)!,
      aiAlt: Color.lerp(aiAlt, other.aiAlt, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
    );
  }
}

extension LoopThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get text => Theme.of(this).textTheme;

  /// Never null: [LoopTheme.dark] always installs the extension.
  LoopAccents get accents =>
      Theme.of(this).extension<LoopAccents>() ?? LoopAccents.dark;
}

@immutable
class LoopTheme {
  const LoopTheme._();

  static ThemeData get dark {
    const ColorScheme scheme = ColorScheme.dark(
      primary: LoopColors.ai,
      onPrimary: Colors.white,
      secondary: LoopColors.aiAlt,
      onSecondary: Color(0xFF04121A),
      surface: LoopColors.surface,
      onSurface: LoopColors.textPrimary,
      error: LoopColors.atRisk,
      onError: Colors.white,
      outline: LoopColors.textTertiary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: LoopColors.backgroundBottom,
      textTheme: LoopTypography.textTheme,
      // The page paints its own gradient; a splash on top of it reads as a
      // grey wash. Press feedback here is scale and border, per widget.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      dividerTheme: const DividerThemeData(
        color: LoopColors.border,
        space: 1,
        thickness: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: LoopColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: LoopRadius.sheet),
      ),
      extensions: const <ThemeExtension<dynamic>>[LoopAccents.dark],
    );
  }
}
