import 'package:flutter/material.dart';

import '../theme/loop_colors.dart';
import '../theme/loop_dimens.dart';
import '../theme/loop_elevation.dart';
import '../theme/loop_motion.dart';
import '../theme/loop_theme.dart';
import 'pressable.dart';

/// How much weight a button is allowed to carry.
///
/// Two, not five. A screen with three equally loud buttons has no primary
/// action, and every screen in LOOP has exactly one thing it wants you to do.
enum PrimaryButtonVariant {
  /// The brand gradient. One per screen, on the action that screen is for.
  filled,

  /// A raised surface and a border. Everything else — dismissing, cancelling,
  /// the second of two choices.
  quiet,
}

/// The button.
///
/// Written once because it was written three times: the retry control, the
/// sheet's close control and the calendar action were each a `Container` with
/// their own padding, radius and border, drifting apart by a couple of pixels
/// at a time. Geometry, type and states now come from the tokens, and a fourth
/// button cannot invent a fourth style.
///
/// States: normal, pressed (scale and opacity, from [Pressable]), disabled and
/// loading. Loading holds the button's width — a control that shrinks to a
/// spinner moves the layout under the finger that just pressed it, which on a
/// phone means the next tap lands somewhere else.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.variant = PrimaryButtonVariant.filled,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    super.key,
  });

  final String label;

  /// Null disables the button. There is no separate `enabled` flag: two ways
  /// to say the same thing is one way to contradict yourself.
  final VoidCallback? onPressed;

  final PrimaryButtonVariant variant;
  final IconData? icon;

  /// Shows a spinner in place of the label and refuses taps. The label stays
  /// in the tree, invisible, so the width does not change.
  final bool isLoading;

  /// Fills its parent's width. Off by default: a button as wide as the screen
  /// reads as a form, not as a choice.
  final bool expand;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final LoopAccents accents = context.accents;
    final bool filled = variant == PrimaryButtonVariant.filled;

    final Color foreground = filled
        ? Colors.white
        : (_enabled ? LoopColors.textPrimary : accents.textTertiary);

    Widget content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: LoopSpacing.xs),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleMedium?.copyWith(color: foreground),
          ),
        ),
      ],
    );

    if (isLoading) {
      content = Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Opacity(opacity: 0, child: content),
          SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foreground,
            ),
          ),
        ],
      );
    }

    return Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      child: ExcludeSemantics(
        child: Pressable(
          onPressed: _enabled ? onPressed : null,
          isButton: false,
          child: AnimatedOpacity(
            duration: LoopMotion.scale(context, LoopMotion.fast),
            opacity: _enabled ? 1 : 0.45,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: LoopSizes.minTouchTarget,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: LoopSpacing.lg,
                vertical: LoopSpacing.sm,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(LoopRadius.sm),
                gradient: filled
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[LoopColors.ai, LoopColors.aiAlt],
                      )
                    : null,
                color: filled ? null : accents.surfaceRaised,
                border: filled ? null : Border.all(color: accents.borderStrong),
                boxShadow: filled && _enabled
                    ? LoopElevation.floating(LoopColors.ai)
                    : LoopElevation.level0,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
