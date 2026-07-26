import 'dart:math';
import 'package:flutter/material.dart';

class SoundWaveBackground extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const SoundWaveBackground({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xff121212),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SoundWavePainter(),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SoundWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final colors = [
      const Color(0xff7B2FBE),
      const Color(0xffA855F7),
      const Color(0xffC084FC),
      const Color(0xff5B21B6),
      const Color(0xffDDD6FE),
    ];

    for (int i = 0; i < 12; i++) {
      final y = size.height * 0.1 + (size.height * 0.75 / 12) * i;
      final opacity = 0.08 + random.nextDouble() * 0.12;
      final strokeWidth = 1.0 + random.nextDouble() * 2.0;

      paint
        ..color = colors[i % colors.length].withOpacity(opacity)
        ..strokeWidth = strokeWidth;

      final path = Path();
      path.moveTo(-20, y);

      double x = -20;
      while (x < size.width + 20) {
        final segmentWidth = 20.0 + random.nextDouble() * 40.0;
        final amplitude = 10.0 + random.nextDouble() * 30.0;
        final direction = random.nextBool() ? 1.0 : -1.0;

        path.quadraticBezierTo(
          x + segmentWidth * 0.5,
          y + amplitude * direction,
          x + segmentWidth,
          y,
        );
        x += segmentWidth;
      }

      canvas.drawPath(path, paint);
    }

    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 5; i++) {
      final cx = size.width * 0.3 + random.nextDouble() * size.width * 0.4;
      final cy = size.height * 0.2 + random.nextDouble() * size.height * 0.6;
      final radius = 30.0 + random.nextDouble() * 80.0;

      circlePaint.color = colors[i % colors.length].withOpacity(0.05 + random.nextDouble() * 0.08);
      canvas.drawCircle(Offset(cx, cy), radius, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
