import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class AiOrb extends StatefulWidget {
  final double size;
  final bool isActive;
  final bool isSpeaking;

  const AiOrb({
    super.key,
    this.size = 200.0,
    this.isActive = true,
    this.isSpeaking = false,
  });

  @override
  State<AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<AiOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AiOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(widget.isSpeaking ? 0.35 : 0.15),
                blurRadius: widget.isSpeaking ? 50 : 30,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: Colors.purple.withOpacity(widget.isSpeaking ? 0.35 : 0.15),
                blurRadius: widget.isSpeaking ? 50 : 30,
                spreadRadius: -5,
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.1, sigmaY: 0.1),
              child: CustomPaint(
                painter: OrbPainter(
                  animationValue: _controller.value,
                  isSpeaking: widget.isSpeaking,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class OrbPainter extends CustomPainter {
  final double animationValue;
  final bool isSpeaking;

  OrbPainter({required this.animationValue, required this.isSpeaking});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Clear background
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.4);
    canvas.drawCircle(center, radius, bgPaint);

    final angle = animationValue * 2 * math.pi;
    final pulse = isSpeaking ? (1.0 + 0.12 * math.sin(angle * 4)) : (1.0 + 0.04 * math.sin(angle * 2));

    // Base Blue Glowing Gradient
    final blueCenter = Offset(
      center.dx + radius * 0.25 * math.cos(angle),
      center.dy + radius * 0.25 * math.sin(angle),
    );
    final bluePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.blue.withOpacity(0.8),
          Colors.blue.withOpacity(0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: blueCenter, radius: radius * 1.1 * pulse));
    canvas.drawCircle(center, radius, bluePaint);

    // Overlay Purple/Magenta Gradient
    final purpleCenter = Offset(
      center.dx + radius * 0.3 * math.cos(angle + math.pi),
      center.dy + radius * 0.3 * math.sin(angle + math.pi),
    );
    final purplePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFD03BFF).withOpacity(0.75),
          const Color(0xFF8A2BE2).withOpacity(0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: purpleCenter, radius: radius * pulse));
    canvas.drawCircle(center, radius, purplePaint);

    // Overlay Vibrant Peach/White Highlight for 3D metallic feel
    final peachCenter = Offset(
      center.dx + radius * 0.35 * math.cos(angle * 1.5 + math.pi / 2),
      center.dy + radius * 0.35 * math.sin(angle * 1.5 + math.pi / 2),
    );
    final peachPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF9EAA).withOpacity(0.85),
          const Color(0xFF6CFCEF).withOpacity(0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: peachCenter, radius: radius * 0.8 * pulse));
    canvas.drawCircle(center, radius, peachPaint);

    // Outer Edge Glass Highlight (Sleek curve highlight)
    final glassHighlightShader = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Colors.white.withOpacity(0.35),
        Colors.white.withOpacity(0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, Paint()..color = Colors.white.withOpacity(0.04));
    
    // Draw reflection arc
    final highlightPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius - 4),
        -math.pi / 3,
        math.pi / 1.5,
      );
    canvas.drawPath(
      highlightPath,
      Paint()
        ..shader = glassHighlightShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant OrbPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.isSpeaking != isSpeaking;
  }
}
