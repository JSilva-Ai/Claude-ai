import 'package:flutter/material.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/loop_colors.dart';
import '../../../../core/theme/loop_dimens.dart';
import '../../../../core/theme/loop_motion.dart';
import '../../../../core/theme/loop_theme.dart';
import '../../../../core/widgets/loop_logo.dart';
import '../../../../core/widgets/pressable.dart';

/// The five places LOOP will have. Create is not a page — it is the action —
/// which is why it is in the middle and drawn differently.
enum LoopDestination { home, loops, create, focus, more }

/// The bar.
///
/// Built by hand rather than with [NavigationBar]: the centre item is a raised
/// action, not a tab, and Material's bar has one selection model for all five
/// slots. It sits inside the safe area, so on a gesture phone it clears the
/// home indicator and on a button phone it does not float above nothing.
class LoopBottomNavigation extends StatelessWidget {
  const LoopBottomNavigation({
    required this.current,
    required this.onSelected,
    super.key,
  });

  final LoopDestination current;
  final ValueChanged<LoopDestination> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final Map<LoopDestination, String> labels = <LoopDestination, String>{
      LoopDestination.home: l10n.navHome,
      LoopDestination.loops: l10n.navLoops,
      LoopDestination.create: l10n.navCreate,
      LoopDestination.focus: l10n.navFocus,
      LoopDestination.more: l10n.navMore,
    };

    // The bar is the one place the accessibility text size is capped. Five
    // labels in a fixed-height strip cannot grow to 200% without either
    // overflowing or swallowing the icons, and the page behind it — where the
    // content actually is — scales without limit.
    final TextScaler scaler =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);

    return Container(
      decoration: BoxDecoration(
        color: LoopColors.surface.withValues(alpha: 0.92),
        border: Border(top: BorderSide(color: context.accents.border)),
      ),
      child: SafeArea(
        top: false,
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: SizedBox(
            height: LoopSizes.bottomNavHeight * scaler.scale(1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                for (final LoopDestination destination
                    in LoopDestination.values)
                  Expanded(
                    child: destination == LoopDestination.create
                        ? _CreateButton(
                            label: labels[destination]!,
                            onPressed: () => onSelected(destination),
                          )
                        : _NavItem(
                            destination: destination,
                            label: labels[destination]!,
                            selected: destination == current,
                            onPressed: () => onSelected(destination),
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final LoopDestination destination;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final LoopAccents accents = context.accents;
    final Color color = selected ? accents.aiAlt : accents.textTertiary;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: Pressable(
          onPressed: onPressed,
          isButton: false,
          minSize: LoopSizes.minTouchTarget,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Home's icon is the loop itself. The other three are outline
              // glyphs, so the brand mark stays the one filled shape in the bar.
              if (destination == LoopDestination.home)
                LoopMark(
                  size: 22,
                  strokeWidth: 2.2,
                  colors: selected
                      ? LoopColors.loopGradient
                      : <Color>[color, color],
                )
              else
                Icon(_iconFor(destination), size: 21, color: color),
              const SizedBox(height: LoopSpacing.xxs + 2),
              // One line, shrinking rather than wrapping: "A continuación" is
              // not going to fit a fifth of a small phone at any font size, and
              // a clipped label is worse than a slightly smaller one.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: LoopMotion.scale(context, LoopMotion.fast),
                  style:
                      (context.text.labelSmall ?? const TextStyle()).copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(label, maxLines: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(LoopDestination destination) =>
      switch (destination) {
        LoopDestination.home => Icons.circle_outlined,
        LoopDestination.loops => Icons.format_list_bulleted_rounded,
        LoopDestination.create => Icons.add_rounded,
        LoopDestination.focus => Icons.gps_fixed_rounded,
        LoopDestination.more => Icons.more_horiz_rounded,
      };
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onPressed,
      semanticLabel: label,
      minSize: LoopSizes.minTouchTarget,
      pressedScale: 0.93,
      child: Center(
        child: Container(
          width: LoopSizes.createButton,
          height: LoopSizes.createButton,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[LoopColors.ai, LoopColors.aiAlt],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0x667C5CFF),
                blurRadius: 20,
                spreadRadius: -4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, size: 26, color: Colors.white),
        ),
      ),
    );
  }
}
