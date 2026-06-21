import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
//  AiOrb  –  Three states:
//    isActive=false              → idle dim pulse
//    isActive=true  isSpeaking=false  → active rotation
//    isActive=true  isSpeaking=true   → STREAMING (full VFX)
// ─────────────────────────────────────────────────────────────
class AiOrb extends StatefulWidget {
  final double size;
  final bool isActive;
  final bool isSpeaking; // used as "isStreaming" in chat context

  const AiOrb({
    super.key,
    this.size = 200.0,
    this.isActive = true,
    this.isSpeaking = false,
  });

  @override
  State<AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<AiOrb> with TickerProviderStateMixin {
  // Primary rotation controller
  late AnimationController _rotCtrl;
  // Fast pulse controller (for streaming ripples)
  late AnimationController _pulseCtrl;
  // Tendril / data stream controller
  late AnimationController _tendrilCtrl;
  // Outer plasma ring controller
  late AnimationController _ringCtrl;

  @override
  void initState() {
    super.initState();

    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _tendrilCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _applyState();
  }

  void _applyState() {
    if (widget.isActive) {
      _rotCtrl.repeat();
      _tendrilCtrl.repeat();
      if (widget.isSpeaking) {
        _pulseCtrl.repeat(reverse: true);
        _ringCtrl.repeat();
      } else {
        _pulseCtrl.stop();
        _ringCtrl.stop();
      }
    } else {
      _rotCtrl.repeat(); // still slowly rotate idle
      _pulseCtrl.stop();
      _tendrilCtrl.stop();
      _ringCtrl.stop();
    }
  }

  @override
  void didUpdateWidget(covariant AiOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive ||
        oldWidget.isSpeaking != widget.isSpeaking) {
      _applyState();
    }
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    _pulseCtrl.dispose();
    _tendrilCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_rotCtrl, _pulseCtrl, _tendrilCtrl, _ringCtrl]),
      builder: (context, _) {
        final isStreaming = widget.isActive && widget.isSpeaking;
        final glowIntensity = isStreaming
            ? (0.45 + 0.25 * _pulseCtrl.value)
            : widget.isActive
                ? 0.25
                : 0.08;

        return Stack(
          alignment: Alignment.center,
          children: [
            // ── Outer plasma rings (streaming only) ──────────────
            if (isStreaming) ...[
              _PlasmaRing(
                size: widget.size * 1.45,
                rotValue: _ringCtrl.value,
                color: const Color(0xFF06B6D4),
                phaseOffset: 0,
                opacity: 0.35 + 0.2 * _pulseCtrl.value,
              ),
              _PlasmaRing(
                size: widget.size * 1.28,
                rotValue: _ringCtrl.value,
                color: const Color(0xFF8B5CF6),
                phaseOffset: math.pi / 3,
                opacity: 0.30 + 0.15 * _pulseCtrl.value,
              ),
              _PlasmaRing(
                size: widget.size * 1.65,
                rotValue: _ringCtrl.value,
                color: const Color(0xFFD946EF),
                phaseOffset: math.pi * 2 / 3,
                opacity: 0.20 + 0.10 * _pulseCtrl.value,
              ),
            ],

            // ── Pulse ripple wave (streaming) ─────────────────────
            if (isStreaming)
              _RippleWave(
                size: widget.size,
                pulseValue: _pulseCtrl.value,
              ),

            // ── Main orb body ─────────────────────────────────────
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(glowIntensity),
                    blurRadius: isStreaming ? 60 : 30,
                    spreadRadius: isStreaming ? 12 : 6,
                  ),
                  BoxShadow(
                    color: const Color(0xFF06B6D4)
                        .withOpacity(glowIntensity * 0.6),
                    blurRadius: isStreaming ? 40 : 15,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.2, sigmaY: 0.2),
                  child: CustomPaint(
                    painter: _OrbCorePainter(
                      rotValue: _rotCtrl.value,
                      pulseValue: _pulseCtrl.value,
                      tendrilValue: _tendrilCtrl.value,
                      isStreaming: isStreaming,
                      isActive: widget.isActive,
                    ),
                  ),
                ),
              ),
            ),

            // ── Data particle streams (streaming only) ────────────
            if (isStreaming)
              _DataStreams(
                size: widget.size,
                tendrilValue: _tendrilCtrl.value,
                pulseValue: _pulseCtrl.value,
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Plasma ring helper widget
// ─────────────────────────────────────────────────────────────
class _PlasmaRing extends StatelessWidget {
  final double size;
  final double rotValue;
  final Color color;
  final double phaseOffset;
  final double opacity;

  const _PlasmaRing({
    required this.size,
    required this.rotValue,
    required this.color,
    required this.phaseOffset,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PlasmaRingPainter(
          rotValue: rotValue,
          color: color,
          phaseOffset: phaseOffset,
          opacity: opacity,
        ),
      ),
    );
  }
}

