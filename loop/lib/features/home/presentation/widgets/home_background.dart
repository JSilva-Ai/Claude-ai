import 'package:flutter/material.dart';

import '../../../../core/theme/loop_colors.dart';

/// The page ground.
///
/// Two gradients and no blur. A BackdropFilter here would have been the
/// obvious way to get the glow behind the header, and it is also the single
/// most expensive thing a phone GPU can be asked to do every frame — for an
/// effect a static radial gradient reproduces at no cost.
class HomeBackground extends StatelessWidget {
  const HomeBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            LoopColors.backgroundTop,
            LoopColors.backgroundBottom,
          ],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            // Off to the right, behind where the ring sits: the light in the
            // reference comes from the loop itself.
            center: const Alignment(0.85, -0.75),
            radius: 1.1,
            colors: <Color>[
              LoopColors.ai.withValues(alpha: 0.16),
              LoopColors.ai.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
