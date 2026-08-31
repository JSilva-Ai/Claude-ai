import 'package:flutter/widgets.dart';

import '../theme/loop_motion.dart';

/// Fades and lifts a widget in, [index] steps behind the one before it.
///
/// The Home's entrance is a stagger and not a single fade, because a screen
/// whose parts arrive in reading order tells the eye where to start. It is
/// intentionally cheap: one opacity and one transform per child, no clipping,
/// no blur, and the whole thing is over in well under a second.
///
/// With "reduce motion" on, the child simply appears — the final state is
/// identical either way, which is the property that makes this safe to wrap
/// around anything.
class Entrance extends StatefulWidget {
  const Entrance({
    required this.child,
    this.index = 0,
    this.duration = LoopMotion.medium,
    this.offset = LoopMotion.enterOffset,
    super.key,
  });

  final Widget child;
  final int index;
  final Duration duration;
  final double offset;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _controller,
    curve: LoopMotion.enter,
  );

  @override
  void initState() {
    super.initState();
    // Scheduled rather than started immediately so the delay is real time
    // after the first frame, not time spent building the rest of the tree.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (LoopMotion.reduced(context)) {
        _controller.value = 1;
        return;
      }
      Future<void>.delayed(LoopMotion.stagger * widget.index, () {
        if (mounted) _controller.forward();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      // Built once and reused: the child does not depend on the animation, so
      // rebuilding it every frame would be pure waste.
      child: widget.child,
      builder: (BuildContext context, Widget? child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _t.value) * widget.offset),
          child: child,
        ),
      ),
    );
  }
}
