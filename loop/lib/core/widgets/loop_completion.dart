import 'package:flutter/widgets.dart';

import '../theme/loop_colors.dart';
import '../theme/loop_dimens.dart';
import '../theme/loop_motion.dart';
import '../theme/loop_typography.dart';
import 'loop_logo.dart';

/// The product's one signature moment: a loop closing.
///
/// The circle draws itself shut, the check strokes through it, and the word
/// arrives last —
///
///     LOOP  →  the ring closes  →  CHECK  →  DONE
///
/// It is 720 ms end to end and it is deliberately not a flourish: this will
/// eventually play every time a person resolves something, several times a
/// day, and an animation you have to sit through twice is an animation you
/// come to resent.
///
/// Cheap by construction. One [AnimationController] drives everything; the
/// mark is the same [LoopMark] painter the rest of the app uses, given two
/// numbers; the word is an opacity and a six-pixel translation. No shadow is
/// animated, nothing is clipped, and no filter runs — so the whole thing is
/// one repaint of a small box, which is what keeps it at frame rate on the
/// phones this has to feel good on.
///
/// With "reduce motion" on it lands on its final state in one frame, which is
/// the same picture the animation ends at.
class LoopCompletion extends StatefulWidget {
  const LoopCompletion({
    this.size = 72,
    this.strokeWidth = 5,
    this.label,
    this.autoPlay = true,
    this.onCompleted,
    super.key,
  });

  final double size;
  final double strokeWidth;

  /// The word under the mark — "DONE" in the user's language. Omit it where
  /// the surrounding copy already says so.
  final String? label;

  /// False holds the widget at its start, for a caller that wants to trigger
  /// the moment itself later.
  final bool autoPlay;

  /// Fires once the check has finished. The seam for whatever comes after a
  /// loop closes — dismissing a card, advancing a list.
  final VoidCallback? onCompleted;

  @override
  State<LoopCompletion> createState() => _LoopCompletionState();
}

class _LoopCompletionState extends State<LoopCompletion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: LoopMotion.completion,
  );

  // The ring and the check overlap by ten percent of the timeline. Run them
  // end to end and the pause between them reads as a stutter; overlap them
  // and it reads as one gesture.
  late final Animation<double> _ring = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.55, curve: LoopMotion.enter),
  );
  late final Animation<double> _check = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 0.85, curve: LoopMotion.enter),
  );
  late final Animation<double> _word = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.68, 1, curve: LoopMotion.enter),
  );

  /// A single settle: the mark swells by four percent as the check lands and
  /// comes back. Any more than that and it bounces like a toy.
  late final Animation<double> _settle = TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(tween: ConstantTween<double>(1), weight: 45),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1, end: 1.04)
            .chain(CurveTween(curve: LoopMotion.enter)),
        weight: 25,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.04, end: 1)
            .chain(CurveTween(curve: LoopMotion.press)),
        weight: 30,
      ),
    ],
  ).animate(_controller);

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) widget.onCompleted?.call();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.autoPlay) return;
      if (LoopMotion.reduced(context)) {
        // Jumping the controller to its end reports `completed` on its own.
        // Calling the callback here as well fired it twice — which, for the
        // thing this will eventually drive (dismissing a resolved loop), is
        // the difference between one card leaving and two.
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
    final String? label = widget.label;

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Transform.scale(
            scale: _settle.value,
            child: LoopMark(
              size: widget.size,
              strokeWidth: widget.strokeWidth,
              progress: _ring.value,
              completion: _check.value,
              trackColor: LoopColors.surfaceRaised,
            ),
          ),
          if (label != null) ...<Widget>[
            SizedBox(height: LoopSpacing.sm * _word.value),
            Opacity(
              opacity: _word.value,
              child: Transform.translate(
                offset: Offset(0, (1 - _word.value) * 6),
                child: Text(
                  label,
                  style: LoopTypography.textTheme.labelMedium?.copyWith(
                    color: LoopColors.done,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
