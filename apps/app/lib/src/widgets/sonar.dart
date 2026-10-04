import 'dart:math';

import 'package:flutter/material.dart';

import '../context.dart';

/// Rings around a signal, with a ping travelling outwards. Still when the
/// platform asks for fewer animations.
class Sonar extends StatefulWidget {
  const Sonar({super.key, this.size = 240});

  final double size;

  @override
  State<Sonar> createState() => _SonarState();
}

class _SonarState extends State<Sonar> with SingleTickerProviderStateMixin {
  late final _ping = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ping.value = 0;
      _ping.stop();
    } else if (!_ping.isAnimating) {
      _ping.repeat();
    }
  }

  @override
  void dispose() {
    _ping.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _ping,
        builder: (context, _) => CustomPaint(
          painter: _SonarPainter(
            ping: _ping.value,
            ring: palette.line,
            signal: palette.accent,
          ),
        ),
      ),
    );
  }
}

class _SonarPainter extends CustomPainter {
  _SonarPainter({required this.ping, required this.ring, required this.signal});

  final double ping;
  final Color ring;
  final Color signal;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final rings = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = ring;
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4 - 1, rings);
    }
    canvas.drawLine(
      center.translate(-radius, 0),
      center.translate(radius, 0),
      rings,
    );
    canvas.drawLine(
      center.translate(0, -radius),
      center.translate(0, radius),
      rings,
    );
    if (ping > 0) {
      canvas.drawCircle(
        center,
        radius * Curves.easeOut.transform(ping),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = signal.withValues(alpha: 1 - ping),
      );
    }
    canvas.drawCircle(center, radius * 0.06, Paint()..color = signal);
    final blip = center + Offset.fromDirection(-pi / 3.4, radius * 0.58);
    canvas.drawCircle(
      blip,
      radius * 0.035,
      Paint()..color = signal.withValues(alpha: 0.35 + 0.65 * (1 - ping)),
    );
  }

  @override
  bool shouldRepaint(_SonarPainter old) =>
      old.ping != ping || old.ring != ring || old.signal != signal;
}