class _PlasmaRingPainter extends CustomPainter {
  final double rotValue;
  final Color color;
  final double phaseOffset;
  final double opacity;

  _PlasmaRingPainter({
    required this.rotValue,
    required this.color,
    required this.phaseOffset,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final angle = rotValue * 2 * math.pi + phaseOffset;

    // Draw a dashed ellipse ring that wobbles
    const dashCount = 40;
    for (int i = 0; i < dashCount; i++) {
      final t = i / dashCount;
      final theta = t * 2 * math.pi + angle;
      final wobble = 1.0 + 0.06 * math.sin(theta * 5 + angle * 3);
      final rx = radius * wobble;
      final ry = radius * (2 - wobble);
      final px = center.dx + rx * math.cos(theta);
      final py = center.dy + ry * math.sin(theta);

      final brightness = (0.4 + 0.6 * math.sin(t * math.pi * 2 + angle)).clamp(0.0, 1.0);
      final dotOpacity = opacity * brightness;

      canvas.drawCircle(
        Offset(px, py),
        2.5,
        Paint()
          ..color = color.withOpacity(dotOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
    }
  }

  @override
  bool shouldRepaint(_PlasmaRingPainter old) => true;
}

// ─────────────────────────────────────────────────────────────
//  Ripple wave (expands outward from orb during streaming)
// ─────────────────────────────────────────────────────────────
class _RippleWave extends StatelessWidget {
  final double size;
  final double pulseValue;

  const _RippleWave({required this.size, required this.pulseValue});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 2,
      height: size * 2,
      child: CustomPaint(
        painter: _RipplePainter(pulseValue: pulseValue, orbSize: size),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double pulseValue;
  final double orbSize;

  _RipplePainter({required this.pulseValue, required this.orbSize});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = orbSize / 2;

    // Draw 3 expanding ripple rings
    for (int i = 0; i < 3; i++) {
      final phase = (pulseValue + i / 3) % 1.0;
      final currentRadius = baseRadius + phase * orbSize * 0.5;
      final opacity = (1.0 - phase) * 0.3;

      canvas.drawCircle(
        center,
        currentRadius,
        Paint()
          ..color = const Color(0xFF8B5CF6).withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) => true;
}

// ─────────────────────────────────────────────────────────────
//  Data Particle Streams (orbiting dots during streaming)
// ─────────────────────────────────────────────────────────────
class _DataStreams extends StatelessWidget {
  final double size;
  final double tendrilValue;
  final double pulseValue;

  const _DataStreams(
      {required this.size,
      required this.tendrilValue,
      required this.pulseValue});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.8,
      height: size * 1.8,
      child: CustomPaint(
        painter: _DataStreamsPainter(
          tendrilValue: tendrilValue,
          pulseValue: pulseValue,
          orbRadius: size / 2,
        ),
      ),
    );
  }
}

class _DataStreamsPainter extends CustomPainter {
  final double tendrilValue;
  final double pulseValue;
  final double orbRadius;

  _DataStreamsPainter({
    required this.tendrilValue,
    required this.pulseValue,
    required this.orbRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final angle = tendrilValue * 2 * math.pi;
    const streamCount = 6;

    for (int s = 0; s < streamCount; s++) {
      final baseAngle = angle + (s * 2 * math.pi / streamCount);
      const particlesPerStream = 8;

      for (int p = 0; p < particlesPerStream; p++) {
        // Each particle moves outward along the stream
        final t = ((tendrilValue * 2 + p / particlesPerStream) % 1.0);
        final dist = orbRadius * 0.9 + t * orbRadius * 0.7;

        // Slight curve per stream
        final curveAngle =
            baseAngle + 0.3 * math.sin(t * math.pi + s);

        final px = center.dx + dist * math.cos(curveAngle);
        final py = center.dy + dist * math.sin(curveAngle);

        final opacity = (1.0 - t) * 0.7;
        final dotSize = (1.0 - t) * 3.0 + 0.5;

        final colors = [
          const Color(0xFF8B5CF6),
          const Color(0xFF06B6D4),
          const Color(0xFFD946EF),
          const Color(0xFF10A37F),
          const Color(0xFFE879F9),
          const Color(0xFF38BDF8),
        ];

        canvas.drawCircle(
          Offset(px, py),
          dotSize,
          Paint()
            ..color = colors[s % colors.length].withOpacity(opacity)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, dotSize),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DataStreamsPainter old) => true;
}

// ─────────────────────────────────────────────────────────────
//  Core Orb Painter (the inner liquid plasma body)
// ─────────────────────────────────────────────────────────────
class _OrbCorePainter extends CustomPainter {
  final double rotValue;
  final double pulseValue;
  final double tendrilValue;
  final bool isStreaming;
  final bool isActive;

  _OrbCorePainter({
    required this.rotValue,
    required this.pulseValue,
    required this.tendrilValue,
    required this.isStreaming,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final angle = rotValue * 2 * math.pi;

    // ── Background ───────────────────────────────────────────
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = Colors.black.withOpacity(isStreaming ? 0.3 : 0.5),
    );

    // ── Pulse scale factor ───────────────────────────────────
    final pulse = isStreaming
        ? (1.0 + 0.14 * math.sin(pulseValue * math.pi))
        : isActive
            ? (1.0 + 0.04 * math.sin(angle * 2))
            : (1.0 + 0.015 * math.sin(angle));

    // ── Deep core glow ───────────────────────────────────────
    _drawRadialBlob(
      canvas,
      center: Offset(
        center.dx + radius * 0.1 * math.cos(angle),
        center.dy + radius * 0.1 * math.sin(angle),
      ),
      clipRect: Rect.fromCircle(center: center, radius: radius),
      blobRadius: radius * 1.1 * pulse,
      colors: isStreaming
          ? [
              const Color(0xFF4C1D95).withOpacity(0.9),
              const Color(0xFF1E1B4B).withOpacity(0.6),
              Colors.transparent,
            ]
          : [
              const Color(0xFF312E81).withOpacity(0.8),
              Colors.transparent,
            ],
    );

    // ── Cyan blob (rotates opposite) ─────────────────────────
    _drawRadialBlob(
      canvas,
      center: Offset(
        center.dx + radius * 0.28 * math.cos(-angle * 1.3 + 0.5),
        center.dy + radius * 0.28 * math.sin(-angle * 1.3 + 0.5),
      ),
      clipRect: Rect.fromCircle(center: center, radius: radius),
      blobRadius: radius * 0.75 * pulse,
      colors: [
        const Color(0xFF06B6D4).withOpacity(isStreaming ? 0.75 : 0.45),
        const Color(0xFF0891B2).withOpacity(0.2),
        Colors.transparent,
      ],
    );

    // ── Purple blob ───────────────────────────────────────────
    _drawRadialBlob(
      canvas,
      center: Offset(
        center.dx + radius * 0.32 * math.cos(angle + math.pi),
        center.dy + radius * 0.32 * math.sin(angle + math.pi),
      ),
      clipRect: Rect.fromCircle(center: center, radius: radius),
      blobRadius: radius * 0.9 * pulse,
      colors: [
        const Color(0xFFD946EF).withOpacity(isStreaming ? 0.7 : 0.4),
        const Color(0xFF8B5CF6).withOpacity(0.3),
        Colors.transparent,
      ],
    );

    // ── Magenta/white hot core (streaming only) ───────────────
    if (isStreaming) {
      final hotIntensity = 0.6 + 0.4 * math.sin(pulseValue * math.pi);
      _drawRadialBlob(
        canvas,
        center: center,
        clipRect: Rect.fromCircle(center: center, radius: radius),
        blobRadius: radius * 0.35 * pulse,
        colors: [
          Colors.white.withOpacity(hotIntensity * 0.7),
          const Color(0xFFE879F9).withOpacity(hotIntensity * 0.5),
          Colors.transparent,
        ],
      );
    }

    // ── Peach/teal highlight shimmer ──────────────────────────
    _drawRadialBlob(
      canvas,
      center: Offset(
        center.dx + radius * 0.38 * math.cos(angle * 1.5 + math.pi / 2),
        center.dy + radius * 0.38 * math.sin(angle * 1.5 + math.pi / 2),
      ),
      clipRect: Rect.fromCircle(center: center, radius: radius),
      blobRadius: radius * 0.65 * pulse,
      colors: [
        const Color(0xFFFF9EAA).withOpacity(0.6),
        const Color(0xFF6CFCEF).withOpacity(0.15),
        Colors.transparent,
      ],
    );

    // ── Glass specular highlight ──────────────────────────────
    final glassShader = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Colors.white.withOpacity(isStreaming ? 0.55 : 0.30),
        Colors.white.withOpacity(0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.35, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final highlightPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius - 3),
        -math.pi / 3,
        math.pi / 1.5,
      );
    canvas.drawPath(
      highlightPath,
      Paint()
        ..shader = glassShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = isStreaming ? 4 : 2.5,
    );

    // ── Inner hex data grid (streaming only) ──────────────────
    if (isStreaming) {
      _drawDataGrid(canvas, center, radius, angle);
    }
  }

  void _drawRadialBlob(
    Canvas canvas, {
    required Offset center,
    required Rect clipRect,
    required double blobRadius,
    required List<Color> colors,
  }) {
    canvas.save();
    canvas.clipRect(clipRect);
    canvas.drawCircle(
      center,
      blobRadius,
      Paint()
        ..shader = RadialGradient(
          colors: colors,
          stops: colors.length == 2
              ? const [0.0, 1.0]
              : const [0.0, 0.55, 1.0],
        ).createShader(
            Rect.fromCircle(center: center, radius: blobRadius)),
    );
    canvas.restore();
  }

  void _drawDataGrid(
      Canvas canvas, Offset center, double radius, double angle) {
    // Draw subtle rotating hex lines inside the orb
    const lineCount = 6;
    for (int i = 0; i < lineCount; i++) {
      final lineAngle = angle * 2 + (i * math.pi / lineCount);
      final x1 = center.dx + radius * 0.55 * math.cos(lineAngle);
      final y1 = center.dy + radius * 0.55 * math.sin(lineAngle);
      final x2 = center.dx + radius * 0.85 * math.cos(lineAngle + math.pi / lineCount);
      final y2 = center.dy + radius * 0.85 * math.sin(lineAngle + math.pi / lineCount);

      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        Paint()
          ..color = Colors.white.withOpacity(0.06)
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbCorePainter old) => true;
}
