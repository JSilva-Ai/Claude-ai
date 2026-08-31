import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/loop_colors.dart';
import '../theme/loop_typography.dart';

/// The wordmark.
///
/// Letterforms come from the system face with wide tracking rather than from a
/// bundled logo font or an SVG: at 19pt the mark is type, and type rendered by
/// the platform is sharp at every pixel ratio without shipping an asset. When
/// there is a real brand face, `LoopTypography.wordmark` is the only edit.
class LoopWordmark extends StatelessWidget {
  const LoopWordmark({this.fontSize, super.key});

  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = fontSize == null
        ? LoopTypography.wordmark
        : LoopTypography.wordmark.copyWith(fontSize: fontSize);

    // The word is the product name; it is the same in all three languages, and
    // it is a graphic as much as a string, so it is not in the ARB as UI copy.
    return Semantics(
      header: true,
      label: 'LOOP',
      child: ExcludeSemantics(child: Text('LOOP', style: style)),
    );
  }
}

/// The loop itself: a ring with a gap, drawn on the brand sweep.
///
/// This is the product's one proprietary shape, so it is vector and it is
/// parametric. [progress] closes it; [completion] turns the closed ring into a
/// check. Both are here rather than in three separate widgets because the ring
/// in the header, the mark in the navigation bar and the future
/// loop-closed celebration are all meant to be recognisably the same object.
class LoopMark extends StatelessWidget {
  const LoopMark({
    this.size = 24,
    this.strokeWidth = 2,
    this.progress = 1,
    this.completion = 0,
    this.colors = LoopColors.loopGradient,
    this.trackColor,
    super.key,
  });

  final double size;
  final double strokeWidth;

  /// 0..1 of the ring that is drawn.
  final double progress;

  /// 0..1 of the check mark drawn inside a closed ring.
  final double completion;

  final List<Color> colors;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: LoopMarkPainter(
          strokeWidth: strokeWidth,
          progress: progress.clamp(0, 1),
          completion: completion.clamp(0, 1),
          colors: colors,
          trackColor: trackColor,
        ),
      ),
    );
  }
}

class LoopMarkPainter extends CustomPainter {
  const LoopMarkPainter({
    required this.strokeWidth,
    required this.progress,
    required this.completion,
    required this.colors,
    this.trackColor,
  });

  final double strokeWidth;
  final double progress;
  final double completion;
  final List<Color> colors;
  final Color? trackColor;

  /// Twelve o'clock. Progress that starts anywhere else reads as an arbitrary
  /// slice rather than as a loop being closed.
  static const double _start = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    final Rect ring = bounds.deflate(strokeWidth / 2);

    final Color? trackColor = this.trackColor;
    if (trackColor != null) {
      canvas.drawArc(
        ring,
        0,
        math.pi * 2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = trackColor,
      );
    }

    if (progress > 0) {
      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: math.pi * 2,
          // Rotated so the gradient starts where the arc starts, not at
          // three o'clock where SweepGradient begins by default.
          transform: const GradientRotation(_start),
          colors: colors,
        ).createShader(ring);
      canvas.drawArc(ring, _start, math.pi * 2 * progress, false, paint);
    }

    if (completion > 0) {
      final double s = size.shortestSide;
      final Path check = Path()
        ..moveTo(s * 0.30, s * 0.52)
        ..lineTo(s * 0.44, s * 0.66)
        ..lineTo(s * 0.72, s * 0.36);

      // Drawn progressively so the check can be animated as one continuous
      // stroke rather than appearing whole.
      final ui.PathMetric metric = check.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * completion),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = colors.last,
      );
    }
  }

  @override
  bool shouldRepaint(LoopMarkPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.completion != completion ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.trackColor != trackColor ||
      !listEquals(oldDelegate.colors, colors);
}
