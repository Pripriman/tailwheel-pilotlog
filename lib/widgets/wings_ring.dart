import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/log_palette.dart';

class WingsRing extends StatelessWidget {
  final double size;
  final double progress;
  final Color color;
  final Color track;
  final double stroke;
  final Widget? child;

  const WingsRing({
    super.key,
    required this.size,
    required this.progress,
    this.color = LogPalette.navy,
    this.track = LogPalette.paperDeep,
    this.stroke = 11,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WingsRingPainter(
          progress: progress.clamp(0, 1).toDouble(),
          color: color,
          track: track,
          stroke: stroke,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _WingsRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color track;
  final double stroke;

  _WingsRingPainter({
    required this.progress,
    required this.color,
    required this.track,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);

    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = LogPalette.rule;
    for (var i = 0; i < 12; i++) {
      final a = start + i * (2 * math.pi / 12);
      final outer = center + Offset(math.cos(a), math.sin(a)) * (radius + stroke / 2);
      final inner = center + Offset(math.cos(a), math.sin(a)) * (radius + stroke / 2 - 3);
      canvas.drawLine(inner, outer, tickPaint);
    }

    if (progress <= 0) return;

    final sweep = 2 * math.pi * progress;
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + 2 * math.pi,
        colors: const [LogPalette.navy, LogPalette.gold, LogPalette.navy],
      ).createShader(rect);
    canvas.drawArc(rect, start, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _WingsRingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.track != track ||
      old.stroke != stroke;
}
