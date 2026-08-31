import 'package:flutter/material.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/loop_colors.dart';
import '../../../../core/theme/loop_dimens.dart';
import '../../../../core/theme/loop_motion.dart';
import '../../../../core/theme/loop_typography.dart';
import '../../../../core/widgets/loop_logo.dart';

/// The ring: how many loops are still open.
///
/// The arc is the share of the day's loops that are still open, so a good day
/// visibly empties the ring. It draws itself once on entry and then only when
/// the numbers change — a permanently spinning ring would be an animation the
/// device pays for on every frame the app is open, for decoration.
class ActiveLoopsIndicator extends StatefulWidget {
  const ActiveLoopsIndicator({
    required this.activeLoops,
    required this.ratio,
    this.size = LoopSizes.activeRing,
    super.key,
  });

  final int activeLoops;

  /// 0..1 of the ring to fill.
  final double ratio;

  final double size;

  @override
  State<ActiveLoopsIndicator> createState() => _ActiveLoopsIndicatorState();
}

class _ActiveLoopsIndicatorState extends State<ActiveLoopsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: LoopMotion.ring,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (LoopMotion.reduced(context)) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double target = widget.ratio.clamp(0.0, 1.0);

    // The ring is a fixed circle around two lines of type, so it has to grow
    // with the accessibility text size or the label overflows it — which it
    // did, by 18 pixels at 200%, before this. It grows to a point: past 140%
    // the circle would eat the greeting beside it, so the text stops scaling
    // where the shape stops growing.
    final TextScaler scaler = MediaQuery.textScalerOf(
      context,
    ).clamp(maxScaleFactor: 1.4);
    final double size = widget.size * scaler.scale(1);

    return Semantics(
      // The ring is a picture; this is what a screen reader says instead of
      // reading a bare "6" with no idea what it counts.
      label: l10n.activeLoopsSemantics(widget.activeLoops),
      // A container of its own: the number and the word inside are decoration
      // of the same fact, and read separately they are "6" followed by an
      // abbreviation.
      container: true,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, _) => LoopMark(
                size: size,
                strokeWidth: 5,
                progress: target *
                    Curves.easeOutCubic.transform(
                      _controller.value,
                    ),
                trackColor: LoopColors.surfaceRaised,
              ),
            ),
            MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${widget.activeLoops}',
                    style: LoopTypography.ringValue,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.loopsActive,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          height: 1.15,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
