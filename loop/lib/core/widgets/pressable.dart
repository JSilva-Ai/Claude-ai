import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/loop_motion.dart';

/// The house press feedback: a small, fast scale-down and a light haptic.
///
/// Every tappable surface on the Home goes through this rather than through
/// InkWell. A Material ripple on a dark gradient card reads as a grey smear,
/// and the ripple's own bounds fight the card's rounded corners. This also
/// puts the semantics and the minimum touch target in one place, so a new
/// tappable cannot ship without either.
class Pressable extends StatefulWidget {
  const Pressable({
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.isButton = true,
    this.pressedScale = 0.97,
    this.borderRadius,
    this.minSize = 0,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final bool isButton;
  final double pressedScale;
  final BorderRadius? borderRadius;

  /// Enforces a minimum hit area on small visual elements (an icon button)
  /// without making the drawn thing that big.
  final double minSize;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _setDown(bool value) {
    if (_down == value) return;
    setState(() => _down = value);
  }

  void _handleTap() {
    final VoidCallback? onPressed = widget.onPressed;
    if (onPressed == null) return;
    // Selection-level feedback: this is a navigation tap, not a confirmation.
    HapticFeedback.selectionClick();
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;
    Widget child = widget.child;

    if (widget.minSize > 0) {
      // The factors matter: without them the Center takes every pixel its
      // parent offers, and a 44pt menu button quietly becomes a hit area
      // spanning the whole header — which is how a tap on "menu" ends up
      // opening whatever sits on the other side of the row. With them the
      // hit area is exactly max(child, minSize).
      child = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.minSize,
          minHeight: widget.minSize,
        ),
        child: Center(widthFactor: 1, heightFactor: 1, child: child),
      );
    }

    return Semantics(
      label: widget.semanticLabel,
      button: widget.isButton && enabled,
      enabled: enabled,
      container: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? _handleTap : null,
        onTapDown: enabled ? (_) => _setDown(true) : null,
        onTapUp: enabled ? (_) => _setDown(false) : null,
        onTapCancel: enabled ? () => _setDown(false) : null,
        child: AnimatedScale(
          scale: _down ? widget.pressedScale : 1,
          duration: LoopMotion.scale(context, LoopMotion.instant),
          curve: LoopMotion.press,
          child: AnimatedOpacity(
            opacity: _down ? 0.86 : 1,
            duration: LoopMotion.scale(context, LoopMotion.instant),
            child: child,
          ),
        ),
      ),
    );
  }
}
