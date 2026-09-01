import 'package:flutter/material.dart';

import '../theme/loop_colors.dart';
import '../theme/loop_dimens.dart';
import '../theme/loop_motion.dart';
import '../theme/loop_theme.dart';
import 'pressable.dart';

/// The ground an icon button sits on.
enum LoopIconButtonVariant {
  /// A translucent panel with a hairline border — the header's menu.
  outlined,

  /// The raised surface, for a control inside a card.
  raised,
}

/// A single glyph you can press.
///
/// Named for the house rather than as a bare `IconButton`, which would shadow
/// Material's in every file that imports both and leave a reader guessing
/// which one they are looking at.
///
/// The constraint that matters here is the one that produced a real defect
/// once already: **the widget must not be bigger than the button.** A 44pt
/// glyph needs a 48pt hit area, and the obvious way to get one — a Center
/// inside a minimum-size box — takes every pixel its parent offers, so the
/// header's menu quietly became a hit area spanning the whole row and a tap on
/// it opened the profile. [Pressable] sizes the area to exactly
/// `max(child, minSize)`; the test for this asserts the rendered width.
class LoopIconButton extends StatelessWidget {
  const LoopIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.variant = LoopIconButtonVariant.outlined,
    this.color,
    this.size = LoopSizes.headerButton,
    this.iconSize = 20,
    super.key,
  });

  final IconData icon;

  /// Null disables it: dimmed, and it does not respond.
  final VoidCallback? onPressed;

  /// Required. A button whose whole content is a picture has no text for a
  /// screen reader to fall back on, so there is no sensible default here.
  final String semanticLabel;

  final LoopIconButtonVariant variant;

  /// The glyph's colour. Defaults to primary text, not to an accent — an icon
  /// button is a control, and only some of them are also information.
  final Color? color;

  final double size;
  final double iconSize;

  bool get _enabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final LoopAccents accents = context.accents;
    final Color foreground =
        _enabled ? (color ?? LoopColors.textPrimary) : accents.textTertiary;

    return Pressable(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      minSize: LoopSizes.minTouchTarget,
      child: AnimatedOpacity(
        duration: LoopMotion.scale(context, LoopMotion.fast),
        opacity: _enabled ? 1 : 0.45,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: switch (variant) {
              LoopIconButtonVariant.outlined => LoopColors.surface.withValues(
                  alpha: 0.7,
                ),
              LoopIconButtonVariant.raised => accents.surfaceRaised,
            },
            borderRadius: const BorderRadius.all(LoopRadius.sm),
            border: Border.all(color: accents.border),
          ),
          child: Icon(icon, size: iconSize, color: foreground),
        ),
      ),
    );
  }
}
